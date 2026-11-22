import { CANONICAL } from './materials.mjs';

/**
 * Gives the screen a clean 0..1 planar UV map across its face (the model
 * already faces +Z), so any image or video fills it edge to edge.
 * Returns the screen's width / height ratio for cropping media.
 */
export function planarScreenUVs(doc) {
  const prims = screenPrimitives(doc);
  if (!prims.length) throw new Error('No screen primitive found');
  const { min, max } = boundsOf(prims);
  const w = max[0] - min[0];
  const h = max[1] - min[1];

  for (const prim of prims) {
    const pos = prim.getAttribute('POSITION');
    const uv = new Float32Array(pos.getCount() * 2);
    const p = [];
    for (let i = 0; i < pos.getCount(); i++) {
      pos.getElement(i, p);
      uv[i * 2] = (p[0] - min[0]) / w;
      uv[i * 2 + 1] = 1 - (p[1] - min[1]) / h;
    }
    const accessor = doc.createAccessor().setType('VEC2').setArray(uv)
      .setBuffer(doc.getRoot().listBuffers()[0]);
    prim.setAttribute('TEXCOORD_0', accessor);
  }
  return w / h;
}

function screenPrimitives(doc) {
  return doc.getRoot().listMeshes()
    .flatMap((m) => m.listPrimitives())
    .filter((p) => p.getMaterial()?.getName() === CANONICAL.screen);
}

function boundsOf(prims) {
  const min = [Infinity, Infinity, Infinity];
  const max = [-Infinity, -Infinity, -Infinity];
  for (const prim of prims) {
    const a = prim.getAttribute('POSITION');
    a.getMin([]).forEach((v, i) => (min[i] = Math.min(min[i], v)));
    a.getMax([]).forEach((v, i) => (max[i] = Math.max(max[i], v)));
  }
  return { min, max };
}
