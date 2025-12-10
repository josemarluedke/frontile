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
