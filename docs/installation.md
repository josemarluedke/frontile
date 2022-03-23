---
title: Installation
---

# Installation

Frontile is separated into several packages so you can choose what features you
want in your project. Here you can find information on how to install all the packages.

## Packages

Independently of what packages you are going to use, you will need to have the Core
package installed. Some other packages use components defined in the Core.

### Core

Package providing essential a11y and base components.

```
ember install @frontile/core
```

```js
// tailwind.config.js

module.exports = {
  // ...
  plugins: [require('@frontile/core/tailwind')]
};
```

### Buttons

Components for working with buttons.

```
ember install @frontile/buttons
```

```js
// tailwind.config.js

module.exports = {
  // ...
  plugins: [require('@frontile/buttons/tailwind')]
};
```

### Forms

Components for working with forms inputs/fields.

```
ember install @frontile/forms
```

```js
// tailwind.config.js

module.exports = {
  // ...
  plugins: [require('@frontile/forms/tailwind')]
};
```

### ChangesetForm

Integration between the Forms package and [ember-changeset](https://github.com/poteto/ember-changeset).

```
ember install @frontile/forms @frontile/changeset-form
```

```js
// tailwind.config.js

module.exports = {
  // ...
  plugins: [require('@frontile/forms/tailwind')]
};
```

### Notifications

Package that provides toast-like notifications.

```
ember install @frontile/notifications
```

```js
// tailwind.config.js

module.exports = {
  // ...
  plugins: [require('@frontile/notifications/tailwind')]
};
```

### Overlays

Components to render content over the UI, like Modal Dialogs.

```
ember install @frontile/overlays
```

```js
// tailwind.config.js

module.exports = {
  // ...
  plugins: [require('@frontile/overlays/tailwind')]
};
```

## Setting up PurgeCSS

There are two practical approaches to set up PurgeCSS to prevent the erasing of
all styles provided by Frontile. The simplest way is to use magical comments to
safelist the TailwindCSS components. The other way is to list all the classes
(or at least their prefix) in the PurgeCSS safelist config.
Check [PurgeCSS docs](https://purgecss.com/safelisting.html) adn [tailwindcss docs](https://tailwindcss.com/docs/content-configuration#using-regular-expressions) for further info on safelisting.

### Using comments

File `app/styles/app.css`:

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

### Using the safelist config option

```js
// tailwind.config.js

module.exports = {
  safelist: [
    { pattern: /^close-button/ },
    { pattern: /^js-focus-visible/ },
    { pattern: /^sr-only/ },

    // Frontile Forms
    { pattern: /^form-field-checkbox/ },
    { pattern: /^form-field-feedback/ },
    { pattern: /^form-field-hint/ },
    { pattern: /^form-field-input/ },
    { pattern: /^form-field-label/ },
    { pattern: /^form-field-radio/ },
    { pattern: /^form-field-textarea/ },
    { pattern: /^form-input/ },
    { pattern: /^form-textarea/ },
    { pattern: /^form-select/ },
    { pattern: /^form-checkbox/ },
    { pattern: /^form-radio/ },
    { pattern: /^form-checkbox-group/ },
    { pattern: /^form-radio-group/ },

    // Frontile Notifications
    { pattern: /^notifications-container/ },
    { pattern: /^notification-card/ },
    { pattern: /^notification-transition/ },

    // Frontile Overlays
    { pattern: /^overlay/ },
    { pattern: /^modal/ },
    { pattern: /^drawer/ },

    // Frontile Buttons
    { pattern: /^btn/ },
  }
  // ...
};

```
