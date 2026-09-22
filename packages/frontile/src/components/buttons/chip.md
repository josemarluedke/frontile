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

## Chip Variants

`solid` is a filled chip, `outline` draws the color as a border on the
page background, and `soft` is a tinted surface with color-tinted text.

```gts preview
import { Chip } from 'frontile';

<template>
  <div class='flex flex-wrap items-center gap-3'>
    <Chip @variant='solid'>Solid</Chip>
    <Chip @variant='outline'>Outline</Chip>
    <Chip @variant='soft'>Soft</Chip>
  </div>
</template>
```

## Chip Colors

Every color is available in every variant. The label on each row is the
`@variant` value; the chip labels are the `@color` values.

```gts preview collapsible
import { Chip } from 'frontile';
import { array } from '@ember/helper';

const colors = [
  'neutral',
  'primary',
  'secondary',
  'tertiary',
  'success',
  'warning',
  'danger'
];

<template>
  <div class='flex flex-col gap-6'>
    {{#each (array 'solid' 'outline' 'soft') as |variant|}}
      <div>
        <p class='font-code text-code-sm text-neutral-strong mb-2'>
          @variant='{{variant}}'
        </p>
        <div class='flex flex-wrap items-center gap-3'>
          {{#each colors as |color|}}
            <Chip @variant={{variant}} @color={{color}}>
              {{color}}
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
    <Chip @size='xs'>Chip xs</Chip>
    <Chip @size='sm'>Chip sm</Chip>
    <Chip @size='md'>Chip md</Chip>
    <Chip @size='lg'>Chip lg</Chip>
  </div>
</template>
```

`xs` is for dense layouts such as table cells, list rows, and chips inside a form
field. It uses the same text size as `sm` and gets smaller by dropping height and
padding, because 12px is about the smallest a label stays readable. Its close
button is small. If removing the chip is the main action, use `sm` or larger.

The dot and the close button scale with the chip, so a size change does not need
any other adjustment.

```gts preview
import { Chip } from 'frontile';
import { array } from '@ember/helper';

const noop = (): void => {};

<template>
  <div class='flex flex-col gap-6'>
    {{#each (array 'solid' 'outline' 'soft') as |variant|}}
      <div>
        <p class='font-code text-code-sm text-neutral-strong mb-2'>
          @variant='{{variant}}'
        </p>
        <div class='flex flex-wrap items-center gap-3'>
          {{#each (array 'xs' 'sm' 'md' 'lg') as |size|}}
            <Chip
              @variant={{variant}}
              @color='primary'
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
      <Chip @variant='outline' @color='primary' @radius={{radius}}>
        {{radius}}
      </Chip>
    {{/each}}
  </div>
</template>
```

## Chip with Dots

`@withDot` adds a small color-tinted dot before the content — useful when the
chip stands for a status and the color needs to read at a glance.

```gts preview collapsible
import { Chip } from 'frontile';
import { array } from '@ember/helper';

const colors = [
  'neutral',
  'primary',
  'secondary',
  'tertiary',
  'success',
  'warning',
  'danger'
];

<template>
  <div class='flex flex-col gap-6'>
    {{#each (array 'solid' 'outline' 'soft') as |variant|}}
      <div>
        <p class='font-code text-code-sm text-neutral-strong mb-2'>
          @variant='{{variant}}'
        </p>
        <div class='flex flex-wrap items-center gap-3'>
          {{#each colors as |color|}}
            <Chip @variant={{variant}} @color={{color}} @withDot={{true}}>
              {{color}}
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

```gts preview collapsible
import { Chip } from 'frontile';
import { array, concat } from '@ember/helper';

const colors = [
  'neutral',
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
    {{#each (array 'solid' 'outline' 'soft') as |variant|}}
      <div>
        <p class='font-code text-code-sm text-neutral-strong mb-2'>
          @variant='{{variant}}'
        </p>
        <div class='flex flex-wrap items-center gap-3'>
          {{#each colors as |color|}}
            <Chip
              @variant={{variant}}
              @color={{color}}
              @onClose={{noop}}
              @closeButtonTitle={{concat 'Remove ' color}}
            >
              {{color}}
            </Chip>
          {{/each}}
        </div>
      </div>
    {{/each}}
  </div>
</template>
```

### Dot and Close Button Together

```gts preview collapsible
import { Chip } from 'frontile';
import { array, concat } from '@ember/helper';

const colors = [
  'neutral',
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
    {{#each (array 'solid' 'outline' 'soft') as |variant|}}
      <div>
        <p class='font-code text-code-sm text-neutral-strong mb-2'>
          @variant='{{variant}}'
        </p>
        <div class='flex flex-wrap items-center gap-3'>
          {{#each colors as |color|}}
            <Chip
              @variant={{variant}}
              @color={{color}}
              @withDot={{true}}
              @onClose={{noop}}
              @closeButtonTitle={{concat 'Remove ' color}}
            >
              {{color}}
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
          @variant='soft'
          @color='primary'
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

```gts preview collapsible
import { Chip } from 'frontile';
import { array } from '@ember/helper';

const colors = [
  'neutral',
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
    {{#each (array 'solid' 'outline' 'soft') as |variant|}}
      <div>
        <p class='font-code text-code-sm text-neutral-strong mb-2'>
          @variant='{{variant}}'
        </p>
        <div class='flex flex-wrap items-center gap-3'>
          {{#each colors as |color|}}
            <Chip
              @variant={{variant}}
              @color={{color}}
              @withDot={{true}}
              @onClose={{noop}}
              @isDisabled={{true}}
            >
              {{color}}
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
  <Chip @variant='outline' @color='primary' @class='px-20 py-2 italic'>
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
  Nothing extra is needed. Do not rely on `@color` or `@withDot` alone to carry
  the meaning: `@color='danger'` reads as "failed" to a sighted user and as
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

```gts preview collapsible
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
            @variant='outline'
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
