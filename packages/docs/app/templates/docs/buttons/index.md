# Buttons Installation

```sh
ember install @frontile/buttons
```

## Styles

```js
// tailwind.config.js

module.exports = {
  purge: {
    // ...
    options: {
      whitelist: [
        /^btn/,
      ]
    }
  },
  theme: {
    // ...
  },
  plugins: [require('@frontile/buttons/tailwind')]
};
```
