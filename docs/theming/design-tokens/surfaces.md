---
title: Surfaces
order: 6
category: theming
subcategory: design-tokens
imports:
  - import SurfaceShowcase from 'site/components/theme-docs/surface-showcase';
---

# Surface System

The Surface system provides a flexible way to create depth and hierarchy in your interfaces using opaque roles and two families of translucent veils.

## Overview

The Surface system consists of three types:

- **Surface Roles** - Semantic, opaque surface tokens for specific UI contexts (app, canvas, card, table, modal, input)
- **Surface Overlay** (subtle, soft, mild, firm, strong) - Translucent layers that push an element _into_ its background
- **Surface Lift** (subtle, soft, mild, firm, strong) - Translucent layers that pull an element _up off_ its background

## Surface Roles

Surface roles provide semantic meaning to your surfaces based on their context in the UI hierarchy. Instead of choosing arbitrary scale values, use these semantic tokens that automatically adapt to the active theme.

<SurfaceShowcase @type="roles" />

### Available Roles

#### App (`bg-surface-app`)

Root application background layer (hierarchy level 0).

**When to use:**

- App shell root
- Full-viewport base layer
- Root layout behind navigation

```gts preview
<template>
  <div class='bg-surface-app p-4'>
    <nav class='p-4 border-b border-neutral-subtle'>
      <h1 class='text-neutral-strong text-xl'>App Navigation</h1>
    </nav>
    <main class='bg-surface-canvas p-6'>
      <p class='text-neutral-strong'>Content area with canvas background</p>
    </main>
  </div>
</template>
```

#### Canvas (`bg-surface-canvas`)

Component contrast baseline (hierarchy level 1).

**When to use:**

- Main content areas
- Page containers that need contrast from app background
- Component baseline surfaces

```gts preview
<template>
  <div class='bg-surface-app p-4'>
    <div class='bg-surface-canvas p-6'>
      <h1 class='text-neutral-strong text-2xl'>Content Area</h1>
      <p class='text-neutral-strong'>Canvas provides contrast against the app
        background</p>
    </div>
  </div>
</template>
```

#### Card (`bg-surface-card`)

Elevated card container surface (hierarchy level 1). Opaque white in light mode;
in dark mode it is a translucent veil (white @ 7%, the same value as
`overlay-subtle`), so whatever sits behind it shows through faintly. Where a
surface has to stay opaque, use `surface-table` — the same colour without the
transparency.

**When to use:**

- Product cards
- Article previews
- Content blocks

```gts preview
<template>
  <div class='bg-surface-canvas p-6'>
    <article
      class='bg-surface-card rounded-lg border border-neutral-subtle p-6'
    >
      <h2 class='text-neutral-strong text-xl mb-2'>Product Title</h2>
      <p class='text-neutral-strong'>This card is elevated off the canvas
        background</p>
    </article>
  </div>
</template>
```

#### Table (`bg-surface-table`)

Data table surface (hierarchy level 1). The same colour as a card, guaranteed
opaque: pure white in light mode, and in dark mode `gray-900` — what
`surface-card` renders over `surface-canvas`.

Tables need that guarantee. A sticky header, a frozen row, or a pinned column
paints over the rows and columns scrolling beneath it, and anything translucent
lets them show through.

**When to use:**

- Data table containers, and the sticky parts inside them
- Any surface at card elevation that has to stay opaque

Recolour it for the whole app the way you would any semantic colour:

```js
module.exports = frontile({
  themes: {
    dark: {
      colors: {
        surface: { table: '#1c1c1c' }
      }
    }
  }
});
```

For one table that sits on a different background, set `--color-surface-table` on
it instead — it is a plain custom property, and it applies to everything below
it. The Table component takes it as a wrapper class; see
[Table](/docs/components/collections/table).

```gts preview
<template>
  <div class='bg-surface-canvas p-6'>
    <div class='bg-surface-table rounded-lg h-32 overflow-auto'>
      <div class='bg-surface-table sticky top-0 px-4 py-2'>
        <p class='text-neutral-bolder'>Sticky header — rows pass under it</p>
      </div>
      <div class='px-4 py-2 text-neutral-strong'>Row one</div>
      <div class='px-4 py-2 text-neutral-strong'>Row two</div>
      <div class='px-4 py-2 text-neutral-strong'>Row three</div>
      <div class='px-4 py-2 text-neutral-strong'>Row four</div>
      <div class='px-4 py-2 text-neutral-strong'>Row five</div>
    </div>
  </div>
</template>
```

#### Modal (`bg-surface-modal`)

Modal, drawer, and popover container surface, highest elevation (hierarchy level 3).

**When to use:**

- Modal dialogs
- Drawers
- Popovers and dropdown menus
- Confirmation prompts

Pair it with `bg-surface-overlay-strong dark:bg-surface-lift-strong` for the backdrop behind modals and drawers.

```gts preview
<template>
  <div class='bg-surface-canvas p-6'>
    <div class='bg-surface-modal rounded-lg shadow-2xl p-6 max-w-md'>
      <h2 class='text-on-surface-modal text-xl mb-2'>Confirm Action</h2>
      <p class='text-on-surface-modal mb-4'>Are you sure you want to continue?</p>
      <div class='flex gap-2'>
        <button
          class='bg-primary text-on-primary px-4 py-2 rounded'
        >Confirm</button>
        <button
          class='bg-neutral-subtle text-neutral-strong px-4 py-2 rounded'
        >Cancel</button>
      </div>
    </div>
  </div>
</template>
```

#### Input (`bg-surface-input`)

Form control surface for inputs, checkboxes, radios, and similar controls (hierarchy level -1).

**When to use:**

- Text inputs
- Checkboxes and radios
- Any native form control background

```gts preview
<template>
  <div class='bg-surface-canvas p-6'>
    <div>
      <label class='block text-neutral-strong text-sm mb-1'>Email</label>
      <input
        class='bg-surface-input border border-neutral rounded px-3 py-2 w-full text-neutral-strong'
        placeholder='Enter your email'
      />
    </div>
  </div>
</template>
```

### Hierarchy Levels

Surface roles are designed to create visual depth through a hierarchy system:

| Level | Role                | Purpose                                                  |
| ----- | ------------------- | -------------------------------------------------------- |
| -1    | Input               | Recessed below canvas                                    |
| 0     | App                 | Root application background                              |
| 1     | Canvas, Card, Table | Component contrast baseline and first level of elevation |
| 3     | Modal               | Highest elevation (modals, drawers, popovers, dropdowns) |

In **light mode**, elevated surfaces appear brighter (white) against gray backgrounds following the elevation-luminance principle.
In **dark mode**, elevated surfaces appear progressively lighter against near-black backgrounds.

## Surface Overlay (subtle, soft, mild, firm, strong)

Translucent overlays with alpha channel that stack on top of solid surfaces. These add depth through transparency rather than changing the base color.

### When to Use

- **Sections within components**: Modal footers, card headers, dropdown sections
- **Cards/panels on pages**: Elevated surfaces that float on top of the page background
- **Hover states**: Subtle translucent effect on hover
- **Progress bars, selection highlights**: Semi-transparent UI elements
- **`strong`**: The heaviest step (75% in light, 95% in dark), far beyond a hover or elevation hint. In light mode this is the backdrop behind modals and drawers; in dark mode the black scrim is `lift-strong` instead, since the families mirror each other — see [Surface Lift](#surface-lift-subtle-soft-mild-firm-strong)

### Example: Modal with Overlay Footer

```hbs
{{! Modal base uses the modal surface role }}
<Modal
  @classes={{hash
    base='bg-surface-modal text-on-surface-modal'
    footer='bg-surface-overlay-subtle'
  }}
>
  <:default>
    Modal content on opaque base
  </:default>

  <:footer>
    Footer with subtle overlay effect
  </:footer>
</Modal>
```

### Example: Card on Page

```hbs
{{! Page has a solid app background }}
<div class='bg-surface-app'>
  {{! Card floats on top with translucent overlay }}
  <div class='bg-surface-overlay-soft rounded-lg p-6'>
    <h3>Card Title</h3>
    <p>Card content with depth</p>
  </div>
</div>
```

### Stacking Overlays

Overlays can stack on top of each other to create progressive depth:

<SurfaceShowcase @type="overlay" />

```hbs
<div class='bg-surface-app p-6'>
  <div class='bg-surface-overlay-subtle p-4 rounded'>
    Layer 1 (subtle)
    <div class='bg-surface-overlay-soft p-4 rounded'>
      Layer 2 (soft)
      <div class='bg-surface-overlay-mild p-4 rounded'>
        Layer 3 (mild)
        <div class='bg-surface-overlay-firm p-4 rounded'>
          Layer 4 (firm)
        </div>
      </div>
    </div>
  </div>
</div>
```

### Example: Modal/Drawer Backdrop

```hbs
<Overlay
  @backdrop={{hash
    class='bg-surface-overlay-strong dark:bg-surface-lift-strong backdrop-blur-sm'
  }}
>
  Modal content
</Overlay>
```

## Surface Lift (subtle, soft, mild, firm, strong)

Lift is the mirror of overlay. Overlay darkens in light mode and lightens in dark mode, pressing an element _into_ the page. Lift does the opposite — a white veil on a light page, a black veil on a dark one — so the element reads as floating _above_ whatever it covers.

<SurfaceShowcase @type="lift" />

Both families share the same level names, and both adapt to the active theme automatically:

| Level    | Light mode  | Dark mode   |
| -------- | ----------- | ----------- |
| `subtle` | white @ 30% | black @ 10% |
| `soft`   | white @ 50% | black @ 20% |
| `mild`   | white @ 70% | black @ 30% |
| `firm`   | white @ 90% | black @ 40% |
| `strong` | white @ 95% | black @ 75% |

Every lift level flips with the scheme, `strong` included.

The two families are exact mirrors, which has one consequence worth knowing: the
heavy black veil used as a modal backdrop is `overlay-strong` in light mode but
`lift-strong` in dark mode. A component that wants a dark scrim in both schemes
pairs them — `bg-surface-overlay-strong dark:bg-surface-lift-strong` — which is
what Overlay's backdrop does.

### When to Use

- **Frosted/glass panels**: Pair with `backdrop-blur-*` for a translucent panel that stays legible over busy content
- **Sticky headers and toolbars**: Content scrolls under them without washing them out
- **Floating controls over imagery**: Media captions, hero overlays, map controls
- **Anything that must read as _above_ the page** rather than recessed into it

Reach for `surface-overlay-*` instead when the element belongs to the surface it sits on — hover states, table stripes, section fills.

### Example: Frosted Sticky Header

```hbs
<header
  class='sticky top-0 bg-surface-lift-firm backdrop-blur-md border-b border-surface-overlay-subtle'
>
  <nav>Content scrolls underneath, header stays legible</nav>
</header>
```

### Example: Caption Over an Image

```hbs
<figure class='relative'>
  <img src='/hero.jpg' alt='' />
  <figcaption
    class='absolute inset-x-0 bottom-0 bg-surface-lift-soft backdrop-blur-sm p-4'
  >
    Floats above the image in either theme
  </figcaption>
</figure>
```

### Example: Overlay vs Lift

The same nesting, one family each — overlay recedes, lift advances:

```hbs
<div class='bg-surface-canvas p-6'>
  {{! Recedes into the page }}
  <div class='bg-surface-overlay-soft p-4 rounded'>Overlay</div>

  {{! Floats above the page }}
  <div class='bg-surface-lift-soft p-4 rounded'>Lift</div>
</div>
```

## Choosing the Right Surface

Follow this decision flow:

1. **Does this match a specific UI context?**
   - If yes → Use `surface-{role}` (app, canvas, card, table, modal, input)
   - Surface roles provide semantic meaning and automatically adapt to themes.

2. **Is this the base container and no role matches?**
   - Use `surface-app` for most cases.

3. **Does it need to be translucent?**
   - If yes → Continue to next step
   - If no → Use a surface role

4. **Should it read as recessed into the surface, or floating above it?**
   - Recessed (hover states, section fills, table stripes) → Use `surface-overlay-*`
   - Floating (frosted panels, sticky headers, captions over media) → Use `surface-lift-*`
   - If it's a modal/drawer backdrop → Use `surface-overlay-strong dark:surface-lift-strong`

## Common Patterns

### Pattern 1: Page Layout with Cards

```gts preview
<template>
  <div class='bg-surface-canvas p-6'>
    <div class='max-w-4xl mx-auto space-y-4'>
      <div class='bg-surface-card rounded-lg border border-neutral-subtle p-6'>
        <h2 class='text-neutral-bolder text-lg font-semibold mb-2'>Card 1</h2>
        <p class='text-neutral-strong'>Content on elevated card surface</p>
      </div>
      <div class='bg-surface-card rounded-lg border border-neutral-subtle p-6'>
        <h2 class='text-neutral-bolder text-lg font-semibold mb-2'>Card 2</h2>
        <p class='text-neutral-strong'>Another elevated card</p>
      </div>
    </div>
  </div>
</template>
```

### Pattern 2: Sidebar Layout

```gts preview
<template>
  <div class='flex h-64'>
    <aside class='bg-surface-card w-48 border-r border-neutral-subtle p-4'>
      <h3 class='text-neutral-strong font-semibold mb-4'>Sidebar</h3>
      <nav class='space-y-2'>
        <a
          href='#'
          class='block text-neutral-strong hover:text-neutral-bolder text-sm'
        >Link 1</a>
        <a
          href='#'
          class='block text-neutral-strong hover:text-neutral-bolder text-sm'
        >Link 2</a>
      </nav>
    </aside>
    <main class='bg-surface-canvas flex-1 p-6'>
      <h1 class='text-neutral-bolder text-xl mb-2'>Main Content</h1>
      <p class='text-neutral-strong'>Content area on canvas</p>
    </main>
  </div>
</template>
```

### Pattern 3: Form with Inputs

```gts preview
<template>
  <div class='bg-surface-canvas p-6'>
    <form
      class='bg-surface-card rounded-lg border border-neutral-subtle p-6 max-w-md'
    >
      <h2 class='text-neutral-strong text-lg font-semibold mb-4'>Sign Up</h2>
      <div class='space-y-4'>
        <div>
          <label class='block text-neutral-strong text-sm mb-1'>Username</label>
          <input
            class='bg-surface-input border border-neutral rounded px-3 py-2 w-full text-neutral-strong'
            placeholder='Enter username'
          />
        </div>
        <div>
          <label class='block text-neutral-strong text-sm mb-1'>Email</label>
          <input
            class='bg-surface-input border border-neutral rounded px-3 py-2 w-full text-neutral-strong'
            placeholder='Enter email'
          />
        </div>
        <button class='bg-primary text-on-primary w-full py-2 rounded'>
          Submit
        </button>
      </div>
    </form>
  </div>
</template>
```

## Migrating from content1-4

If you're upgrading from an older version that used `content1-4`, here's the migration mapping:

| Old                            | New                                 | Reason                            |
| ------------------------------ | ----------------------------------- | --------------------------------- |
| `bg-content1`                  | `bg-surface-app`                    | Base opaque surface               |
| `bg-content3 dark:bg-content2` | `bg-surface-overlay-soft`           | Single value works in both themes |
| `selection:bg-content3`        | `selection:bg-surface-overlay-soft` | Translucent selection highlight   |

## Best Practices

### Do

- **Prefer surface roles** (`surface-canvas`, `surface-card`, etc.) over ad hoc colors when they match your UI context
- Stack overlays on a surface role for depth
- Use `overlay-strong` with `dark:lift-strong` for modal/drawer backdrops
- Test in both light and dark modes
- Follow the hierarchy levels for visual consistency

### Don't

- Don't use overlay without a solid role beneath it
- Don't mix surface system with old content1-4
- Don't use too many overlay layers (max 3-4)
- Don't forget to check contrast ratios
