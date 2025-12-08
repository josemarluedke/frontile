---
title: Configuration Overview
order: 10
category: theming
subcategory: configuration
---

# Configuration

Learn how to configure and customize Frontile's theme system to match your application's design requirements.

## Overview

Frontile provides two primary methods for configuring your theme:

1. **CSS Variables** - Recommended for most customizations
2. **JavaScript Configuration** - For complex theme setups and color customization

## CSS Variables (Recommended)

The most straightforward way to customize Frontile is using CSS variables in your stylesheet. This approach leverages Tailwind v4's `@theme` directive for simple, performant customization.

### Quick Start

Add customizations after importing the theme in your `app/styles/app.css`:

```css
@import 'tailwindcss' source('../../');
@plugin "@frontile/theme/plugin/default";
@import "@frontile/theme";

@theme {
  /* Customize design tokens */
  --radius: 12px;
  --border-width-default: 2px;
  --size-icon-md: 20px;
  --opacity-hover: .85;
}
```

### What You Can Customize

Use CSS variables to customize:

- **Border radius** - `--radius`, `--radius-xl`, `--radius-pill`
- **Border widths** - `--border-width-thin`, `--border-width-heavy`
- **Icon sizes** - `--size-icon-sm`, `--size-icon-md`, `--size-icon-lg`
- **Shadows** - `--shadow-elevation-1`, `--shadow-elevation-2`
- **Opacity** - `--opacity-hover`, `--opacity-disabled`
- **Typography** - Font families, sizes, and text styles
- **Component sizes** - Modal and drawer sizes

### Benefits of CSS Variables

- **Simple** - No JavaScript configuration needed
- **Fast** - Changes are applied at CSS level
- **Flexible** - Can be changed at runtime
- **Theme-specific** - Easy to customize per theme (light/dark)

### When to Use CSS Variables

Choose CSS variables when you need to:

- Override specific design token values
- Adjust border radius, spacing, or sizing
- Customize per-theme values (different in light vs dark)
- Make runtime changes via JavaScript

## JavaScript Configuration

For more complex customization, especially colors, use JavaScript configuration. This method provides programmatic control and type safety.

### Quick Start

Create `frontile.js` in your project root:

```js
const { frontile } = require('@frontile/theme/plugin');

module.exports = frontile({
  defaultTheme: 'light',
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

Then reference it in your CSS:

```css
@import 'tailwindcss' source('../../');
@plugin "./../../frontile.js";
@import "@frontile/theme";
```

### What You Can Customize

Use JavaScript configuration for:

- **Semantic colors** - Brand, success, danger, warning, neutral
- **Default theme** - Which theme loads by default
- **Theme variants** - Create multiple theme variations
- **Complex configurations** - Programmatic theme generation

### When to Use JavaScript Configuration

Choose JavaScript configuration when you need to:

- Customize semantic colors (brand, success, danger, etc.)
- Set the default theme (light or dark)
- Create multiple theme variants
- Generate themes programmatically
- Share configuration across projects

## Comparison

| Feature | CSS Variables | JavaScript Config |
|---------|---------------|-------------------|
| **Border radius** | ✅ Recommended | ❌ Not needed |
| **Semantic colors** | ❌ Use JS instead | ✅ Recommended |
| **Icon sizes** | ✅ Recommended | ❌ Not needed |
| **Elevation shadows** | ✅ Recommended | ❌ Not needed |
| **Typography** | ✅ Recommended | ❌ Not needed |
| **Default theme** | ❌ Not possible | ✅ Use JS |
| **Runtime changes** | ✅ Easy | ❌ Requires rebuild |
| **Per-theme values** | ✅ Simple | ⚠️ More complex |

## Common Patterns

### Pattern 1: Simple Adjustments

For minor adjustments to existing tokens, use CSS variables:

```css
@theme {
  --radius: 6px;
  --opacity-hover: .9;
}
```

### Pattern 2: Custom Brand Colors

For brand color customization, use JavaScript:

```js
module.exports = frontile({
  themes: {
    light: {
      colors: {
        brand: {
          subtle: '#f0f9ff',
          soft: '#7dd3fc',
          medium: '#0ea5e9',
          strong: '#0c4a6e'
        }
      }
    }
  }
});
```

### Pattern 3: Mixed Approach

Combine both methods for comprehensive customization:

```js
// frontile.js - Customize colors
module.exports = frontile({
  themes: {
    light: {
      colors: { /* custom colors */ }
    }
  }
});
```

```css
/* app.css - Customize design tokens */
@theme {
  --radius: 8px;
  --size-icon-md: 18px;
}
```

### Pattern 4: Theme-Specific Overrides

Use CSS for theme-specific token values:

```css
/* Light theme */
.light,
.dark .theme-inverse {
  --opacity-hover: .85;
  --shadow-elevation-2: 0px 4px 12px rgba(0, 0, 0, 0.1);
}

/* Dark theme */
.dark,
.light .theme-inverse {
  --opacity-hover: .75;
  --shadow-elevation-2: 0px 4px 12px rgba(0, 0, 0, 0.3);
}
```

## Next Steps

- [CSS Variables Reference](css-variables.md) - Complete list of available variables
- [Theme Switching](theme-switching.md) - Implement light/dark mode
- [Customization Guide](customization.md) - Detailed customization examples
