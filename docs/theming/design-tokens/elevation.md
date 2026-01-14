---
title: Elevation
order: 7
category: theming
subcategory: design-tokens
---

# Elevation

Frontile provides an elevation system using shadows to create visual depth and hierarchy in your interface.

## Overview

Elevation helps establish spatial relationships and visual hierarchy by making elements appear "closer" or "further" from the user. Frontile provides six elevation levels (0-5), each designed for specific UI contexts.

Higher elevations indicate elements that are more prominent or interactive, such as floating menus, modals, and tooltips.

## Elevation Levels

```gts preview
<template>
  <div class='grid grid-cols-2 md:grid-cols-3 gap-8 p-8'>
    <div class='shadow-elevation-0 bg-surface-canvas p-6 rounded'>
      <h3 class='mb-2'>Level 0</h3>
      <p class='text-neutral-soft'>No shadow</p>
      <p class='text-neutral-soft text-sm mt-2'>Flat surface</p>
    </div>
    <div class='shadow-elevation-1 bg-surface-canvas p-6 rounded'>
      <h3 class='mb-2'>Level 1</h3>
      <p class='text-neutral-soft'>Subtle lift</p>
      <p class='text-neutral-soft text-sm mt-2'>Hover states</p>
    </div>
    <div class='shadow-elevation-2 bg-surface-canvas p-6 rounded'>
      <h3 class='mb-2'>Level 2</h3>
      <p class='text-neutral-soft'>Raised surface</p>
      <p class='text-neutral-soft text-sm mt-2'>Cards, panels</p>
    </div>
    <div class='shadow-elevation-3 bg-surface-canvas p-6 rounded'>
      <h3 class='mb-2'>Level 3</h3>
      <p class='text-neutral-soft'>Floating element</p>
      <p class='text-neutral-soft text-sm mt-2'>Dropdowns</p>
    </div>
    <div class='shadow-elevation-4 bg-surface-canvas p-6 rounded'>
      <h3 class='mb-2'>Level 4</h3>
      <p class='text-neutral-soft'>Elevated overlay</p>
      <p class='text-neutral-soft text-sm mt-2'>Modals, dialogs</p>
    </div>
    <div class='shadow-elevation-5 bg-surface-canvas p-6 rounded'>
      <h3 class='mb-2'>Level 5</h3>
      <p class='text-neutral-soft'>Maximum depth</p>
      <p class='text-neutral-soft text-sm mt-2'>Top layer</p>
    </div>
  </div>
</template>
```

## When to Use Each Level

| Level | Utility              | Use Cases                         | Examples                                                  |
| ----- | -------------------- | --------------------------------- | --------------------------------------------------------- |
| 0     | `shadow-elevation-0` | Flat elements, no depth needed    | Inline content, flat buttons, embedded content            |
| 1     | `shadow-elevation-1` | Subtle separation from background | Hover states, subtle cards, list items                    |
| 2     | `shadow-elevation-2` | Standard raised surfaces          | Cards, panels, tiles, navigation bars                     |
| 3     | `shadow-elevation-3` | Floating elements above content   | Dropdowns, tooltips, popovers, date pickers               |
| 4     | `shadow-elevation-4` | Modal overlays                    | Modals, dialogs, drawers, sheets                          |
| 5     | `shadow-elevation-5` | Maximum emphasis                  | Critical alerts, system notifications, top-layer elements |

## Common Use Cases

### Cards and Panels

```gts preview
<template>
  <div class='grid md:grid-cols-2 gap-6'>
    {{! Basic card with level 2 elevation }}
    <div class='shadow-elevation-2 bg-surface-canvas rounded-xl p-6'>
      <h3 class='mb-3'>Product Card</h3>
      <p class='text-neutral-soft mb-4'>
        Standard card with level 2 elevation provides subtle depth.
      </p>
      <button
        class='bg-brand-medium text-on-brand-medium px-4 py-2 rounded hover:bg-brand-soft'
      >
        View Details
      </button>
    </div>

    {{! Feature card with no shadow }}
    <div
      class='shadow-elevation-0 border border-neutral-medium bg-surface-canvas rounded-xl p-6'
    >
      <h3 class='mb-3'>Flat Card</h3>
      <p class='text-neutral-soft mb-4'>
        Uses border instead of shadow for a flatter appearance.
      </p>
      <button
        class='border border-brand-medium text-brand-medium px-4 py-2 rounded hover:bg-brand-subtle'
      >
        Learn More
      </button>
    </div>
  </div>
</template>
```

### Interactive States

```gts preview
<template>
  <div class='flex gap-4 flex-wrap'>
    {{! Button that lifts on hover }}
    <button
      class='bg-brand-medium text-on-brand-medium px-6 py-3 rounded shadow-elevation-1 hover:shadow-elevation-3 transition-shadow'
    >
      Hover to Lift
    </button>

    {{! Card that lifts on hover }}
    <div
      class='bg-surface-canvas rounded-xl p-6 shadow-elevation-1 hover:shadow-elevation-2 transition-shadow cursor-pointer'
    >
      <h4 class='mb-2'>Interactive Card</h4>
      <p class='text-neutral-soft'>Elevation increases on hover</p>
    </div>
  </div>
</template>
```

## Best Practices

### Establish Clear Hierarchy

Use elevation consistently to indicate the z-axis position of elements:

- **Base layer** (level 0-1): Page content, static elements
- **Raised layer** (level 2): Cards, panels, navigation
- **Floating layer** (level 3): Dropdowns, popovers, tooltips
- **Overlay layer** (level 4-5): Modals, critical alerts

### Avoid Elevation Confusion

Don't use high elevation for non-interactive or less important elements. Reserve levels 4-5 for elements that truly need to command attention.

### Transition Elevations

Animate elevation changes for smooth interactions:

```html
<div class="shadow-elevation-1 hover:shadow-elevation-3 transition-shadow">
  Smooth elevation transition
</div>
```

### Consider Dark Mode

Shadows may be less visible in dark mode. Consider combining elevation with subtle borders:

```html
<div class="shadow-elevation-2 border border-neutral-medium/20">
  Enhanced depth with border
</div>
```

## Accessibility

### Don't Rely on Shadows Alone

Never use shadows as the only indicator of important information. Always provide additional visual cues:

- Use borders for critical boundaries
- Use semantic colors for status
- Provide clear text labels
- Ensure proper focus indicators

### Test in Different Lighting

Shadows may be difficult to perceive:

- On certain displays (high brightness, poor contrast)
- For users with visual impairments
- In different lighting conditions

Always provide alternative visual cues beyond elevation.

## Customization

Override elevation shadows using CSS variables:

```css
@import '@frontile/theme';

@theme {
  /* Customize specific elevation levels */
  --shadow-elevation-1: 0px 2px 4px rgba(0, 0, 0, 0.05);
  --shadow-elevation-2: 0px 4px 12px rgba(0, 0, 0, 0.1);
  --shadow-elevation-3: 0px 8px 24px rgba(0, 0, 0, 0.15);
  --shadow-elevation-4: 0px 16px 48px rgba(0, 0, 0, 0.2);
}
```

### Theme-Specific Shadows

Adjust shadows for light and dark themes:

```css
/* Light theme */
.light,
.dark .theme-inverse {
  --shadow-elevation-2: 0px 4px 12px rgba(0, 0, 0, 0.1);
}

/* Dark theme */
.dark,
.light .theme-inverse {
  --shadow-elevation-2: 0px 4px 12px rgba(0, 0, 0, 0.4);
}
```

For more customization options, see the [Configuration Guide](../configuration/customization.md).
