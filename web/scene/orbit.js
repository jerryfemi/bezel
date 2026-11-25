// Drag to turn and tilt the device. Shift+drag (or Move mode) positions it on
// the artboard. Rotation follows the pointer and keeps release momentum.
// The edge limit applies only while the user drags: turning or zooming never
// changes the position they chose.
import * as THREE from './vendor/three_bundle.js';
import { FRAME_HEIGHT } from './stage.js';

const DEG_PER_PX = 0.35;
const TURN_SOFT_LIMIT = 70;
const TILT_MIN = -30;
const TILT_MAX = 60;
const FRICTION = 0.92; // momentum kept per frame
const SPRING = 0.18; // pull back into the tilt range per frame
const MIN_VISIBLE = 0.3; // part of the device that must stay in frame when moved

export function createOrbit(
  stage,
  onChange,
  isPinching = () => false,
  placement,
  getDevice = () => null,
  onPositionChange = () => {},
) {
  const el = stage.renderer.domElement;
  const pose = { turn: 0, tilt: 0 };
  const velocity = { turn: 0, tilt: 0 };
  const raycaster = new THREE.Raycaster();
  let position = { x: 0, y: 0 }; // fractions of the artboard, relative to center
  let drag = null;
  let mode = 'rotate';

  const set = (turn, tilt) => {
    pose.turn = turn;
    pose.tilt = tilt;
    onChange(pose.turn, pose.tilt);
    stage.invalidate();
  };

  const setPlacement = (next) => {
    const rect = el.getBoundingClientRect();
    const aspect = rect.width && rect.height ? rect.width / rect.height : 1;
    position = next;
    placement.position.set(next.x * FRAME_HEIGHT * aspect, next.y * FRAME_HEIGHT, 0);
    stage.invalidate();
  };

  const constrainPosition = (x, y) => {
    const root = getDevice();
    const rect = el.getBoundingClientRect();
    if (!root || !rect.width || !rect.height) return { x, y };

    const projectBounds = () => {
      stage.scene.updateMatrixWorld(true);
      stage.camera.updateMatrixWorld(true);
      const box = new THREE.Box3().setFromObject(root);
      if (box.isEmpty()) return null;
      const points = [
        new THREE.Vector3(box.min.x, box.min.y, box.min.z),
        new THREE.Vector3(box.min.x, box.min.y, box.max.z),
        new THREE.Vector3(box.min.x, box.max.y, box.min.z),
        new THREE.Vector3(box.min.x, box.max.y, box.max.z),
        new THREE.Vector3(box.max.x, box.min.y, box.min.z),
        new THREE.Vector3(box.max.x, box.min.y, box.max.z),
        new THREE.Vector3(box.max.x, box.max.y, box.min.z),
        new THREE.Vector3(box.max.x, box.max.y, box.max.z),
      ];
      const screen = points.map((point) => {
        point.project(stage.camera);
        return {
          x: (point.x * 0.5 + 0.5) * rect.width,
          y: (-point.y * 0.5 + 0.5) * rect.height,
        };
      });
      return {
        left: Math.min(...screen.map((p) => p.x)),
        right: Math.max(...screen.map((p) => p.x)),
        top: Math.min(...screen.map((p) => p.y)),
        bottom: Math.max(...screen.map((p) => p.y)),
      };
    };

    // Keep at least MIN_VISIBLE of the device inside the frame; going
    // partly off the edge (or zooming past it) is allowed on purpose.
    const keep = (lo, hi, size) => {
      const need = Math.min(hi - lo, size) * MIN_VISIBLE;
      if (hi < need) return need - hi;
      if (lo > size - need) return size - need - lo;
      return 0;
    };
    setPlacement({ x, y });
    const bounds = projectBounds();
    if (!bounds) return { x, y };
    const dx = keep(bounds.left, bounds.right, rect.width);
    const dy = keep(bounds.top, bounds.bottom, rect.height);
    const next = { x: x + dx / rect.width, y: y - dy / rect.height };
    return next;
  };

  const setPosition = (x, y, notify = true) => {
    const next = constrainPosition(x, y);
    const changed = Math.abs(next.x - position.x) > 1e-6 || Math.abs(next.y - position.y) > 1e-6;
    setPlacement(next);
    if (notify && changed) onPositionChange(next.x, next.y);
  };

  const pointOnCanvas = (e) => {
    const rect = el.getBoundingClientRect();
    return new THREE.Vector2(
      ((e.clientX - rect.left) / rect.width) * 2 - 1,
      -((e.clientY - rect.top) / rect.height) * 2 + 1,
    );
  };

  const hitsDevice = (e) => {
    const root = getDevice();
    if (!root) return false;
    stage.scene.updateMatrixWorld(true);
    stage.camera.updateMatrixWorld(true);
    raycaster.setFromCamera(pointOnCanvas(e), stage.camera);
    return raycaster.intersectObject(root, true).length > 0;
  };

  // The hover cursor needs a raycast; do it at most every 80 ms.
  let lastHover = 0;
  const updateCursor = (e) => {
    if (drag) return;
    if (mode === 'rotate') { el.style.cursor = 'grab'; return; }
    const now = performance.now();
    if (now - lastHover < 80) return;
    lastHover = now;
    el.style.cursor = hitsDevice(e) ? 'grab' : 'default';
  };

  const onDown = (e) => {
    if (stage.locked || isPinching() || drag) return;
    const dragMode = e.shiftKey ? 'move' : mode;
    if (dragMode === 'move') {
      if (!hitsDevice(e)) return;
      el.setPointerCapture(e.pointerId);
      el.style.cursor = 'grabbing';
      drag = {
        mode: dragMode,
        pointerId: e.pointerId,
        x: e.clientX,
        y: e.clientY,
        startX: position.x,
        startY: position.y,
      };
      return;
    }
    el.setPointerCapture(e.pointerId);
    el.style.cursor = 'grabbing';
    velocity.turn = velocity.tilt = 0;
    drag = { mode, pointerId: e.pointerId, x: e.clientX, y: e.clientY, t: performance.now() };
  };

  const onMove = (e) => {
    if (!drag) {
      updateCursor(e);
      return;
    }
    if (drag.pointerId !== e.pointerId) return;
    if (isPinching()) {
      drag = null;
      updateCursor(e);
      return;
    }
    if (drag.mode === 'move') {
      const rect = el.getBoundingClientRect();
      if (!rect.width || !rect.height) return;
      setPosition(
        drag.startX + (e.clientX - drag.x) / rect.width,
        drag.startY - (e.clientY - drag.y) / rect.height,
      );
      return;
    }

    const now = performance.now();
    const dt = Math.max(1, now - drag.t);
    const dTurn = resist(pose.turn, (e.clientX - drag.x) * DEG_PER_PX, TURN_SOFT_LIMIT);
    const dTilt = resistRange(pose.tilt, (e.clientY - drag.y) * DEG_PER_PX);
    velocity.turn = (dTurn / dt) * 16;
    velocity.tilt = (dTilt / dt) * 16;
    drag = { ...drag, x: e.clientX, y: e.clientY, t: now };
    set(pose.turn + dTurn, pose.tilt + dTilt);
  };

  const onUp = (e) => {
    if (drag && drag.pointerId !== e.pointerId) return;
    drag = null;
    updateCursor(e);
  };

  const step = () => {
    if (mode !== 'rotate' || drag) return;
    let { turn, tilt } = pose;
    const moving = Math.abs(velocity.turn) > 0.01 || Math.abs(velocity.tilt) > 0.01;
    if (moving) {
      turn += resist(turn, velocity.turn, TURN_SOFT_LIMIT);
      tilt += velocity.tilt;
      velocity.turn *= FRICTION;
      velocity.tilt *= FRICTION;
    }
    const target = Math.min(TILT_MAX, Math.max(TILT_MIN, tilt));
    const settling = Math.abs(target - tilt) > 0.05;
    if (settling) { tilt += (target - tilt) * SPRING; velocity.tilt = 0; }
    if (moving || settling) set(wrap(turn), tilt);
  };

  // A new frame shape changes the width the fractions refer to; re-place only.
  const onResize = () => setPlacement(position);

  el.addEventListener('pointerdown', onDown);
  el.addEventListener('pointermove', onMove);
  el.addEventListener('pointerup', onUp);
  el.addEventListener('pointercancel', onUp);
  stage.onFrame.push(step);
  stage.onResize.push(onResize);

  return {
    pose,
    get mode() { return mode; },
    setMode(next) {
      mode = next;
      drag = null;
      velocity.turn = velocity.tilt = 0;
      el.style.cursor = mode === 'rotate' ? 'grab' : 'default';
    },
    /** Sets the saved position as-is (opening a project, Center device). */
    setPosition(x, y) { setPlacement({ x, y }); onPositionChange(x, y); },
    /** Re-applies the position after a size change, without limiting it. */
    refresh() { setPlacement(position); },
    setPose(turn, tilt) { velocity.turn = velocity.tilt = 0; set(turn, tilt); },
    dispose() {
      el.removeEventListener('pointerdown', onDown);
      el.removeEventListener('pointermove', onMove);
      el.removeEventListener('pointerup', onUp);
      el.removeEventListener('pointercancel', onUp);
      const frameIndex = stage.onFrame.indexOf(step);
      if (frameIndex >= 0) stage.onFrame.splice(frameIndex, 1);
      const resizeIndex = stage.onResize.indexOf(onResize);
      if (resizeIndex >= 0) stage.onResize.splice(resizeIndex, 1);
    },
  };
}

/** Past ±limit, outward movement is damped to 35%. */
function resist(value, delta, limit) {
  const outward = Math.sign(delta) === Math.sign(value) && Math.abs(value) > limit;
  return outward ? delta * 0.35 : delta;
}

/** Rubber band outside the tilt range: the further out, the less it follows. */
function resistRange(value, delta) {
  const over = value < TILT_MIN ? TILT_MIN - value : value > TILT_MAX ? value - TILT_MAX : 0;
  return over > 0 ? delta / (1 + over / 8) : delta;
}

/** Keeps turn within -180..180 so the number never grows without bound. */
function wrap(deg) {
  return ((((deg + 180) % 360) + 360) % 360) - 180;
}
