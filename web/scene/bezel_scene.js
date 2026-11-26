// Entry point. Exposes window.BezelScene so Flutter (Dart JS interop) can
// mount a 3D view into a platform-view element and drive it.
import * as THREE from './vendor/three_bundle.js';
import { createStage } from './stage.js';
import { loadDevice, disposeDevice } from './device.js';
import { applyFinish } from './finish.js';
import { createAssets } from './assets.js';
import { createScreenTrack } from './screen_track.js';
import { createAudioTrack } from './audio_track.js';
import { pickFile } from './pick_file.js';
import { createOrbit } from './orbit.js';
import { createBackdrop } from './backdrop.js';
import { applyLight } from './lighting.js';
import { createZoom } from './zoom.js';
import { createPlayer } from './player.js';
import { exportClip } from './export/exporter.js';

function mount(host, onPose, onTime, onPosition) {
  const stage = createStage(host);
  // placement is the user's artboard position; pivot carries rotation; zoomGroup
  // carries zoom. Keeping these transforms separate prevents captions from
  // changing the user's chosen device position.
  const placement = new THREE.Group();
  const pivot = new THREE.Group();
  const zoomGroup = new THREE.Group();
  stage.scene.add(placement);
  placement.add(pivot);
  pivot.add(zoomGroup);
  let device = null;
  const report = () => onPose?.(orbit.pose.turn, orbit.pose.tilt, zoom.value);
  const reportPosition = (x, y) => onPosition?.(x, y);
  let orbit = null;
  const zoom = createZoom(stage, zoomGroup, () => {
    report();
    orbit?.refresh();
  });
  orbit = createOrbit(stage, (turn, tilt) => {
    pivot.rotation.set(THREE.MathUtils.degToRad(tilt), THREE.MathUtils.degToRad(turn), 0, 'YXZ');
    report();
  }, zoom.pinching, placement, () => device?.root, reportPosition);
  const applyPose = (p) => {
    zoom.set(p.zoom);
    orbit.setPose(p.turn, p.tilt);
  };
  let backdrop = null;
  // Everything timed follows the player: captions, the screen, and sound.
  const assets = createAssets();
  const audio = createAudioTrack(assets);
  let tracks = { captions: [], screens: [], audio: [] };
  let screen = null; // created per device (it owns the screen material)
  const clipsEnd = () => Math.max(0, ...[...tracks.captions, ...tracks.screens, ...tracks.audio].map((c) => c.end));
  const player = createPlayer(stage, applyPose, (time, playing) => {
    // At the very end, show the last frame rather than what comes after it.
    const shown = Math.min(time, Math.max(0, player.duration - 1e-3));
    backdrop?.setTime(shown);
    screen?.update(shown, playing);
    audio.update(shown, playing);
    onTime?.(time, playing);
  }, clipsEnd);
  let timelineData = { keyframes: [], loop: true };
  let exportCancelled = false;
  backdrop = createBackdrop(stage, pivot);
  stage.resize();

  // A click (not a drag) on the phone's screen: Flutter offers the file picker.
  let onScreenTap = null;
  const ray = new THREE.Raycaster();
  const el = stage.renderer.domElement;
  let down = null;
  el.addEventListener('pointerdown', (e) => { down = { x: e.clientX, y: e.clientY }; });
  el.addEventListener('pointerup', (e) => {
    const d = down;
    down = null;
    if (!d || !device || !onScreenTap || orbit.mode === 'move' || stage.locked) return;
    if (tracks.screens.length) return; // the prompt only shows on an empty screen
    if (Math.hypot(e.clientX - d.x, e.clientY - d.y) > 5) return;
    const box = el.getBoundingClientRect();
    const p = new THREE.Vector2(
      ((e.clientX - box.left) / box.width) * 2 - 1,
      -((e.clientY - box.top) / box.height) * 2 + 1);
    ray.setFromCamera(p, stage.camera);
    if (ray.intersectObjects(device.parts.screen, true).length) onScreenTap();
  });

  return {
    /** Resolves with the device profile as a JSON string. */
    async loadDevice(baseUrl, finishId) {
      const next = await loadDevice(baseUrl);
      if (device) { zoomGroup.remove(device.root); screen.dispose(); disposeDevice(device); }
      device = next;
      zoomGroup.add(device.root);
      orbit.refresh();
      screen = createScreenTrack(stage, device, assets);
      screen.setClips(tracks.screens);
      screen.update(player.time, player.playing);
      applyFinish(device, finishId);
      stage.invalidate();
      return JSON.stringify(device.profile);
    },
    setFinish(finishId) { if (device) { applyFinish(device, finishId); stage.invalidate(); } },
    /** Registers a media file: kind 'image' | 'video' | 'audio'. */
    addAsset(id, url, kind) { assets.add(id, url, kind); },
    removeAsset(id) { assets.remove(id); },
    /** Resolves with JSON {duration, width, height}. */
    async probeAsset(id) { return JSON.stringify(await assets.probe(id)); },
    /** Resolves with JSON [dataUrl, ...]: small frames across a video (or the image). */
    async filmstrip(id, count, height) { return JSON.stringify(await assets.filmstrip(id, count, height)); },
    /** Resolves with JSON [0..1, ...]: loudness across the file. */
    async peaks(id, count) { return JSON.stringify(await assets.peaks(id, count)); },
    /** Opens the browser's file picker. Resolves with {name, type, bytes} or null. */
    pickFile(accept) { return pickFile(accept); },
    /**
     * JSON {captions: [{id, start, end, headline, ...}], screens: [{id, start, end,
     * assetId, inPoint, volume, muted, fadeIn, fadeOut}], audio: [same as screens],
     * mutedTracks: ['screen' | 'audio', ...]}, each in time order.
     */
    setTracks(json) {
      tracks = JSON.parse(json);
      // A muted track silences every clip on it, in preview and in export.
      const muted = new Set(tracks.mutedTracks ?? []);
      if (muted.has('screen')) tracks.screens = tracks.screens.map((c) => ({ ...c, muted: true }));
      if (muted.has('audio')) tracks.audio = tracks.audio.map((c) => ({ ...c, muted: true }));
      backdrop.setCaptions(tracks.captions);
      screen?.setClips(tracks.screens);
      audio.setClips(tracks.audio);
      player.refresh();
    },
    /** Hides `part` of caption `id` while it is typed on the canvas (null id: none). */
    setCaptionEditing(id, part) { backdrop.setEditing(id, part); },
    setPose(turn, tilt, zoomLevel) {
      if (zoomLevel != null) zoom.set(zoomLevel);
      orbit.setPose(turn, tilt);
    },
    setPosition(x, y) { orbit.setPosition(x, y); },
    setMoveMode(enabled) { orbit.setMode(enabled ? 'move' : 'rotate'); },
    /** JSON: {style: 'solid'|'spotlight'|'image', color: '#rrggbb', imageUrl?}. */
    setBackground(json) { return backdrop.setBackground(JSON.parse(json)); },
    /** fn(): the user clicked the phone's screen. */
    onScreenTap(fn) { onScreenTap = fn; },
    /** fn(json | null): {id, head, sub}: the caption on screen; bounds {x, y, w, h} as fractions of the frame. */
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
        stage, applyPose, backdrop, assets,
        screen: () => screen,
        timeline: () => timelineData,
        tracks: () => tracks,
        duration: () => player.duration,
        pause: () => { player.pause(); audio.pauseAll(); screen?.pauseAll(); },
        restore: () => player.refresh(),
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
      screen?.dispose();
      audio.dispose();
      assets.dispose();
      backdrop.dispose();
      if (device) disposeDevice(device);
      stage.dispose();
    },
  };
}

window.BezelScene = { mount };
window.dispatchEvent(new Event('bezel-scene-ready'));
