// Renames source materials to Bezel's canonical names so the runtime can find
// the screen, body and frame on any device without per-model code.
export const CANONICAL = {
  screen: 'bezel:screen',
  screenGlass: 'bezel:screen_glass',
  body: 'bezel:body',
  frame: 'bezel:frame',
};

export function canonicaliseMaterials(doc, mapping) {
  const byName = new Map(doc.getRoot().listMaterials().map((m) => [m.getName(), m]));
  const missing = [];
  for (const [role, names] of Object.entries(mapping)) {
    for (const name of names) {
      const material = byName.get(name);
      if (!material) { missing.push(name); continue; }
      material.setName(CANONICAL[role]);
    }
  }
  if (missing.length) throw new Error(`Materials not found: ${missing.join(', ')}`);
}

/** The screen starts blank; the runtime puts the user's media on it. */
export function blankScreen(doc) {
  for (const m of doc.getRoot().listMaterials()) {
    if (m.getName() !== CANONICAL.screen) continue;
    m.setBaseColorTexture(null)
      .setBaseColorFactor([0.02, 0.02, 0.03, 1])
      .setEmissiveTexture(null)
      .setMetallicFactor(0)
      .setRoughnessFactor(0.25);
  }
}

/** Gives glass meshes over the screen their own material so it can be kept faint. */
export function splitScreenGlass(doc, meshNames = []) {
  const meshes = doc.getRoot().listMeshes().filter((m) => meshNames.includes(m.getName()));
  if (meshes.length !== meshNames.length) throw new Error(`Screen glass meshes not found: ${meshNames}`);
  for (const mesh of meshes) {
    for (const prim of mesh.listPrimitives()) {
      prim.setMaterial(prim.getMaterial().clone().setName(CANONICAL.screenGlass));
    }
  }
}

/**
 * Removes real-time transmission (see-through glass). In the browser it costs
 * a second render of the whole scene; plain blended glass looks the same here.
 */
export function stripTransmission(doc) {
  for (const m of doc.getRoot().listMaterials()) {
    const ext = m.getExtension('KHR_materials_transmission');
    if (!ext) continue;
    m.setExtension('KHR_materials_transmission', null);
    if (m.getAlphaMode() === 'OPAQUE') m.setAlphaMode('BLEND');
  }
}
