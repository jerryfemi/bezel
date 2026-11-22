# Three.js vendor bundle

Bezel ships Three.js inside the app (no CDN). `entry.js` re-exports Three.js
plus the two add-ons the scene uses; esbuild turns that into one file:
`web/scene/vendor/three_bundle.js`.

To upgrade: change the `three` version in `package.json`, then
`npm install && npm run build` in this folder.
