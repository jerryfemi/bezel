// Renderer, camera, lights and the render loop for one mounted 3D view.
// Renders only when something changed (or every frame while `alwaysRender`
// is set, e.g. while a video plays on the screen).
import * as THREE from './vendor/three_bundle.js';

const FOV = 30;
const FRAME_HEIGHT = 1.25; // world units kept in view vertically (device is 1 tall)

export function createStage(host) {
  const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true, preserveDrawingBuffer: true });
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  renderer.outputColorSpace = THREE.SRGBColorSpace;
  renderer.toneMapping = THREE.ACESFilmicToneMapping;
  renderer.domElement.style.cssText = 'width:100%;height:100%;display:block;touch-action:none;cursor:grab';
  host.appendChild(renderer.domElement);

  const scene = new THREE.Scene();
  scene.background = new THREE.Color('#1A1F2B');
  const pmrem = new THREE.PMREMGenerator(renderer);
  scene.environment = pmrem.fromScene(new THREE.RoomEnvironment(), 0.04).texture;

  const key = new THREE.DirectionalLight('#ffffff', 1.6);
  key.position.set(1.5, 2, 3);
  scene.add(key, new THREE.AmbientLight('#ffffff', 0.25));

  const camera = new THREE.PerspectiveCamera(FOV, 1, 0.01, 50);
  camera.position.set(0, 0, FRAME_HEIGHT / 2 / Math.tan(THREE.MathUtils.degToRad(FOV / 2)));

  const stage = { THREE, renderer, scene, camera, host, dirty: true, alwaysRender: false, onFrame: [] };
  stage.invalidate = () => { stage.dirty = true; };

  const resize = () => {
    const { clientWidth: w, clientHeight: h } = host;
    if (!w || !h) return;
    renderer.setSize(w, h, false);
    camera.aspect = w / h;
    camera.updateProjectionMatrix();
    stage.invalidate();
  };
  const observer = new ResizeObserver(resize);
  observer.observe(host);
  resize();

  let frame = 0;
  const tick = (now) => {
    frame = requestAnimationFrame(tick);
    stage.onFrame.forEach((fn) => fn(now));
    if (!stage.dirty && !stage.alwaysRender) return;
    stage.dirty = false;
    renderer.render(scene, camera);
  };
  frame = requestAnimationFrame(tick);

  stage.dispose = () => {
    cancelAnimationFrame(frame);
    observer.disconnect();
    pmrem.dispose();
    renderer.dispose();
    renderer.domElement.remove();
  };
  return stage;
}
