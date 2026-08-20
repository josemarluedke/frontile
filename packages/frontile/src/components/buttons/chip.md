---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Chip

Chips are compact elements that represent an input, attribute, or action.

## Import

```js
import { Chip } from 'frontile';
```

## Usage

```gts preview
import { Chip } from 'frontile';

<template>
  <Chip>Chip</Chip>
</template>
```

## Chip Appearances

```gts preview
import { Chip } from 'frontile';

<template>
  <div>
    <Chip @appearance='default'>Default</Chip>
    <Chip @appearance='outlined'>Outlined</Chip>
    <Chip @appearance='faded'>Faded</Chip>
  </div>
</template>
```

## Chip Intents

```gts preview
import { Chip } from 'frontile';

<template>
  <div>
    <Chip @intent='default'>Chip</Chip>
    <Chip @intent='primary'>Primary</Chip>
    <Chip @intent='secondary'>Secondary</Chip>
    <Chip @intent='tertiary'>Tertiary</Chip>
    <Chip @intent='success'>Success</Chip>
    <Chip @intent='warning'>Warning</Chip>
    <Chip @intent='danger'>Danger</Chip>
  </div>
  <div class='mt-6'>
    <Chip @appearance='outlined' @intent='default'>Chip</Chip>
    <Chip @appearance='outlined' @intent='primary'>Primary</Chip>
    <Chip @appearance='outlined' @intent='secondary'>Secondary</Chip>
    <Chip @appearance='outlined' @intent='tertiary'>Tertiary</Chip>
    <Chip @appearance='outlined' @intent='success'>Success</Chip>
    <Chip @appearance='outlined' @intent='warning'>Warning</Chip>
    <Chip @appearance='outlined' @intent='danger'>Danger</Chip>
  </div>
  <div class='mt-6'>
    <Chip @appearance='faded' @intent='default'>Chip</Chip>
    <Chip @appearance='faded' @intent='primary'>Primary</Chip>
    <Chip @appearance='faded' @intent='secondary'>Secondary</Chip>
    <Chip @appearance='faded' @intent='tertiary'>Tertiary</Chip>
    <Chip @appearance='faded' @intent='success'>Success</Chip>
    <Chip @appearance='faded' @intent='warning'>Warning</Chip>
    <Chip @appearance='faded' @intent='danger'>Danger</Chip>
  </div>
</template>
```

## Chip with Dots

```gts preview
import { Chip } from 'frontile';

<template>
  <div>
    <Chip @appearance='outlined' @intent='default' @withDot={{true}}>Chip</Chip>
    <Chip
      @appearance='outlined'
      @intent='primary'
      @withDot={{true}}
    >Primary</Chip>
    <Chip
      @appearance='outlined'
      @intent='secondary'
      @withDot={{true}}
    >Secondary</Chip>
    <Chip
      @appearance='outlined'
      @intent='tertiary'
      @withDot={{true}}
    >Tertiary</Chip>
    <Chip
      @appearance='outlined'
      @intent='success'
      @withDot={{true}}
    >Success</Chip>
    <Chip
      @appearance='outlined'
      @intent='warning'
      @withDot={{true}}
    >Warning</Chip>
    <Chip
      @appearance='outlined'
      @intent='danger'
      @withDot={{true}}
    >Danger</Chip>
  </div>
</template>
```

## Close Button

If you pass the `@onClose` argument, the close button will be visible.

```gts preview
import Component from '@glimmer/component';
import { action } from '@ember/object';
import { Chip } from 'frontile';

export default class DemoComponent extends Component {
  @action
  onClose() {
    console.log('close');
  }

  <template>
    <Chip @appearance='faded' @onClose={{this.onClose}}>My Chip</Chip>
    <Chip @appearance='faded' @intent='primary' @onClose={{this.onClose}}>My
      Chip</Chip>
    <Chip @appearance='faded' @intent='secondary' @onClose={{this.onClose}}>My
      Chip</Chip>
    <Chip @appearance='faded' @intent='tertiary' @onClose={{this.onClose}}>My
      Chip</Chip>
    <Chip @appearance='faded' @intent='success' @onClose={{this.onClose}}>My
      Chip</Chip>
    <Chip @appearance='faded' @intent='warning' @onClose={{this.onClose}}>My
      Chip</Chip>
    <Chip @appearance='faded' @intent='danger' @onClose={{this.onClose}}>My Chip</Chip>
  </template>
}
```

## Chip Sizes

```gts preview
import { Chip } from 'frontile';

<template>
  <Chip @size='sm'>Chip</Chip>
  <Chip @size='md'>Chip</Chip>
  <Chip @size='lg'>Chip</Chip>
</template>
```

## Disabled

You can pass the argument `@isDisabled` to represent a disabled chip.

```gts preview
import { Chip } from 'frontile';

<template>
  <div>
    <Chip @intent='default' @isDisabled={{true}}>Chip</Chip>
    <Chip @intent='primary' @isDisabled={{true}}>Primary</Chip>
    <Chip @intent='secondary' @isDisabled={{true}}>Secondary</Chip>
    <Chip @intent='tertiary' @isDisabled={{true}}>Tertiary</Chip>
    <Chip @intent='success' @isDisabled={{true}}>Success</Chip>
    <Chip @intent='warning' @isDisabled={{true}}>Warning</Chip>
    <Chip @intent='danger' @isDisabled={{true}}>Danger</Chip>
  </div>
</template>
```

You can also use TailwindCSS classes to customize even further.

```gts preview
import { Chip } from 'frontile';

<template>
  <Chip @appearance='outlined' @intent='primary' @class='px-20 py-2 italic'>
    Chip
  </Chip>
</template>
```

Note that here we used the HTML attribute `class`, instead of the argument `@class`.
Using the class attribute will just append the class names passed in, while the
argument `@class` will override and merge TailwindCSS class names.

### Naming the close button

Every close button is announced as "Close" unless you say otherwise, which does
not tell anyone _what_ is being removed. When several closable chips sit together
— the usual case, since chips represent a set — give each one a
`@closeButtonTitle` naming its own value:

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { concat, fn } from '@ember/helper';
import { Chip } from 'frontile';

export default class Example extends Component {
  @tracked filters = ['Fiber', 'Metro', 'Wholesale'];

  remove = (name: string): void => {
    this.filters = this.filters.filter((filter) => filter !== name);
  };

  <template>
    <div class='flex flex-wrap items-center gap-2'>
      {{#each this.filters as |filter|}}
        <Chip
          @appearance='faded'
          @intent='primary'
          @onClose={{fn this.remove filter}}
          @closeButtonTitle={{concat 'Remove ' filter}}
        >
          {{filter}}
        </Chip>
      {{else}}
        <p class='text-neutral'>All filters removed.</p>
      {{/each}}
    </div>
  </template>
}
```

## Accessibility

A `Chip` is a `<div>` holding text — it has no role of its own, because a chip is
not one thing. What it means depends on what you are using it for, and that
determines what you owe it:

- **As a label or attribute** (a status, a tag, a count) it is ordinary text.
  Nothing extra is needed. Do not rely on `@intent` alone to carry the meaning:
  `@intent='danger'` reads as "failed" to a sighted user and as nothing at all to
  a screen reader, so keep the word in the content.
- **As a removable value** — with `@onClose` — the close button is the only
  interactive part. It is a real `<button>`, reached with `Tab` and activated
  with `Enter` or `Space`, and it needs a name that identifies the chip; see
  [above](#naming-the-close-button).
- **As something clickable in its own right**, a chip is the wrong element. Put a
  `Button` or a link inside it, or use a `Button` instead — attaching a click
  handler to the `<div>` leaves it unfocusable and unannounced.

When chips represent a set that changes, the container should say so, or removals
happen silently for anyone not watching the screen. A `role='list'` wrapper gives
the set a size and position; an `aria-live` region announces the change:

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { concat, fn } from '@ember/helper';
import { Chip } from 'frontile';

export default class Example extends Component {
  @tracked tags = ['Design', 'Docs', 'Testing'];
  @tracked announcement = '';

  remove = (name: string): void => {
    this.tags = this.tags.filter((tag) => tag !== name);
    this.announcement = `${name} removed. ${this.tags.length} remaining.`;
  };

  <template>
    <ul role='list' aria-label='Tags' class='flex flex-wrap items-center gap-2'>
      {{#each this.tags as |tag|}}
        <li>
          <Chip
            @appearance='outlined'
            @onClose={{fn this.remove tag}}
            @closeButtonTitle={{concat 'Remove ' tag}}
          >
            {{tag}}
          </Chip>
        </li>
      {{/each}}
    </ul>

    <p aria-live='polite' class='text-neutral mt-3'>{{this.announcement}}</p>
  </template>
}
```

`@isDisabled` styles the chip as disabled and disables its close button, so the
value can no longer be removed. It does not hide the chip from assistive
technology — the text is still read, which is usually what you want for a value
that is present but locked.

## API

<Signature @component="Chip" />
