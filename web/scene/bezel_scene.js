// Entry point. Exposes window.BezelScene so Flutter (Dart JS interop) can
// mount a 3D view into a platform-view element and drive it.
import * as THREE from './vendor/three_bundle.js';
import { createStage } from './stage.js';
import { loadDevice, disposeDevice } from './device.js';
import { applyFinish } from './finish.js';
import { createScreenMedia } from './screen_media.js';
import { createOrbit } from './orbit.js';
import { createBackdrop } from './backdrop.js';
import { applyLight } from './lighting.js';
import { createZoom } from './zoom.js';
import { createPlayer } from './player.js';
import { exportClip } from './export/exporter.js';

function mount(host, onPose, onTime) {
  const stage = createStage(host);
  // pivot: layout position + rotation. zoomGroup (inside it): the user's zoom.
  const pivot = new THREE.Group();
  const zoomGroup = new THREE.Group();
  pivot.add(zoomGroup);
  stage.scene.add(pivot);
  const report = () => onPose?.(orbit.pose.turn, orbit.pose.tilt, zoom.value);
  const zoom = createZoom(stage, zoomGroup, () => report());
  const orbit = createOrbit(stage, (turn, tilt) => {
    pivot.rotation.set(THREE.MathUtils.degToRad(tilt), THREE.MathUtils.degToRad(turn), 0, 'YXZ');
    report();
  }, zoom.pinching);
  const applyPose = (p) => {
    zoom.set(p.zoom);
    orbit.setPose(p.turn, p.tilt);
  };
  const player = createPlayer(stage, applyPose, (time, playing) => onTime?.(time, playing));
  let timelineData = { keyframes: [], loop: true };
  let exportCancelled = false;
  const backdrop = createBackdrop(stage, pivot);
  stage.resize();
  let device = null;

  // A click (not a drag) on the phone's screen: Flutter offers the file picker.
  let onScreenTap = null;
  const ray = new THREE.Raycaster();
  const el = stage.renderer.domElement;
  let down = null;
  el.addEventListener('pointerdown', (e) => { down = { x: e.clientX, y: e.clientY }; });
  el.addEventListener('pointerup', (e) => {
    const d = down;
    down = null;
    if (!d || !device || !onScreenTap || stage.locked) return;
    if (Math.hypot(e.clientX - d.x, e.clientY - d.y) > 5) return;
    const box = el.getBoundingClientRect();
    const p = new THREE.Vector2(
      ((e.clientX - box.left) / box.width) * 2 - 1,
      -((e.clientY - box.top) / box.height) * 2 + 1);
    ray.setFromCamera(p, stage.camera);
    if (ray.intersectObjects(device.parts.screen, true).length) onScreenTap();
  });
  let media = null;

  return {
    /** Resolves with the device profile as a JSON string. */
    async loadDevice(baseUrl, finishId) {
      const next = await loadDevice(baseUrl);
      if (device) { zoomGroup.remove(device.root); media.dispose(); disposeDevice(device); }
      device = next;
      zoomGroup.add(device.root);
      media = createScreenMedia(stage, device);
      applyFinish(device, finishId);
      stage.invalidate();
      return JSON.stringify(device.profile);
    },
    setFinish(finishId) { if (device) { applyFinish(device, finishId); stage.invalidate(); } },
    setScreenImage(url) { return media?.setImage(url); },
    setScreenVideo(url) { return media?.setVideo(url); },
    setPose(turn, tilt, zoomLevel) {
      if (zoomLevel != null) zoom.set(zoomLevel);
      orbit.setPose(turn, tilt);
    },
    /** JSON: {style: 'solid'|'spotlight'|'image', color: '#rrggbb', imageUrl?}. */
    setBackground(json) { return backdrop.setBackground(JSON.parse(json)); },
    /**
     * JSON: {enabled, headline, subtitle, side: 'left'|'above'|'right', font,
     * align, size, subSize, dx, dy, subDx, subDy, hidden}. See caption.js.
     */
    setCaption(json) { backdrop.setCaption(JSON.parse(json)); },
    /** fn(): the user clicked the phone's screen. */
    onScreenTap(fn) { onScreenTap = fn; },
    /** fn(json | null): {head, sub} bounds {x, y, w, h} as fractions of the frame. */
    onCaptionBounds(fn) { backdrop.onCaptionBounds(fn); },
    /** JSON: {angle: degrees, intensity: 0..1, reflections: bool}. */
    setLight(json) { applyLight(stage, JSON.parse(json)); },
    /** JSON: {loop, keyframes: [{time, turn, tilt, zoom, easing: {kind, bounce}}]}. */
    setTimeline(json) { timelineData = JSON.parse(json); player.setTimeline(timelineData); },
    setLoopRange(start, end) { player.setLoopRange(start, end); },
    play() { player.play(); },
    pause() { player.pause(); },
    seek(seconds) { player.seek(seconds); },
    /**
     * Renders and downloads the clip. JSON: {format, width, height, fps, name}.
     * onProgress(frame, total). Resolves with JSON {filename, bytes}, or 'null' if cancelled.
     */
    async exportClip(json, onProgress) {
      exportCancelled = false;
      const ctx = {
        stage, applyPose, media: () => media,
        timeline: () => timelineData,
        pause: () => player.pause(),
      };
      const result = await exportClip(ctx, JSON.parse(json), (f, n) => onProgress?.(f, n), () => exportCancelled);
      return JSON.stringify(result);
    },
    cancelExport() { exportCancelled = true; },
    /** A small JPEG of the current frame as a data URL (project thumbnails). */
    snapshot(width) {
      if (stage.locked) return null;
      stage.renderer.render(stage.scene, stage.camera);
      const src = stage.renderer.domElement;
      if (!src.width || !src.height) return null;
      const c = document.createElement('canvas');
      c.width = width;
      c.height = Math.round((width * src.height) / src.width);
      c.getContext('2d').drawImage(src, 0, 0, c.width, c.height);
      return c.toDataURL('image/jpeg', 0.8);
    },
    dispose() {
      orbit.dispose();
      zoom.dispose();
      media?.dispose();
      backdrop.dispose();
      if (device) disposeDevice(device);
      stage.dispose();
    },
  };
}

window.BezelScene = { mount };
window.dispatchEvent(new Event('bezel-scene-ready'));
