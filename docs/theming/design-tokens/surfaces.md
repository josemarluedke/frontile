---
title: Surfaces
order: 6
category: theming
subcategory: design-tokens
imports:
  - import SurfaceShowcase from 'site/components/theme-docs/surface-showcase';
---

# Surface System

The Surface system provides a flexible way to create depth and hierarchy in your interfaces using solid bases and translucent overlays.

> **Important**: Surface overlays are translucent and require a solid base beneath them. Always use `surface-solid-*` as the base layer before applying overlays.

## Overview

The Surface system consists of four types:

- **Surface Roles** - Semantic surface tokens for specific UI contexts (app, canvas, card, panel, popover, overlayContent, inset)
- **Surface Solid (0-11)** - Opaque base layers with a 12-step scale
- **Surface Overlay (subtle, soft, medium, strong)** - Translucent layers that stack on top
- **Surface Overlay Inverse (subtle, soft, medium, strong)** - High-contrast overlays for backdrops

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
  <div class="bg-surface-app p-4">
    <nav class="p-4 border-b border-neutral-subtle">
      <h1 class="text-neutral-strong text-xl">App Navigation</h1>
    </nav>
    <main class="bg-surface-canvas p-6">
      <p class="text-neutral-strong">Content area with canvas background</p>
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
  <div class="bg-surface-app p-4">
    <div class="bg-surface-canvas p-6">
      <h1 class="text-neutral-strong text-2xl">Content Area</h1>
      <p class="text-neutral-strong">Canvas provides contrast against the app background</p>
    </div>
  </div>
</template>
```

#### Card (`bg-surface-card`)
Elevated card container surface (hierarchy level 1).

**When to use:**
- Product cards
- Article previews
- Content blocks

```gts preview
<template>
  <div class="bg-surface-canvas p-6">
    <article class="bg-surface-card rounded-lg border border-neutral-subtle p-6">
      <h2 class="text-neutral-strong text-xl mb-2">Product Title</h2>
      <p class="text-neutral-strong">This card is elevated off the canvas background</p>
    </article>
  </div>
</template>
```

#### Panel (`bg-surface-panel`)
Sidebar and panel container surface (hierarchy level 1).

**When to use:**
- Navigation sidebars
- Inspector panels
- Tool palettes

```gts preview
<template>
  <div class="flex h-48">
    <aside class="bg-surface-panel border-r border-neutral-subtle p-4 w-48">
      <h3 class="text-neutral-strong font-semibold mb-2">Navigation</h3>
      <nav class="space-y-1">
        <a href="#" class="block text-neutral-strong hover:text-neutral-bolder">Dashboard</a>
        <a href="#" class="block text-neutral-strong hover:text-neutral-bolder">Settings</a>
      </nav>
    </aside>
    <main class="bg-surface-canvas flex-1 p-4">
      <p class="text-neutral-strong">Main content area</p>
    </main>
  </div>
</template>
```

#### Popover (`bg-surface-popover`)
Popover and tooltip container surface (hierarchy level 2).

**When to use:**
- Dropdown menus
- Tooltips
- Context menus

```gts preview
<template>
  <div class="bg-surface-canvas p-6">
    <div class="bg-surface-popover rounded-md shadow-lg border border-neutral-subtle p-4 w-48">
      <div class="space-y-2">
        <button class="block w-full text-left px-2 py-1 text-neutral-strong hover:bg-neutral-subtle rounded text-sm">
          Edit
        </button>
        <button class="block w-full text-left px-2 py-1 text-neutral-strong hover:bg-neutral-subtle rounded text-sm">
          Delete
        </button>
      </div>
    </div>
  </div>
</template>
```

#### Overlay Content (`bg-surface-overlay-content`)
Modal and drawer container surface, highest elevation (hierarchy level 3).

**When to use:**
- Modal dialogs
- Drawers
- Confirmation prompts

```gts preview
<template>
  <div class="bg-surface-canvas p-6">
    <div class="bg-surface-overlay-content rounded-lg shadow-2xl p-6 max-w-md">
      <h2 class="text-neutral-strong text-xl mb-2">Confirm Action</h2>
      <p class="text-neutral-strong mb-4">Are you sure you want to continue?</p>
      <div class="flex gap-2">
        <button class="bg-brand-medium text-on-brand-medium px-4 py-2 rounded">Confirm</button>
        <button class="bg-neutral-subtle text-neutral-strong px-4 py-2 rounded">Cancel</button>
      </div>
    </div>
  </div>
</template>
```

#### Inset (`bg-surface-inset`)
Recessed surface for inputs, wells, and embedded content (hierarchy level -1).

**When to use:**
- Text inputs
- Search fields
- Code blocks

```gts preview
<template>
  <div class="bg-surface-canvas p-6">
    <div class="space-y-4">
      <div>
        <label class="block text-neutral-strong text-sm mb-1">Email</label>
        <input
          class="bg-surface-inset border border-neutral-medium rounded px-3 py-2 w-full text-neutral-strong"
          placeholder="Enter your email"
        />
      </div>
      <div>
        <label class="block text-neutral-strong text-sm mb-1">Code Example</label>
        <pre class="bg-surface-inset rounded-md p-4 text-neutral-strong text-sm"><code>const example = true;</code></pre>
      </div>
    </div>
  </div>
</template>
```

### Hierarchy Levels

Surface roles are designed to create visual depth through a hierarchy system:

| Level | Role | Purpose |
|-------|------|---------|
| -1 | Inset | Recessed below canvas |
| 0 | App | Root application background |
| 1 | Canvas, Card, Panel | Component contrast baseline and first level of elevation |
| 2 | Popover | Second level of elevation |
| 3 | Overlay Content | Highest elevation (modals, drawers) |

In **light mode**, elevated surfaces appear brighter (white) against gray backgrounds following the elevation-luminance principle.
In **dark mode**, elevated surfaces appear progressively lighter against near-black backgrounds.

## Surface Solid (0-11)

A 12-step opaque scale for base backgrounds. In light mode, 0 is white (#FFFFFF) and 11 is black (#000000). In dark mode, the scale inverts: 0 is black and 11 is white.

<SurfaceShowcase @type="solid" />

### When to Use

- **Page backgrounds**: `bg-surface-solid-1` for main content areas
- **Modal/drawer bases**: `bg-surface-solid-1` as the opaque container
- **Text colors**: `text-surface-solid-11` for body text, `text-surface-solid-10` for slightly muted text
- **Any surface that needs to be fully opaque**

### Example: Page Layout

```hbs
<div class='bg-surface-solid-1 text-surface-solid-11'>
  <header class='bg-surface-solid-0 border-b border-neutral-subtle'>
    <h1 class='text-surface-solid-11'>Page Title</h1>
  </header>

  <main>
    <p class='text-surface-solid-10'>
      Body text with good contrast
    </p>
  </main>
</div>
```

## Surface Overlay (subtle, soft, medium, strong)

Translucent overlays with alpha channel that stack on top of solid surfaces. These add depth through transparency rather than changing the base color.

### When to Use

- **Sections within components**: Modal footers, card headers, dropdown sections
- **Cards/panels on pages**: Elevated surfaces that float on top of the page background
- **Hover states**: Subtle translucent effect on hover
- **Progress bars, selection highlights**: Semi-transparent UI elements

### Example: Modal with Overlay Footer

```hbs
{{! Modal base uses solid background }}
<Modal
  @classes={{hash
    base='bg-surface-solid-1 text-surface-solid-11'
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
{{! Page has solid background }}
<div class='bg-surface-solid-1'>
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
<div class='bg-surface-solid-1 p-6'>
  <div class='bg-surface-overlay-subtle p-4 rounded'>
    Layer 1 (subtle)
    <div class='bg-surface-overlay-soft p-4 rounded'>
      Layer 2 (soft)
      <div class='bg-surface-overlay-medium p-4 rounded'>
        Layer 3 (medium)
        <div class='bg-surface-overlay-strong p-4 rounded'>
          Layer 4 (strong)
        </div>
      </div>
    </div>
  </div>
</div>
```

## Surface Overlay Inverse (subtle, soft, medium, strong)

Translucent overlays for high-contrast sections within the same theme. Creates light overlays on dark surfaces in light mode, or dark overlays on light surfaces in dark mode.

<SurfaceShowcase @type="overlay-inverse" />

### When to Use

- **Modal/drawer backdrops**: The semi-transparent overlay behind modals
- **Scrim overlays**: Darkening or lightening effect over content
- **High-contrast sections**: Within the same theme but needing visual separation

### Example: Modal Backdrop

```hbs
<Overlay
  @backdrop={{hash class='bg-surface-overlay-inverse-strong backdrop-blur-sm'}}
>
  Modal content
</Overlay>
```

## Choosing the Right Surface

Follow this decision flow:

1. **Does this match a specific UI context?**
   - If yes → Use `surface-{role}` (canvas, card, panel, popover, overlayContent, inset)
   - Surface roles provide semantic meaning and automatically adapt to themes.

2. **Is this the base container?**
   - If yes and no role matches → Use `surface-solid-*`
   - Base containers (pages, modals, drawers) need opaque backgrounds. Use `surface-solid-1` for most cases.

3. **Does it need to be translucent?**
   - If no → Use `surface-solid-*`
   - If yes → Continue to next step

4. **Is it on top of a solid surface?**
   - If yes → Use `surface-overlay-*`
   - If it's a backdrop → Use `surface-overlay-inverse-*`
   - Overlays need a solid base to work properly. Backdrops use inverse for high contrast.

## Common Patterns

### Pattern 1: Page Layout with Cards

```gts preview
<template>
  <div class="bg-surface-canvas p-6">
    <div class="max-w-4xl mx-auto space-y-4">
      <div class="bg-surface-card rounded-lg border border-neutral-subtle p-6">
        <h2 class="text-neutral-bolder text-lg font-semibold mb-2">Card 1</h2>
        <p class="text-neutral-strong">Content on elevated card surface</p>
      </div>
      <div class="bg-surface-card rounded-lg border border-neutral-subtle p-6">
        <h2 class="text-neutral-bolder text-lg font-semibold mb-2">Card 2</h2>
        <p class="text-neutral-strong">Another elevated card</p>
      </div>
    </div>
  </div>
</template>
```

### Pattern 2: Sidebar Layout

```gts preview
<template>
  <div class="flex h-64">
    <aside class="bg-surface-panel w-48 border-r border-neutral-subtle p-4">
      <h3 class="text-neutral-strong font-semibold mb-4">Sidebar</h3>
      <nav class="space-y-2">
        <a href="#" class="block text-neutral-strong hover:text-neutral-bolder text-sm">Link 1</a>
        <a href="#" class="block text-neutral-strong hover:text-neutral-bolder text-sm">Link 2</a>
      </nav>
    </aside>
    <main class="bg-surface-canvas flex-1 p-6">
      <h1 class="text-neutral-bolder text-xl mb-2">Main Content</h1>
      <p class="text-neutral-strong">Content area on canvas</p>
    </main>
  </div>
</template>
```

### Pattern 3: Form with Inset Inputs

```gts preview
<template>
  <div class="bg-surface-canvas p-6">
    <form class="bg-surface-card rounded-lg border border-neutral-subtle p-6 max-w-md">
      <h2 class="text-neutral-strong text-lg font-semibold mb-4">Sign Up</h2>
      <div class="space-y-4">
        <div>
          <label class="block text-neutral-strong text-sm mb-1">Username</label>
          <input
            class="bg-surface-inset border border-neutral-medium rounded px-3 py-2 w-full text-neutral-strong"
            placeholder="Enter username"
          />
        </div>
        <div>
          <label class="block text-neutral-strong text-sm mb-1">Email</label>
          <input
            class="bg-surface-inset border border-neutral-medium rounded px-3 py-2 w-full text-neutral-strong"
            placeholder="Enter email"
          />
        </div>
        <button class="bg-brand-medium text-on-brand-medium w-full py-2 rounded">
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
| `bg-content1`                  | `bg-surface-solid-1`                | Base opaque surface               |
| `bg-content3 dark:bg-content2` | `bg-surface-overlay-soft`           | Single value works in both themes |
| `selection:bg-content3`        | `selection:bg-surface-overlay-soft` | Translucent selection highlight   |

## Best Practices

### Do

- **Prefer surface roles** (`surface-canvas`, `surface-card`, etc.) over arbitrary scale values when they match your UI context
- Use `surface-solid-*` for base containers when no role matches
- Stack overlays on solid surfaces for depth
- Use inverse overlays for backdrops
- Test in both light and dark modes
- Follow the hierarchy levels for visual consistency

### Don't

- Don't use overlay without a solid base
- Don't mix surface system with old content1-4
- Don't use too many overlay layers (max 3-4)
- Don't forget to check contrast ratios
- Don't use `surface-solid-*` when a semantic role would be more appropriate
