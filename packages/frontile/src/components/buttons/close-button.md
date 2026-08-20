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

## Usage

```gts preview
import { CloseButton } from 'frontile';

<template><CloseButton /></template>
```

## Sizes

```gts preview
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

```gts preview
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
          class='bg-primary-soft border border-primary rounded p-4 flex items-center justify-between'
        >
          <span>This is a dismissible message</span>
          <CloseButton @onPress={{this.handleClose}} />
        </div>
      {{else}}
        <p class='text-neutral'>Message dismissed (will reappear in 2 seconds)</p>
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

## Accessibility

The icon is `aria-hidden`, and the accessible name comes from `@title` rendered
inside a [`VisuallyHidden`](/docs/components/utilities/visually-hidden) — so the
button always has a name, defaulting to "Close", without any visible text.

| Key     | Behaviour                                                            |
| ------- | -------------------------------------------------------------------- |
| `Tab`   | Moves focus to the button. `disabled` removes it from the tab order. |
| `Enter` | Activates it, firing `@onPress`.                                     |
| `Space` | Activates it, firing `@onPress`.                                     |

Because the `press` modifier calls `preventDefault()` on Enter and Space, the
browser never synthesises a `click` — so use `@onPress` rather than a
`{{on "click"}}` handler, or keyboard users get nothing. This is the same reason
`@onClick` is deprecated.

### Set `@title` when there is more than one

"Close" is a fine name for the single dismiss button on a modal. It is a poor one
in a list, where every button is announced identically and none of them says what
it closes. Name the thing:

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { concat, fn } from '@ember/helper';
import { CloseButton } from 'frontile';

export default class Example extends Component {
  @tracked messages = ['Deploy finished', 'Backup complete', 'Invite sent'];

  dismiss = (message: string): void => {
    this.messages = this.messages.filter((item) => item !== message);
  };

  <template>
    <ul role='list' aria-label='Notifications' class='flex flex-col gap-2'>
      {{#each this.messages as |message|}}
        <li
          class='bg-surface-card border border-neutral-soft rounded flex items-center justify-between gap-4 p-3'
        >
          <span>{{message}}</span>
          <CloseButton
            @title={{concat 'Dismiss: ' message}}
            @onPress={{fn this.dismiss message}}
          />
        </li>
      {{else}}
        <li class='text-neutral'>Nothing left to dismiss.</li>
      {{/each}}
    </ul>
  </template>
}
```

Passing a block replaces the default icon, and with it the `aria-hidden` that
kept the icon out of the accessible name. Mark your own icon `aria-hidden='true'`
so the name stays whatever `@title` says:

```gts preview
import { CloseButton } from 'frontile';
import { DeleteIcon } from 'site/components/icons';

<template>
  <CloseButton @title='Delete draft' as |iconClass|>
    <DeleteIcon class={{iconClass}} aria-hidden='true' />
  </CloseButton>
</template>
```

Removing something on press leaves focus on a button that no longer exists, which
drops it back to the top of the document. Move focus somewhere deliberate — the
next item, or the container that held the removed one.

## Migration from onClick

If you're currently using `@onClick`, you should migrate to `@onPress` for better cross-platform support:

```js
// ❌ Deprecated - will show a deprecation warning
<CloseButton @onClick={{this.handleClick}} />

// ✅ Recommended - better cross-platform support
<CloseButton @onPress={{this.handlePress}} />
```

The `@onClick` argument is still supported, but has been deprecated since v0.17
and will be removed in a future release. `@onPress` covers the same cases and
more:

- Better touch device support
- Automatic keyboard accessibility
- Consistent behavior across all input methods
- Enhanced pointer event handling

## API

<Signature @component="CloseButton" />
