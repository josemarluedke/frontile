# Forms Installation

```sh
ember install @frontile/forms
```

## Styles

```js
// tailwind.config.js

module.exports = {
  purge: {
    // ...
    options: {
      whitelist: [
        /^form-field-checkbox/,
        /^form-field-feedback/,
        /^form-field-hint/,
        /^form-field-input/,
        /^form-field-label/,
        /^form-field-radio/,
        /^form-field-textarea/,
        /^form-input/,
        /^form-textarea/,
        /^form-select/,
        /^form-checkbox/,
        /^form-radio/,
        /^form-checkbox-group/,
        /^form-radio-group/,
      ]
    }
  },
  theme: {
    // ...
  },
  plugins: [require('@frontile/forms/tailwind')]
};
```
