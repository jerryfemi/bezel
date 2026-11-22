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

function mount(host, onPose) {
  const stage = createStage(host);
  const pivot = new THREE.Group();
  stage.scene.add(pivot);
  const orbit = createOrbit(stage, (turn, tilt) => {
    pivot.rotation.set(THREE.MathUtils.degToRad(tilt), THREE.MathUtils.degToRad(turn), 0, 'YXZ');
    onPose?.(turn, tilt);
  });
  const backdrop = createBackdrop(stage, pivot);
  stage.resize();
  let device = null;
  let media = null;

  return {
    /** Resolves with the device profile as a JSON string. */
    async loadDevice(baseUrl, finishId) {
      const next = await loadDevice(baseUrl);
      if (device) { pivot.remove(device.root); media.dispose(); disposeDevice(device); }
      device = next;
      pivot.add(device.root);
      media = createScreenMedia(stage, device);
      applyFinish(device, finishId);
      stage.invalidate();
      return JSON.stringify(device.profile);
    },
    setFinish(finishId) { if (device) { applyFinish(device, finishId); stage.invalidate(); } },
    setScreenImage(url) { return media?.setImage(url); },
    setScreenVideo(url) { return media?.setVideo(url); },
    setPose(turn, tilt) { orbit.setPose(turn, tilt); },
    /** JSON: {style: 'solid'|'spotlight'|'image', color: '#rrggbb', imageUrl?}. */
    setBackground(json) { return backdrop.setBackground(JSON.parse(json)); },
    /** JSON: {enabled, headline, subtitle, side: 'left'|'above'|'right'}. */
    setCaption(json) { backdrop.setCaption(JSON.parse(json)); },
    /** JSON: {angle: degrees, intensity: 0..1, reflections: bool}. */
    setLight(json) { applyLight(stage, JSON.parse(json)); },
    dispose() {
      orbit.dispose();
      media?.dispose();
      backdrop.dispose();
      if (device) disposeDevice(device);
      stage.dispose();
    },
  };
}

window.BezelScene = { mount };
window.dispatchEvent(new Event('bezel-scene-ready'));
