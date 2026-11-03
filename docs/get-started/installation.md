---
title: Installation
order: 2
category: get-started
---

# Installation

Frontile is a component library for Ember.js that ships all its components in a single package. Modern build tools with tree-shaking include only the components you use in your final bundle.

## Install Frontile

Install the main `frontile` package along with the theme:

:::code-tabs

```sh title="pnpm"
pnpm install frontile @frontile/theme
```

```sh title="npm"
npm install frontile @frontile/theme
```

```sh title="yarn"
yarn add frontile @frontile/theme
```

:::

You now have access to all Frontile components:

```js
import { Button, Input, Modal, Table } from 'frontile';
```

With modern build tools and explicit imports (`.gts`/`.gjs`), only the components you import will be included in your application bundle through tree-shaking.

> **Note:** The following packages are deprecated and will be removed in 0.19.0. See the [migration guides](/docs/migrations/v0-18/) for details:
>
> - [`@frontile/changeset-form`](/docs/migrations/v0-18/changeset-form) - Use `frontile` forms instead
> - [`@frontile/forms-legacy`](/docs/migrations/v0-18/forms-legacy) - Migrate to the new `frontile` forms
>
> If you're currently using the separate scoped packages (`@frontile/buttons`, `@frontile/forms`, etc.), you can migrate to the consolidated `frontile` package by updating your imports:
>
> ```diff
> - import { Button } from '@frontile/buttons';
> + import { Button } from 'frontile';
> ```

## Set up Tailwind CSS

Frontile's theme is a Tailwind CSS v4 plugin, so your app needs Tailwind
processing its stylesheet. A new app generated from `@ember/app-blueprint` does
not include Tailwind; skip this section if your app already has it.

:::code-tabs

```sh title="pnpm"
pnpm add -D tailwindcss @tailwindcss/vite
```

```sh title="npm"
npm install -D tailwindcss @tailwindcss/vite
```

```sh title="yarn"
yarn add -D tailwindcss @tailwindcss/vite
```

:::

Add the plugin to your Vite config:

```js title="vite.config.mjs" {2,10}
import { defineConfig } from 'vite';
import tailwindcss from '@tailwindcss/vite';
import { extensions, classicEmberSupport, ember } from '@embroider/vite';
import { babel } from '@rollup/plugin-babel';

export default defineConfig({
  plugins: [
    classicEmberSupport(),
    ember(),
    tailwindcss(),
    babel({
      babelHelpers: 'runtime',
      extensions,
    }),
  ],
});
```

The stylesheet must be imported from JavaScript so it goes through Vite. Create
`app/app.css` and import it at the top of `app/app.js`:

```js title="app/app.js"
import './app.css';
```

Do not put the Tailwind imports in `app/styles/app.css`. That file is served to
the browser as-is, without passing through Tailwind, so the browser tries to
fetch `@import "@frontile/theme"` as a URL and the dev server fails with
`unexepected @embroider/virtual specifier: @embroider/virtual/@frontile/theme`.

## Setup Theme

### Using Default Theme

For the default theme, add this to your `app/app.css`:

```css title="app/app.css" {7-8}
@import 'tailwindcss' source('../');
@plugin "@frontile/theme/plugin/default";
@import "@frontile/theme";

/* Tailwind v4 skips node_modules when scanning for classes. Without these,
   Frontile's own component classes are purged and components render unstyled. */
@source '../node_modules/frontile';
@source '../node_modules/@frontile';
```

Paths are relative to this file. If your stylesheet lives somewhere else, such
as `app/styles/app.css` in an app that runs Tailwind through PostCSS, add one
`../` per extra level.

### Customizing Frontile Theme

To customize the frontile theme, create a file in the root of your project named `frontile.js` with the following content:

```js title="frontile.js"
const { frontile } = require('@frontile/theme/plugin');

module.exports = frontile({
  /* your config */
});
```

Then update your `app/app.css` to use the custom configuration:

```css title="app/app.css"
@import 'tailwindcss' source('../');
@plugin "../frontile.js";
@import "@frontile/theme";

@source '../node_modules/frontile';
@source '../node_modules/@frontile';
```

For more advanced configuration options, see the [Theme documentation](../theming/overview.md).
