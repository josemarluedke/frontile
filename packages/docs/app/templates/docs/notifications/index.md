# Notifications Installation

```sh
ember install @frontile/notifications
```

## Styles

```js
// tailwind.config.js

module.exports = {
  purge: {
    // ...
    options: {
      safelist: [
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
