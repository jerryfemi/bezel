# Device Mockup Studio — Technical Direction & Implementation Plan

> This document is the current source of truth for the next architectural/design phase of Device Mockup Studio.
>
> It consolidates the existing product plan, the design system, the ContextCore discussion, and the decision to investigate real 3D device rendering with `flutter_scene`.
>
> **Animation / Cinema Mode is intentionally excluded from implementation scope for now.** The architecture should leave room for it later, but no timeline/keyframe system should be built in this phase.

---

# 1. Product Definition

## What the product is

Device Mockup Studio is a browser-based creative tool for developers and designers.

A user uploads an app screenshot or screen recording, chooses a device, adjusts its presentation, and exports a polished mockup.

The core promise is:

> Turn a raw app screenshot or screen recording into presentation-ready device imagery without requiring Photoshop, Figma, After Effects, or a 3D application.

The output should feel like a **real physical device in space**, rather than a screenshot pasted into a flat frame.

Primary use cases:

- App portfolio screenshots
- LinkedIn / X / social posts
- Product launch graphics
- App landing pages
- Product presentations
- App Store / marketing imagery
- Short device showcase videos

---

# 2. Important Product Direction Change

The original implementation plan was designed around fake 3D:

- transparent PNG/WebP device bezels
- Flutter `Matrix4`
- `RenderRepaintBoundary.toImage()`
- FFmpeg WASM for video export

That remains a valid fallback and useful reference implementation.

However, the product now has a stronger target:

> **Use actual 3D device models when technically viable.**

The reason is visual fidelity.

A 2D bezel transformed with `Matrix4` can simulate perspective, but it cannot create actual geometry. At stronger angles, there is no physical side thickness, back geometry, buttons, camera bump geometry, or physically correct lighting.

A real GLB/glTF device model provides:

- actual side thickness
- real geometry
- realistic perspective
- physical device edges
- material/roughness information
- lighting interaction
- proper rotation through arbitrary angles
- a much stronger foundation for future motion design

This means the rendering layer should be designed as a **3D scene renderer**, not as a widget containing a transformed PNG.

---

# 3. `flutter_scene` Direction

The current direction is to prototype `flutter_scene` and adopt it as the primary renderer if the proof-of-concept passes the required tests.

Current `flutter_scene` documentation describes:

- GLB/glTF runtime import
- PBR materials
- image-based lighting
- directional/point/spot lights
- shadows
- post-processing
- WebGL2 backend on Web
- Flutter `SceneView`
- render-target control
- synchronous frame capture as `ui.Image`

This is particularly relevant because the earlier concern was that a 3D renderer might not be capturable for export.

The current package documentation explicitly lists frame capture as `ui.Image`, which makes the export architecture significantly more promising than originally assumed.

However:

- `flutter_scene` is still pre-1.0
- it evolves quickly
- minor releases may contain breaking changes
- it depends on Flutter GPU
- Flutter GPU has not shipped to the stable channel
- current `flutter_scene` documentation therefore requires Flutter master
- Web uses the package's own WebGL2 backend
- Web is supported under both CanvasKit and Skwasm

At the time of writing, pub.dev lists `flutter_scene` 0.20.0.

**Do not blindly migrate the production project before the renderer POC succeeds.**

---

# 4. Flutter Channel Decision

The project may need to move from Flutter stable to Flutter master if the selected `flutter_scene` version requires it.

Do not treat this as a casual dependency addition.

Before migration:

1. Record the current Flutter/Dart version.
2. Create a dedicated git branch.
3. Record the current working stable revision.
4. Switch to the required Flutter master revision.
5. Run the existing application.
6. Run the complete existing test/build flow.
7. Verify Flutter Web build.
8. Verify existing packages still resolve.
9. Only then add `flutter_scene`.

The exact Flutter revision must be determined from the `flutter_scene` version selected at implementation time.

Do not hard-code an old master revision from an earlier plan.

---

# 5. The Critical Renderer POC

Before redesigning the entire application around 3D, build a minimal isolated proof-of-concept.

## POC requirements

The POC must prove:

```text
Flutter Web
    ↓
flutter_scene
    ↓
Load GLB
    ↓
Render real device geometry
    ↓
Identify screen mesh/material
    ↓
Apply a user screenshot as the screen texture
    ↓
Rotate device
    ↓
Move camera
    ↓
Render WebGL2
    ↓
Capture frame as ui.Image
    ↓
Encode PNG
```

Then test the same rendered scene at multiple resolutions.

### Required tests

- GLB loads successfully
- Device looks correct
- Screen material can be identified
- Screenshot can replace screen content
- Screenshot maintains correct UV mapping
- Device can rotate freely
- Camera can be controlled independently
- Lighting works
- Transparent/controlled background behavior works
- Frame capture returns a valid `ui.Image`
- Captured image contains the actual 3D device
- PNG export is correct
- Repeated capture does not leak GPU/memory resources
- Web performance is acceptable
- Chrome works
- Edge works
- A second WebGL2-capable browser is tested if practical

### Do not proceed to full migration until:

**GLB → screen texture → 3D render → frame capture → PNG**

works reliably.

---

# 6. New Architectural Principle

The biggest architectural change is:

> **The application state describes the scene. The renderer decides how to render the scene.**

Do not let Flutter widgets own the rendering state.

Do not make `Matrix4` part of the domain model.

Do not make `RepaintBoundary` the fundamental export abstraction.

Those are implementation details.

---

# 7. Proposed Architecture

```text
                         MockupProject
                              |
                              v
                        Scene / Project State
                              |
                              v
                       MockupSceneState
                              |
                +-------------+-------------+
                |                           |
                v                           v
        Preview Renderer              Export Renderer
                |                           |
                v                           v
        flutter_scene / 3D             render frame
                |                           |
                +-------------+-------------+
                              |
                              v
                         Frame/Image
                              |
                    +---------+---------+
                    |                   |
                    v                   v
                   PNG              FFmpeg WASM
                                       |
                                      MP4
```

The key separation is:

### Domain state

What the user wants.

### Renderer

How the scene is drawn.

### Exporter

How rendered frames become files.

---

# 8. Core Domain Model

The domain should represent a mockup scene without knowing anything about Flutter widgets or `Matrix4`.

Conceptually:

```dart
class MockupProject {
  final DeviceConfig device;
  final MediaSource media;
  final DeviceTransform deviceTransform;
  final CameraState camera;
  final BackgroundConfig background;
  final LightingConfig lighting;
  final ExportConfig export;
}
```

---

# 9. Device Transform

The device's transform should be represented independently from rendering.

```dart
class DeviceTransform {
  final Vector3 position;
  final Vector3 rotation;
  final double scale;
}
```

Depending on the chosen math representation, use Euler angles or quaternions internally.

The important architectural rule:

> The domain does not know about `Matrix4`.

The 3D renderer converts domain state into its own scene-node transform.

---

# 10. Camera State

Camera is not the same thing as device rotation.

This distinction matters.

## Device rotation

The phone itself rotates.

Examples:

- front
- slight left
- slight right
- 3/4 view
- side view

## Camera movement

The camera moves around the device or changes optical properties.

Examples:

- move closer
- move farther away
- move upward
- move downward
- orbit
- change perspective/FOV

The current product does not need to expose all of this immediately, but the architecture should preserve the distinction.

Conceptually:

```dart
class CameraState {
  final Vector3 position;
  final Vector3 rotation;
  final double fieldOfView;
}
```

Do not implement a simple user-facing "zoom" as a domain-level scale mutation if the desired visual behavior is actually a camera move.

The UI can still call it "Zoom".

---

# 11. Why This Matters

With fake 3D:

```text
User
 ↓
Matrix4
 ↓
Flutter transform
 ↓
RepaintBoundary
```

With real 3D:

```text
User
 ↓
Scene state
 ↓
3D renderer
 ↓
Camera/device transforms
 ↓
GPU
```

The second architecture is much better for the long-term product.

The rotation dial can continue to manipulate the same conceptual state.

The renderer changes; the interaction model does not.

---

# 12. Device Asset Architecture

A device should not be represented only by a file path.

Each device should have metadata describing its 3D model.

Example:

```text
assets/
  devices/
    iphone_15/
      model.glb
      spec.json
```

Possible metadata:

```json
{
  "id": "iphone_15",
  "name": "iPhone 15",
  "model": "model.glb",
  "screenMaterial": "Screen",
  "defaultCamera": {
    "distance": 4.2,
    "fieldOfView": 35
  }
}
```

The exact schema should be finalized after inspecting the first production-quality GLB.

---

# 13. Screen Material Is Critical

The most important property of a device model is not merely that it looks like an iPhone.

The model must have a usable screen surface.

Ideal model:

```text
iPhone.glb
|
+-- Body
+-- Glass
+-- Buttons
+-- Camera
+-- Screen
       ^
       |
   user content
```

The screen must be:

- identifiable
- correctly UV mapped
- large enough for the source content
- compatible with runtime texture replacement

If the screen cannot reliably receive dynamic content, the model may be unsuitable for the product even if it looks beautiful.

---

# 14. Device Asset Selection Criteria

Do not accept a model merely because it looks good in a GLB viewer.

Evaluate:

1. Commercial licensing
2. GLB/glTF compatibility
3. Screen mesh/material accessibility
4. UV quality
5. Mesh quality
6. Polygon count
7. Texture resolution
8. Material quality
9. Scale/orientation
10. Camera/coordinate conventions
11. Whether the model includes unnecessary geometry
12. Whether it performs well in WebGL2

For a device mockup application, a well-structured medium-complexity model is usually preferable to a gigantic photorealistic mesh.

---

# 15. Renderer Abstraction

Introduce an explicit renderer boundary.

```dart
abstract interface class MockupRenderer {
  Widget buildPreview(MockupProject project);

  Future<RenderedFrame> renderFrame(
    MockupProject project,
    RenderFrameRequest request,
  );
}
```

The exact API can be adapted to `flutter_scene`.

The important point is the separation.

Potential implementations:

```text
MockupRenderer
|
+-- Scene3DRenderer
|     |
|     +-- flutter_scene
|
+-- Fake3DRenderer
      |
      +-- legacy Matrix4 implementation
```

The fake renderer does not need to remain the primary path, but keeping the abstraction makes rollback and experimentation much safer.

---

# 16. Do Not Over-Abstract Too Early

Do not create an elaborate generic rendering framework.

For the first implementation, the renderer boundary only needs to isolate:

- scene construction
- model loading
- texture binding
- camera
- device transform
- lighting
- frame capture

The rest of the application should remain ordinary Flutter.

---

# 17. Editor UI Architecture

The UI remains Flutter.

Only the mockup viewport becomes a specialized 3D rendering surface.

```text
EditorScreen
|
+-- StudioTopBar
|
+-- StudioToolRail
|
+-- MockupViewport
|     |
|     +-- Scene3DRenderer
|
+-- InspectorPanel
|
+-- FloatingCanvasControls
```

The Flutter UI should not know how the GLB is internally rendered.

---

# 18. State Management

Continue using Riverpod.

Suggested conceptual providers:

```text
mockupProjectProvider
sceneStateProvider
selectedToolProvider
selectedDeviceProvider
mediaProvider
cameraStateProvider
exportStateProvider
```

Avoid making the renderer itself the source of truth.

The scene renderer should reflect application state.

The application state should not depend on querying the renderer every frame.

---

# 19. Rendering State vs UI State

Keep these separate.

## Rendering state

- device
- device transform
- camera
- background
- lighting
- screen content
- render resolution

## UI state

- selected tool
- open inspector
- selected control
- hover/focus
- dialogs
- export progress
- import progress

This prevents UI changes from accidentally becoming part of the exported mockup.

---

# 20. Export Architecture

Export must be treated as its own subsystem.

Do not assume:

```dart
RepaintBoundary.toImage()
```

is the universal solution.

For the 3D renderer, use the rendering/capture capabilities exposed by `flutter_scene`.

The current package documentation explicitly lists render-target control and synchronous frame capture as `ui.Image`.

The desired pipeline is:

```text
MockupProject
     ↓
RenderFrameRequest
     ↓
Scene3DRenderer
     ↓
flutter_scene render target
     ↓
ui.Image
     ↓
PNG encoder
```

For video:

```text
Source video
     +
MockupProject
     ↓
For each frame:
     ↓
Update screen texture
     ↓
Render 3D scene
     ↓
Capture frame
     ↓
RGBA/PNG frame
     ↓
FFmpeg WASM
     ↓
MP4
```

---

# 21. Important Export Rule

Do not make preview rendering and export rendering share UI widgets.

They should share **scene state**.

Preview:

```text
Scene state
 ↓
live GPU rendering
 ↓
interactive viewport
```

Export:

```text
Scene state
 ↓
controlled render target
 ↓
frame capture
 ↓
file
```

This allows export resolution to differ from preview resolution.

---

# 22. Export Resolution

The user should be able to choose output resolution independently from the editor viewport.

Example:

```text
Preview:
1440 × 900

Export:
1080 × 1920
1920 × 1080
2048 × 2048
custom
```

Do not use the browser viewport dimensions as the source of truth for export.

The renderer should accept an explicit render size.

---

# 23. Video Export

Keep FFmpeg WASM as the likely browser-side encoding layer unless a better solution is proven.

The renderer generates frames.

FFmpeg encodes them.

```text
3D renderer
   ↓
frame capture
   ↓
bounded frame queue
   ↓
FFmpeg WASM
   ↓
MP4
```

Do not make the renderer responsible for video encoding.

---

# 24. Frame Pipeline

Avoid unbounded frame buffering.

Use a bounded producer/consumer design:

```text
Renderer
   ↓
Frame Queue
   ↓
Encoder
```

The renderer should not generate thousands of frames into memory before encoding begins.

Export should:

- show progress
- avoid blocking the editor unnecessarily
- release frame resources
- clean up temporary buffers
- fail gracefully

---

# 25. Image Export

Image export should support:

- PNG
- transparent background where applicable
- explicit resolution
- high-quality rendering
- deterministic output

The exact transparent-background behavior must be tested with the selected `flutter_scene` WebGL2 backend.

Do not assume transparency works simply because the preview appears correct.

---

# 26. Video Screen Content

For a screenshot:

```text
image → screen material
```

For a video:

```text
video frame → screen material
```

The source media should not be permanently baked into the GLB.

The device model is reusable.

The user's content is dynamic.

This is one of the main reasons the model needs a dedicated screen material.

---

# 27. Background System

The background remains separate from the device model.

Support eventually:

- solid color
- gradient
- uploaded image
- potentially environment lighting/background

Do not confuse:

```text
visual background
```

with:

```text
3D environment lighting
```

They may be related, but they are separate concepts.

A background image may be the visible canvas while an HDR/environment map provides realistic device lighting.

---

# 28. Lighting

Real 3D allows the mockup to get depth from actual lighting rather than fake shadow/reflection layers.

Initial lighting should remain simple.

Recommended starting point:

- controlled studio environment
- one primary key light if necessary
- subtle fill
- soft shadow
- no excessive bloom
- no dramatic post-processing by default

The product is a mockup generator, not a game engine.

The renderer should prioritize:

- clean device edges
- readable screen
- realistic materials
- believable shadow
- predictable output

---

# 29. Visual Design System

The UI design system remains the source of truth.

The product philosophy is:

> **Confident Restraint**

The tool exists to make the user's mockup look expensive.

Therefore:

> The mockup is allowed to be loud. The UI stays quiet.

The complexity belongs in the rendering, not the interface.

---

# 30. Color System

Recommended Option A:

```text
Canvas:          #0B0C0E
Surface:         #16181C
Surface Raised:  #1E2126
Border:          #26292E
Primary Text:    #F5F1E8
Secondary Text:  #9A9791
Accent:          #4DE8C4
Danger:          #E8664D
```

Accent usage must remain sparse.

Use the phosphor teal for:

- primary actions
- active tools
- focused controls
- rotation readouts
- important state

Do not introduce the ContextCore hyper-blue as a competing brand color.

---

# 31. ContextCore Inspiration

ContextCore is a reference for:

- precision
- hierarchy
- information density
- alignment
- restrained borders
- technical sophistication
- avoiding generic Material UI
- deliberate spacing

Do NOT copy:

- ContextCore's brand palette
- its exact typography
- its exact component shapes
- its dashboard metaphor
- its visual identity

The product should remain a **creative editor**, not a technical dashboard.

---

# 32. Typography

Use:

### Space Grotesk

For:

- major headings
- landing page hero
- empty states
- major screen titles

### Inter

For:

- buttons
- labels
- menus
- inspector text
- body copy
- normal UI

### IBM Plex Mono

Only for technical/numeric information:

```text
X: 12°
Y: -8°
1920 × 1080
00:04.82
78%
```

Do not use a mono font for the entire application.

Do not introduce JetBrains Mono as the primary UI font.

---

# 33. Editor Layout

Desktop-first editor:

```text
┌─────────────────────────────────────────────────────────────┐
│ Top bar — 56px                                              │
├────────┬───────────────────────────────────────┬────────────┤
│ Rail   │                                       │ Context    │
│ 72px   │               Canvas                  │ panel      │
│        │                                       │ 280px      │
│        │            DEVICE HERO                │            │
│        │                                       │            │
└────────┴───────────────────────────────────────┴────────────┘
```

Top bar:

- 56px
- project name
- undo
- redo
- Export

Left rail:

- 72px
- icon-only
- device
- background
- media
- effects/settings as needed

Right inspector:

- 280px
- contextual
- one active tool's properties
- collapsible

The canvas should visually dominate the application.

---

# 34. UI Component Direction

Replace default Flutter/Material components that make the application feel generic.

Create reusable primitives:

```text
StudioIconButton
StudioButton
StudioSegmentedControl
StudioSlider
PanelSectionHeader
InspectorSection
FloatingToolbar
RotationDial
```

Do not style each widget independently.

Create tokens:

```text
AppColors
AppSpacing
AppRadius
AppTypography
AppTheme
```

---

# 35. Left Rail

The rail should be:

- 72px
- icon-only
- restrained
- square/subtle
- quiet

Active state:

- subtle accent border or indicator
- low-opacity accent surface
- optional tiny accent glow

Avoid:

- giant buttons
- pill navigation
- blue neon effects
- excessive glow

---

# 36. Inspector

The inspector is a professional creative-tool inspector, not a dashboard.

Example:

```text
DEVICE
────────────────

iPhone 15

Rotation

X      12°
Y      -8°

Zoom
──────●──────

Position

X       0
Y       0

Presets

[ Front ]
[ 3/4 Left ]
[ 3/4 Right ]
```

Use compact sections.

Do not make every property a large card.

---

# 37. Floating Canvas Controls

Glassmorphism is allowed only when functionally justified.

Good:

```text
Floating controls over live canvas
```

Bad:

```text
Glass top bar
Glass left rail
Glass inspector
Glass everything
```

Floating toolbar:

- translucent surface
- approximately 20px blur
- 1px subtle border
- 14px radius
- restrained shadow

The purpose is to allow controls to sit over the preview without visually destroying it.

---

# 38. Rotation Control

The rotation control is the signature interaction.

It should not be a generic slider.

Concept:

- circular dial/joystick
- approximately 120px
- floating over the canvas
- subtle glass treatment
- technical angle readout

Example:

```text
12° / -8°
```

The dial and direct device dragging must manipulate the same underlying device rotation state.

There must be one source of truth.

---

# 39. Direct Device Manipulation

The user should be able to drag the device directly.

Conceptually:

```text
Pointer drag
    ↓
DeviceTransform
    ↓
Scene3DRenderer
```

The rotation dial does:

```text
Dial drag
    ↓
DeviceTransform
    ↓
Scene3DRenderer
```

Both inputs converge on the same state.

Do not create separate rotation states for the dial and viewport.

---

# 40. Angle Presets

Initial presets:

- Front
- 3/4 Left
- 3/4 Right

Later presets can include:

- Side
- Back
- Hero
- Custom

Preset selection should modify scene state, not bypass the renderer.

---

# 41. Snapping

When manually rotating:

- if release is within approximately 5° of a known preset, magnetically snap toward it
- otherwise leave the user's exact rotation

The behavior should feel helpful, not restrictive.

Do not force snapping continuously while dragging.

---

# 42. Motion of the UI

UI animation should remain nearly invisible.

Panel transitions:

- ~120ms ease-out
- opacity + small translation

Buttons:

- ~80ms
- background/border/opacity changes

Avoid scaling UI buttons on hover.

The device itself is allowed to have visually meaningful movement because it is the content.

Respect reduced-motion preferences for decorative UI motion.

---

# 43. Spacing

Use the 4px base scale:

```text
4
8
12
16
24
32
48
64
```

Avoid arbitrary values unless technically necessary.

---

# 44. Radius

Use:

```text
Small controls: 8px
Panels/cards:   14px
Floating UI:    14px
Modals:         20px
```

Do not make everything perfectly sharp.

Do not make everything extremely rounded.

The visual language should echo real device/product geometry.

---

# 45. Accessibility

Maintain:

- visible keyboard focus
- semantic labels
- usable contrast
- keyboard navigation where practical
- reduced-motion support
- tooltips for icon-only controls

Do not use phosphor teal as small body text.

It is an accent, not a body-text color.

---

# 46. Recommended Project Structure

Suggested direction:

```text
lib/
|
+-- models/
|   +-- mockup_project.dart
|   +-- device_config.dart
|   +-- device_transform.dart
|   +-- camera_state.dart
|   +-- media_source.dart
|   +-- background_config.dart
|   +-- lighting_config.dart
|   +-- export_config.dart
|
+-- rendering/
|   +-- mockup_renderer.dart
|   +-- render_request.dart
|   +-- rendered_frame.dart
|   |
|   +-- scene3d/
|       +-- scene3d_renderer.dart
|       +-- scene_loader.dart
|       +-- device_scene.dart
|       +-- screen_material_controller.dart
|       +-- camera_controller.dart
|       +-- lighting_controller.dart
|       +-- frame_capture.dart
|
+-- export/
|   +-- image_export_service.dart
|   +-- video_export_service.dart
|   +-- frame_queue.dart
|   +-- ffmpeg_encoder.dart
|
+-- state/
|   +-- mockup_project_provider.dart
|   +-- scene_state_provider.dart
|   +-- selected_tool_provider.dart
|   +-- export_state_provider.dart
|
+-- editor/
|   +-- editor_screen.dart
|   +-- mockup_viewport.dart
|   +-- studio_top_bar.dart
|   +-- studio_tool_rail.dart
|   +-- inspector_panel.dart
|   +-- rotation_dial.dart
|   +-- floating_canvas_controls.dart
|
+-- design_system/
|   +-- app_colors.dart
|   +-- app_spacing.dart
|   +-- app_radius.dart
|   +-- app_typography.dart
|   +-- app_theme.dart
|   +-- widgets/
|
+-- devices/
|   +-- device_registry.dart
|
assets/
|
+-- devices/
    +-- iphone_15/
    |   +-- model.glb
    |   +-- spec.json
    |
    +-- android_example/
        +-- model.glb
        +-- spec.json
```

Adjust names to the existing repository rather than blindly creating duplicate structures.

---

# 47. Separation of Concerns

## UI layer

Responsible for:

- user input
- controls
- layout
- inspector
- interaction

## State layer

Responsible for:

- current project
- current device
- camera
- transform
- media
- background
- export state

## Renderer

Responsible for:

- GLB loading
- scene construction
- device transform
- camera
- lighting
- materials
- screen texture
- rendering
- frame capture

## Export

Responsible for:

- image encoding
- video frame orchestration
- FFmpeg
- progress
- file output

No layer should absorb another layer's responsibilities.

---

# 48. Performance Requirements

The editor is a WebGL-based creative tool.

Performance should be treated as a product requirement.

Initial goals:

- interactive device rotation should feel immediate
- no unnecessary widget rebuilds while dragging
- avoid rebuilding the entire editor on every scene update
- reuse loaded GLB resources
- reuse GPU textures where possible
- avoid unnecessary texture uploads
- keep device models reasonably optimized
- dispose scene resources correctly
- avoid accumulating captured frames in memory

Do not optimize prematurely, but do not build the renderer around per-frame object allocation.

---

# 49. Device Model Performance

A device model should not contain unnecessary detail.

Prefer:

```text
Good geometry
+
good materials
+
good lighting
```

over:

```text
massive geometry
+
huge textures
+
expensive effects
```

The visual goal is a convincing marketing mockup, not a forensic simulation of every component inside the phone.

---

# 50. Web-Specific Testing

Because Web is the primary platform:

Test the real WebGL2 path early.

Do not develop only against native and assume Web will behave identically.

Test:

- Chrome
- Edge
- CanvasKit
- Skwasm where practical
- low/mid/high GPU machines where available
- different viewport sizes
- device rotation
- GLB loading
- texture updates
- frame capture
- high-resolution export

The current `flutter_scene` documentation states that its WebGL2 backend works with both CanvasKit and Skwasm without extra flags, but this project should still verify the exact configuration used in production.

---

# 51. Export Validation Matrix

Before calling the 3D renderer production-ready:

| Test | Required |
|---|---|
| Screenshot → GLB screen | Yes |
| GLB rotation | Yes |
| Camera movement | Yes |
| PNG capture | Yes |
| Transparent background | Verify |
| 1080p output | Yes |
| 2K output | Verify |
| High-resolution screenshot texture | Verify |
| Video frame capture | Verify |
| MP4 encoding | Verify |
| Audio passthrough | Decide separately |
| Repeated exports | No memory leak |
| Long video | Stress test |

---

# 52. Current Scope

## Build now

### Renderer

- `flutter_scene` POC
- GLB loading
- screen material replacement
- device transforms
- camera
- basic lighting
- frame capture
- PNG export

### Editor

- device selection
- screenshot import
- video import
- device rotation
- camera/zoom controls as appropriate
- position
- background
- inspector
- rotation dial
- angle presets

### Design

- complete editor shell
- design tokens
- custom controls
- polished inspector
- canvas-dominant composition

### Export

- image export
- video export investigation
- FFmpeg WASM integration where proven viable

---

# 53. Explicitly NOT Building Yet

Do not implement:

- timeline
- keyframes
- easing editor
- Cinema Mode
- camera animation
- device animation tracks
- multi-device scenes
- cloud rendering
- native video encoders
- complex scene composition
- collaborative editing
- full 3D asset marketplace

The architecture may support these later, but they are not current scope.

---

# 54. Recommended Implementation Sequence

## Phase 0 — Protect the existing project

1. Commit current working state.
2. Create a feature branch.
3. Record Flutter/Dart versions.
4. Record current build status.
5. Preserve the existing fake-3D implementation as a fallback until 3D is proven.

---

## Phase 1 — Renderer POC

Build a tiny isolated screen.

Success criteria:

```text
GLB
 ↓
flutter_scene
 ↓
WebGL2
 ↓
screen texture
 ↓
device rotation
 ↓
camera
 ↓
ui.Image capture
 ↓
PNG
```

Do not redesign the editor during this phase.

---

## Phase 2 — Renderer Integration

Once the POC succeeds:

1. Introduce `MockupProject`.
2. Introduce `SceneState`.
3. Introduce `MockupRenderer`.
4. Implement `Scene3DRenderer`.
5. Move device transforms into scene state.
6. Move camera into scene state.
7. Connect Riverpod state.
8. Connect the existing media system.
9. Connect the inspector.

---

## Phase 3 — UI Glow-Up

Rebuild the editor shell around the design system.

Order:

1. overall composition
2. canvas
3. top bar
4. left rail
5. inspector
6. floating controls
7. rotation dial
8. individual controls
9. micro-polish

Do not redesign isolated buttons first.

---

## Phase 4 — Export

1. PNG capture
2. explicit resolution
3. transparent background tests
4. video frame capture
5. FFmpeg WASM integration
6. bounded frame queue
7. progress UI
8. memory/performance testing

---

# 55. The Agent's Working Rules

Before modifying the UI:

1. Inspect the existing editor.
2. Identify existing reusable components.
3. Identify visual inconsistencies.
4. Identify state/rendering coupling.
5. Identify existing export assumptions.
6. Do not duplicate existing architecture without reason.

Before modifying the renderer:

1. Inspect current device asset format.
2. Inspect current `Matrix4` implementation.
3. Inspect current media pipeline.
4. Inspect current export pipeline.
5. Identify where `RepaintBoundary.toImage()` is currently assumed.
6. Build the `flutter_scene` POC before deleting the old implementation.

---

# 56. Important Anti-Patterns

Do NOT:

- turn the product into a generic SaaS dashboard
- copy ContextCore's branding
- use hyper-blue as the main accent
- use JetBrains Mono throughout the UI
- introduce excessive glassmorphism
- use gradients everywhere
- use giant rounded cards
- make every control razor-thin
- use Material defaults everywhere
- make the inspector dominate the screen
- put the device inside unnecessary cards
- let UI chrome compete with the mockup
- store renderer-specific state in domain models
- put `Matrix4` into `MockupProject`
- make widgets responsible for export
- make FFmpeg responsible for rendering
- make the 3D engine responsible for application state

---

# 57. Architecture in One Sentence

> **Flutter owns the editor; Riverpod owns the project state; `flutter_scene` owns 3D rendering; the export layer owns frame capture/encoding; the device model is data; and the UI never needs to know how the device is rendered.**

---

# 58. Final Recommendation

Use real 3D as the target architecture if the POC proves:

```text
GLB
+
dynamic screen texture
+
WebGL2 preview
+
reliable frame capture
+
PNG export
```

This is the highest-value technical direction because it solves the fundamental visual limitation of the current fake-3D approach while creating a much stronger foundation for future product capabilities.

Keep the renderer behind an abstraction so the existing fake-3D implementation remains available as a fallback during migration.

Do not let the current pre-1.0 status of `flutter_scene` stop experimentation. Instead, isolate the dependency risk and test the exact Web build/export path early.

The product should ultimately feel like:

> **A focused creative tool that makes app screenshots look like premium product photography.**

Not:

> A developer dashboard with a 3D viewer attached.

---

# 59. Current External Reference

At the time this document was prepared, the current `flutter_scene` package documentation lists:

- version 0.20.0
- GLB/glTF import
- WebGL2 Web backend
- CanvasKit and Skwasm Web support
- render-target control
- synchronous frame capture as `ui.Image`
- PBR lighting/materials
- post-processing capabilities
- Flutter master requirement because Flutter GPU is not yet on stable

The agent should re-check the package documentation/changelog before upgrading dependencies because this project intentionally depends on a rapidly evolving pre-1.0 graphics stack.

---

# 60. Design Source Hierarchy

When making decisions, use this priority:

1. Product requirements
2. This implementation plan
3. Device Mockup Studio `SKILL.md`
4. Existing working application architecture
5. `flutter_scene` current documentation/API
6. ContextCore as visual inspiration only

If ContextCore conflicts with the Device Mockup Studio design system, **the Device Mockup Studio design system wins**.

If an architectural decision conflicts with the actual current `flutter_scene` API, **the actual package API wins**, and this document should be updated rather than forcing an inaccurate abstraction.

