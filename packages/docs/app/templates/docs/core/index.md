# Core Installation

```sh
ember install @frontile/core
```

## Styles

```js
// tailwind.config.js

module.exports = {
  purge: {
    // ...
    options: {
      safelist: [
        /^close-button/,
        /^visually-hidden/
      ]
    }
  },
  theme: {
    // ...
  },
  plugins: [require('@frontile/core/tailwind')]
};
```
