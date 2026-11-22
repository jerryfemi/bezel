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
