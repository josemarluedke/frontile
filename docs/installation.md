---
title: Installation
---

# Installation

Frontile is separated into several packages so you can choose what features you
want in your project. Here you can find information on how to install all the packages.

## Packages

```sh
# Independently of which other packages you will use,
# you will need to have those two packages installed:
ember install @frontile/utilities
ember install @frontile/theme

# Optional packages:
ember install @frontile/buttons
ember install @frontile/collections
ember install @frontile/status
ember install @frontile/forms
ember install @frontile/changeset-form
ember install @frontile/notifications
ember install @frontile/overlays
```

## Setup Theme

Add `frontile` plugin to your tailwind `tailwind.config.js`, add options to `content` and `safelist`.

```js
// tailwind.config.js
const { frontile, safelist } = require('@frontile/theme/plugin');

/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: 'class',
  plugins: [frontile()],

  content: [
    // ....
    './node_modules/@frontile/theme/dist/**/*.{js,ts}'
  ],

  safelist: [
    ...safelist,

    // Power Select
    { pattern: /^ember-power-select/ }
  ]
  // ...
};

```
