---
title: Installation
order: 1
url: /
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
