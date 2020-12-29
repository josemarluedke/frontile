---
title: Installation
order: 1
url: /
---

# Overlays Installation


```
ember install @frontile/overlays
```

```js
// tailwind.config.js

module.exports = {
  purge: {
    // ...
    options: {
      whitelist: [
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
