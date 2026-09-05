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

`@defaultValue` picks the item that starts selected and the control tracks the
rest itself, so the shortest working control needs no state and no handler.
Click between the items below: the indicator slides.

```gts preview
import { SegmentedControl } from 'frontile';

<template>
  <SegmentedControl @defaultValue='week' aria-label='Date range' as |Ctl|>
    <Ctl.Item @value='day'>Day</Ctl.Item>
    <Ctl.Item @value='week'>Week</Ctl.Item>
    <Ctl.Item @value='month'>Month</Ctl.Item>
  </SegmentedControl>
</template>
```

## Controlled and uncontrolled

The mode is decided by whether `@value` is *passed*, not by what it holds.
Omit the argument entirely and the control is uncontrolled; write it at all —
including `@value={{undefined}}`, or `@value={{this.selection}}` where
`selection` happens to be `undefined` — and it is controlled. That is what lets
a controlled control start with nothing selected and, later, be cleared back to
nothing by assigning `undefined`.

Without `@value` the control is uncontrolled. `@defaultValue` seeds the initial
selection, the control keeps the current one internally, and `@onChange` still
fires on every pick — so you can observe the value without having to own it.
That is the right default for a control whose selection nothing else drives.

Passing `@value` makes it controlled: the selection then only ever reflects what
you pass, so pair it with `@onChange` and assign the new value back to your own
state. Reach for it when something outside the control also sets the selection —
a query parameter, a saved preference, a value you validate before accepting.
`@defaultValue` is ignored in that mode.

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
    <div class='flex flex-col items-start gap-3'>
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

      <p class='text-body-sm text-neutral-strong'>Selected: {{this.range}}</p>
    </div>
  </template>
}
```

`@value` is compared against each item's `@value` with `===`. Object values
must be referentially stable, or every item will read as unselected; two items
that share a value both render as selected, which is useful when the same
choice has more than one entry point but otherwise worth avoiding.

## Intents

`@intent` colors the selection indicator, so the selected option carries the
meaning rather than the control as a whole. `default` keeps the neutral raised
pill; the rest tint it and switch the selected label to the matching contrast
ink.

```gts preview
import { SegmentedControl } from 'frontile';

<template>
  <div class='flex flex-col items-start gap-3'>
    <SegmentedControl
      @defaultValue='week'
      @intent='default'
      aria-label='Default intent'
      as |Ctl|
    >
      <Ctl.Item @value='day'>Day</Ctl.Item>
      <Ctl.Item @value='week'>Week</Ctl.Item>
      <Ctl.Item @value='month'>Month</Ctl.Item>
    </SegmentedControl>
    <SegmentedControl
      @defaultValue='week'
      @intent='primary'
      aria-label='Primary intent'
      as |Ctl|
    >
      <Ctl.Item @value='day'>Day</Ctl.Item>
      <Ctl.Item @value='week'>Week</Ctl.Item>
      <Ctl.Item @value='month'>Month</Ctl.Item>
    </SegmentedControl>
    <SegmentedControl
      @defaultValue='week'
      @intent='secondary'
      aria-label='Secondary intent'
      as |Ctl|
    >
      <Ctl.Item @value='day'>Day</Ctl.Item>
      <Ctl.Item @value='week'>Week</Ctl.Item>
      <Ctl.Item @value='month'>Month</Ctl.Item>
    </SegmentedControl>
    <SegmentedControl
      @defaultValue='week'
      @intent='tertiary'
      aria-label='Tertiary intent'
      as |Ctl|
    >
      <Ctl.Item @value='day'>Day</Ctl.Item>
      <Ctl.Item @value='week'>Week</Ctl.Item>
      <Ctl.Item @value='month'>Month</Ctl.Item>
    </SegmentedControl>
    <SegmentedControl
      @defaultValue='week'
      @intent='success'
      aria-label='Success intent'
      as |Ctl|
    >
      <Ctl.Item @value='day'>Day</Ctl.Item>
      <Ctl.Item @value='week'>Week</Ctl.Item>
      <Ctl.Item @value='month'>Month</Ctl.Item>
    </SegmentedControl>
    <SegmentedControl
      @defaultValue='week'
      @intent='warning'
      aria-label='Warning intent'
      as |Ctl|
    >
      <Ctl.Item @value='day'>Day</Ctl.Item>
      <Ctl.Item @value='week'>Week</Ctl.Item>
      <Ctl.Item @value='month'>Month</Ctl.Item>
    </SegmentedControl>
    <SegmentedControl
      @defaultValue='week'
      @intent='danger'
      aria-label='Danger intent'
      as |Ctl|
    >
      <Ctl.Item @value='day'>Day</Ctl.Item>
      <Ctl.Item @value='week'>Week</Ctl.Item>
      <Ctl.Item @value='month'>Month</Ctl.Item>
    </SegmentedControl>
  </div>
</template>
```

## Sizes

```gts preview
import { SegmentedControl } from 'frontile';

<template>
  <div class='flex flex-col items-start gap-3'>
    <SegmentedControl
      @defaultValue='week'
      @size='sm'
      aria-label='Small'
      as |Ctl|
    >
      <Ctl.Item @value='day'>Day</Ctl.Item>
      <Ctl.Item @value='week'>Week</Ctl.Item>
      <Ctl.Item @value='month'>Month</Ctl.Item>
    </SegmentedControl>
    <SegmentedControl
      @defaultValue='week'
      @size='md'
      aria-label='Medium'
      as |Ctl|
    >
      <Ctl.Item @value='day'>Day</Ctl.Item>
      <Ctl.Item @value='week'>Week</Ctl.Item>
      <Ctl.Item @value='month'>Month</Ctl.Item>
    </SegmentedControl>
    <SegmentedControl
      @defaultValue='week'
      @size='lg'
      aria-label='Large'
      as |Ctl|
    >
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
  <SegmentedControl
    @defaultValue='month'
    @variant='ghost'
    aria-label='Date range'
    as |Ctl|
  >
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

Four items with the first selected leaves two hairlines showing at rest. Click
along the row and watch them wink out as the indicator arrives and return
behind it.

```gts preview
import { SegmentedControl } from 'frontile';

<template>
  <SegmentedControl
    @defaultValue='day'
    @hasSeparators={{true}}
    aria-label='Date range'
    as |Ctl|
  >
    <Ctl.Item @value='day'>Day</Ctl.Item>
    <Ctl.Item @value='week'>Week</Ctl.Item>
    <Ctl.Item @value='month'>Month</Ctl.Item>
    <Ctl.Item @value='year'>Year</Ctl.Item>
  </SegmentedControl>
</template>
```

## Full width

`@isFullWidth={{true}}` stretches the control to its container and gives
every item equal width. Both controls below sit in the same 24rem panel: the
first shrinks to its labels, the second fills the line.

```gts preview
import { SegmentedControl } from 'frontile';

<template>
  <div
    class='flex w-96 max-w-full flex-col items-start gap-3 rounded-lg border border-neutral-soft p-4'
  >
    <SegmentedControl @defaultValue='week' aria-label='Default width' as |Ctl|>
      <Ctl.Item @value='day'>Day</Ctl.Item>
      <Ctl.Item @value='week'>Week</Ctl.Item>
      <Ctl.Item @value='month'>Month</Ctl.Item>
    </SegmentedControl>

    <SegmentedControl
      @defaultValue='week'
      @isFullWidth={{true}}
      aria-label='Full width'
      as |Ctl|
    >
      <Ctl.Item @value='day'>Day</Ctl.Item>
      <Ctl.Item @value='week'>Week</Ctl.Item>
      <Ctl.Item @value='month'>Month</Ctl.Item>
    </SegmentedControl>
  </div>
</template>
```

## Vertical

`@orientation='vertical'` stacks the items in a column and switches the arrow
keys that move between them to up/down. The track and the indicator swap their
pill radius for a rounded rectangle, and every item takes the column's full
width, so the indicator slides straight down instead of resizing at each stop —
clearest when the labels differ in length.

```gts preview
import { SegmentedControl } from 'frontile';

<template>
  <SegmentedControl
    @defaultValue='week'
    @orientation='vertical'
    aria-label='Date range'
    as |Ctl|
  >
    <Ctl.Item @value='day'>Day</Ctl.Item>
    <Ctl.Item @value='week'>This week</Ctl.Item>
    <Ctl.Item @value='month'>Month to date</Ctl.Item>
    <Ctl.Item @value='year'>Year</Ctl.Item>
  </SegmentedControl>
</template>
```

## Disabled

An individual item can be disabled with its own `@isDisabled`; keyboard
navigation skips it and it cannot be clicked. `@isDisabled` on the control
disables every item, which is why the second control below does not respond.

```gts preview
import { SegmentedControl } from 'frontile';

<template>
  <div class='flex flex-col items-start gap-3'>
    <SegmentedControl
      @defaultValue='day'
      aria-label='One item disabled'
      as |Ctl|
    >
      <Ctl.Item @value='day'>Day</Ctl.Item>
      <Ctl.Item @value='week' @isDisabled={{true}}>Week</Ctl.Item>
      <Ctl.Item @value='month'>Month</Ctl.Item>
    </SegmentedControl>

    <SegmentedControl
      @defaultValue='day'
      @isDisabled={{true}}
      aria-label='Whole control disabled'
      as |Ctl|
    >
      <Ctl.Item @value='day'>Day</Ctl.Item>
      <Ctl.Item @value='week'>Week</Ctl.Item>
    </SegmentedControl>
  </div>
</template>
```

## Icon and label

Each item yields `isSelected`, so a demo can show only an icon when unselected
and add the label once selected — a compact idle state that expands to
explain itself. Clicking between them is also the clearest look at the
indicator resizing as it moves, not just translating.

```gts preview
import { SegmentedControl } from 'frontile';
import { ViewIcon, ComponentIcon, TargetIcon } from 'site/components/icons';

<template>
  <SegmentedControl @defaultValue='list' aria-label='Layout' as |Ctl|>
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

Form mode also constrains what an item's `@value` can usefully be. A form post
carries strings, so the input's `value` attribute is `String(value)` — an
object value submits as the literal `[object Object]`, and a `null` as
`"null"`. `@onChange` still receives the original typed value, so use `@name`
with string (or otherwise string-round-trippable) item values, and reach for
button mode when the values are objects.

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
      <SegmentedControl
        @defaultValue='week'
        @name='range'
        aria-label='Range'
        as |Ctl|
      >
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

## Custom styling

Every slot is overridable through `@classes`, so a control can be restyled well
past the built-in variants without dropping to a fork. The example below is a
brand-styled toggle: a white card-coloured track with a hairline border, a
filled `primary` pill, and the brand color carried by the unselected labels
instead of neutral ink.

Three of the four pieces come from arguments rather than overrides —
`@intent='primary'` fills the indicator and picks the contrast ink for the
selected label, `@isFullWidth={{true}}` stretches the control and divides it
evenly, and `@size='lg'` sets the padding. Only the track's surface and the
label treatment need `@classes`.

`text-neutral-bolder` is the strongest neutral ink, which inverts with the
theme -- near-black (`gray-900`) in light, near-white (`gray-100`) in dark --
so the unselected labels stay legible on the white track without hard-coding a
colour per mode. `font-label text-header-md` overrides the size variant's own
type step; because both live in Tailwind's font-size group, the `@classes`
value is the one that wins.

```gts preview
import { SegmentedControl } from 'frontile';
import { hash } from '@ember/helper';

<template>
  {{! The demo preview container is shrink-to-fit, so a width has to be
      given explicitly for `@isFullWidth` to have anything to stretch into. }}
  <div class='w-[34rem] max-w-full'>
    <SegmentedControl
      @defaultValue='resident'
      @intent='primary'
      @size='lg'
      @isFullWidth={{true}}
      @classes={{hash
        base='bg-surface-card border border-neutral-soft'
        item='text-neutral-bolder font-label text-header-md'
      }}
      aria-label='Account type'
      as |Ctl|
    >
      <Ctl.Item @value='resident'>Resident</Ctl.Item>
      <Ctl.Item @value='business'>Business</Ctl.Item>
    </SegmentedControl>
  </div>
</template>
```

### Styling the selected and disabled items

`@classes.item` applies to every item, so an override that should only affect the
selected one needs a modifier. Each item publishes two data attributes for this,
in **both** rendering modes:

| Attribute | Values |
| --------- | ------ |
| `data-selected` | `"true"` / `"false"` |
| `data-disabled` | `"true"` / `"false"` |

So `data-[selected=true]:` is the hook, and it is the same in button mode and
form mode:

```gts
@classes={{hash item='text-primary data-[selected=true]:text-on-primary'}}
```

Reach for these rather than the underlying ARIA or DOM state. Button mode's item
carries `aria-checked` and takes a native `disabled`, while form mode's item is a
`<label>` whose `sr-only` input holds both — so `aria-checked:` and `disabled:`
silently do nothing in form mode, and `has-[:checked]:` does nothing in button
mode. The data attributes are the one hook that spans both. The theme itself is
written against them for exactly this reason.

This also matches how the rest of Frontile exposes selection: `Switch`,
`Listbox`, `NativeSelect` and `Table` all publish `data-selected` the same way.

Overriding `@classes.indicator` is how a different indicator shape is built —
an underline rather than a pill, say. `SelectionIndicator`'s
[own documentation](/docs/components/utilities/selection-indicator) covers the
custom properties to position it with, and the one trap to avoid.

## Accessibility

The control renders `role="radiogroup"` with `aria-orientation`, and each
item is a radio (`role="radio"` in button mode, a native `<input
type="radio">` in form mode) — not a tab. Use `SegmentedControl` for a choice
that only changes a value; once tabs exist, prefer them for options that each
reveal their own panel.

The group needs an accessible name from the consumer: pass `aria-label` (as
every demo above does) or `aria-labelledby`.

| Key                        | Behaviour                                                            |
| -------------------------- | -------------------------------------------------------------------- |
| `Tab`                      | Moves focus to the group. Only the selected item is a tab stop.      |
| `ArrowRight` / `ArrowDown` | Moves selection to the next enabled item, wrapping at the end.       |
| `ArrowLeft` / `ArrowUp`    | Moves selection to the previous enabled item, wrapping at the start. |
| `Home` / `End`             | Moves selection to the first / last enabled item.                    |

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
