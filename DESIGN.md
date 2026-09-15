---
name: Frontile
description: Accessible, Glint-typed Ember.js components on a semantic token system that inverts per subtree.
colors:
  primary-subtle: "#f1fdfc"
  primary-muted: "#c6f5f4"
  primary-mild: "#26a0aa"
  primary: "#076873"
  primary-firm: "#01525c"
  primary-strong: "#003138"
  primary-bolder: "#00262c"
  secondary-subtle: "#fff3e9"
  secondary-mild: "#ffb686"
  secondary: "#ff914d"
  secondary-strong: "#d95503"
  tertiary: "#f17bad"
  tertiary-strong: "#c10566"
  neutral-subtle: "#f8f8f8"
  neutral-muted: "#ececec"
  neutral-soft: "#dddcdc"
  neutral-mild: "#c9c8c7"
  neutral: "#94918f"
  neutral-firm: "#554f4b"
  neutral-strong: "#39332e"
  neutral-bolder: "#241c17"
  success: "#a3fa3a"
  warning: "#ff914d"
  danger: "#e51701"
  surface-app: "#ffffff"
  surface-canvas: "#f8f8f8"
  surface-app-dark: "#000000"
  surface-canvas-dark: "#140b06"
typography:
  display:
    fontFamily: "Domine, Georgia, 'Times New Roman', serif"
    fontSize: "var(--text-marquee-2xl)"
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: "0"
  headline:
    fontFamily: "'Open Sans', system-ui, -apple-system, 'Segoe UI', sans-serif"
    fontSize: "var(--text-header-2xl)"
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: "-0.03125rem"
  title:
    fontFamily: "'Open Sans', system-ui, sans-serif"
    fontSize: "var(--text-header-md)"
    fontWeight: 700
    lineHeight: 1.4
  body:
    fontFamily: "'Open Sans', system-ui, sans-serif"
    fontSize: "var(--text-body-md)"
    fontWeight: 400
    lineHeight: 1.5
  label:
    fontFamily: "'Open Sans', system-ui, sans-serif"
    fontSize: "var(--text-label-xs)"
    fontWeight: 600
    lineHeight: 1
  code:
    fontFamily: "'Source Code Pro', ui-monospace, 'SFMono-Regular', Menlo, monospace"
    fontSize: "var(--text-code-md)"
    fontWeight: 400
    lineHeight: 1.5
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.surface-app}"
  button-primary-hover:
    backgroundColor: "{colors.primary-firm}"
  surface-card:
    backgroundColor: "{colors.surface-app}"
    textColor: "{colors.neutral-firm}"
---

# Design System: Frontile

## Overview

Frontile's visual system is a **semantic token system, not a palette**. Its distinguishing
property is that nothing in a component names a color, a size, or a weight directly: every
component resolves its appearance through role tokens (`primary`, `neutral`, `surface-*`) at
named levels, and through seven typographic roles. The consequence is the system's most
valuable and least advertised trait — **an entire subtree can be inverted to the opposite
theme by adding one class**, because the tokens are CSS custom properties scoped by selector
rather than by media query.

The character is quiet and workmanlike rather than expressive. Teal at low chroma carries
interaction; a warm-leaning gray family (not a blue-gray) carries everything else, which
gives light surfaces a paper-ish cast and dark surfaces a slightly warm black. This is a
system built to disappear underneath a consuming product's own brand — its restraint is a
feature, since every consumer is expected to override it.

**Key characteristics:**

- Role-and-level naming (`subtle` → `bolder`), never a numbered scale.
- Every foreground has a generated `on-*` counterpart guaranteeing WCAG contrast.
- Light and dark are peers, defined side by side; neither is the "real" theme.
- Any subtree can hold the opposite theme via `.theme-inverse`.
- Seven type roles on one 1.067 typescale, so scale steps are small and deliberate.

## Colors

Low-chroma teal for interaction, a warm neutral family for structure, and four status hues
that are used **only** when they mean what they say.

### Primary
- **Deep Teal** (`#076873`, DEFAULT): the resting interactive fill — primary buttons, links,
  focus, selected state. Levels run `subtle` `#f1fdfc` → `bolder` `#00262c`; in dark mode the
  ramp inverts so `strong` becomes the *lightest* teal.

### Secondary
- **Warm Orange** (`#ff914d`): a secondary accent, deliberately warm against the teal. Used
  sparingly; at `subtle`/`muted` levels it is a tint, and at DEFAULT it is loud enough to own
  a region — which means it must be chosen, not sprinkled.

### Neutral
- **Warm Gray** (`#94918f` DEFAULT, `#f8f8f8` subtle → `#241c17` bolder): all text,
  borders, and dividers. Notably warm — `neutral-bolder` is `#241c17`, a near-black brown,
  not a blue-black.

### Status
- **Success** `#a3fa3a`, **Warning** `#ff914d`, **Danger** `#e51701`. Semantic only. Note
  that light-theme `success` and `warning` are high-chroma and light, so text on them needs
  the generated `on-*` ink rather than white.

### Surfaces
- `surface-app` (page ground: white / black), `surface-canvas` (recessed band: `#f8f8f8` /
  `#140b06`), plus `surface-overlay-*` and `surface-lift-*` translucent families for veils and
  scrims. `surface-overlay-strong` is the modal backdrop.

### Named Rules

**The No-Literal-Color Rule.** A hardcoded color value on any Frontile surface is a defect.
If a value is needed that no token provides, the token set is wrong — fix the token, don't
inline the hex. Two sanctioned exceptions: a demonstration that is *about* palettes, where
ramp values are the subject matter; and a surface that must defy the scheme, which earns a
named token of its own rather than scattered literals (the site's `--color-code-*` family
exists because the site's code windows are pinned to Shiki's dark token set).

**The Ramps Invert Rule.** In dark mode the neutral and accent ramps run the other way:
`neutral-bolder` is the lightest neutral, and `primary-bolder` is the lightest teal. A token
chosen for its name rather than checked in both schemes will invert on you — a code panel
built on `neutral-bolder` renders as a white slab on a dark page. Always verify both.

**The On-Color Rule.** Never pair a hand-picked ink with a semantic background. Every
category/level has a generated `on-<category>-<level>` guaranteed to meet contrast, and it is
derived from *that* ramp — so if you override a ramp's values you must override its `on-*`
values too, or the old ink stays and contrast silently breaks.

**The Status-Means-Status Rule.** `success`, `warning`, and `danger` communicate state. Using
`warning` to color-code a category, or `success` to make a section feel green, destroys the
only signal these hues carry. Decorative category coding is prohibited. The narrow exception
is *illustration* — the traffic-light dots on the site's code window depict a window's
controls and report no state; they are `aria-hidden` and never the sole carrier of meaning.

## Typography

**Display Font:** Domine (with Georgia, 'Times New Roman', serif) — bundled variable font.
**Body/UI Font:** Open Sans (with system-ui, -apple-system, 'Segoe UI') — bundled variable.
**Code Font:** Source Code Pro (with ui-monospace, SFMono-Regular, Menlo) — expected from the
consuming app, falls back to the platform mono.

**Character:** A transitional serif with strong, stubby serifs against a humanist sans. The
pairing reads institutional rather than fashionable — Domine gives titles weight without
elegance-signalling, and Open Sans keeps dense UI legible at small sizes.

### Hierarchy

Applied as two classes: the role's family (`font-marquee`) plus the role's step
(`text-marquee-2xl`). All seven roles sit on one 1.067 typescale, so adjacent steps are
close and jumps must be deliberate.

- **marquee** (Domine, 600): the only display role. `2xs`–`3xl`. Leading tightens to 1.2 at
  `lg` and above. Page and part titles only.
- **header** (Open Sans, 700, tracking −0.5px at `md`+): section and card titles. `4xs`–`3xl`.
- **strong** (Open Sans, 700): shares header's size matrix; for numerics, counts, and prices
  where emphasis is quantitative rather than hierarchical.
- **body** (Open Sans, 400, leading 1.5): running text. `pico`–`xl`. Keep measure 65–75ch.
- **label** (Open Sans, 600, leading 1.0): control labels, chips, table headers, badges.
- **caption** (Open Sans, 400, tracking +1px): captions and fine print.
- **code** (Source Code Pro, 400): `sm` and `md` only. Code, data, and measurement — never
  as a costume for "technical".

### Named Rules

**The Two-Class Rule.** Type is always `font-<role>` + `text-<role>-<size>`. A bare
`text-lg` or `font-bold` bypasses the system and breaks the role's tracking and leading.

**The One-Marquee Rule.** Marquee is a display role, not a heading level. A surface gets one
marquee moment; everything below it is `header`.

## Layout

Content sits in a centered container, typically `max-w-7xl` with `px-4 sm:px-6 lg:px-8`;
reading-width passages narrow to `max-w-4xl` or tighter. Vertical rhythm is section-scale:
bands of `py-24` on desktop separated by a change of surface (`surface-app` ↔
`surface-canvas`), so structure is communicated by ground color rather than by rules. Spacing
within a band follows Tailwind's default scale; grouped elements sit at `gap-2`/`gap-3` and
unrelated blocks at `gap-6`/`gap-8`. More space above a heading than below it.

Breakpoints are Tailwind's defaults, mobile-first. Grids collapse `lg:grid-cols-3` →
`md:grid-cols-2` → single column. Dark and light are both first-class at every breakpoint.

## Elevation & Depth

**Predominantly tonal, not shadowed.** Depth comes from surface steps and translucent
overlay/lift families rather than from drop shadows: a card is distinguished by
`surface-card` against `surface-canvas`, and in dark mode `card` is deliberately a 7% white
veil rather than an opaque step, so stacked surfaces read as translucency over a single
ground. Shadows exist for genuinely floating layers only — popovers, dropdowns, modals,
drawers.

### Named Rules

**The Veil-Not-Lift Rule.** In dark mode, layering is achieved by translucency over the
ground, not by lightening a solid fill. Adding an opaque gray card in dark mode breaks the
depth model.

**The No-Halo Rule.** A zero-offset colored glow is decoration, not depth. Shadows carry a
real offset and a soft blur, or they are absent.

## Shapes

Rounded-rectangle language throughout, with radius signalling scale: controls and inputs take
small-to-medium radii, cards and code panels take `rounded-xl`, and avatars/spinners are fully
round. Borders are hairline — 1px, in a neutral level one or two steps from the surface. A
colored left- or right-border thicker than 1px is not part of this language.

## Iconography

Frontile ships no icon set. The docs site draws from **Lucide** via `unplugin-icons`
(`~icons/lucide/*`), wrapped once in `site/app/components/icons.gts` so every glyph shares one
stroke weight and accepts `class` and ARIA attributes. Hand-rolled SVG paths are not the
house style; add to that module rather than inlining a new path.

## Components

Everything is styled with Tailwind Variants through `@frontile/theme`'s `useStyles()`, exposed
per-component as slots. Two rules follow from that:

- **`@classes` is the extension point.** Consumers override per-slot; components merge with
  the theme's classes and resolve conflicts. Styling a Frontile component with a wrapper
  selector or plain CSS is working against the system.
- **Variants are named, not ad hoc.** `@color` (`neutral` | `primary` | `secondary` |
  `tertiary` | `success` | `warning` | `danger`), `@variant` (`solid` | `soft` | `subtle` |
  `outline` | `ghost` | `plain` | `custom`), and `@size` (`xs`–`2xl`). Feedback surfaces
  (Alert, form feedback) take `@status` instead of `@color`.
- **`@intent` and `@appearance` are deprecated.** v0.18 renamed them to `@color` and
  `@variant`, and renamed their values with them: `intent="default"` is `color="neutral"`,
  `appearance="default"` is `variant="solid"`, `outlined` is `outline`, and `minimal` is
  `plain`. The old names still resolve, so a call site using them is stale rather than
  broken — but new work should not add more.

Form controls own their labelling: `Checkbox`, `Switch`, `Radio`, `Input`, `Textarea`, and
`Select` take `@label` (via `FormControlSharedArgs`) and render the `<label>` element and its
association themselves. **A form control's label passed as block content is silently dropped**
— it renders an unlabelled control. Use `@label`.

## Do's and Don'ts

**Do**
- Compose from Frontile components on Frontile's own surfaces; the site is the proof.
- Use `.theme-inverse` to place a subtree in the opposite theme — it is a supported feature,
  and the most persuasive thing this system can demonstrate.
- Reach for `on-<category>-<level>` for text on a colored ground, so contrast is guaranteed.
- Let a change of surface token carry section structure.
- Give form controls `@label`.

**Don't**
- Write literal color values, or gradients built from them.
- Use status hues decoratively, or color-code categories.
- Use `text-*`/`font-*` outside the role system.
- Apply gradient text, or a colored halo in place of a shadow.
- Build the page out of identical icon-heading-text cards; the token system has more
  structure available than a single card grid.
- Assume dark mode is a variant of light — check both, since the ramps invert.
