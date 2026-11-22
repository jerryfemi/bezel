// Zoom the device: scroll wheel / trackpad pinch on desktop, two-finger pinch
// on touch. Zoom scales the device group, so it composes with layout.
const MIN = 0.5;
const MAX = 2.5;
const WHEEL_SPEED = 0.0015;

export function createZoom(stage, group, onChange) {
  const el = stage.renderer.domElement;
  const pointers = new Map();
  let zoom = 1;
  let pinchStart = null;

  const set = (z) => {
    zoom = Math.min(MAX, Math.max(MIN, z));
    group.scale.setScalar(zoom);
    onChange(zoom);
    stage.invalidate();
  };

  const spread = () => {
    const [a, b] = [...pointers.values()];
    return Math.hypot(a.x - b.x, a.y - b.y);
  };

  const onWheel = (e) => {
    e.preventDefault(); // trackpad pinch arrives as ctrl+wheel; never scroll the page
    set(zoom * Math.exp(-e.deltaY * WHEEL_SPEED * (e.ctrlKey ? 4 : 1)));
  };
  const onDown = (e) => {
    pointers.set(e.pointerId, { x: e.clientX, y: e.clientY });
    if (pointers.size === 2) pinchStart = { spread: spread(), zoom };
  };
  const onMove = (e) => {
    if (!pointers.has(e.pointerId)) return;
    pointers.set(e.pointerId, { x: e.clientX, y: e.clientY });
    if (pointers.size === 2 && pinchStart) set(pinchStart.zoom * (spread() / pinchStart.spread));
  };
  const onUp = (e) => {
    pointers.delete(e.pointerId);
    if (pointers.size < 2) pinchStart = null;
  };

  el.addEventListener('wheel', onWheel, { passive: false });
  el.addEventListener('pointerdown', onDown);
  el.addEventListener('pointermove', onMove);
  el.addEventListener('pointerup', onUp);
  el.addEventListener('pointercancel', onUp);

  return {
    get value() { return zoom; },
    /** True while two fingers are down; the orbit drag pauses meanwhile. */
    pinching: () => pointers.size >= 2,
    set,
    dispose() {
      el.removeEventListener('wheel', onWheel);
      el.removeEventListener('pointerdown', onDown);
      el.removeEventListener('pointermove', onMove);
      el.removeEventListener('pointerup', onUp);
      el.removeEventListener('pointercancel', onUp);
    },
  };
}
