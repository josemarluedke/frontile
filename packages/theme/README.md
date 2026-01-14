## @frontile/theme

Component Library for Ember Octane apps: Theme

## Compatibility

- Ember.js v3.16 or above
- Ember CLI v2.13 or above
- Node.js v10 or above

## Installation

```sh
ember install @frontile/theme
```

### Styles

#### Tailwind CSS v3

```js
// tailwind.config.js

const { frontile, safelist } = require('@frontile/theme/plugin');

module.exports = {
  content: [
    './app/**/*.{html,js,ts,hbs,gts,gjs}',
    './node_modules/@frontile/theme/dist/**/*.js',
  ],
  safelist: [
    ...safelist,
  ],
  darkMode: "class",
  theme: {
    extend: {},
  },
  plugins: [frontile()],
  // ...
};
```

#### Tailwind CSS v4

##### Using Default Theme

For the default theme, add this to your `app/styles/app.css`:

```css
@import "tailwindcss" source("../../");
@plugin "@frontile/theme/plugin/default";
@source '../../node_modules/@frontile';
```

##### Customizing Frontile Theme

To customize the frontile theme, create a file in the root of your project named `frontile.js` with the following content:

```js
const { frontile } = require('@frontile/theme/plugin');

module.exports = frontile({ /* your config */ });
```

Then update your `app/styles/app.css` to use the custom configuration:

```css
@import "tailwindcss" source("../../");
@plugin "./../../frontile.js";
@source '../../node_modules/@frontile';
```

### Color Configuration

You can customize Frontile colors in two ways:

#### Option 1: Via Plugin Configuration (Recommended)

Configure colors in your `frontile.js` file. This approach automatically generates "on-" colors for optimal text contrast:

```js
const { frontile } = require('@frontile/theme/plugin');

module.exports = frontile({
  themes: {
    light: {
      colors: {
        brand: {
          subtle: '#3b82f6',
          medium: '#2563eb',
          strong: '#1d4ed8',
        }
      }
    },
    dark: {
      colors: {
        brand: {
          subtle: '#60a5fa',
          medium: '#3b82f6',
          strong: '#2563eb',
        }
      }
    }
  }
});
```

Use any color format (hex, rgb, hsl, oklch, etc.). The plugin automatically generates "on-" colors for optimal text contrast.

**CSS Variable References:** You can also reference other CSS variables in your configuration:

```js
module.exports = frontile({
  themes: {
    light: {
      colors: {
        brand: {
          subtle: 'var(--color-surface-solid-6)',
        }
      }
    }
  }
});
```

**Note:** When using CSS variable references, automatic "on-" color generation is skipped since the actual color value isn't known at build time. You'll need to manually define the corresponding "on-" colors if needed.

### Customizing On-Colors

The theme system automatically generates "on-color" variants (e.g., `on-brand`, `on-success`) for semantic colors to ensure optimal text contrast. These colors are used as text/foreground colors on semantic backgrounds.

By default, on-colors are calculated using WCAG contrast guidelines and will be either pure white or pure black. However, you can override these auto-generated colors to match your brand or design requirements:

```js
const { frontile } = require('@frontile/theme/plugin');

module.exports = frontile({
  themes: {
    light: {
      colors: {
        // Define background colors as usual
        brand: {
          subtle: '#3b82f6',
          soft: '#2563eb',
          medium: '#1e40af',
          strong: '#1e3a8a',
          DEFAULT: '#1e40af'
        },
        // Override on-colors to use custom values
        'on-brand': {
          subtle: '#ffffff',      // Pure white
          soft: '#e0f2ff',        // Light blue tint instead of pure white
          medium: '#ffffff',      // Pure white
          strong: '#bfdbfe',      // Lighter blue
          DEFAULT: '#ffffff'      // Pure white
        }
      }
    }
  }
});
```

**Partial overrides are supported** - any variants you don't define will still be auto-generated:

```js
module.exports = frontile({
  themes: {
    light: {
      colors: {
        brand: {
          subtle: '#3b82f6',
          medium: '#1e40af',
          strong: '#1e3a8a',
        },
        'on-brand': {
          medium: '#e0f2ff',  // Only override medium, others auto-generate
        }
      }
    }
  }
});
```

You can override on-colors for any semantic color category:
- `on-neutral`, `on-brand`, `on-accent`, `on-success`, `on-warning`, `on-danger`
- `on-surface-solid` (with numeric keys 0-11)

#### Option 2: Via CSS Variables

Override colors directly in your CSS:

```css
@import "tailwindcss" source("../../");
@plugin "@frontile/theme/plugin/default";
@source '../../node_modules/@frontile';

@theme {
  /* Override brand colors */
  --color-brand-subtle: #3b82f6;
  --color-brand-medium: #2563eb;
  --color-brand-strong: #1d4ed8;

  /* Manually define "on-" colors for text contrast */
  --color-on-brand-subtle: #ffffff;
  --color-on-brand-medium: #ffffff;
  --color-on-brand-strong: #ffffff;
}
```

**Note:** When defining colors via CSS, you must manually define corresponding "on-" colors. The plugin cannot automatically generate them because CSS variable values are not accessible at build time.

## Documentation

Visit [frontile.dev](https://frontile.dev/) to read the docs
and see live demos.

## License

This project is licensed under the [MIT License](LICENSE.md).
