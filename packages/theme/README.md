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

```js
// tailwind.config.js

const { frontile, safelist } = require('@frontile/theme/plugin');

module.exports = {
  content: []
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

## Documentation

Visit [frontile.dev](https://frontile.dev/) to read the docs
and see live demos.

## License

This project is licensed under the [MIT License](LICENSE.md).
