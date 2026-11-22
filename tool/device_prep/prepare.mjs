// Usage (from the repo root):  node tool/device_prep/prepare.mjs [deviceId]
// Reads each source GLB listed in devices.config.mjs and writes
// web/devices/<id>/model.glb + profile.json.
import { mkdir, writeFile, stat } from 'node:fs/promises';
import { join } from 'node:path';
import { NodeIO } from '@gltf-transform/core';
import { ALL_EXTENSIONS } from '@gltf-transform/extensions';
import { devices } from './devices.config.mjs';
import { orient } from './orient.mjs';
import {
  canonicaliseMaterials, blankScreen, splitScreenGlass, stripTransmission,
} from './materials.mjs';
import { planarScreenUVs } from './screen_uv.mjs';
import { optimize } from './optimize.mjs';
import { buildProfile } from './profile.mjs';

const repoRoot = process.env.BEZEL_ROOT ?? process.cwd();
const io = new NodeIO().registerExtensions(ALL_EXTENSIONS);
const only = process.argv[2];

for (const device of devices.filter((d) => !only || d.id === only)) {
  const doc = await io.read(join(repoRoot, device.source));
  const size = await orient(doc, device.frontAxis);
  splitScreenGlass(doc, device.screenGlassMeshes);
  canonicaliseMaterials(doc, device.materials);
  stripTransmission(doc);
  blankScreen(doc);
  const aspect = planarScreenUVs(doc);
  await optimize(doc);

  const outDir = join(repoRoot, 'web', 'devices', device.id);
  await mkdir(outDir, { recursive: true });
  const modelPath = join(outDir, 'model.glb');
  await io.write(modelPath, doc);
  const profile = buildProfile(device, size, aspect);
  await writeFile(join(outDir, 'profile.json'), JSON.stringify(profile, null, 2) + '\n');

  const kb = Math.round((await stat(modelPath)).size / 1024);
  console.log(`${device.id}: ${kb} KB, screen aspect ${profile.screens[0].aspect}`);
}
