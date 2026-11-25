// Where the caption sits in the frame, and how the device makes room for it.
// The room-making offset sits on the pivot, under the user's own Move
// position (on the placement group), so the two add up and never fight.
import { FRAME_HEIGHT } from './stage.js';

export function resolveSide(caption, aspect) {
  if (!caption?.enabled) return 'none';
  return aspect < 1 ? 'above' : caption.side;
}

/** Caption box in canvas pixels for a canvas of size w × h. */
export function captionBox(side, w, h) {
  if (side === 'above') return { x: w * 0.1, y: h * 0.05, w: w * 0.8, h: h * 0.24 };
  const x = side === 'left' ? w * 0.08 : w * 0.54;
  return { x, y: h * 0.1, w: w * 0.38, h: h * 0.8 };
}

/** Moves and scales the device pivot to make room for the caption. */
export function placeDevice(pivot, side, aspect) {
  const visibleWidth = FRAME_HEIGHT * aspect;
  pivot.position.set(0, 0, 0);
  pivot.scale.setScalar(1);
  if (side === 'left') pivot.position.x = visibleWidth * 0.2;
  if (side === 'right') pivot.position.x = -visibleWidth * 0.2;
  if (side === 'above') {
    pivot.scale.setScalar(0.72);
    pivot.position.y = -FRAME_HEIGHT * 0.13;
  }
}
