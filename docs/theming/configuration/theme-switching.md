---
title: Theme Switching
order: 12
category: theming
subcategory: configuration
---

# Theme Switching

Frontile supports light and dark themes with seamless switching and theme inversion for creating visual contrast within your application.

## Basic Light/Dark Mode

Toggle between light and dark themes by adding or removing the `dark` class on a parent element (typically `<html>` or `<body>`):

```html
<!-- Dark mode -->
<html class="dark">
  <!-- All content uses dark theme -->
</html>

<!-- Light mode -->
<html class="light">
  <!-- All content uses light theme -->
</html>
```

The `light` class is optional since light mode is the default. However, it's useful when you want to be explicit.

## Implementing Theme Switching

### Client-Side Toggle

Here's a basic implementation for theme switching:

```gts
import { Component } from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';

export default class ThemeToggle extends Component {
  @tracked isDark = false;

  constructor(owner, args) {
    super(owner, args);
    // Check localStorage or system preference
    this.isDark = localStorage.getItem('theme') === 'dark' ||
      (!localStorage.getItem('theme') && window.matchMedia('(prefers-color-scheme: dark)').matches);
    this.applyTheme();
  }

  @action
  toggleTheme() {
    this.isDark = !this.isDark;
    this.applyTheme();
    localStorage.setItem('theme', this.isDark ? 'dark' : 'light');
  }

  applyTheme() {
    const html = document.documentElement;
    if (this.isDark) {
      html.classList.add('dark');
      html.classList.remove('light');
    } else {
      html.classList.add('light');
      html.classList.remove('dark');
    }
  }

  <template>
    <button {{on 'click' this.toggleTheme}}>
      {{if this.isDark '☀️ Light Mode' '🌙 Dark Mode'}}
    </button>
  </template>
}
```

### Respecting System Preference

Detect and respond to the user's system theme preference:

```js
// Check system preference on load
const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;

// Listen for system preference changes
window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
  const isDark = e.matches;
  // Update theme
  document.documentElement.classList.toggle('dark', isDark);
  document.documentElement.classList.toggle('light', !isDark);
});
```

### Persisting Theme Choice

Store the user's theme preference:

```js
// Save preference
localStorage.setItem('theme', 'dark');

// Load preference
const savedTheme = localStorage.getItem('theme');
if (savedTheme) {
  document.documentElement.classList.add(savedTheme);
}

// Or use system preference if no saved preference
if (!savedTheme) {
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
  document.documentElement.classList.add(prefersDark ? 'dark' : 'light');
}
```

## How Theme Classes Work

Frontile uses CSS selectors that intelligently apply theme-specific styles:

```css
/* Light theme styles apply to: */
.light *,                    /* Elements in light mode */
.dark .theme-inverse *       /* Theme-inverse within dark mode */

/* Dark theme styles apply to: */
.dark *,                     /* Elements in dark mode */
.light .theme-inverse *      /* Theme-inverse within light mode */
```

This means themes properly cascade and can be nested anywhere in your application.

## Theme Inverse

Create sections with inverted theme colors using the `theme-inverse` utility. In light mode, these sections display dark theme colors, and vice versa.

### Basic Usage

```gts preview
import { Button } from 'frontile';

<template>
  <div class='space-y-8 p-8'>
    {{! Regular theme section }}
    <div class='p-6 bg-surface-overlay-subtle rounded-lg'>
      <h3 class='text-header-md text-neutral-strong mb-4'>Regular Theme</h3>
      <p class='text-body-md text-neutral-firm mb-4'>
        This section uses the current theme colors.
      </p>
      <Button @intent='primary'>Primary Button</Button>
    </div>

    {{! Inverted theme section }}
    <div class='theme-inverse p-6 bg-surface-canvas rounded-lg'>
      <div class='p-6 bg-surface-overlay-subtle rounded-lg'>
        <h3 class='text-header-md text-neutral-strong mb-4'>Inverted Theme</h3>
        <p class='text-body-md text-neutral-firm mb-4'>
          This section uses the opposite theme colors automatically.
        </p>
        <Button @intent='primary'>Primary Button</Button>
      </div>
    </div>
  </div>
</template>
```

### Use Cases for Theme Inverse

Theme inverse is perfect for creating visual contrast and emphasis:

- **Hero sections** - Dark hero on light page, or vice versa
- **Feature highlights** - Draw attention to specific sections
- **Sidebars/panels** - Create visual separation
- **Marketing sections** - Alternate theme for variety

### Component Examples

All Frontile components work automatically with theme-inverse:

```gts preview
import { Button, Chip, ProgressBar } from 'frontile';

<template>
  <div class='space-y-6'>
    {{! Cards with status chips }}
    <div class='theme-inverse p-6 bg-surface-canvas rounded-lg'>
      <h4 class='text-header-sm text-neutral-strong mb-3'>Project Status</h4>
      <div class='flex flex-wrap gap-2 mb-4'>
        <Chip @intent='success'>Active</Chip>
        <Chip @intent='warning'>In Review</Chip>
        <Chip @intent='default'>Draft</Chip>
      </div>
      <ProgressBar @progress={{65}} @intent='primary' />
    </div>
  </div>
</template>
```

## Important: Modals and Overlays

### Default Behavior

By default, Modal and Drawer components render at the top level of the DOM using portals. This means they inherit the theme from `<html>` or `<body>`, **not** from `theme-inverse` sections:

```gts
import { Modal, Button, toggleState } from 'frontile';

const state = toggleState(false);

<template>
  <div class='theme-inverse p-6 bg-surface-canvas rounded-lg'>
    <p class='text-neutral-firm mb-4'>
      This section uses inverted theme, but the modal uses root theme.
    </p>
    <Button @onPress={{state.toggle}}>Open Modal</Button>

    {{! Modal renders at top level - uses root theme }}
    <Modal @isOpen={{state.current}} @onClose={{state.toggle}} as |modal|>
      <modal.Header>Modal Header</modal.Header>
      <modal.Body>
        This modal inherits from html/body, not the theme-inverse parent.
      </modal.Body>
    </Modal>
  </div>
</template>
```

### Rendering in Place

To make modals inherit `theme-inverse`, render them in place:

```gts
import { Modal, Button, toggleState } from 'frontile';

const state = toggleState(false);

<template>
  <div class='theme-inverse p-6 bg-surface-canvas rounded-lg'>
    <Button @onPress={{state.toggle}}>Open Modal</Button>

    {{! Modal renders in place - inherits theme-inverse }}
    <Modal
      @isOpen={{state.current}}
      @onClose={{state.toggle}}
      @renderInPlace={{true}}
      as |modal|
    >
      <modal.Header>Modal Header</modal.Header>
      <modal.Body>
        This modal inherits the theme-inverse from its parent.
      </modal.Body>
    </Modal>
  </div>
</template>
```

## Best Practices

### Always Set Base Backgrounds

Surface overlay colors are semi-transparent. Always provide a solid base background:

```html
<!-- ✓ Good - has base background -->
<div class="theme-inverse bg-surface-canvas">
  <div class="bg-surface-overlay-subtle p-4">
    Content
  </div>
</div>

<!-- ✗ Bad - overlay has no base -->
<div class="theme-inverse">
  <div class="bg-surface-overlay-subtle p-4">
    Content (might be invisible!)
  </div>
</div>
```

### Use Semantic Colors

Theme-inverse works automatically with semantic colors:

```html
<div class="theme-inverse p-6 bg-surface-canvas">
  <h3 class="text-neutral-strong">Heading</h3>
  <p class="text-neutral-firm">Body text</p>
  <button class="bg-brand-medium text-on-brand-medium">
    Action
  </button>
</div>
```

### Test Both Themes

Always test your UI in both light and dark modes:

```html
<!-- Test light mode -->
<html class="light">
  <!-- Your app -->
</html>

<!-- Test dark mode -->
<html class="dark">
  <!-- Your app -->
</html>
```

### Avoid Hard-Coded Colors

Don't use hard-coded Tailwind colors that don't adapt to themes:

```html
<!-- ✗ Bad - doesn't adapt to theme -->
<div class="bg-gray-900 text-white">
  Content
</div>

<!-- ✓ Good - adapts automatically -->
<div class="bg-surface-canvas text-neutral-strong">
  Content
</div>
```

## Dark/Light Variants

Tailwind's `dark:` and `light:` variants work correctly with `theme-inverse`:

```html
<div class="theme-inverse p-6 bg-surface-canvas">
  <div class="bg-white dark:bg-gray-900">
    <!-- In light mode with theme-inverse: shows gray-900 (dark theme) -->
    <!-- In dark mode with theme-inverse: shows white (light theme) -->
    Content
  </div>
</div>
```

The variants understand theme-inverse contexts:
- `dark:` applies in dark mode AND in `.light .theme-inverse`
- `light:` applies in light mode AND in `.dark .theme-inverse`

## How Theme Inverse Works

Under the hood:
- Theme-inverse only works with base themes (light and dark)
- In light mode, `.light .theme-inverse` applies dark theme colors
- In dark mode, `.dark .theme-inverse` applies light theme colors
- All CSS variables are automatically swapped
- Components work without modification

## Advanced: Multiple Theme Levels

You can nest theme-inverse multiple times, though it's rarely needed:

```html
<html class="dark">
  <!-- Dark theme -->
  <div class="theme-inverse">
    <!-- Light theme -->
    <div class="theme-inverse">
      <!-- Dark theme again -->
    </div>
  </div>
</html>
```

## Next Steps

- [CSS Variables Reference](css-variables.md) - Customize theme tokens
- [Customization Guide](customization.md) - Theme customization examples
- [Colors Documentation](../design-tokens/colors.md) - Understanding semantic colors
