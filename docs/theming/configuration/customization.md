---
title: Customization
order: 13
category: theming
subcategory: configuration
---

# Customization Guide

Complete guide to customizing Frontile's theme system, from simple token adjustments to comprehensive brand theming.

## Quick Start

The fastest way to customize Frontile is using CSS variables in your `app/styles/app.css`:

```css
@import 'tailwindcss' source('../../');
@plugin "@frontile/theme/plugin/default";
@import "@frontile/theme";

@theme {
  --radius: 12px;
  --size-icon-md: 20px;
  --opacity-hover: .9;
}
```

## Customizing Colors

### Using JavaScript Configuration

Colors should be customized using JavaScript configuration for best results. Create `frontile.js` in your project root:

```js
const { frontile } = require('@frontile/theme/plugin');

module.exports = frontile({
  themes: {
    light: {
      colors: {
        brand: {
          subtle: '#f0f9ff',
          soft: '#7dd3fc',
          medium: '#0ea5e9',
          strong: '#0c4a6e'
        },
        success: {
          subtle: '#f0fdf4',
          soft: '#86efac',
          medium: '#22c55e',
          strong: '#14532d'
        },
        danger: {
          subtle: '#fef2f2',
          soft: '#fca5a5',
          medium: '#ef4444',
          strong: '#7f1d1d'
        },
        warning: {
          subtle: '#fffbeb',
          soft: '#fde68a',
          medium: '#f59e0b',
          strong: '#78350f'
        }
      }
    },
    dark: {
      colors: {
        brand: {
          subtle: '#0c4a6e',
          soft: '#0ea5e9',
          medium: '#38bdf8',
          strong: '#e0f2fe'
        }
        // ... other colors
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

### How Color Customization Works

Frontile automatically:
- Generates contrasting text colors (`on-{color}-{level}`)
- Converts your colors to OKLCH format for perceptual uniformity
- Accepts any color format as input (hex, rgb, hsl, oklch, CSS variables)
- Creates theme-aware CSS variables
- Ensures proper contrast ratios

### Customizing On-Colors

By default, Frontile auto-generates optimal `on-{color}-{level}` text colors (black or white) based on WCAG contrast calculations. If you need specific on-colors for brand consistency, you can override them in your theme configuration:

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
        },
        // Override specific on-colors
        'on-brand': {
          medium: '#ffffff',  // Force white text on brand-medium
          strong: '#e0f2fe'   // Use light blue instead of white
        }
        // on-brand-subtle and on-brand-soft will still be auto-generated
      }
    }
  }
});
```

**Key behavior:**
- Partial overrides work — define only the levels you want to customize, and the rest will be auto-generated
- Works for: `on-neutral`, `on-brand`, `on-accent`, `on-success`, `on-warning`, `on-danger`, `on-surface-solid`
- CSS variable references (e.g., `var(--my-color)`) are passed through as-is — auto-generation is skipped since contrast can't be calculated

## Customizing Typography

### Font Families

Override font families for different text categories:

```css
@font-face {
  font-family: 'Inter';
  src: url('/fonts/inter-var.woff2') format('woff2');
  font-weight: 100 900;
  font-display: swap;
}

@font-face {
  font-family: 'JetBrains Mono';
  src: url('/fonts/jetbrains-mono.woff2') format('woff2');
  font-display: swap;
}

@theme {
  --font-header: 'Inter', system-ui, sans-serif;
  --font-body: 'Inter', system-ui, sans-serif;
  --font-label: 'Inter', system-ui, sans-serif;
  --font-code: 'JetBrains Mono', monospace;
}
```

### Theme-Specific Fonts

Use different fonts for light and dark themes:

```css
.light,
.dark .theme-inverse {
  --font-body: 'Inter', system-ui, sans-serif;
}

.dark,
.light .theme-inverse {
  --font-body: 'Geist', system-ui, sans-serif;
}
```

## Customizing Border Radius

### Global Radius

Adjust border radius throughout your application:

```css
@theme {
  /* Softer, more rounded design */
  --radius: 12px;
  --radius-xl: 20px;
  --radius-2xl: 28px;
  --radius-pill: 9999px;
}
```

### Sharp Design

Create a more angular design:

```css
@theme {
  /* Sharp, geometric design */
  --radius: 2px;
  --radius-sm: 1px;
  --radius-md: 3px;
  --radius-xl: 6px;
  --radius-2xl: 8px;
}
```

## Customizing Icon Sizes

Adjust icon sizes to match your design:

```css
@theme {
  /* Slightly larger icons */
  --size-icon-xs: 13px;
  --size-icon-sm: 15px;
  --size-icon-md: 19px;
  --size-icon-lg: 23px;
  --size-icon-xl: 27px;
}
```

## Customizing Borders

### Border Widths

Adjust border thickness:

```css
@theme {
  /* Thicker borders throughout */
  --border-width-thin: 1px;
  --border-width-default: 2px;
  --border-width-heavy: 3px;
  --border-width-aggressive: 5px;
}
```

## Customizing Elevation

### Shadow Styles

Adjust shadow intensity and style:

```css
@theme {
  /* Subtler shadows */
  --shadow-elevation-1: 0px 1px 2px rgba(0, 0, 0, 0.04);
  --shadow-elevation-2: 0px 2px 8px rgba(0, 0, 0, 0.06);
  --shadow-elevation-3: 0px 8px 16px rgba(0, 0, 0, 0.08);
  --shadow-elevation-4: 0px 16px 32px rgba(0, 0, 0, 0.12);
}
```

### Theme-Specific Shadows

Different shadows for light and dark modes:

```css
/* Light theme - softer shadows */
.light,
.dark .theme-inverse {
  --shadow-elevation-2: 0px 2px 8px rgba(0, 0, 0, 0.08);
  --shadow-elevation-3: 0px 8px 20px rgba(0, 0, 0, 0.12);
}

/* Dark theme - stronger shadows for contrast */
.dark,
.light .theme-inverse {
  --shadow-elevation-2: 0px 4px 12px rgba(0, 0, 0, 0.4);
  --shadow-elevation-3: 0px 12px 28px rgba(0, 0, 0, 0.5);
}
```

## Customizing Opacity

Adjust hover and disabled opacity:

```css
@theme {
  --opacity-hover: .9;
  --opacity-disabled: .4;
}
```

## Customizing Component Sizes

### Modal Sizes

Adjust modal dimensions:

```css
:root {
  --modal-xs: 18rem;
  --modal-sm: 22rem;
  --modal-md: 32rem;
  --modal-lg: 48rem;
  --modal-xl: 64rem;
}

/* Responsive sizing */
@media (max-width: 768px) {
  :root {
    --modal-md: 90vw;
    --modal-lg: 90vw;
    --modal-xl: 95vw;
  }
}
```

### Drawer Sizes

```css
:root {
  --drawer-sm: 20rem;
  --drawer-md: 32rem;
  --drawer-lg: 48rem;
  --drawer-xl: 64rem;
}
```

## Setting Default Theme

Specify which theme loads by default:

```js
// frontile.js
module.exports = frontile({
  defaultTheme: 'dark', // or 'light'
  themes: {
    light: { /* ... */ },
    dark: { /* ... */ }
  }
});
```

## Complete Brand Example

Here's a complete example of customizing Frontile for a brand:

### frontile.js

```js
const { frontile } = require('@frontile/theme/plugin');

module.exports = frontile({
  defaultTheme: 'light',
  themes: {
    light: {
      colors: {
        // Purple brand color
        brand: {
          subtle: '#faf5ff',
          soft: '#c084fc',
          medium: '#9333ea',
          strong: '#581c87'
        },
        // Success remains green
        success: {
          subtle: '#f0fdf4',
          soft: '#86efac',
          medium: '#22c55e',
          strong: '#14532d'
        },
        // Custom orange warning
        warning: {
          subtle: '#fff7ed',
          soft: '#fdba74',
          medium: '#f97316',
          strong: '#7c2d12'
        }
      }
    },
    dark: {
      colors: {
        brand: {
          subtle: '#581c87',
          soft: '#9333ea',
          medium: '#a855f7',
          strong: '#f3e8ff'
        }
        // ... other colors
      }
    }
  }
});
```

### app/styles/app.css

```css
@import 'tailwindcss' source('../../');
@plugin "./../../frontile.js";
@import "@frontile/theme";

/* Load custom fonts */
@font-face {
  font-family: 'Poppins';
  src: url('/fonts/poppins-var.woff2') format('woff2');
  font-weight: 100 900;
  font-display: swap;
}

@theme {
  /* Typography */
  --font-header: 'Poppins', system-ui, sans-serif;
  --font-body: 'Poppins', system-ui, sans-serif;
  --font-label: 'Poppins', system-ui, sans-serif;

  /* Rounded design */
  --radius: 12px;
  --radius-xl: 20px;
  --radius-2xl: 24px;

  /* Slightly larger icons */
  --size-icon-sm: 16px;
  --size-icon-md: 20px;
  --size-icon-lg: 24px;

  /* Subtle opacity changes */
  --opacity-hover: .9;
  --opacity-disabled: .5;
}

/* Component customization */
:root {
  /* Wider modals */
  --modal-md: 36rem;
  --modal-lg: 52rem;
}
```

## Common Customization Patterns

### Pattern 1: Minimal/Sharp Design

```css
@theme {
  --radius: 2px;
  --radius-xl: 4px;
  --radius-2xl: 6px;
  --border-width-default: 1px;
  --shadow-elevation-2: 0px 1px 3px rgba(0, 0, 0, 0.06);
}
```

### Pattern 2: Soft/Rounded Design

```css
@theme {
  --radius: 16px;
  --radius-xl: 24px;
  --radius-2xl: 32px;
  --shadow-elevation-2: 0px 8px 24px rgba(0, 0, 0, 0.08);
}
```

### Pattern 3: Bold/High Contrast

```css
@theme {
  --border-width-default: 2px;
  --border-width-heavy: 3px;
  --opacity-hover: .95;
}

.light,
.dark .theme-inverse {
  --shadow-elevation-2: 0px 4px 12px rgba(0, 0, 0, 0.15);
}
```

### Pattern 4: Subtle/Minimal

```css
@theme {
  --border-width-thin: 0.5px;
  --border-width-default: 1px;
  --opacity-hover: .85;
  --shadow-elevation-2: 0px 2px 4px rgba(0, 0, 0, 0.04);
}
```

## Advanced: Per-Component Customization

Override styles for specific components using Tailwind variants:

```css
/* Larger buttons */
.btn-lg {
  @apply px-6 py-3 text-label-lg;
}

/* Card with custom shadow */
.card {
  @apply rounded-2xl shadow-elevation-3;
}

/* Custom modal backdrop */
.modal-backdrop {
  @apply bg-surface-overlay-inverse-strong backdrop-blur-md;
}
```

## Testing Your Customizations

### Visual Regression Testing

Test your theme in different scenarios:

```html
<!-- Test light mode -->
<html class="light">
  <!-- Your components -->
</html>

<!-- Test dark mode -->
<html class="dark">
  <!-- Your components -->
</html>

<!-- Test theme-inverse -->
<div class="theme-inverse bg-surface-canvas">
  <!-- Your components -->
</div>
```

### Browser DevTools

Use browser DevTools to inspect CSS variables:

```js
// Check current value
getComputedStyle(document.documentElement).getPropertyValue('--radius');

// Test changes
document.documentElement.style.setProperty('--radius', '16px');
```

## Best Practices

### Document Your Customizations

Add comments explaining why values were chosen:

```css
@theme {
  /* Brand guideline requires 16px minimum border radius */
  --radius: 16px;

  /* Larger icons for better visibility on mobile */
  --size-icon-md: 22px;
}
```

### Use Consistent Scales

Maintain proportional relationships when customizing:

```css
/* Good - maintains scale relationships */
@theme {
  --radius-sm: 4px;
  --radius: 8px;
  --radius-xl: 16px;
  --radius-2xl: 24px;
}

/* Avoid - breaks scale relationships */
@theme {
  --radius-sm: 2px;
  --radius: 20px;
  --radius-xl: 15px;
  --radius-2xl: 8px;
}
```

### Test Accessibility

Ensure customizations maintain accessibility:

- Maintain sufficient color contrast (WCAG AA minimum 4.5:1)
- Don't reduce opacity below readable levels
- Test with screen readers
- Verify keyboard navigation remains clear

### Performance Considerations

- CSS variable changes are performant
- Avoid excessive theme switching
- Use `prefers-reduced-motion` for users who need it:

```css
@media (prefers-reduced-motion: reduce) {
  * {
    transition-duration: 0.01ms !important;
  }
}
```

## Troubleshooting

### Colors Not Updating

**Problem**: Changed color values but UI doesn't update

**Solution**: Colors must be configured via JavaScript, not CSS variables:

```js
// Correct
module.exports = frontile({
  themes: {
    light: {
      colors: {
        brand: { /* ... */ }
      }
    }
  }
});
```

### Utilities Not Generated

**Problem**: Custom CSS variable doesn't generate utility class

**Solution**: Make sure the variable is in the `@theme` block:

```css
/* Generates utilities */
@theme {
  --radius-custom: 10px;
}

/* Does NOT generate utilities */
:root {
  --radius-custom: 10px;
}
```

### Theme-Specific Values Not Applying

**Problem**: Theme-specific overrides don't work

**Solution**: Use both selectors for proper theme-inverse support:

```css
/* Correct */
.light,
.dark .theme-inverse {
  --opacity-hover: .85;
}

/* Incomplete */
.light {
  --opacity-hover: .85;
}
```

## Next Steps

- [CSS Variables Reference](css-variables.md) - Complete variable list
- [Design Tokens](../design-tokens/overview.md) - Understanding tokens
- [Theme Switching](theme-switching.md) - Implement theme toggling
