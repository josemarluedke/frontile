---
imports:
  - import Signature from 'site/components/signature';
---

# CloseButton

This component provides the commonly used Close Button with an icon.

It is also used under other components in Frontile, for example `Modal` and `Drawer`

## Import

```js
import { CloseButton } from 'frontile';
```

```gjs preview
import { CloseButton } from 'frontile';

<template>
  <div class='flex items-center space-x-2'>
    <CloseButton @size='xs' />
    <CloseButton @size='sm' />
    <CloseButton @size='md' />
    <CloseButton @size='lg' />
    <CloseButton @size='xl' />
  </div>
</template>
```

## Press Interactions

The CloseButton component supports press interactions through the `@onPress` callback, providing cross-platform support for mouse, touch, and keyboard events.

```gjs preview
import { CloseButton } from 'frontile';
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';

export default class CloseButtonExample extends Component {
  @tracked isVisible = true;

  handleClose = () => {
    this.isVisible = false;
    // Reset after a delay for demo purposes
    setTimeout(() => {
      this.isVisible = true;
    }, 2000);
  };

  <template>
    <div class='flex items-center space-x-4'>
      {{#if this.isVisible}}
        <div
          class='bg-brand-soft border border-brand-medium rounded p-4 flex items-center justify-between'
        >
          <span>This is a dismissible message</span>
          <CloseButton @onPress={{this.handleClose}} />
        </div>
      {{else}}
        <p class='text-gray-500'>Message dismissed (will reappear in 2 seconds)</p>
      {{/if}}
    </div>
  </template>
}
```

### Press State

CloseButtons automatically track their pressed state and add a `data-pressed` attribute when being pressed, which can be used for styling:

```css
button[data-pressed='true'] {
  transform: scale(0.95);
  transition: transform 0.1s ease;
}
```

### Keyboard Accessibility

The press interaction automatically handles keyboard accessibility, responding to both Enter and Space key presses, making your close buttons fully accessible to keyboard and screen reader users.

## Migration from onClick

If you're currently using `@onClick`, you should migrate to `@onPress` for better cross-platform support:

```js
// ❌ Deprecated - will show a deprecation warning
<CloseButton @onClick={{this.handleClick}} />

// ✅ Recommended - better cross-platform support
<CloseButton @onPress={{this.handlePress}} />
```

The `@onClick` argument is still supported but deprecated and will be removed in v0.18.0. The `@onPress` callback provides the same functionality with additional benefits:

- Better touch device support
- Automatic keyboard accessibility
- Consistent behavior across all input methods
- Enhanced pointer event handling

## API

<Signature @component="CloseButton" />
