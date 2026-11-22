import { flatten, clearNodeTransform, getBounds, transformMesh } from '@gltf-transform/functions';
import { rotationY, centerAndScale, turnToFront } from './matrix.mjs';

/**
 * Bakes every node transform into its mesh, then rotates the model so the
 * screen faces +Z, centres it on the origin and scales it to 1 unit tall.
 */
export async function orient(doc, frontAxis) {
  await doc.transform(flatten());
  const root = doc.getRoot();
  const meshNodes = root.listNodes().filter((n) => n.getMesh());
  meshNodes.forEach((n) => clearNodeTransform(n));

  const rotation = rotationY(turnToFront(frontAxis));
  uniqueMeshes(meshNodes).forEach((m) => transformMesh(m, rotation));

  const scene = root.listScenes()[0];
  const { min, max } = getBounds(scene);
  const center = min.map((v, i) => (v + max[i]) / 2);
  const scale = 1 / (max[1] - min[1]);
  const fit = centerAndScale(center, scale);
  uniqueMeshes(meshNodes).forEach((m) => transformMesh(m, fit));

  const size = max.map((v, i) => (v - min[i]) * scale);
  return { width: size[0], height: size[1], depth: size[2] };
}

function uniqueMeshes(nodes) {
  return [...new Set(nodes.map((n) => n.getMesh()))];
}
