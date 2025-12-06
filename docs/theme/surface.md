---
order: 3
category: theme
label: New
imports:
  - import SurfaceShowcase from 'site/components/theme-docs/surface-showcase';
---

# Surface System

The Surface system provides a flexible way to create depth and hierarchy in your interfaces using solid bases and translucent overlays.

> **Important**: Surface overlays are translucent and require a solid base beneath them. Always use `surface-solid-*` as the base layer before applying overlays.

## Overview

The Surface system consists of three types:

- **Surface Solid (0-11)** - Opaque base layers with a 12-step scale
- **Surface Overlay (subtle, soft, medium, strong)** - Translucent layers that stack on top
- **Surface Overlay Inverse (subtle, soft, medium, strong)** - High-contrast overlays for backdrops

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
<div class='bg-surface-solid-1 text-surface-solid-11 min-h-screen'>
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

1. **Is this the base container?**
   - If yes → Use `surface-solid-*`
   - Base containers (pages, modals, drawers) need opaque backgrounds. Use `surface-solid-1` for most cases.

2. **Does it need to be translucent?**
   - If no → Use `surface-solid-*`
   - If yes → Continue to next step

3. **Is it on top of a solid surface?**
   - If yes → Use `surface-overlay-*`
   - If it's a backdrop → Use `surface-overlay-inverse-*`
   - Overlays need a solid base to work properly. Backdrops use inverse for high contrast.

## Common Patterns

### Pattern 1: Dropdown Menu

```hbs
{{! Dropdown is a base container, uses solid }}
<Dropdown @classes={{hash base='bg-surface-solid-1'}}>
  {{! Optional: sections within can use overlay }}
  <div class='bg-surface-overlay-subtle'>Header</div>
  <div>Menu items...</div>
</Dropdown>
```

### Pattern 2: Progress Bar

```hbs
{{! Track uses overlay on page background }}
<div class='bg-surface-overlay-soft rounded-full h-2'>
  {{! Fill uses solid color }}
  <div class='bg-brand-medium h-full rounded-full' style='width: 60%'></div>
</div>
```

### Pattern 3: Text Selection

```hbs
<input class='selection:bg-surface-overlay-soft' />
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

- Use `surface-solid-*` for base containers
- Stack overlays on solid surfaces for depth
- Use inverse overlays for backdrops
- Test in both light and dark modes

### Don't

- Don't use overlay without a solid base
- Don't mix surface system with old content1-4
- Don't use too many overlay layers (max 3-4)
- Don't forget to check contrast ratios
