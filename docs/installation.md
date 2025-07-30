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
pnpm install @frontile/utilities
pnpm install @frontile/theme

# Optional packages:
pnpm install @frontile/buttons
pnpm install @frontile/collections
pnpm install @frontile/status
pnpm install @frontile/forms
pnpm install @frontile/notifications
pnpm install @frontile/overlays
```

> **Note:** The following packages are deprecated and will be removed before v1 release:
> - `@frontile/changeset-form` - Use `@frontile/forms` instead for form handling
> - `@frontile/forms-legacy` - Migrate to the new `@frontile/forms` package

## Setup Theme

### Tailwind CSS v4 (Recommended)

#### Using Default Theme

For the default theme, add this to your `app/styles/app.css`:

```css
@import 'tailwindcss' source('../../');
@plugin "@frontile/theme/plugin/default";
@source '../../node_modules/@frontile';
@custom-variant dark (&:is(.dark *));
```

#### Customizing Frontile Theme

To customize the frontile theme, create a file in the root of your project named `frontile.js` with the following content:

```js
const { frontile } = require('@frontile/theme/plugin');

module.exports = frontile({
  /* your config */
});
```

Then update your `app/styles/app.css` to use the custom configuration:

```css
@import 'tailwindcss' source('../../');
@plugin "./../../frontile.js";
@source '../../node_modules/@frontile';
```

### Tailwind CSS v3 (Legacy)

For projects still using Tailwind CSS v3, add `frontile` plugin to your `tailwind.config.js`, add options to `content` and `safelist`.

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
