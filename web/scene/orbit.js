// Drag to turn and tilt the device. Follows the pointer 1:1, keeps the
// release velocity as momentum, and resists softly past the comfort limits
// so the back only shows when the user means it.
const DEG_PER_PX = 0.35;
const TURN_SOFT_LIMIT = 70;
const TILT_MIN = -30;
const TILT_MAX = 60;
const FRICTION = 0.92; // momentum kept per frame
const SPRING = 0.18; // pull back into the tilt range per frame

export function createOrbit(stage, onChange) {
  const el = stage.renderer.domElement;
  const pose = { turn: 0, tilt: 0 };
  const velocity = { turn: 0, tilt: 0 };
  let drag = null;

  const set = (turn, tilt) => {
    pose.turn = turn;
    pose.tilt = tilt;
    onChange(pose.turn, pose.tilt);
    stage.invalidate();
  };

  const onDown = (e) => {
    el.setPointerCapture(e.pointerId);
    el.style.cursor = 'grabbing';
    velocity.turn = velocity.tilt = 0;
    drag = { x: e.clientX, y: e.clientY, t: performance.now() };
  };
  const onMove = (e) => {
    if (!drag) return;
    const now = performance.now();
    const dt = Math.max(1, now - drag.t);
    const dTurn = resist(pose.turn, (e.clientX - drag.x) * DEG_PER_PX, TURN_SOFT_LIMIT);
    const dTilt = resistRange(pose.tilt, (e.clientY - drag.y) * DEG_PER_PX);
    velocity.turn = (dTurn / dt) * 16;
    velocity.tilt = (dTilt / dt) * 16;
    drag = { x: e.clientX, y: e.clientY, t: now };
    set(pose.turn + dTurn, pose.tilt + dTilt);
  };
  const onUp = () => { drag = null; el.style.cursor = 'grab'; };

  const step = () => {
    if (drag) return;
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

  el.addEventListener('pointerdown', onDown);
  el.addEventListener('pointermove', onMove);
  el.addEventListener('pointerup', onUp);
  el.addEventListener('pointercancel', onUp);
  stage.onFrame.push(step);

  return {
    pose,
    setPose(turn, tilt) { velocity.turn = velocity.tilt = 0; set(turn, tilt); },
    dispose() {
      el.removeEventListener('pointerdown', onDown);
      el.removeEventListener('pointermove', onMove);
      el.removeEventListener('pointerup', onUp);
      el.removeEventListener('pointercancel', onUp);
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
