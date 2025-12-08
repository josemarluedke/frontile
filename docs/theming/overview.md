---
title: Theme System
order: 1
category: theming
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

### Using Default Theme

Add this to your `app/styles/app.css`:

```css
@import 'tailwindcss' source('../../');
@plugin "@frontile/theme/plugin/default";
@import "@frontile/theme";
```

### Custom Theme Configuration

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
@import "@frontile/theme";
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
    class='bg-brand-medium text-on-brand-medium hover:bg-brand-soft px-4 py-2 rounded'
  >
    Click me
  </button>
</template>
```

This button automatically adapts to light and dark themes without additional code. The `brand-medium` color provides the right emphasis, while `on-brand-medium` automatically calculates the optimal contrasting text color (black or white) for accessibility.

## Theme Switching

Toggle between light and dark themes by adding or removing the `dark` class on a parent element (typically `<html>` or `<body>`):

```html
<html class="dark">
  <!-- Your content adapts to dark mode -->
</html>
```

Remove the `dark` class to revert to light theme. You can also explicitly use the `light` class if needed.

### How Theme Classes Work

Frontile uses custom CSS variants that intelligently apply theme-specific styles:

- **`.dark`** - When present on a parent element, all descendant elements use dark theme colors
- **`.light`** - When present on a parent element, all descendant elements use light theme colors (default)
- **`.theme-inverse`** - Inverts the current theme for a section and its descendants

The theme system uses sophisticated CSS selectors to ensure proper inheritance:

```css
/* Light theme applies to .light elements and .theme-inverse within .dark */
.light *, .dark .theme-inverse *

/* Dark theme applies to .dark elements and .theme-inverse within .light */
.dark *, .light .theme-inverse *
```

This means you can nest themes and use theme-inverse sections anywhere in your application, and the colors will automatically adapt.

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

Each category has intuitive levels: `subtle`, `soft`, `medium`, and `strong`. The `on-{color}-{level}` prefix automatically provides optimal contrasting text colors (black or white) for accessibility.

<ColorPaletteGrid @category="brand" @showDescription={{false}} />
<ColorPaletteGrid @category="success" @showDescription={{false}} />
<ColorPaletteGrid @category="danger" @showDescription={{false}} />

### How Colors Adapt to Themes

Colors automatically adapt based on the current theme (`.dark`, `.light`, or `.theme-inverse`). Frontile uses CSS variables that change their values based on the theme context:

```css
/* Example: brand-medium adapts to the theme */
.light {
  --brand-medium: 220 90% 50%;  /* Bright blue in light mode */
}

.dark {
  --brand-medium: 220 90% 60%;  /* Lighter blue in dark mode */
}
```

When you use `bg-brand-medium`, the actual color value comes from the CSS variable, which automatically switches based on whether the element is in a `.light` or `.dark` context.

### Using Colors in Your CSS

You can use semantic colors in custom CSS using the Tailwind `theme()` function or CSS variables:

```css
/* Using Tailwind theme function */
.my-component {
  background-color: theme(colors.brand.medium);
  color: theme(colors.on-brand.medium);
}

/* Using CSS variables directly */
.my-component {
  background-color: hsl(var(--brand-medium));
  color: hsl(var(--on-brand-medium));
}
```

### Customizing Colors

You can customize semantic colors using the JavaScript plugin configuration:

```js
const { frontile } = require('@frontile/theme/plugin');

module.exports = frontile({
  themes: {
    light: {
      colors: {
        brand: {
          subtle: '#eff6ff',
          soft: '#93c5fd',
          medium: '#3b82f6',
          strong: '#1e40af'
        }
      }
    },
    dark: {
      colors: {
        brand: {
          subtle: '#1e3a8a',
          soft: '#3b82f6',
          medium: '#60a5fa',
          strong: '#dbeafe'
        }
      }
    }
  }
});
```

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
          subtle: '#eff6ff',
          soft: '#93c5fd',
          medium: '#3b82f6',
          strong: '#1e40af'
        }
      }
    },
    dark: {
      colors: {
        brand: {
          subtle: '#1e3a8a',
          soft: '#3b82f6',
          medium: '#60a5fa',
          strong: '#dbeafe'
        }
      }
    }
  }
});

// Note: on-{color}-{level} classes are automatically generated
// based on the background colors you define above
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

## Advanced Configuration

### Customizing with CSS Variables

The recommended approach for Tailwind v4 is to customize theme values directly using CSS variables. This provides fine-grained control without JavaScript configuration and better performance.

#### Override Theme Defaults

Add your customizations in your `app/styles/app.css` after importing the theme:

```css
@import 'tailwindcss' source('../../');
@plugin "@frontile/theme/plugin/default";
@import "@frontile/theme";

/* Override Tailwind theme utilities */
@theme {
  /* Custom border radius values */
  --radius: 0.75rem;        /* Change default radius */
  --radius-pill: 2rem;      /* Custom pill radius */

  /* Custom opacity values */
  --opacity-hover: .9;
  --opacity-disabled: .4;
}

/* Override component-specific values */
:root {
  /* Modal sizes */
  --modal-md: 32rem;
  --modal-lg: 48rem;

  /* Drawer sizes */
  --drawer-md: 32rem;
  --drawer-lg: 48rem;
}
```

#### Theme-Specific Customization

Customize layout values for specific themes using the `.dark` and `.light` classes. **Important:** To properly target all instances of a theme including `.theme-inverse` sections, use both selectors:

```css
@import "@frontile/theme";

/* Light theme customization - targets .light AND .theme-inverse within .dark */
.light,
.dark .theme-inverse {
  --opacity-hover: .85;
}

/* Dark theme customization - targets .dark AND .theme-inverse within .light */
.dark,
.light .theme-inverse {
  --opacity-hover: .75;
  --modal-lg: 56rem;
}
```

**Why both selectors?**
- `.light` targets elements in light mode
- `.dark .theme-inverse` targets inverted sections within dark mode (which display light theme)
- This ensures your customizations apply consistently across both regular theme usage and theme-inverse sections

> **Note:** Variables in the `@theme` block automatically generate Tailwind utilities (e.g., `--radius-xl` creates `rounded-xl` class). Variables in `:root` or theme-specific selectors are for component-specific values that don't need utility classes. **Colors should be customized using the JavaScript plugin configuration, not CSS variables.**

### JavaScript Configuration

You can also configure the theme using JavaScript by creating a `frontile.js` file in your project root:

```js
const { frontile } = require('@frontile/theme/plugin');

module.exports = frontile({
  defaultTheme: 'dark',
  themes: {
    light: {
      colors: {
        // Customize semantic colors
        brand: {
          subtle: '#eff6ff',
          soft: '#93c5fd',
          medium: '#3b82f6',
          strong: '#1e40af'
        }
      },
      layout: {
        // Customize layout values
        opacity: {
          hover: .85,
          disabled: .4
        },
        radius: {
          DEFAULT: '0.75rem',
          pill: '2rem'
        }
      }
    },
    dark: {
      colors: {
        brand: {
          subtle: '#1e3a8a',
          soft: '#3b82f6',
          medium: '#60a5fa',
          strong: '#dbeafe'
        }
      }
    }
  }
});
```

Then reference it in your CSS:

```css
@import 'tailwindcss' source('../../');
@plugin "./../../frontile.js";
@import "@frontile/theme";
```

## Best Practices

### Use Semantic Colors

Always prefer semantic color classes over generic Tailwind utilities:

```hbs
{{! Good - uses semantic colors }}
<button class='bg-brand-medium text-on-brand-medium hover:bg-brand-soft'>
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
