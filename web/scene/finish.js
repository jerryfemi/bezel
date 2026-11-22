// Applies a finish (body + frame colour) from the device profile.

export function applyFinish(device, finishId) {
  const finish = device.profile.finishes.find((f) => f.id === finishId)
    ?? device.profile.finishes[0];
  tint(device.parts.body, finish.body);
  tint(device.parts.frame, finish.frame);
  return finish.id;
}

function tint(meshes, hex) {
  for (const mesh of meshes) mesh.material.color.set(hex);
}
