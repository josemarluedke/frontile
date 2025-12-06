---
order: 4
category: theme
---

# Customization

Frontile's theme system is built on Tailwind CSS, providing semantic colors and surfaces that automatically adapt between light and dark modes. This guide covers installation, configuration, and customization.

## Installation

Install the theme package using Ember CLI:

```bash
ember install @frontile/theme
```

## Configuration

### Tailwind CSS v4 (Recommended)

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
@custom-variant dark (&:is(.dark *));
```

### Tailwind CSS v3

Modify your `tailwind.config.js`:

```javascript
const { frontile, safelist } = require('@frontile/theme/plugin');

module.exports = {
  content: [
    './app/**/*.{html,js,ts,hbs,gts,gjs}',
    './node_modules/@frontile/theme/dist/**/*.js'
  ],
  safelist: [...safelist],
  darkMode: 'class',
  theme: {
    extend: {}
  },
  plugins: [frontile()]
};
```

## Theme Switching

Frontile supports theme switching via the `dark` class. Toggle between light and dark themes by adding or removing the class on a parent element (typically `<html>` or `<body>`):

```html
<html class="dark">
  <!-- Your content adapts to dark mode -->
</html>
```

Remove the `dark` class to revert to light theme. You can also explicitly use the `light` class if needed.

## Customizing Colors

### Understanding Color Structure

Frontile uses semantic color categories (neutral, brand, success, danger, warning, inverse) with named levels (contrast-1, subtle, soft, medium, strong, contrast-2).

Each color in the palette follows this structure:

```js
{
  'contrast-1': '#ffffff',  // High contrast (white) for text on dark backgrounds
  'subtle': '#f0f9ff',      // Minimal emphasis and backgrounds
  'soft': '#93c5fd',        // Moderate emphasis
  'medium': '#3b82f6',      // Standard emphasis (often the DEFAULT)
  'strong': '#1e3a8a',      // Maximum emphasis
  'contrast-2': '#000000'   // High contrast (black) for text on light backgrounds
}
```

See the [Colors documentation](/docs/theme/colors) for complete details on each level's purpose.

### Customizing Semantic Colors

Override default colors in your configuration:

```js
const { frontile } = require('@frontile/theme/plugin');

module.exports = frontile({
  themes: {
    light: {
      colors: {
        brand: {
          'contrast-1': '#ffffff',
          'subtle': '#eff6ff',
          'soft': '#93c5fd',
          'medium': '#3b82f6',
          'strong': '#1e40af',
          'contrast-2': '#000000'
        },
        success: {
          'contrast-1': '#ffffff',
          'subtle': '#f0fdf4',
          'soft': '#86efac',
          'medium': '#22c55e',
          'strong': '#15803d',
          'contrast-2': '#000000'
        }
        // ... other semantic colors
      }
    },
    dark: {
      colors: {
        brand: {
          'contrast-1': '#000000',
          'subtle': '#1e3a8a',
          'soft': '#3b82f6',
          'medium': '#60a5fa',
          'strong': '#dbeafe',
          'contrast-2': '#ffffff'
        }
        // ... other semantic colors (often inverted from light)
      }
    }
  }
});
```

### Customizing Surface Colors

Override surface solid or overlay colors:

```js
module.exports = frontile({
  themes: {
    light: {
      colors: {
        surface: {
          solid: {
            0: '#ffffff',
            1: '#f9f9f9',
            2: '#f1f1f1',
            // ... through 11
            11: '#000000'
          },
          overlay: {
            subtle: '#00000005',
            soft: '#0000000a',
            medium: '#00000012',
            strong: '#0000001C'
          }
        }
      }
    }
  }
});
```

See the [Surface documentation](/docs/theme/surface) for guidance on the surface system.

## Creating Custom Themes

### Extending Existing Themes

Create new themes by extending existing ones:

```js
module.exports = frontile({
  themes: {
    light: {
      // ... base light theme
    },
    dark: {
      // ... base dark theme
    },
    highContrast: {
      extend: 'dark',
      colors: {
        neutral: {
          'contrast-1': '#000000',
          'strong': '#ffffff',
          'medium': '#ffffff',
          // ... adjust for higher contrast
        },
        surface: {
          solid: {
            0: '#000000',
            1: '#0a0a0a',
            // ... darker surfaces
            11: '#ffffff'
          }
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
<button class="bg-brand-medium text-brand-contrast-1 hover:bg-brand-soft">
  Submit
</button>

{{! Avoid - hard-coded colors don't adapt to theme }}
<button class="bg-blue-500 text-white hover:bg-blue-400">
  Submit
</button>
```

### Use Surface System for Backgrounds

Use the surface system for component backgrounds:

```hbs
{{! Good - uses surface solid for base }}
<div class="bg-surface-solid-1">
  {{! Good - uses overlay for elevated surface }}
  <div class="bg-surface-overlay-soft rounded-lg p-4">
    Card content
  </div>
</div>

{{! Avoid - mixing old content colors }}
<div class="bg-content1">
  <div class="bg-content2 rounded-lg p-4">
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

## Migrating from Old Colors

If upgrading from an older version of Frontile:

| Old Color        | New Semantic Color | Notes                                    |
| ---------------- | ------------------ | ---------------------------------------- |
| `primary-*`      | `brand-*`          | Renamed for clarity                      |
| `default-*`      | `neutral-*`        | More descriptive name                    |
| `content1`       | `surface-solid-1`  | Part of new surface system               |
| `content2-4`     | `surface-overlay-*`| Now translucent overlays                 |
| `background`     | `surface-solid-0`  | Use solid-0 or solid-1 for page backgrounds |
| `foreground`     | `surface-solid-11` | Use for primary text                     |

See the [Semantic Colors v2 migration guide](/docs/migration/semantic-colors-v2) for complete migration instructions.

## Additional Resources

- **[Theme Overview](/docs/theme/overview)** - Introduction to the theme system
- **[Semantic Colors](/docs/theme/colors)** - Complete color reference with examples
- **[Surface System](/docs/theme/surface)** - Surface solid and overlay reference
- **[Component Styles](/docs/theme/component-styles)** - Customize component appearance
