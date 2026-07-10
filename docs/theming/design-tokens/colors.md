---
title: Colors
order: 2
category: theming
subcategory: design-tokens
imports:
  - import ColorPaletteGrid from 'site/components/theme-docs/color-palette-grid';
---

# Semantic Colors

Frontile's semantic color system provides meaningful, accessible colors that adapt automatically between light and dark themes.

## Overview

Instead of using arbitrary gray scales like `bg-gray-300`, Frontile's semantic colors use meaningful names that describe their purpose and visual weight. Each color automatically adapts between light and dark themes, ensuring consistent contrast and accessibility.

## Color Levels

Every category exposes the same set of levels, organized into **two bands**.
The bands share one emphasis vocabulary but are consumed by different CSS
properties — the band a level belongs to tells you what it's for.

| Band        | Levels (low → high emphasis)                     | Use for                                          |
| ----------- | ------------------------------------------------ | ------------------------------------------------ |
| **Surface** | `subtle` · `muted` · `soft` · `DEFAULT` · `firm` | Fills — `bg-*` and decorative `border-*`         |
| **Ink**     | `strong` · `bolder`                              | Legible foregrounds — `text-*`, outlined borders |

- **`DEFAULT`** is the resting fill. It has no suffix, so the bare class works:
  `bg-primary` is the DEFAULT fill, `text-primary` the DEFAULT-level text.
- **`firm`** is the most emphatic _fill_ (e.g. a pressed background). It sits at
  the top of the surface band, below the ink band it never competes with —
  `firm` is a background, `strong`/`bolder` are text, so they live in different
  property slots even though they share the ladder.
- **`on-{category}-{level}`** is the auto-generated black/white text that meets
  WCAG contrast on that fill (e.g. `text-on-primary` on `bg-primary`).

### Names are ranks, not brightness

A level name describes **emphasis rank**, never a specific lightness. The same
token can be dark in light mode and light in dark mode, because interaction
direction inverts between schemes (light mode lightens on hover and darkens on
press; dark mode does the reverse). A brightness word like "deep" or "light"
would be correct in one theme and wrong in the other, so the vocabulary stays
abstract.

### Why two bands instead of one numbered scale

Tailwind maps one token name to exactly one color value, reused across every
property (`bg-primary`, `text-primary`, and `border-primary` are always the
same color). A fill and the text that must stay legible on top of it are
different colors, so they can't share a single rung — they need two names. The
band split makes that boundary explicit instead of hiding it inside a flat
`50…900`-style scale.

## Color Categories

### Neutral

<ColorPaletteGrid @category="neutral" @showDescription={{true}} />

**Usage Examples:**

Text colors:

- `text-neutral-firm` - Secondary text for descriptions and metadata
- `text-neutral-strong` - Default text color for body content
- `text-neutral-bolder` - Maximum emphasis for headings

Background colors with automatic text colors:

- `bg-neutral-subtle` with `text-on-neutral-subtle` - Subtle background for hover states
- `bg-neutral-soft` with `text-on-neutral-soft` - Soft background for cards
- `bg-neutral` with `text-on-neutral` - Medium emphasis background
- `bg-neutral-strong` with `text-on-neutral-strong` - Strong emphasis background

### Primary

<ColorPaletteGrid @category="primary" @showDescription={{true}} />

**Usage Examples:**

```gts preview
<template>
  <div class='flex gap-4 flex-col'>
    {{! Filled Button }}
    <button
      class='bg-primary text-on-primary hover:bg-primary-soft px-4 py-2 rounded'
    >
      Filled Button
    </button>

    {{! Outlined Button }}
    <button
      class='border border-primary text-primary hover:bg-primary-subtle bg-transparent px-4 py-2 rounded'
    >
      Outlined Button
    </button>

    {{! Tonal Button }}
    <button
      class='bg-primary-subtle text-primary-strong hover:bg-primary-soft/20 px-4 py-2 rounded'
    >
      Tonal Button
    </button>

    {{! Text Button }}
    <button
      class='text-primary hover:bg-primary-subtle bg-transparent px-4 py-2 rounded'
    >
      Text Button
    </button>
  </div>
</template>
```

Banners:

```gts preview
<template>
  <div class='flex gap-4 flex-col'>
    {{! Filled Banner }}
    <div class='bg-primary text-on-primary p-4 rounded'>
      <div class='font-semibold'>Filled Banner</div>
      <div class='text-sm opacity-90'>High emphasis notification with brand
        colors</div>
    </div>

    {{! Tonal Banner }}
    <div class='bg-primary-subtle border border-primary-soft p-4 rounded'>
      <div class='text-primary-strong font-semibold'>Tonal Banner</div>
      <div class='text-primary-strong text-sm'>Subtle notification with brand
        colors</div>
    </div>
  </div>
</template>
```

### Accent

<ColorPaletteGrid @category="accent" @showDescription={{true}} />

**Usage Examples:**

```gts preview
<template>
  <div class='flex gap-4 flex-col'>
    {{! Accent Alert }}
    <div class='bg-accent-subtle border border-accent-soft p-4 rounded'>
      <div class='text-accent-strong'>
        <div class='font-semibold'>New Feature!</div>
        <div class='text-sm'>Check out our latest updates and improvements.</div>
      </div>
    </div>

    {{! Accent Button }}
    <button
      class='bg-accent text-on-accent hover:bg-accent-soft px-4 py-2 rounded'
    >
      Explore Features
    </button>
  </div>
</template>
```

### Success

<ColorPaletteGrid @category="success" @showDescription={{true}} />

**Usage Examples:**

```gts preview
<template>
  <div class='flex gap-4 flex-col'>
    {{! Success Alert }}
    <div class='bg-success-subtle border border-success-soft p-4 rounded'>
      <div class='text-success-strong'>
        <div class='font-semibold'>Success!</div>
        <div class='text-sm'>Your changes have been saved successfully.</div>
      </div>
    </div>

    {{! Success Button }}
    <button
      class='bg-success text-on-success hover:bg-success-soft px-4 py-2 rounded'
    >
      Confirm Action
    </button>
  </div>
</template>
```

### Danger

<ColorPaletteGrid @category="danger" @showDescription={{true}} />

**Usage Examples:**

```gts preview
<template>
  <div class='flex gap-4 flex-col'>
    {{! Error Alert }}
    <div class='bg-danger-subtle border border-danger-soft p-4 rounded'>
      <div class='text-danger-strong'>
        <div class='font-semibold'>Error</div>
        <div class='text-sm'>Failed to save changes. Please try again.</div>
      </div>
    </div>

    {{! Destructive Button }}
    <button
      class='bg-danger text-on-danger hover:bg-danger-soft px-4 py-2 rounded'
    >
      Delete Item
    </button>
  </div>
</template>
```

### Warning

<ColorPaletteGrid @category="warning" @showDescription={{true}} />

**Usage Examples:**

```gts preview
<template>
  <div class='flex gap-4 flex-col'>
    {{! Warning Alert }}
    <div class='bg-warning-subtle border border-warning-soft p-4 rounded'>
      <div class='text-warning-strong'>
        <div class='font-semibold'>Warning</div>
        <div class='text-sm'>This action cannot be undone.</div>
      </div>
    </div>

    {{! Warning Button }}
    <button class='bg-warning text-on-warning hover:bg-warning-soft rounded'>
      Proceed with Caution
    </button>
  </div>
</template>
```

## Choosing the Right Color Level

Pick from the band that matches the property you're setting.

### Backgrounds & decorative borders (surface band)

- **`subtle`**: Hover states, selected rows, tonal/hairline backgrounds
- **`muted`**: Hover on tonal fills, chip and close-button backgrounds
- **`soft`**: Card backgrounds, secondary surfaces, the hover step for solid fills
- **`DEFAULT`** (bare `bg-{color}`): Primary buttons, badges, tags, resting borders
- **`firm`**: Pressed/active backgrounds

### Text & outlined borders (ink band)

- **`strong`**: Default body text, readable content, outlined-control text and borders
- **`bolder`**: Headings, hover/active text, highest-emphasis foregrounds
- **`on-{color}-{level}`**: Automatic contrasting text on a colored fill (e.g., `text-on-primary` on `bg-primary`)

> **Note:** Surface-band levels (`subtle` … `firm`) are fills, not text colors.
> In dark mode they map to values that are illegible as text on dark surfaces.
> For visible text use an ink-band level (`strong`/`bolder`) or the matching
> `on-{color}` token.

## Accessibility

All color combinations in Frontile meet WCAG 2.1 Level AA contrast requirements (minimum 4.5:1 contrast ratio).

### Automatic "On-" Colors

Frontile automatically generates optimal contrasting text colors for every background color using WCAG contrast calculations. Simply use the `on-` prefix with the same color level:

```html
<!-- Automatically generates optimal text color (black or white) -->
<button class="bg-primary text-on-primary">
  <div class="bg-success-soft text-on-success-soft">
    <div class="bg-neutral-strong text-on-neutral-strong"></div>
  </div>
</button>
```

**How it works:**

1. Frontile calculates the relative luminance of each background color
2. Determines contrast ratio with both black and white text
3. Selects the color with better contrast (≥4.5:1 ratio)
4. Generates the appropriate `on-{color}-{level}` class automatically

**Benefits:**

- No need to manually determine text colors
- Always meets WCAG AA standards
- Automatically adapts to theme changes (light/dark mode)
- Works with custom theme colors

### Customizing On-Colors

While auto-generated on-colors work for most cases, you can override them for brand consistency or specific design requirements:

```js
const { frontile } = require('@frontile/theme/plugin');

module.exports = frontile({
  themes: {
    light: {
      colors: {
        primary: {
          subtle: '#eff6ff',
          soft: '#93c5fd',
          DEFAULT: '#3b82f6',
          strong: '#1e40af'
        },
        // Override specific on-colors
        'on-primary': {
          DEFAULT: '#ffffff', // Force white text on the bare primary fill
          strong: '#e0f2fe' // Use light blue instead of auto-generated white
        }
        // on-primary-subtle and on-primary-soft are still auto-generated
      }
    }
  }
});
```

Partial overrides are supported — only define the levels you want to customize, and the rest will be auto-generated as usual. This works for all semantic color categories: `on-neutral`, `on-primary`, `on-accent`, `on-success`, `on-warning`, `on-danger`, and `on-surface-modal`.

> **Note:** If a color value is a CSS variable reference (e.g., `var(--my-color)`), auto-generation is skipped for that color since contrast cannot be calculated at build time.

## Migrating from Old Colors

If you're upgrading from an older version of Frontile, see the [Semantic Colors v2 Migration Guide](../../migrations/v0.18/semantic-colors.md) for detailed instructions on updating your code.
