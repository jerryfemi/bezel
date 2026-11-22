# Device prep

Turns downloaded device models (Sketchfab GLB) into the files Bezel loads.

For each device in `devices.config.mjs` it:

1. bakes all node transforms and turns the model so the screen faces +Z, +Y up,
   centred on the origin and exactly 1 unit tall;
2. renames the screen, screen glass, body and frame materials to
   `bezel:screen`, `bezel:screen_glass`, `bezel:body`, `bezel:frame`;
3. blanks the screen and gives it a clean 0–1 UV map so any media fills it;
4. compresses textures to WebP (max 2048 px) and drops unused data;
5. writes `web/devices/<id>/model.glb` and `profile.json`.

## Adding a device

1. Put the source GLB in `assets/devices/` (source files are not committed).
2. Run `npx @gltf-transform/cli inspect <file>` and note the material names.
3. Add an entry to `devices.config.mjs`.
4. From the repo root: `cd tool/device_prep && npm install && cd ../.. && node tool/device_prep/prepare.mjs <id>`.

A model only works if its screen is its own material. Models baked into one
mesh and one texture set cannot show user media or change colour.
