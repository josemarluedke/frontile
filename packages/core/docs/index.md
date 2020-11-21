---
title: Installation
order: 1
---

# Core Installation


```
ember install @frontile/core
```

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
