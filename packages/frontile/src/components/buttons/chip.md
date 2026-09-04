---
imports:
  - import Signature from 'site/components/signature';
---

# Chip

Chips are compact elements that represent an input, attribute, or action — a
filter that has been applied, a tag on a record, a value selected in a
multi-select field.

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

`default` is a filled chip, `outlined` draws the intent color as a border on the
page background, and `faded` is a tinted surface with intent-colored text.

```gts preview
import { Chip } from 'frontile';

<template>
  <div class='flex flex-wrap items-center gap-3'>
    <Chip @appearance='default'>Default</Chip>
    <Chip @appearance='outlined'>Outlined</Chip>
    <Chip @appearance='faded'>Faded</Chip>
  </div>
</template>
```

## Chip Intents

Every intent is available in every appearance. The label on each row is the
`@appearance` value; the chip labels are the `@intent` values.

```gts preview
import { Chip } from 'frontile';
import { array } from '@ember/helper';

const intents = [
  'default',
  'primary',
  'secondary',
  'tertiary',
  'success',
  'warning',
  'danger'
];

<template>
  <div class='flex flex-col gap-6'>
    {{#each (array 'default' 'outlined' 'faded') as |appearance|}}
      <div>
        <p class='font-code text-code-sm text-neutral-strong mb-2'>
          @appearance='{{appearance}}'
        </p>
        <div class='flex flex-wrap items-center gap-3'>
          {{#each intents as |intent|}}
            <Chip @appearance={{appearance}} @intent={{intent}}>
              {{intent}}
            </Chip>
          {{/each}}
        </div>
      </div>
    {{/each}}
  </div>
</template>
```

## Chip Sizes

```gts preview
import { Chip } from 'frontile';

<template>
  <div class='flex flex-wrap items-center gap-3'>
    <Chip @size='sm'>Chip sm</Chip>
    <Chip @size='md'>Chip md</Chip>
    <Chip @size='lg'>Chip lg</Chip>
  </div>
</template>
```

The dot and the close button scale with the chip, so a size change does not need
any other adjustment.

```gts preview
import { Chip } from 'frontile';
import { array } from '@ember/helper';

const noop = (): void => {};

<template>
  <div class='flex flex-col gap-6'>
    {{#each (array 'default' 'outlined' 'faded') as |appearance|}}
      <div>
        <p class='font-code text-code-sm text-neutral-strong mb-2'>
          @appearance='{{appearance}}'
        </p>
        <div class='flex flex-wrap items-center gap-3'>
          {{#each (array 'sm' 'md' 'lg') as |size|}}
            <Chip
              @appearance={{appearance}}
              @intent='primary'
              @size={{size}}
              @withDot={{true}}
              @onClose={{noop}}
              @closeButtonTitle='Remove {{size}} chip'
            >
              {{size}}
            </Chip>
          {{/each}}
        </div>
      </div>
    {{/each}}
  </div>
</template>
```

## Chip Radius

`full` is the default. Use a smaller radius when chips sit alongside other
squared-off controls.

```gts preview
import { Chip } from 'frontile';
import { array } from '@ember/helper';

<template>
  <div class='flex flex-wrap items-center gap-3'>
    {{#each (array 'none' 'sm' 'lg' 'full') as |radius|}}
      <Chip @appearance='outlined' @intent='primary' @radius={{radius}}>
        {{radius}}
      </Chip>
    {{/each}}
  </div>
</template>
```

## Chip with Dots

`@withDot` adds a small intent-colored dot before the content — useful when the
chip stands for a status and the color needs to read at a glance.

```gts preview
import { Chip } from 'frontile';
import { array } from '@ember/helper';

const intents = [
  'default',
  'primary',
  'secondary',
  'tertiary',
  'success',
  'warning',
  'danger'
];

<template>
  <div class='flex flex-col gap-6'>
    {{#each (array 'default' 'outlined' 'faded') as |appearance|}}
      <div>
        <p class='font-code text-code-sm text-neutral-strong mb-2'>
          @appearance='{{appearance}}'
        </p>
        <div class='flex flex-wrap items-center gap-3'>
          {{#each intents as |intent|}}
            <Chip
              @appearance={{appearance}}
              @intent={{intent}}
              @withDot={{true}}
            >
              {{intent}}
            </Chip>
          {{/each}}
        </div>
      </div>
    {{/each}}
  </div>
</template>
```

## Close Button

Passing `@onClose` makes the close button visible.

```gts preview
import { Chip } from 'frontile';
import { array, concat } from '@ember/helper';

const intents = [
  'default',
  'primary',
  'secondary',
  'tertiary',
  'success',
  'warning',
  'danger'
];

const noop = (): void => {};

<template>
  <div class='flex flex-col gap-6'>
    {{#each (array 'default' 'outlined' 'faded') as |appearance|}}
      <div>
        <p class='font-code text-code-sm text-neutral-strong mb-2'>
          @appearance='{{appearance}}'
        </p>
        <div class='flex flex-wrap items-center gap-3'>
          {{#each intents as |intent|}}
            <Chip
              @appearance={{appearance}}
              @intent={{intent}}
              @onClose={{noop}}
              @closeButtonTitle={{concat 'Remove ' intent}}
            >
              {{intent}}
            </Chip>
          {{/each}}
        </div>
      </div>
    {{/each}}
  </div>
</template>
```

### Dot and Close Button Together

```gts preview
import { Chip } from 'frontile';
import { array, concat } from '@ember/helper';

const intents = [
  'default',
  'primary',
  'secondary',
  'tertiary',
  'success',
  'warning',
  'danger'
];

const noop = (): void => {};

<template>
  <div class='flex flex-col gap-6'>
    {{#each (array 'default' 'outlined' 'faded') as |appearance|}}
      <div>
        <p class='font-code text-code-sm text-neutral-strong mb-2'>
          @appearance='{{appearance}}'
        </p>
        <div class='flex flex-wrap items-center gap-3'>
          {{#each intents as |intent|}}
            <Chip
              @appearance={{appearance}}
              @intent={{intent}}
              @withDot={{true}}
              @onClose={{noop}}
              @closeButtonTitle={{concat 'Remove ' intent}}
            >
              {{intent}}
            </Chip>
          {{/each}}
        </div>
      </div>
    {{/each}}
  </div>
</template>
```

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

### Keeping the close button out of the tab order

`@closeButtonTabIndex="-1"` makes a chip's close button a pointer-only affordance.
Reach for it when chips sit _inside_ another control — a multi-select field, say —
where each chip would otherwise cost a Tab stop before the control itself is
reachable. `Select` does exactly this in chips mode. If you do it, you owe keyboard
users another way to remove a chip (`Select` uses `Backspace` on the field); leaving
them with no route at all is worse than the extra tab stops.

## Disabled

`@isDisabled` dims the chip and disables its close button, so the value can no
longer be removed.

```gts preview
import { Chip } from 'frontile';
import { array } from '@ember/helper';

const intents = [
  'default',
  'primary',
  'secondary',
  'tertiary',
  'success',
  'warning',
  'danger'
];

const noop = (): void => {};

<template>
  <div class='flex flex-col gap-6'>
    {{#each (array 'default' 'outlined' 'faded') as |appearance|}}
      <div>
        <p class='font-code text-code-sm text-neutral-strong mb-2'>
          @appearance='{{appearance}}'
        </p>
        <div class='flex flex-wrap items-center gap-3'>
          {{#each intents as |intent|}}
            <Chip
              @appearance={{appearance}}
              @intent={{intent}}
              @withDot={{true}}
              @onClose={{noop}}
              @isDisabled={{true}}
            >
              {{intent}}
            </Chip>
          {{/each}}
        </div>
      </div>
    {{/each}}
  </div>
</template>
```

## Customizing

You can also use TailwindCSS classes to customize even further.

```gts preview
import { Chip } from 'frontile';

<template>
  <Chip @appearance='outlined' @intent='primary' @class='px-20 py-2 italic'>
    Chip
  </Chip>
</template>
```

The argument `@class` overrides and merges TailwindCSS class names, while the HTML
attribute `class` just appends the class names passed in.

## Accessibility

A `Chip` is a `<div>` holding text — it has no role of its own, because a chip is
not one thing. What it means depends on what you are using it for, and that
determines what you owe it:

- **As a label or attribute** (a status, a tag, a count) it is ordinary text.
  Nothing extra is needed. Do not rely on `@intent` or `@withDot` alone to carry
  the meaning: `@intent='danger'` reads as "failed" to a sighted user and as
  nothing at all to a screen reader, so keep the word in the content.
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

`@isDisabled` does not hide the chip from assistive technology — the text is
still read, which is usually what you want for a value that is present but
locked.

## API

<Signature @component="Chip" />
