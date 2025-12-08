---
title: Installation
---

# Installation

Frontile is a comprehensive component library for Ember.js that provides all the components you need in a single package. Modern build tools with tree-shaking will ensure only the components you use are included in your final bundle.

## Install Frontile

Install the main `frontile` package along with the theme:

```sh
pnpm install frontile @frontile/theme
```

That's it! You now have access to all Frontile components:

```js
import { Button, Input, Modal, Table } from 'frontile';
```

With modern build tools and explicit imports (`.gts`/`.gjs`), only the components you import will be included in your application bundle through tree-shaking.

> **Note:** The following packages are deprecated and will be removed before v1 release:
>
> - `@frontile/changeset-form` - Use `@frontile/forms` instead for form handling
> - `@frontile/forms-legacy` - Migrate to the new `@frontile/forms` package
>
> If you're currently using the separate scoped packages (`@frontile/buttons`, `@frontile/forms`, etc.), you can migrate to the consolidated `frontile` package. Simply update your imports:
>
> ```diff
> - import { Button } from '@frontile/buttons';
> + import { Button } from 'frontile';
> ```

## Setup Theme

### Using Default Theme

For the default theme, add this to your `app/styles/app.css`:

```css
@import 'tailwindcss' source('../../');
@plugin "@frontile/theme/plugin/default";
@import "@frontile/theme";
```

### Customizing Frontile Theme

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
@import "@frontile/theme";
```

For more advanced configuration options, see the [Theme documentation](theming/overview.md).
