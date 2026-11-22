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
  const player = createPlayer(stage, (p) => {
    zoom.set(p.zoom);
    orbit.setPose(p.turn, p.tilt);
  }, (time, playing) => onTime?.(time, playing));
  const backdrop = createBackdrop(stage, pivot);
  stage.resize();
  let device = null;
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
    /** JSON: {enabled, headline, subtitle, side: 'left'|'above'|'right'}. */
    setCaption(json) { backdrop.setCaption(JSON.parse(json)); },
    /** JSON: {angle: degrees, intensity: 0..1, reflections: bool}. */
    setLight(json) { applyLight(stage, JSON.parse(json)); },
    /** JSON: {loop, keyframes: [{time, turn, tilt, zoom, easing: {kind, bounce}}]}. */
    setTimeline(json) { player.setTimeline(JSON.parse(json)); },
    play() { player.play(); },
    pause() { player.pause(); },
    seek(seconds) { player.seek(seconds); },
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
