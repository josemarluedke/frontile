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
      whitelist: [
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
