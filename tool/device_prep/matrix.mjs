// Tiny column-major 4x4 helpers (glTF convention).

/** Rotation about +Y by `deg` degrees. */
export function rotationY(deg) {
  const r = (deg * Math.PI) / 180;
  const c = Math.round(Math.cos(r) * 1e9) / 1e9;
  const s = Math.round(Math.sin(r) * 1e9) / 1e9;
  return [c, 0, -s, 0, 0, 1, 0, 0, s, 0, c, 0, 0, 0, 0, 1];
}

/** Uniform scale `k` applied after moving `center` to the origin. */
export function centerAndScale(center, k) {
  const [x, y, z] = center;
  return [k, 0, 0, 0, 0, k, 0, 0, 0, 0, k, 0, -x * k, -y * k, -z * k, 1];
}

/** Degrees about +Y that turn `frontAxis` into +Z. */
export function turnToFront(frontAxis) {
  const table = { '+z': 0, '-z': 180, '-x': 90, '+x': -90 };
  if (!(frontAxis in table)) throw new Error(`Unsupported frontAxis: ${frontAxis}`);
  return table[frontAxis];
}
