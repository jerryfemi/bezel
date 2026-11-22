// Run after `flutter build web` (from this folder: npm install, then npm run build).
//
// Bundles build/web/scene/bezel_scene.js and everything it imports into one
// minified file named after its content hash, points index.html at it, and
// removes the loose module files. Browsers then always fetch the new scene
// after a deploy instead of mixing cached modules from an older one.
import { build } from 'esbuild';
import { createHash } from 'node:crypto';
import { readFile, writeFile, rm, readdir } from 'node:fs/promises';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const web = resolve(dirname(fileURLToPath(import.meta.url)), '../../build/web');
const sceneDir = join(web, 'scene');

const result = await build({
  entryPoints: [join(sceneDir, 'bezel_scene.js')],
  bundle: true,
  format: 'esm',
  minify: true,
  legalComments: 'none',
  write: false,
});
const code = result.outputFiles[0].contents;
const hash = createHash('sha256').update(code).digest('hex').slice(0, 10);
const name = `bezel_scene.${hash}.js`;

// Remove the loose modules (keep non-JS files such as vendor/THREE_LICENSE).
for (const entry of await readdir(sceneDir, { recursive: true })) {
  if (entry.endsWith('.js')) await rm(join(sceneDir, entry));
}
await writeFile(join(sceneDir, name), code);

const indexPath = join(web, 'index.html');
const html = await readFile(indexPath, 'utf8');
if (!html.includes('scene/bezel_scene.js')) throw new Error('index.html has no scene/bezel_scene.js script tag');
await writeFile(indexPath, html.replace('scene/bezel_scene.js', `scene/${name}`));

console.log(`scene/${name}  ${(code.length / 1024).toFixed(0)} KB`);
