// Easing curves: progress p (0..1) in, eased progress out.

/**
 * Spring step response, sized to settle by p = 1. `bounce` 0 is critically
 * damped (no overshoot); up to 0.5 overshoots and settles.
 */
export function spring(p, bounce = 0) {
  if (p >= 1) return 1;
  const w = 12;
  const z = 1 - 1.2 * Math.min(0.5, Math.max(0, bounce));
  if (z >= 1) return 1 - (1 + w * p) * Math.exp(-w * p);
  const wd = w * Math.sqrt(1 - z * z);
  const decay = Math.exp(-z * w * p);
  return 1 - decay * (Math.cos(wd * p) + ((z * w) / wd) * Math.sin(wd * p));
}

export function ease(p) {
  return p < 0.5 ? 4 * p * p * p : 1 - Math.pow(-2 * p + 2, 3) / 2;
}

export function apply(easing, p) {
  if (easing?.kind === 'linear') return p;
  if (easing?.kind === 'ease') return ease(p);
  return spring(p, easing?.bounce ?? 0);
}
