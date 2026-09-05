---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# SegmentedControl

A row (or column) of mutually exclusive options with a single indicator that
slides between them. Use it in place of a small `RadioGroup` or a set of
`ToggleButton`s whenever the choice is small, fixed, and always visible — a
view switcher, a billing period, a density setting.

## Import

```js
import { SegmentedControl } from 'frontile';
```

## Usage

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { SegmentedControl } from 'frontile';

export default class Example extends Component {
  @tracked range = 'week';

  onChange = (value: string): void => {
    this.range = value;
  };

  <template>
    <SegmentedControl
      @value={{this.range}}
      @onChange={{this.onChange}}
      aria-label='Date range'
      as |Ctl|
    >
      <Ctl.Item @value='day'>Day</Ctl.Item>
      <Ctl.Item @value='week'>Week</Ctl.Item>
      <Ctl.Item @value='month'>Month</Ctl.Item>
    </SegmentedControl>
  </template>
}
```

`@value` is compared against each item's `@value` with `===`. Object values
must be referentially stable, or every item will read as unselected; two items
that share a value both render as selected, which is useful when the same
choice has more than one entry point but otherwise worth avoiding.

## Intents

`@variant='ghost'` drops the track's fill, which is what lets the intent color
read on the pill itself rather than competing with a filled background.

```gts preview
import { SegmentedControl } from 'frontile';

<template>
  <div class='flex flex-col items-start gap-3'>
    <SegmentedControl @value='on' @variant='ghost' @intent='default' as |Ctl|>
      <Ctl.Item @value='on'>Default</Ctl.Item>
      <Ctl.Item @value='off'>Off</Ctl.Item>
    </SegmentedControl>
    <SegmentedControl @value='on' @variant='ghost' @intent='primary' as |Ctl|>
      <Ctl.Item @value='on'>Primary</Ctl.Item>
      <Ctl.Item @value='off'>Off</Ctl.Item>
    </SegmentedControl>
    <SegmentedControl @value='on' @variant='ghost' @intent='secondary' as |Ctl|>
      <Ctl.Item @value='on'>Secondary</Ctl.Item>
      <Ctl.Item @value='off'>Off</Ctl.Item>
    </SegmentedControl>
    <SegmentedControl @value='on' @variant='ghost' @intent='tertiary' as |Ctl|>
      <Ctl.Item @value='on'>Tertiary</Ctl.Item>
      <Ctl.Item @value='off'>Off</Ctl.Item>
    </SegmentedControl>
    <SegmentedControl @value='on' @variant='ghost' @intent='success' as |Ctl|>
      <Ctl.Item @value='on'>Success</Ctl.Item>
      <Ctl.Item @value='off'>Off</Ctl.Item>
    </SegmentedControl>
    <SegmentedControl @value='on' @variant='ghost' @intent='warning' as |Ctl|>
      <Ctl.Item @value='on'>Warning</Ctl.Item>
      <Ctl.Item @value='off'>Off</Ctl.Item>
    </SegmentedControl>
    <SegmentedControl @value='on' @variant='ghost' @intent='danger' as |Ctl|>
      <Ctl.Item @value='on'>Danger</Ctl.Item>
      <Ctl.Item @value='off'>Off</Ctl.Item>
    </SegmentedControl>
  </div>
</template>
```

## Sizes

```gts preview
import { SegmentedControl } from 'frontile';

<template>
  <div class='flex flex-col items-start gap-3'>
    <SegmentedControl @value='week' @size='sm' as |Ctl|>
      <Ctl.Item @value='day'>Day</Ctl.Item>
      <Ctl.Item @value='week'>Week</Ctl.Item>
      <Ctl.Item @value='month'>Month</Ctl.Item>
    </SegmentedControl>
    <SegmentedControl @value='week' @size='md' as |Ctl|>
      <Ctl.Item @value='day'>Day</Ctl.Item>
      <Ctl.Item @value='week'>Week</Ctl.Item>
      <Ctl.Item @value='month'>Month</Ctl.Item>
    </SegmentedControl>
    <SegmentedControl @value='week' @size='lg' as |Ctl|>
      <Ctl.Item @value='day'>Day</Ctl.Item>
      <Ctl.Item @value='week'>Week</Ctl.Item>
      <Ctl.Item @value='month'>Month</Ctl.Item>
    </SegmentedControl>
  </div>
</template>
```

## Ghost

`@variant='ghost'` removes the recessed track, leaving only the indicator
pill. Reach for it inline — next to a heading, inside a toolbar — where a
solid track would compete with the surrounding content.

```gts preview
import { SegmentedControl } from 'frontile';

<template>
  <SegmentedControl @value='month' @variant='ghost' as |Ctl|>
    <Ctl.Item @value='day'>Day</Ctl.Item>
    <Ctl.Item @value='week'>Week</Ctl.Item>
    <Ctl.Item @value='month'>Month</Ctl.Item>
  </SegmentedControl>
</template>
```

## Separators

`@hasSeparators={{true}}` draws a hairline between neighbouring items. The
line on either side of the selected item is hidden, so the indicator never
appears to slide across a visible rule.

```gts preview
import { SegmentedControl } from 'frontile';

<template>
  <SegmentedControl @value='week' @hasSeparators={{true}} as |Ctl|>
    <Ctl.Item @value='day'>Day</Ctl.Item>
    <Ctl.Item @value='week'>Week</Ctl.Item>
    <Ctl.Item @value='month'>Month</Ctl.Item>
  </SegmentedControl>
</template>
```

## Full width

`@isFullWidth={{true}}` stretches the control to its container and gives
every item equal width.

```gts preview
import { SegmentedControl } from 'frontile';

<template>
  <div class='max-w-md'>
    <SegmentedControl @value='week' @isFullWidth={{true}} as |Ctl|>
      <Ctl.Item @value='day'>Day</Ctl.Item>
      <Ctl.Item @value='week'>Week</Ctl.Item>
      <Ctl.Item @value='month'>Month</Ctl.Item>
    </SegmentedControl>
  </div>
</template>
```

## Vertical

`@orientation='vertical'` stacks the items in a column and switches the arrow
keys that move between them to up/down.

```gts preview
import { SegmentedControl } from 'frontile';

<template>
  <SegmentedControl @value='week' @orientation='vertical' as |Ctl|>
    <Ctl.Item @value='day'>Day</Ctl.Item>
    <Ctl.Item @value='week'>Week</Ctl.Item>
    <Ctl.Item @value='month'>Month</Ctl.Item>
  </SegmentedControl>
</template>
```

## Disabled

An individual item can be disabled with its own `@isDisabled`; keyboard
navigation skips it and it cannot be clicked. `@isDisabled` on the control
disables every item.

```gts preview
import { SegmentedControl } from 'frontile';

<template>
  <div class='flex flex-col items-start gap-3'>
    <SegmentedControl @value='day' as |Ctl|>
      <Ctl.Item @value='day'>Day</Ctl.Item>
      <Ctl.Item @value='week' @isDisabled={{true}}>Week</Ctl.Item>
      <Ctl.Item @value='month'>Month</Ctl.Item>
    </SegmentedControl>

    <SegmentedControl @value='day' @isDisabled={{true}} as |Ctl|>
      <Ctl.Item @value='day'>Day</Ctl.Item>
      <Ctl.Item @value='week'>Week</Ctl.Item>
    </SegmentedControl>
  </div>
</template>
```

## Icon and label

Each item yields `isSelected`, so a demo can show only an icon when unselected
and add the label once selected — a compact idle state that expands to
explain itself.

```gts preview
import { SegmentedControl } from 'frontile';
import { ViewIcon, ComponentIcon, TargetIcon } from 'site/components/icons';

<template>
  <SegmentedControl @value='list' as |Ctl|>
    <Ctl.Item @value='list' as |item|>
      <ViewIcon />
      {{if item.isSelected 'List'}}
    </Ctl.Item>
    <Ctl.Item @value='grid' as |item|>
      <ComponentIcon />
      {{if item.isSelected 'Grid'}}
    </Ctl.Item>
    <Ctl.Item @value='target' as |item|>
      <TargetIcon />
      {{if item.isSelected 'Focus'}}
    </Ctl.Item>
  </SegmentedControl>
</template>
```

## Form mode

Passing `@name` switches items from `<button role="radio">` to `<label>`
wrapping a native, visually-hidden radio input under that name, so the
control's value submits with an ordinary form post — no `@onChange` required,
though one still fires. Keyboard behaviour also changes: a same-named native
radio group already handles arrow keys and focus on its own, so the component
steps aside rather than layering its own handling on top.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { SegmentedControl, Button } from 'frontile';

export default class Example extends Component {
  @tracked submitted = '';

  onSubmit = (event: SubmitEvent): void => {
    event.preventDefault();
    const data = new FormData(event.target as HTMLFormElement);
    this.submitted = String(data.get('range'));
  };

  <template>
    <form {{on 'submit' this.onSubmit}}>
      <SegmentedControl @value='week' @name='range' aria-label='Range' as |Ctl|>
        <Ctl.Item @value='day'>Day</Ctl.Item>
        <Ctl.Item @value='week'>Week</Ctl.Item>
        <Ctl.Item @value='month'>Month</Ctl.Item>
      </SegmentedControl>

      <div class='mt-3'>
        <Button @type='submit'>Submit</Button>
      </div>
    </form>

    {{#if this.submitted}}
      <p data-test-submitted>Submitted: {{this.submitted}}</p>
    {{/if}}
  </template>
}
```

> A consumer that flips `@value` asynchronously — after a network round trip,
> say — will briefly see form mode's selected-label colour flip, revert, and
> flip again while the indicator itself only moves once, at the end. This is
> a side effect of re-asserting native `checked` state a frame after the
> click so it cannot disagree with a declined or absent `@onChange`; it is
> bounded to a single frame and only visible on an async `@value`, so it is
> worth knowing about rather than mistaking for a bug.

> Any interactive content yielded into an item ends up nested inside that
> item's `<label>` in form mode. A nested link or button becomes a
> click/activation hazard — clicking it also toggles the radio — so keep
> yielded content to text, icons, and other non-interactive markup in form
> mode.

## Accessibility

The control renders `role="radiogroup"` with `aria-orientation`, and each
item is a radio (`role="radio"` in button mode, a native `<input
type="radio">` in form mode) — not a tab. Use `SegmentedControl` for a choice
that only changes a value; once tabs exist, prefer them for options that each
reveal their own panel.

The group needs an accessible name from the consumer: pass `aria-label` (as
every demo above does) or `aria-labelledby`.

| Key                        | Behaviour                                                                    |
| --------------------------- | ----------------------------------------------------------------------------- |
| `Tab`                       | Moves focus to the group. Only the selected item is a tab stop.               |
| `ArrowRight` / `ArrowDown`  | Moves selection to the next enabled item, wrapping at the end.                |
| `ArrowLeft` / `ArrowUp`     | Moves selection to the previous enabled item, wrapping at the start.          |
| `Home` / `End`              | Moves selection to the first / last enabled item.                             |

Horizontal orientation uses left/right, vertical orientation uses up/down.
Disabled items are skipped entirely. In button mode, arrow navigation both
moves focus and selects immediately (automatic activation), matching the
native `<input type="radio">` behaviour form mode gets for free — form mode
does not implement this table itself; it defers to the browser's own
same-named-radio-group keyboard handling instead of duplicating it, since
fighting native radio semantics would only reintroduce the bugs the browser
already solved.

## API

<Signature @component="SegmentedControl" />
<Signature @component="SegmentedControlItem" />
