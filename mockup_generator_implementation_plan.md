# Device Mockup Generator — Implementation Plan

## 1. Product Summary

A Flutter app that lets users upload a screenshot or screen recording and place it into a realistic, tiltable device bezel (phone/tablet), then export a watermark-free high-resolution image or video. Positioned as a Rotato/Previewed-style tool, built native and cross-platform.

**Core promise to users:** the mockup should feel like a real, physical object in space — not a flat overlay — and export cleanly to PNG/MP4.

---

## 2. Key Architectural Decisions (and why)

| Decision | Choice | Reasoning |
|---|---|---|
| 3D rendering approach | **Fake 3D** via `Matrix4` perspective transforms on layered 2D assets, not a true 3D engine | True 3D (`flutter_scene`) requires Flutter's unstable master channel and is labeled early-preview. Not viable for a production v1. |
| Rejected: WebView-based 3D | `o3d` / `model_viewer_plus` | These render via a WebView platform view, which lives outside Flutter's own paint tree. `RepaintBoundary` cannot reliably capture platform views — export would silently fail or return blank frames. Since export is the core feature, this is disqualifying, not a minor tradeoff. |
| Image export | `RepaintBoundary.toImage()` | Native, stable, well-supported. No caveats as long as everything on screen is pure Flutter widgets (see row above). |
| Video export | **Native hardware encoders** (`AVAssetWriter` on iOS, `MediaCodec` on Android) via platform channels, fed frames captured through `RepaintBoundary` | `ffmpeg_kit_flutter` was retired by its maintainer in January 2025, partly due to codec-patent licensing exposure. Community forks exist but inherit that same legal ambiguity. Native encoders avoid the dependency entirely, are hardware-accelerated, and keep binary size down. |
| Future true-3D tier | `flutter_scene` (Flutter GPU / Impeller-based) | Only revisit once the package is off master channel and Impeller's 3D roadmap matures. This is the only 3D engine option that renders *inside* Flutter's scene graph, meaning it would actually be exportable. |

---

## 3. Tech Stack

- **Framework:** Flutter (stable channel) — target desktop + mobile first; web deprioritized until video export story is resolved for web (MediaRecorder-based path would need separate design).
- **State management:** Riverpod (matches prior project conventions).
- **Local persistence:** Hive (project drafts, saved presets) — consistent with prior stack choices.
- **Video preview:** `video_player` for scrubbing/previewing the source clip before export.
- **Image capture:** `dart:ui` + `RenderRepaintBoundary` (built-in, no package).
- **Video export:** Custom platform channel to native `AVAssetWriter` (iOS) / `MediaCodec` (Android). No third-party video package for encoding.
- **Asset format:** Transparent PNG/WebP bezels; SVG considered for scalability but rasterized bezels are simpler to get pixel-perfect against real device photography.

---

## 4. Phased Roadmap

### Phase 0 — Foundations (1–2 weeks)
- [ ] Project scaffold, design system pass (colors, type — reuse existing portfolio identity: near-black base, phosphor-teal accent, Space Grotesk/IBM Plex Mono).
- [ ] Define the `MockupProject` data model: source asset (image/video path), selected device, rotation state, background style, export settings.
- [ ] Source or commission first 3 device bezel asset sets (e.g. iPhone 15, a mid-range Android, an iPad) as transparent PNGs with precisely matched screen-cutout coordinates.
- [ ] Build the asset metadata format (JSON per device: screen rect in bezel-image pixel space, corner radius, bezel dimensions) so new devices can be added without code changes.

**Definition of done:** app boots, can pick a device from a list, shows its bezel on screen.

### Phase 1 — Fake-3D Image Mockup (2–3 weeks)
- [ ] Implement `PhoneMockupWidget` (drag-to-tilt via `Matrix4`, perspective entry, clamped rotation).
- [ ] Screenshot import (image picker) + fit/zoom/pan behind the bezel (pinch-to-zoom via `InteractiveViewer` or manual gesture handling).
- [ ] Background system: solid color, gradient, or uploaded background image behind the device.
- [ ] Shadow/reflection layer that responds to tilt angle for depth cues.
- [ ] Export via `captureMockupAsPng()`, at 2x/3x/4x pixel ratio options.
- [ ] Preset angles (front-on, 3/4 left, 3/4 right) as quick-select buttons in addition to free drag.

**Definition of done:** user can upload a screenshot, tilt it, and export a crisp PNG mockup with no watermark. **This is the shippable v1.**

### Phase 2 — Video Mockup + Native Export (3–5 weeks)
- [ ] Swap static `Image` screen content for a live `video_player` texture inside the same `PhoneMockupWidget`.
- [ ] Playback controls: trim start/end, loop preview while adjusting tilt.
- [ ] Frame capture loop: on export, drive the animation (if any camera movement is baked in) frame-by-frame, capturing each via `RepaintBoundary.toImage()` at a fixed fps (24/30/60 selectable).
- [ ] Platform channel implementation:
  - iOS: `AVAssetWriter` + `AVAssetWriterInputPixelBufferAdaptor`, feeding captured RGBA frames as `CVPixelBuffer`s.
  - Android: `MediaCodec` + `Surface` input, feeding frames via `ImageReader`/`Surface` writes.
- [ ] Progress UI for export (this can take real wall-clock time for longer clips — needs a proper progress bar, not a spinner).
- [ ] Handle audio passthrough from the source video if present (native encoders support muxing audio track — decide whether v2 needs this or defers it).

**Definition of done:** user can upload a screen recording, apply a mockup (static tilt or simple animated camera move), and export a real MP4 with no third-party video-encoding dependency.

### Phase 3 — Animated Camera Moves (2–3 weeks, can run parallel to Phase 2 polish)
- [ ] Keyframe system: user sets 2+ tilt/zoom states, app interpolates between them over a duration (the actual "cinematic" selling point of tools like Rotato).
- [ ] Easing curve picker (ease-in-out, spring, linear).
- [ ] Timeline scrubber UI to preview the animated path before export.

**Definition of done:** user can create a mockup where the device visibly rotates/pans over the duration of the export, not just a static angle.

### Phase 4 — True 3D (Exploratory / Pro tier, no fixed timeline)
- [ ] Revisit `flutter_scene` status — confirm stable-channel support and export compatibility with `RepaintBoundary` in a spike before committing.
- [ ] If viable: source or generate glTF models per device, replace bezel PNGs with meshes, implement dynamic texture binding for video screen content.
- [ ] Gate behind a clearly-labeled beta/Pro flag given engine maturity risk.

**Explicitly not scheduled** until Phase 4 conditions are met — do not let this phase bleed into Phase 1–3 scope.

---

## 5. Suggested Project Structure

```
lib/
  models/
    mockup_project.dart
    device_spec.dart          // per-device bezel metadata
  widgets/
    phone_mockup_widget.dart  // core tilt/perspective widget
    background_picker.dart
    device_selector.dart
    timeline_scrubber.dart    // Phase 3
  services/
    export/
      image_export_service.dart
      video_export_service.dart   // dart-side orchestration
    platform/
      video_encoder_channel.dart  // MethodChannel wrapper
  screens/
    editor_screen.dart
    export_progress_screen.dart
ios/Runner/
  VideoEncoder.swift           // AVAssetWriter implementation
android/app/src/main/kotlin/.../
  VideoEncoder.kt               // MediaCodec implementation
assets/
  devices/
    iphone_15/
      bezel.png
      spec.json
```

---

## 6. Key Risks & Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Native encoder platform-channel work is genuinely complex (buffer formats, timing/PTS management) | Could blow the Phase 2 timeline | Timebox a spike early in Phase 2 to prove out a minimal "10 solid-color frames → valid MP4" pipeline before building the full feature around it |
| Frame-capture-then-encode loses real-time performance if not pipelined | Export takes too long, feels broken | Decouple capture from encode with a bounded queue; don't block UI thread; show real progress |
| Bezel/screen-cutout misalignment per device | Mockups look "off," undermines the core value prop | Build the spec.json + a small internal calibration tool that overlays a test grid so exact screen-rect coordinates can be verified per device before shipping |
| Audio muxing adds real complexity to native encoder work | Scope creep in Phase 2 | Explicitly decide up front whether v2 ships silent-video-only, and treat audio as a fast-follow if needed |
| `flutter_scene` for Phase 4 remains unstable indefinitely | Phase 4 never becomes viable | Not a blocker — Phases 1–3 are a complete, shippable product without it |

---

## 7. Out of Scope (for now)

- Web export (video encoding story on web is a separate design problem — MediaRecorder API vs current native-channel approach don't share code).
- Multi-device "scene" compositions (several phones arranged together) — nice future feature, not needed for MVP value prop.
- Cloud/server-side rendering — revisit only if native on-device performance proves insufficient for longer video exports.
