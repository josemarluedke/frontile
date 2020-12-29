---
title: Installation
order: 1
url: /
---

# Notifications Installation


```
ember install @frontile/notifications
```

```js
// tailwind.config.js

module.exports = {
  purge: {
    // ...
    options: {
      whitelist: [
        /^notifications-container/,
        /^notification-card/,
        /^notification-transition/
      ]
    }
  },
  theme: {
    // ...
  },
  plugins: [require('@frontile/notifications/tailwind')]
};
```
