---
title: Installation
order: 1
url: /
---

# Buttons Installation


```
ember install @frontile/buttons
```

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
