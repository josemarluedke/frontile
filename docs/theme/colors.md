---
order: 2
category: theme
label: New
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

- `text-neutral-contrast-1` - White text on dark backgrounds (light mode)
- `text-neutral-soft` - Muted text for hints and placeholders
- `text-neutral-medium` - Default text color for body content
- `text-neutral-strong` - Strong emphasis for headings

Background colors:

- `bg-neutral-subtle` - Subtle background for hover states
- `bg-neutral-soft` - Soft background for cards
- `bg-neutral-medium` - Medium emphasis background
- `bg-neutral-strong` - Strong emphasis background

### Brand

<ColorPaletteGrid @category="brand" @showDescription={{true}} />

**Usage Examples:**

```gts preview
<template>
  <div class='flex gap-4 flex-col'>
    {{! Filled Button }}
    <button class='bg-brand-medium text-brand-contrast-1 hover:bg-brand-soft px-4 py-2 rounded'>
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
    <div class='bg-brand-medium text-brand-contrast-1 p-4 rounded'>
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
    <button class='bg-success-medium text-success-contrast-1 hover:bg-success-soft px-4 py-2 rounded'>
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
    <button class='bg-danger-medium text-danger-contrast-1 hover:bg-danger-soft px-4 py-2 rounded'>
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
      class='bg-warning-medium text-warning-contrast-1 hover:bg-warning-soft rounded'
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

- **contrast-1/2**: Text on colored backgrounds (ensures contrast)
- **soft**: Muted text, hints, placeholders
- **medium**: Links, interactive text
- **strong**: Headings, important text

### For Borders

- **subtle**: Dividers, minimal borders
- **soft**: Default borders, card outlines
- **medium**: Focus rings, emphasized borders

## Accessibility

All color combinations in Frontile meet WCAG 2.1 Level AA contrast requirements. Use `contrast-1` or `contrast-2` for text on colored backgrounds to ensure sufficient contrast.

> **Tip**: The `contrast-1` and `contrast-2` levels automatically flip between white and black based on the theme, ensuring optimal contrast in both light and dark modes.

## Migrating from Old Colors

If you're upgrading from an older version of Frontile, see the [Semantic Colors v2 Migration Guide](/docs/migration/semantic-colors-v2) for detailed instructions on updating your code.
