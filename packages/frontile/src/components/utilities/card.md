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
border. `soft` swaps the fill for a faint tint, also without a border. The border is
1px in every variant and state.

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
handler, the role and the focus stop. Use the [`press`](/docs/components/utilities/press)
modifier for the handler. It answers mouse, touch, Enter and Space, so a card with
`role='button'` is operable from the keyboard without a separate `keydown` handler.
An `outline` card takes `@color` for its hover border. Hover keeps the 1px border and
draws a second 1px layer inside it in the same colour, so the edge reads as 2px
without moving the contents.

```gts preview collapsible
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Card, press } from 'frontile';

export default class Example extends Component {
  @tracked presses = 0;

  onPress = (): void => {
    this.presses += 1;
  };

  <template>
    <div class='demo-stack'>
      <Card
        @isInteractive={{true}}
        role='button'
        tabindex='0'
        {{press this.onPress}}
      >
        Pressed
        {{this.presses}}
        times
      </Card>
      <Card
        @isInteractive={{true}}
        @color='primary'
        role='button'
        tabindex='0'
        {{press this.onPress}}
      >
        Primary hover border
      </Card>
      <Card
        @variant='flat'
        @isInteractive={{true}}
        role='button'
        tabindex='0'
        {{press this.onPress}}
      >
        Flat
      </Card>
      <Card
        @variant='soft'
        @isInteractive={{true}}
        role='button'
        tabindex='0'
        {{press this.onPress}}
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
state. The label is stretched over the whole card with `after:absolute after:inset-0`
(Card is already `position: relative`), so a click anywhere on the card, padding
included, reaches the radio. Without that, only the text is a label and a click in
the padding hits the plain `div`. Card does not do this for you: it is a surface, so
the hit area is the call site's job. Keep the label itself unpositioned, or the
overlay will size to the label instead of the card.
`@color` picks the border colour. Selected keeps the 1px border and adds a
second 1px layer inside it in the same colour, so it reads as 2px without changing
the card's size. In Windows High Contrast (forced colors) the browser draws no
shadow, so a selected card gets a real 3px border there instead.

```gts preview collapsible
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
          <label class='block cursor-pointer after:absolute after:inset-0'>
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

## Selection indicator

A selected card can show a check badge at its top-right corner. It is opt-in: pass
an `<:indicator>` block and Card draws the circle and shows it only while
`@isSelected` is true. The icon is yours, so Card depends on no icon library; use
whichever one your app already has. The circle takes its fill from `@color`.

The label uses the same stretched overlay as the Selected example, so the whole card
is the click target. The indicator ignores pointer events and does not block it.

Once you use a named block, the card's own contents go in `<:default>`, because
Ember does not allow loose content beside named blocks.

```gts preview collapsible
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { array, fn } from '@ember/helper';
import { on } from '@ember/modifier';
import { Card } from 'frontile';
import { CheckIcon } from 'site/components/icons';

export default class Example extends Component {
  @tracked selected = 'a';

  choose = (id: string): void => {
    this.selected = id;
  };

  isSelected = (id: string): boolean => this.selected === id;

  <template>
    <fieldset class='demo-stack'>
      <legend class='sr-only'>Speed</legend>
      {{#each (array 'a' 'b' 'c') as |id|}}
        <Card
          @isInteractive={{true}}
          @color='primary'
          @isSelected={{this.isSelected id}}
          @class='has-focus-visible:ring-3 has-focus-visible:ring-focus has-focus-visible:ring-offset-2 has-focus-visible:ring-offset-background'
        >
          <:default>
            <label class='block cursor-pointer after:absolute after:inset-0'>
              <input
                type='radio'
                name='speed'
                class='sr-only'
                checked={{this.isSelected id}}
                {{on 'change' (fn this.choose id)}}
              />
              Option
              {{id}}
            </label>
          </:default>
          <:indicator><CheckIcon /></:indicator>
        </Card>
      {{/each}}
    </fieldset>
  </template>
}
```

The circle overhangs the corner by a few pixels, so a parent with
`overflow: hidden` will clip it. Leave room around the card, or avoid clipping
ancestors.

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
link inside it, or set `role` and `tabindex` through `...attributes` and add the
`press` modifier, as in the Interactive example. `press` supplies the Enter and Space
handling but not the role or the focus stop. `@isInteractive` only styles the card.
A selectable card needs the semantics and keyboard behaviour of the pattern it is
part of. A native radio input inside the card, as in the Selected example, supplies
both, as long as its label covers the whole card (`after:absolute after:inset-0`),
because Card does not forward clicks on its padding to a control inside it. A
hand-built `role='radio'` also needs `aria-checked`, a roving `tabindex` and
arrow-key handling.

The selection indicator is decorative: it is hidden from assistive technology with
`aria-hidden`, so it never replaces the selected state the radio, checkbox or
`aria-checked` already reports.

Selected and disabled are shown through `data-selected` and `data-disabled`. Neither
is announced by assistive technology, so mirror them with `aria-checked` or
`aria-disabled` where the pattern calls for it.

## API

<Signature @component="Card" />
