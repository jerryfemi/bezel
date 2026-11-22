// Loads a prepared device (web/devices/<id>/) and finds its canonical parts.
import * as THREE from './vendor/three_bundle.js';

const loader = new THREE.GLTFLoader();

export async function loadDevice(baseUrl) {
  const profile = await (await fetch(`${baseUrl}/profile.json`)).json();
  const base = new URL(`${baseUrl}/`, document.baseURI);
  const gltf = await loader.loadAsync(new URL(profile.model, base).href);
  const parts = { screen: [], screenGlass: [], body: [], frame: [] };
  const roles = {
    'bezel:screen': 'screen', 'bezel:screen_glass': 'screenGlass',
    'bezel:body': 'body', 'bezel:frame': 'frame',
  };
  gltf.scene.traverse((obj) => {
    if (!obj.isMesh) return;
    const role = roles[obj.material?.name];
    if (role) parts[role].push(obj);
  });
  calmScreenGlass(parts.screenGlass);
  return { profile, root: gltf.scene, parts };
}

/** Keeps the glass layer as a faint reflection so it never hides the screen. */
function calmScreenGlass(meshes) {
  for (const mesh of meshes) {
    const m = mesh.material;
    m.transparent = true;
    m.opacity = 0.08;
    m.transmission = 0;
    m.color?.set('#ffffff');
    m.roughness = 0.05;
    m.depthWrite = false;
  }
}

export function disposeDevice(device) {
  device.root.traverse((obj) => {
    if (!obj.isMesh) return;
    obj.geometry.dispose();
    const mats = Array.isArray(obj.material) ? obj.material : [obj.material];
    mats.forEach((m) => { Object.values(m).forEach((v) => v?.isTexture && v.dispose()); m.dispose(); });
  });
}
