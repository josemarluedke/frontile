---
label: New
imports:
  - import Signature from 'site/components/signature'
---

# Card

A surface for grouping content: a fill, a border, rounded corners and padding. A
Card has no regions of its own. What goes inside, and how it is laid out, is up to
you.

## Import

```js
import { Card } from 'frontile';
```

## Usage

```gts preview
import { Card } from 'frontile';

<template>
  <div class='demo-stack'>
    <Card>
      <p class='text-neutral-bolder font-semibold'>Card title</p>
      <p class='text-neutral-firm text-sm'>
        Anything can go here. Card only supplies the surface.
      </p>
    </Card>
  </div>
</template>
```

## Variants

`outline` is the default, a bordered card. `flat` keeps the card fill but hides the
border. `soft` swaps the fill for a faint tint, also without a border.

```gts preview
import { Card } from 'frontile';

<template>
  <div class='demo-stack'>
    <Card @variant='outline'>Outline</Card>
    <Card @variant='flat'>Flat</Card>
    <Card @variant='soft'>Soft</Card>
  </div>
</template>
```

## Density

`@density` sets only the padding. `comfortable` is the default.

```gts preview
import { Card } from 'frontile';

<template>
  <div class='demo-stack'>
    <Card @density='compact'>Compact</Card>
    <Card @density='comfortable'>Comfortable</Card>
    <Card @density='spacious'>Spacious</Card>
  </div>
</template>
```

## Elevation

An `outline` card is `raised` by default and casts a soft shadow. `@elevation='none'`
removes it, including the extra lift on hover for an interactive card. `flat` and
`soft` have no shadow either way, so the setting does nothing for them.

```gts preview
import { Card } from 'frontile';

<template>
  <div class='demo-stack'>
    <Card @elevation='raised'>Raised</Card>
    <Card @elevation='none'>None</Card>
  </div>
</template>
```

## Interactive

`@isInteractive` adds the hover, pressed, focus and pointer styles for a card that
can be clicked. It does not add behaviour: Card stays a `div`, and you supply the
click handler, the role, the focus stop and the keyboard handling. A card with
`role='button'` has to answer Enter and Space as well as clicks, as below. An
`outline` card takes `@color` for its hover border.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { Card } from 'frontile';

export default class Example extends Component {
  @tracked clicks = 0;

  count = (): void => {
    this.clicks += 1;
  };

  // A `role='button'` has to be operable from the keyboard: Enter and Space
  // activate it, the way a native button does.
  onKeydown = (event: KeyboardEvent): void => {
    if (event.key === 'Enter' || event.key === ' ') {
      event.preventDefault();
      this.count();
    }
  };

  <template>
    <div class='demo-stack'>
      <Card
        @isInteractive={{true}}
        role='button'
        tabindex='0'
        {{on 'click' this.count}}
        {{on 'keydown' this.onKeydown}}
      >
        Clicked
        {{this.clicks}}
        times
      </Card>
      <Card
        @isInteractive={{true}}
        @color='primary'
        role='button'
        tabindex='0'
        {{on 'click' this.count}}
        {{on 'keydown' this.onKeydown}}
      >
        Primary hover border
      </Card>
      <Card
        @variant='flat'
        @isInteractive={{true}}
        role='button'
        tabindex='0'
        {{on 'click' this.count}}
        {{on 'keydown' this.onKeydown}}
      >
        Flat
      </Card>
      <Card
        @variant='soft'
        @isInteractive={{true}}
        role='button'
        tabindex='0'
        {{on 'click' this.count}}
        {{on 'keydown' this.onKeydown}}
      >
        Soft
      </Card>
    </div>
  </template>
}
```

## Selected

`@isSelected` only changes how the card looks. Card holds no selection state and adds
no `role` or `aria-*`. Whatever provides the behaviour must also provide the
semantics and the keyboard support. The simplest way is a native control: here each
card wraps a visually hidden radio input, so Tab, the arrow keys and the screen
reader announcement all come from the browser, and the card only mirrors the checked
state. `@color` picks the border colour.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { array, fn } from '@ember/helper';
import { on } from '@ember/modifier';
import { Card } from 'frontile';

export default class Example extends Component {
  @tracked selected = 'b';

  choose = (id: string): void => {
    this.selected = id;
  };

  isSelected = (id: string): boolean => this.selected === id;

  <template>
    <fieldset class='demo-stack'>
      <legend class='sr-only'>Plan</legend>
      {{#each (array 'a' 'b' 'c') as |id|}}
        <Card
          @isInteractive={{true}}
          @color='primary'
          @isSelected={{this.isSelected id}}
          @class='has-focus-visible:ring-3 has-focus-visible:ring-focus has-focus-visible:ring-offset-2 has-focus-visible:ring-offset-background'
        >
          <label class='block cursor-pointer'>
            <input
              type='radio'
              name='plan'
              class='sr-only'
              checked={{this.isSelected id}}
              {{on 'change' (fn this.choose id)}}
            />
            Option
            {{id}}
          </label>
        </Card>
      {{/each}}
    </fieldset>
  </template>
}
```

## Disabled

A disabled card is dimmed and drops its hover and pressed styles. It can also be
selected: the selected border stays visible at the dimmed level, so a locked choice
still reads as chosen.

```gts preview
import { Card } from 'frontile';

<template>
  <div class='demo-stack'>
    <Card @isDisabled={{true}}>Disabled</Card>
    <Card @isDisabled={{true}} @isSelected={{true}} @color='primary'>
      Selected and disabled
    </Card>
  </div>
</template>
```

## Composing content

Card yields a single block, so you arrange the inside yourself. This is a row on wide
screens that becomes a tile on narrow ones, with the price and button built from
ordinary markup and the Frontile Button.

```gts preview
import { Card } from 'frontile';
import { Button } from 'frontile/buttons';

<template>
  <div class='demo-stack'>
    <Card @density='compact'>
      <div class='flex flex-col gap-4 sm:flex-row sm:items-center'>
        <div class='flex-1'>
          <p class='text-neutral-bolder font-semibold'>Main text about the option</p>
          <p class='text-neutral-firm text-sm'>Detail about the option</p>
        </div>
        <Button @color='primary' @size='sm' @class='w-full sm:w-auto'>
          Choose
        </Button>
      </div>
    </Card>
  </div>
</template>
```

## Accessibility

Card renders a plain `div` and adds no `role`, `tabindex` or `aria-*`. It is a
surface, not a control.

If the card is clickable, give it an interactive element or a role: put a `button` or
link inside it, or set `role` and `tabindex` through `...attributes` and handle Enter
and Space yourself, as in the Interactive example. `@isInteractive` only styles it.
A selectable card needs the semantics and keyboard behaviour of the pattern it is
part of. A native radio input inside the card, as in the Selected example, supplies
both; a hand-built `role='radio'` also needs `aria-checked`, a roving `tabindex` and
arrow-key handling.

Selected and disabled are shown through `data-selected` and `data-disabled`. Neither
is announced by assistive technology, so mirror them with `aria-checked` or
`aria-disabled` where the pattern calls for it.

## API

<Signature @component="Card" />
