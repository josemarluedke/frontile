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

## Documentation

Visit [frontile.dev](https://frontile.dev/) to read the docs
and see live demos.

## License

This project is licensed under the [MIT License](LICENSE.md).
