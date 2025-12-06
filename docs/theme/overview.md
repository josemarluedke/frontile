---
order: 1
category: theme
label: New
imports:
  - import ColorPaletteGrid from 'site/components/theme-docs/color-palette-grid';
  - import SurfaceShowcase from 'site/components/theme-docs/surface-showcase';
---

# Theme System

Frontile's theme system provides a comprehensive, accessible design foundation built on semantic colors, flexible surfaces, and automatic dark mode support.

## Installation

Install the theme package using Ember CLI:

```bash
ember install @frontile/theme
```

## Configuration

### Tailwind CSS v4

#### Using Default Theme

Add this to your `app/styles/app.css`:

```css
@import 'tailwindcss' source('../../');
@plugin "@frontile/theme/plugin/default";
@source '../../node_modules/@frontile';
@custom-variant dark (&:is(.dark *));
```

#### Custom Theme Configuration

Create `frontile.js` in your project root:

```js
const { frontile } = require('@frontile/theme/plugin');

module.exports = frontile({
  /* your configuration */
});
```

Then update `app/styles/app.css`:

```css
@import 'tailwindcss' source('../../');
@plugin "./../../frontile.js";
@source '../../node_modules/@frontile';
@custom-variant dark (&:is(.dark *, .light .theme-inverse *):not(.dark .theme-inverse *));
@custom-variant light (&:is(.light *, .dark .theme-inverse *):not(.light .theme-inverse *));
```

## Key Concepts

### Semantic Colors

Meaningful color categories (neutral, brand, success, danger, warning) with intuitive levels (subtle, soft, medium, strong) that adapt between light and dark themes.

### Surface System

Flexible depth system with opaque solid surfaces (0-11) and translucent overlays (subtle, soft, medium, strong) for creating visual hierarchy.

### Dark Mode

Automatic theme adaptation with intelligent color inversion. Simply toggle the `dark` class to switch between light and dark modes.

## Quick Example

Here's how easy it is to create a themed button with Frontile:

```gts preview
<template>
  <button
    class='bg-brand-medium text-brand-contrast-1 hover:bg-brand-soft px-4 py-2 rounded'
  >
    Click me
  </button>
</template>
```

This button automatically adapts to light and dark themes without additional code. The `brand-medium` color provides the right emphasis, while `brand-contrast-1` ensures accessible text contrast.

## Theme Switching

Toggle between light and dark themes by adding or removing the `dark` class on a parent element (typically `<html>` or `<body>`):

```html
<html class="dark">
  <!-- Your content adapts to dark mode -->
</html>
```

Remove the `dark` class to revert to light theme. You can also explicitly use the `light` class if needed.

## Theme Inverse

Create sections with inverted theme colors using the `theme-inverse` utility class. In light mode, these sections display dark theme colors, and vice versa.

```gts preview
import { Button } from 'frontile';

<template>
  <div class='space-y-8 p-8'>
    <div class='p-6 bg-surface-overlay-subtle rounded-lg'>
      <h3 class='text-lg font-bold text-neutral-strong mb-4'>Regular Theme</h3>
      <Button @intent='primary'>Primary Button</Button>
    </div>

    <div class='theme-inverse p-6 bg-background rounded-lg'>
      <div class='p-6 bg-surface-overlay-subtle rounded-lg'>
        <h3 class='text-lg font-bold text-neutral-strong mb-4'>Inverted Theme</h3>
        <Button @intent='primary'>Primary Button</Button>
      </div>
    </div>
  </div>
</template>
```

[Learn more about theme-inverse →](/docs/theme/theme-inverse)

## Color System

Frontile provides six semantic color categories:

- **Neutral** - Default interface colors
- **Brand** - Primary brand colors (blue)
- **Success** - Positive states and actions (green)
- **Danger** - Errors and destructive actions (red)
- **Warning** - Warnings and cautions (orange)
- **Inverse** - High-contrast overlays

Each category has intuitive levels: `contrast-1`, `subtle`, `soft`, `medium`, `strong`, and `contrast-2`.

<ColorPaletteGrid @category="brand" @showDescription={{false}} />
<ColorPaletteGrid @category="success" @showDescription={{false}} />
<ColorPaletteGrid @category="danger" @showDescription={{false}} />

[Learn more about semantic colors →](/docs/theme/colors)

## Surface System

The Surface system provides two types of backgrounds:

- **Surface Solid** - Opaque base layers (0-11 scale)
- **Surface Overlay** - Translucent layers (subtle, soft, medium, strong)

<SurfaceShowcase @type="overlay" />

[Learn more about the surface system →](/docs/theme/surface)

## Basic Customization

### Customizing Colors

Override semantic colors in your configuration:

```js
const { frontile } = require('@frontile/theme/plugin');

module.exports = frontile({
  themes: {
    light: {
      colors: {
        brand: {
          'contrast-1': '#ffffff',
          subtle: '#eff6ff',
          soft: '#93c5fd',
          medium: '#3b82f6',
          strong: '#1e40af',
          'contrast-2': '#000000'
        }
      }
    },
    dark: {
      colors: {
        brand: {
          'contrast-1': '#000000',
          subtle: '#1e3a8a',
          soft: '#3b82f6',
          medium: '#60a5fa',
          strong: '#dbeafe',
          'contrast-2': '#ffffff'
        }
      }
    }
  }
});
```

### Setting Default Theme

Specify which theme loads by default:

```js
module.exports = frontile({
  defaultTheme: 'light', // or 'dark'
  themes: {
    // ... your themes
  }
});
```

## Best Practices

### Use Semantic Colors

Always prefer semantic color classes over generic Tailwind utilities:

```hbs
{{! Good - uses semantic colors }}
<button class='bg-brand-medium text-brand-contrast-1 hover:bg-brand-soft'>
  Submit
</button>

{{! Avoid - hard-coded colors don't adapt to theme }}
<button class='bg-blue-500 text-white hover:bg-blue-400'>
  Submit
</button>
```

### Use Surface System for Backgrounds

Use the surface system for component backgrounds:

```hbs
{{! Good - uses surface solid for base }}
<div class='bg-surface-solid-1'>
  {{! Good - uses overlay for elevated surface }}
  <div class='bg-surface-overlay-soft rounded-lg p-4'>
    Card content
  </div>
</div>
```

### Test in Both Modes

Always verify your UI in both light and dark modes:

```html
<!-- Test light mode -->
<html class="light">
  <!-- Your app -->
</html>

<!-- Test dark mode -->
<html class="dark">
  <!-- Your app -->
</html>
```
