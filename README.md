# Bezel

Bezel turns app screenshots and screen recordings into polished device mockups and animated clips. It is a Flutter web app with a Three.js scene renderer.

## Features

- Import an image or screen recording for a device display.
- Choose a device and finish, then adjust its pose, lighting, background, and captions.
- Create camera movement with the motion timeline.
- Export PNG, GIF, WebM, or MP4 clips.
- Save and reopen projects in the current browser.

The bundled device catalog currently includes iPhone 13 Pro Max and iPhone 16 Pro Max models.

## Run locally

Requirements: Flutter stable (Dart 3.11.5 or newer within the Dart 3 range) and Chrome for local web development. Node.js 22 or newer is required to bundle the production scene.

```sh
flutter pub get
flutter run -d chrome
```

MP4 and WebM export uses the browser's WebCodecs support and available codecs. PNG and GIF export do not use WebCodecs.

## Build for the web

The scene bundler must run after Flutter creates `build/web`:

```sh
flutter pub get
flutter build web --release
npm ci --prefix tool/scene_bundle
npm run build --prefix tool/scene_bundle
```

The scene bundler writes a content-hashed Three.js bundle into `build/web/scene` and updates the generated `index.html` to load it.

## Deploy

The single GitHub Actions workflow at `.github/workflows/deploy.yml` builds the Flutter app, bundles the scene, and deploys it to Firebase Hosting. Pushes to `main` deploy to the live channel; pull requests from this repository get a preview channel. The workflow uses Firebase project `bezel-2ebea` and Hosting site `bezel-3d`.

Add the service account JSON as the GitHub Actions secret `FIREBASE_SERVICE_ACCOUNT_BEZEL_2EBEA` for deployments to run.

For a manual deploy, install and authenticate the Firebase CLI, then run:

```sh
flutter pub get
flutter build web --release
npm ci --prefix tool/scene_bundle
npm run build --prefix tool/scene_bundle
firebase deploy --only hosting --project bezel-2ebea
```

## Project layout

- `lib/features/` — editor, tools, projects, motion, and export UI/state.
- `lib/features/scene3d/` — Dart controller and interop for the browser scene.
- `web/scene/` — Three.js scene, playback, and export implementation.
- `web/devices/` — prepared device models and profiles served with the app.
- `tool/scene_bundle/` — production bundling for the Three.js scene.
- `tool/device_prep/` — preparation scripts for adding device models.
