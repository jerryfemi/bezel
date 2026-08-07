---
name: device-mockup-studio-design
description: Design system and visual identity for the device mockup generator web app (fake-3D tilt mockups for screenshots/video, à la Rotato/Previewed). Use this skill whenever writing UI code, CSS, Flutter widget styling, component markup, marketing/landing page copy, or making any visual decision (color, type, spacing, motion) for this project. Always consult before generating a new screen, component, button, panel, or page for this app, even if the user doesn't explicitly ask for "design" — this ensures visual consistency across the whole product instead of ad-hoc styling choices.
---

# Device Mockup Studio — Design System

## Design Philosophy: Confident Restraint

The product's whole job is to make a user's screenshot or video look expensive. That means **the UI's job is to disappear.** Every design decision here optimizes for one rule:

> The mockup the user is building is the only thing allowed to be loud. The tool around it stays quiet.

Concretely this means: no competing gradients fighting the device preview for attention, no decorative animation on UI chrome, minimal chrome overall, and color used sparingly enough that when it does appear (an accent, a focus ring, an active state) it actually means something.

This mirrors how the category leader positions itself — professional-grade output without professional-grade complexity in the tool itself. Complexity is allowed in the *rendering*, not in the *interface*.

---

## Color System

Two viable directions. **Recommendation: Option A**, since it extends an identity already established across other shipped projects (portfolio site, GlideMenu, etc.) — cross-project consistency compounds into a recognizable personal brand over time.

### Option A — Brand-Consistent (recommended)

Extends the existing near-black / warm-ivory / phosphor-teal identity into a tool context.

| Token | Hex | Use |
|---|---|---|
| `canvas` | `#0B0C0E` | App background. Warm-tinted near-black, not pure black — pure `#000000` reads as a placeholder/unfinished, not intentional. |
| `surface` | `#16181C` | Panels, toolbars, cards |
| `surface-raised` | `#1E2126` | Modals, dropdowns, anything floating above surface |
| `border` | `#26292E` | Hairline dividers, 1px panel edges |
| `border-active` | `accent @ 35% opacity` | Focused input/panel edges — use opacity, not a flat second color |
| `text-primary` | `#F5F1E8` | Warm ivory, not pure white — pure white on near-black is harsher than needed for long editing sessions |
| `text-secondary` | `#9A9791` | Labels, captions, disabled states |
| `accent` | `#4DE8C4` | Phosphor teal — reserved for primary actions, active tool states, the rotation-angle readout, focus glow |
| `accent-glow` | `accent @ 12% opacity, 24px blur` | Micro-glow behind active elements only — restrained, not everywhere |
| `danger` | `#E8664D` | Destructive actions, export failures — same saturation/lightness curve as accent so it doesn't feel like a different design language |

### Option B — Distinct Product Identity

If you'd rather this project have its own visual voice separate from the portfolio (defensible if you ever want to position/sell it as a standalone SaaS brand, not "a FlutterGuy project"):

| Token | Hex | Use |
|---|---|---|
| `canvas` | `#0A0A0F` | Cool near-black, faint violet undertone — reinforces "device in space" concept |
| `surface` | `#15151D` | Panels |
| `accent` | `#5B8DFF` | Electric blue — cooler, more "glass and motion" than teal |
| `accent-secondary` | `#8B5CF6` | Violet, used only in gradients paired with accent, never alone |

**Rule either way:** never introduce a third hue. Current guidance in premium tool design is to push one accent hard rather than juggle several — a monochrome-plus-one-accent system reads as more expensive than a "colorful" one.

---

## Typography

Reuses the established stack, which already happens to match current best practice (variable fonts, one display face + one workhorse face + one mono face):

- **Display / Headings:** Space Grotesk (variable) — used for the landing page hero, section headers, empty states. Never for UI labels or body text.
- **UI / Body:** Inter (variable) — every button label, input, menu item, paragraph of copy.
- **Numeric / Technical:** IBM Plex Mono — resolution values, rotation-angle readout (e.g. `X: 12° Y: -8°`), export progress percentages, timecodes on the video scrubber. Use **tabular figures** so numbers don't jitter as they update in real time.

### Type Scale

| Token | Size / Line-height | Weight | Use |
|---|---|---|---|
| `display` | 40px / 1.1 | 600 | Landing hero only |
| `h1` | 28px / 1.2 | 600 | Screen titles |
| `h2` | 20px / 1.3 | 600 | Panel section headers |
| `body` | 15px / 1.5 | 400 | Default UI text |
| `label` | 13px / 1.4 | 500, uppercase, +0.02em tracking | Field labels, tab names |
| `mono-readout` | 13px / 1.4 | 500, tabular-nums | Angle/coordinate/timecode values |
| `caption` | 12px / 1.4 | 400 | Helper text, tooltips |

Avoid more than 3 weights in the whole app (400 / 500 / 600). Variable fonts make it tempting to use fine-grained weight differences — resist it, it reads as inconsistency rather than nuance at this scale.

---

## Layout: The Editor Screen

The core screen is a **canvas-dominant** layout — the device preview is the largest thing on screen at all times, never competing with panel chrome for space.

```
┌─────────────────────────────────────────────────────────┐
│  Top bar: project name · undo/redo · Export button       │  56px
├───────────┬───────────────────────────────┬─────────────┤
│           │                                 │             │
│  Left     │                                 │   Right     │
│  rail     │        Device preview           │   panel     │
│  (tools:  │        (dominant, ~70%          │   (context- │
│  device,  │         of viewport)            │   sensitive:│
│  bg,      │                                 │   device    │
│  export)  │                                 │   props /   │
│  72px     │                                 │   bg props) │
│           │                                 │   280px     │
├───────────┴───────────────────────────────┴─────────────┤
│  Bottom (Phase 3 only): keyframe timeline scrubber        │  64px
└─────────────────────────────────────────────────────────┘
```

- **Left rail:** icon-only, 72px wide, no labels (tooltips on hover). Tool switching, not property editing.
- **Right panel:** collapsible. Whatever tool is active in the left rail determines its content. Never more than one panel open at once — no accordion stacks.
- **Floating toolbar over canvas** (angle presets — front/3-quarter-left/3-quarter-right): this is the one place to use the glass treatment below, since it needs to float over the preview without fully occluding it.

---

## Depth & Glass Treatment (used sparingly, on purpose)

Glassmorphism only earns its place where it's functionally necessary — floating an element over the live preview without hiding it. Do **not** apply it to the left rail, right panel, or top bar; those are opaque surfaces sitting *beside* the canvas, not floating over it, so blur there would be decoration with no purpose.

```css
.floating-toolbar {
  background: rgba(22, 24, 28, 0.65);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(245, 241, 232, 0.08);
  border-radius: 14px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
}
```

For elevation elsewhere (panels, cards), prefer a **1px border + very soft shadow** over heavier drop shadows — flatter, more current, and cheaper to render at scale.

---

## The Rotation Control (the one truly custom component)

This is the single most important UI element in the app — it's the interaction that sells the whole product. Do not build it as a generic slider.

- A circular dial/joystick control, roughly 120px diameter, sitting bottom-center over the canvas (semi-transparent, glass-treated per above).
- Dragging inside it maps directly to the same `rotationX`/`rotationY` the canvas gesture already produces — the dial and direct canvas-drag should always be in sync, two inputs for the same state.
- The live angle readout (mono font, tabular figures) sits just above or inside the dial center: `12° / -8°`.
- On release, ease back toward the nearest angle preset only if the user is within ~5° of one (magnetic snap) — otherwise leave it exactly where they dropped it. Snapping should feel like a helpful suggestion, not a fight for control.

---

## Motion Principles

The product's actual animated content (the rotating device) is the star. UI chrome motion should be nearly silent by comparison:

- Panel open/close: 120ms ease-out, opacity + 4px slide. No bounce, no overshoot.
- Button/hover states: 80ms, opacity/background only — no scale transforms on buttons (scale transforms compete visually with the device tilt, which is the one place scale/rotation should draw the eye).
- Respect `prefers-reduced-motion` — disable panel slide transitions, keep the core mockup tilt interaction itself (that's content, not decoration, so it stays).

---

## Spacing & Radius Scale

4px base grid: `4 · 8 · 12 · 16 · 24 · 32 · 48 · 64`.

Corner radius intentionally echoes real device bezel radii rather than generic "rounded corners":
- Small controls (buttons, inputs): `8px`
- Panels/cards: `14px`
- Floating toolbar: `14px`
- Modal: `20px`

---

## Accessibility Notes

- Text-primary (`#F5F1E8`) on canvas (`#0B0C0E`) exceeds WCAG AA for body text — verify any new color pairing against this baseline before shipping it.
- Accent (`#4DE8C4`) on canvas passes for large text/icons but is borderline for small text — never use accent color as body copy color, only for icons, borders, and large numerals.
- All interactive elements need a visible focus state independent of hover (keyboard users don't hover) — use `border-active` token, not just a color shift.

---

## Voice, for landing page / marketing copy

Short, outcome-first, no jargon — mirrors the "professional-grade visuals without professional-grade complexity" positioning that works for this category. Lead with what the output looks like, not how the tool works. Avoid words like "revolutionary," "seamless," "powerful" — show the mockup, let it do the talking.
