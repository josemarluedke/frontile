# Overlays Installation

```sh
ember install @frontile/overlays
```

## Styles

```js
// tailwind.config.js

module.exports = {
  purge: {
    // ...
    options: {
      safelist: [
        /^overlay/,
        /^modal/,
        /^drawer/
      ]
    }
  },
  theme: {
    // ...
  },
  plugins: [
    require('@frontile/core/tailwind'),
    require('@frontile/overlays/tailwind')
  ]
};
```

> Note: The overlays package depends on the core styles, so you must also include `@frontile/core` Tailwind Plugin.
