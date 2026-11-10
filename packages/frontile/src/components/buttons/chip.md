---
imports:
  - import Signature from 'site/components/signature';
---

# Chip

Chips are compact, interactive elements — a filter you can toggle, a link to a
related item, a removable value in a multi-select field. The body of a Chip is a
link or a button, and a Chip can also carry a close button. For a status, a tag or
a count that does nothing when clicked, use a
[Badge](/docs/components/status/badge).

## Import

```js
import { Chip } from 'frontile';
```

## Usage

```gts preview
import { Chip } from 'frontile';

const noop = (): void => {};

<template>
  <div class='flex flex-wrap items-center gap-3'>
    <Chip @href='https://github.com/josemarluedke/frontile'>Link chip</Chip>
    <Chip @onPress={{noop}}>Pressable chip</Chip>
  </div>
</template>
```

The body is a link when you pass `@href` or `@route`, and a button when you pass
`@onPress`. See [Links](#links) and [Pressable](#pressable).

## Links

`@href` renders the body as a plain anchor, which is the choice when your app has
no router or the link leaves it.

```gts preview
import { Chip } from 'frontile';

<template>
  <div class='flex flex-wrap items-center gap-3'>
    <Chip @href='https://github.com/josemarluedke/frontile' @color='primary'>
      Frontile on GitHub
    </Chip>
    <Chip
      @href='https://github.com/josemarluedke/frontile'
      @variant='soft'
      @color='primary'
    >
      Soft link
    </Chip>
  </div>
</template>
```

`@route` renders an Ember `LinkTo`. Pass `@model`, `@models` or `@query` for dynamic
segments and query params. The docs site has no routes for a Chip to link to, so
this example is shown as reference and not rendered.

```gts
import { Chip } from 'frontile';
import { hash } from '@ember/helper';

<template>
  <Chip @route='projects.project' @model='frontile'>Frontile</Chip>
  <Chip @route='projects' @query={{hash status='open'}}>Open projects</Chip>
</template>
```

When more than one of `@route`, `@href` and `@onPress` is given, `@route` wins,
then `@href`.

## Pressable

`@onPress` renders the body as a button and calls the handler with the same
`PressEvent` as [Button](/docs/components/buttons/button). It runs for a click,
`Enter` and `Space`.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Chip } from 'frontile';

export default class Example extends Component {
  @tracked count = 0;

  increment = (): void => {
    this.count += 1;
  };

  <template>
    <div class='flex flex-wrap items-center gap-3'>
      <Chip @onPress={{this.increment}} @color='primary'>Add one</Chip>
      <p class='text-neutral'>Pressed {{this.count}} times.</p>
    </div>
  </template>
}
```

## Selected

`@isSelected` marks a chip as selected, such as an applied filter. The chip keeps
its pressed fill, and a button body gets `aria-pressed`. Leave `@isSelected` out
for a chip that is not a toggle, so no `aria-pressed` is rendered at all.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { fn } from '@ember/helper';
import { Chip } from 'frontile';

export default class Example extends Component {
  @tracked selected = ['Fiber'];
  options = ['Fiber', 'Metro', 'Wholesale'];

  toggle = (name: string): void => {
    this.selected = this.selected.includes(name)
      ? this.selected.filter((item) => item !== name)
      : [...this.selected, name];
  };

  isSelected = (name: string): boolean => this.selected.includes(name);

  <template>
    <div class='flex flex-wrap items-center gap-2'>
      {{#each this.options as |option|}}
        <Chip
          @variant='soft'
          @color='primary'
          @isSelected={{this.isSelected option}}
          @onPress={{fn this.toggle option}}
        >
          {{option}}
        </Chip>
      {{/each}}
    </div>
  </template>
}
```

On a link body, `@isSelected` changes the color only. It does not set
`aria-current`, and `...attributes` land on the chip's wrapper and not on the
anchor, so a selected link chip is not announced as selected.

## Hover and focus

A chip with a link or button body always shows a pointer cursor and responds to
the pointer and the keyboard:

- **Hover** fills the whole chip one step stronger. It does not apply while the
  pointer is on the close button, which has its own hover.
- **Active** (while pressed) fills it one more step.
- **Focus** draws a focus ring around the body when it is reached with the
  keyboard.
- **Selected** holds the pressed fill and does not respond to hover.
- **Disabled** shows none of these.

Hover a chip, then its close button. Pressing the body and pressing the close
button are separate actions.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { array } from '@ember/helper';
import { Chip } from 'frontile';

export default class Example extends Component {
  @tracked pressed = 0;
  @tracked closed = 0;

  press = (): void => {
    this.pressed += 1;
  };

  close = (): void => {
    this.closed += 1;
  };

  <template>
    <div class='flex flex-col items-start gap-4'>
      {{#each (array 'solid' 'outline' 'soft') as |variant|}}
        <Chip
          @variant={{variant}}
          @color='primary'
          @onPress={{this.press}}
          @onClose={{this.close}}
          @closeButtonTitle='Remove {{variant}} chip'
        >
          {{variant}}
        </Chip>
      {{/each}}
      <p class='text-neutral'>
        Body pressed
        {{this.pressed}}
        times, close pressed
        {{this.closed}}
        times.
      </p>
    </div>
  </template>
}
```

## Chip Variants

`solid` is a filled chip, `outline` draws the color as a border on the
page background, and `soft` is a tinted surface with color-tinted text.

```gts preview
import { Chip } from 'frontile';

const noop = (): void => {};

<template>
  <div class='flex flex-wrap items-center gap-3'>
    <Chip @variant='solid' @onPress={{noop}}>Solid</Chip>
    <Chip @variant='outline' @onPress={{noop}}>Outline</Chip>
    <Chip @variant='soft' @onPress={{noop}}>Soft</Chip>
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
            <Chip @variant={{variant}} @color={{color}} @onPress={{noop}}>
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

const noop = (): void => {};

<template>
  <div class='flex flex-wrap items-center gap-3'>
    <Chip @size='xs' @onPress={{noop}}>Chip xs</Chip>
    <Chip @size='sm' @onPress={{noop}}>Chip sm</Chip>
    <Chip @size='md' @onPress={{noop}}>Chip md</Chip>
    <Chip @size='lg' @onPress={{noop}}>Chip lg</Chip>
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

## Chip vs Badge

A Chip is interactive. Its body is a link (`@route` or `@href`) or a button
(`@onPress`), and it can also have a close button (`@onClose`). A Chip with only
`@onClose` is the minimal removable chip, as in a multi-select field.

A chip with none of `@route`, `@href`, `@onPress` and `@onClose` does nothing when
clicked, and is not a supported use of Chip. Use a
[Badge](/docs/components/status/badge) for a status, a count or any other label
that does not respond to the user.

A Chip is always a pill, which signals that it can be acted on.

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
              @onPress={{noop}}
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

## Close Button

Passing `@onClose` makes the close button visible. It is a separate control
beside the body, never inside it, so pressing it does not press the body. A chip
with `@onClose` and no link or button body is a removable value.

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

`@isDisabled` dims the chip and disables the whole of it. A button body is
`disabled`, a link body drops its `href` and gets `aria-disabled="true"`, and the
close button is disabled, so the value can no longer be removed.

```gts preview
import { Chip } from 'frontile';

const noop = (): void => {};

<template>
  <div class='flex flex-wrap items-center gap-3'>
    <Chip @onPress={{noop}} @isDisabled={{true}}>Button</Chip>
    <Chip
      @href='https://github.com/josemarluedke/frontile'
      @isDisabled={{true}}
    >
      Link
    </Chip>
    <Chip @onClose={{noop}} @isDisabled={{true}}>Removable</Chip>
  </div>
</template>
```

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

A `Chip` is a wrapper `<div>` with no role of its own. Its body is a real link or
button, and the close button is a real `<button>` beside it. They are siblings, so
each has its own tab stop and focus ring, and a button is never nested inside a
link or another button.

- **Links and buttons.** `@route` and `@href` render an anchor, and are for going
  somewhere. `@onPress` renders a `<button type="button">`, and is for doing
  something on the page. Pick by what the chip does.
- **Keyboard.** `Enter` and `Space` activate a button body, and `Enter` activates a
  link body. `Backspace` or `Delete` on a focused body or close button calls
  `@onClose` when it is set and the chip is not disabled, and does nothing
  otherwise.
- **Selected.** `@isSelected` gives a button body `aria-pressed`. A link body only
  changes color, and sets no `aria-current`.
- **Disabled.** A disabled button body is `disabled`. A disabled link has no
  `href` and gets `aria-disabled="true"`, so it is announced as disabled but is
  not a link any more.
- **Close button name.** Every close button is announced as "Close" unless you set
  `@closeButtonTitle`, so give each chip a name that identifies its value; see
  [above](#naming-the-close-button).
- **Color and dots never carry meaning alone.** `@color='danger'` reads as
  "failed" to a sighted user and as nothing at all to a screen reader, so keep
  the word in the content.
- **No action, no Chip.** Do not attach a click handler to the wrapper. Use
  `@onPress` or a link, or use a [Badge](/docs/components/status/badge) for a
  label that does nothing.

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
