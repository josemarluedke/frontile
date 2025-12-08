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

## Color Categories

### Neutral

<ColorPaletteGrid @category="neutral" @showDescription={{true}} />

**Usage Examples:**

Text colors:

- `text-neutral-soft` - Muted text for hints and placeholders
- `text-neutral-medium` - Default text color for body content
- `text-neutral-strong` - Strong emphasis for headings

Background colors with automatic text colors:

- `bg-neutral-subtle` with `text-on-neutral-subtle` - Subtle background for hover states
- `bg-neutral-soft` with `text-on-neutral-soft` - Soft background for cards
- `bg-neutral-medium` with `text-on-neutral-medium` - Medium emphasis background
- `bg-neutral-strong` with `text-on-neutral-strong` - Strong emphasis background

### Brand

<ColorPaletteGrid @category="brand" @showDescription={{true}} />

**Usage Examples:**

```gts preview
<template>
  <div class='flex gap-4 flex-col'>
    {{! Filled Button }}
    <button class='bg-brand-medium text-on-brand-medium hover:bg-brand-soft px-4 py-2 rounded'>
      Filled Button
    </button>

    {{! Outlined Button }}
    <button
      class='border border-brand-medium text-brand-medium hover:bg-brand-subtle bg-transparent px-4 py-2 rounded'
    >
      Outlined Button
    </button>

    {{! Tonal Button }}
    <button class='bg-brand-subtle text-brand-strong hover:bg-brand-soft/20 px-4 py-2 rounded'>
      Tonal Button
    </button>

    {{! Text Button }}
    <button class='text-brand-medium hover:bg-brand-subtle bg-transparent px-4 py-2 rounded'>
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
    <div class='bg-brand-medium text-on-brand-medium p-4 rounded'>
      <div class='font-semibold'>Filled Banner</div>
      <div class='text-sm opacity-90'>High emphasis notification with brand colors</div>
    </div>

    {{! Tonal Banner }}
    <div class='bg-brand-subtle border border-brand-soft p-4 rounded'>
      <div class='text-brand-strong font-semibold'>Tonal Banner</div>
      <div class='text-brand-strong text-sm'>Subtle notification with brand colors</div>
    </div>
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
    <button class='bg-success-medium text-on-success-medium hover:bg-success-soft px-4 py-2 rounded'>
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
    <button class='bg-danger-medium text-on-danger-medium hover:bg-danger-soft px-4 py-2 rounded'>
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
    <button
      class='bg-warning-medium text-on-warning-medium hover:bg-warning-soft rounded'
    >
      Proceed with Caution
    </button>
  </div>
</template>
```

## Choosing the Right Color Level

### For Backgrounds

- **subtle**: Hover states, selected rows, minimal backgrounds
- **soft**: Card backgrounds, secondary surfaces
- **medium**: Primary buttons, badges, tags
- **strong**: High-emphasis buttons, active states

### For Text

- **on-{color}-{level}**: Automatic contrasting text on colored backgrounds (e.g., `text-on-brand-medium`)
- **soft**: Muted text, hints, placeholders
- **medium**: Links, interactive text
- **strong**: Headings, important text

### For Borders

- **subtle**: Dividers, minimal borders
- **soft**: Default borders, card outlines
- **medium**: Focus rings, emphasized borders

## Accessibility

All color combinations in Frontile meet WCAG 2.1 Level AA contrast requirements (minimum 4.5:1 contrast ratio).

### Automatic "On-" Colors

Frontile automatically generates optimal contrasting text colors for every background color using WCAG contrast calculations. Simply use the `on-` prefix with the same color level:

```html
<!-- Automatically generates optimal text color (black or white) -->
<button class="bg-brand text-on-brand">
<div class="bg-success-soft text-on-success-soft">
<div class="bg-neutral-strong text-on-neutral-strong">
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

## Migrating from Old Colors

If you're upgrading from an older version of Frontile, see the [Semantic Colors v2 Migration Guide](/docs/migration/semantic-colors-v2) for detailed instructions on updating your code.
