---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# DateInput

A date that is typed rather than picked: `mm / dd / yyyy` rendered as separately
focusable segments, each one editable with digits and arrow keys. Reach for it when a
calendar is the wrong tool — a birth date, an expiry date, anything far from today. For a
field that also offers a calendar, use [DatePicker](./date-picker), which renders these
same segments and adds one.

## Import

```js
import { DateInput } from 'frontile';
```

## Usage

```gts preview
import { DateInput } from 'frontile';

<template>
  <div class='demo-stack'>
    <DateInput @label='Birth date' />
  </div>
</template>
```

## Typing a Date

Digits go into the focused segment and advance to the next one as soon as the segment
cannot take another: typing `1` in the month shows `01` and waits, a following `2` makes
`12` and moves on, while a following `5` cannot extend `12`, so the month commits and `05`
starts in the day.

A year segment holding one or two digits resolves into the hundred years running from 80
back to 19 forward when you leave it, so in 2026 `45` becomes 2045 and `99` becomes 1999.
Three or four digits are taken literally: `0045` is the year 45. Pasting follows the same
rule.

A partly filled field composes no date. Typing a month and a day fires no `@onChange`, and
the value stays `null` until every segment holds a finished number. Leaving the field
neither clears the entry nor fills in what is missing: the digits you typed stay on screen,
the segments you skipped stay empty, and the value stays `null`.

An impossible day shortens to the month's length: February with `31` in the day composes
the 28th (the 29th in a leap year), and the segment redisplays.

## Controlled vs Uncontrolled

`@value` accepts a `Date` or a `yyyy-MM-dd` string, and `@defaultValue` seeds an
uncontrolled field. `@onChange` always hands back `Date`s, regardless of which form
`@value` was given in.

The field keeps its own segments and treats `@value` as something to sync *from*: setting
it rewrites what is displayed, and typing updates the field immediately without waiting
for `@value` to come back. Passing `undefined` changes nothing, so a field whose `@value`
has no data yet still honours `@defaultValue`. This is what lets it work inside a `<Form>`,
where `@value` is bound to data the field is itself the only source of.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { DateInput } from 'frontile';

export default class ControlledDateInput extends Component {
  @tracked value: Date | null = new Date(2026, 0, 20);

  handleChange = (value: Date | null) => {
    this.value = value;
  };

  get valueLabel(): string {
    return this.value ? this.value.toDateString() : 'No date entered';
  }

  <template>
    <div class='demo-stack'>
      <DateInput
        @label='Start date'
        @value={{this.value}}
        @onChange={{this.handleChange}}
      />
      <p class='text-sm text-neutral-soft'>{{this.valueLabel}}</p>
    </div>
  </template>
}
```

## Locale and Format

`@locale` decides the order of the segments and the literals between them; it defaults to
`navigator.language`. Changing it at runtime reorders the field without emptying it.

```gts preview
import { DateInput } from 'frontile';

const value = new Date(2026, 0, 20);

<template>
  <div class='grid gap-4 md:grid-cols-3'>
    <DateInput @label='en-US' @locale='en-US' @defaultValue={{value}} />
    <DateInput @label='en-GB' @locale='en-GB' @defaultValue={{value}} />
    <DateInput @label='de-DE' @locale='de-DE' @defaultValue={{value}} />
  </div>
</template>
```

`@formatOptions` decides which segments appear and in what order. It defaults to
`{ year: 'numeric', month: '2-digit', day: '2-digit' }`. A filled segment always shows its
full width — two digits for the month and day, four for the year — so `month: 'numeric'`
and `month: '2-digit'` render the same field.

A textual month — `{ month: 'short' }`, and so any `dateStyle` preset — has no numeric
segment to type into. The month falls back to a numeric one and the component warns. Only
the month is replaced, so `{ month: 'short', day: '2-digit' }` still renders exactly those
two segments. A `dateStyle` preset names no fields at all, so it falls back to the numeric
default in full.

```gts preview
import { DateInput } from 'frontile';

const value = new Date(2026, 0, 5);
const monthAndDay = { month: '2-digit', day: '2-digit' } as const;
const yearAndMonth = { year: 'numeric', month: '2-digit' } as const;

<template>
  <div class='grid gap-4 md:grid-cols-3'>
    <DateInput @label='Default' @locale='en-US' @defaultValue={{value}} />
    <DateInput
      @label='Month and day'
      @locale='en-US'
      @defaultValue={{value}}
      @formatOptions={{monthAndDay}}
    />
    <DateInput
      @label='Year and month'
      @locale='en-US'
      @defaultValue={{value}}
      @formatOptions={{yearAndMonth}}
    />
  </div>
</template>
```

## Copy and Paste

Copying writes the field as it reads on screen, literals included, and cutting copies and
then clears.

Pasting accepts three shapes, tried in that order: an ISO `yyyy-MM-dd` string, a bare run
of digits split by segment width (`12252026`), and numbers separated by anything
non-numeric, mapped onto the segments in their locale order — so `25/12/2026` is the 25th
of December under `en-GB`. Text that yields fewer numbers than there are segments fills
what it can. A number outside its segment's bounds refuses the whole paste rather than
being clamped to fit, and text that reads as no date at all is dropped with no change.

Paste `2026-01-20`, `01/20/2026` or `01202026` into the field below.

```gts preview
import { DateInput } from 'frontile';

<template>
  <div class='demo-stack'>
    <DateInput
      @label='Start date'
      @locale='en-US'
      @description='Paste 2026-01-20 into any segment.'
    />
  </div>
</template>
```

## Validation

`@minValue` and `@maxValue` bound the allowed dates and `@isDateUnavailable` rejects
individual ones. A value outside those bounds marks the field invalid; none of them ever
block a keystroke, because a year on its way to `2020` passes through `2`, `20` and `202`
and a field that refused those could not be typed into at all.

`@errors` renders feedback of your own, exactly as on every other form field.

```gts preview
import { DateInput } from 'frontile';

const min = new Date(2026, 0, 1);
const max = new Date(2026, 0, 31);
const value = new Date(2026, 5, 14);
const isWeekend = (date: Date) => date.getDay() === 0 || date.getDay() === 6;

<template>
  <div class='demo-stack'>
    <DateInput
      @label='Appointment date'
      @locale='en-US'
      @defaultValue={{value}}
      @minValue={{min}}
      @maxValue={{max}}
      @isDateUnavailable={{isWeekend}}
      @description='Weekdays in January 2026 only.'
    />
  </div>
</template>
```

## Clearable

`@isClearable` adds a clear button at the end of the field once any segment holds a digit.
It never renders on a disabled or read-only field, and clearing moves focus to the first
segment so a keyboard user does not lose their place.

```gts preview
import { DateInput } from 'frontile';

const value = new Date(2026, 0, 20);

<template>
  <div class='demo-stack'>
    <DateInput @label='Start date' @defaultValue={{value}} @isClearable={{true}} />
  </div>
</template>
```

## Sizes

```gts preview
import { DateInput } from 'frontile';

<template>
  <div class='grid gap-4 md:grid-cols-3'>
    <DateInput @label='Small' @inputSize='sm' />
    <DateInput @label='Medium' @inputSize='md' />
    <DateInput @label='Large' @inputSize='lg' />
  </div>
</template>
```

## Disabled and Read-only

`@isDisabled` takes the segments out of the tab order entirely. `@isReadOnly` keeps them
focusable, navigable and copyable, and refuses every edit.

```gts preview
import { DateInput } from 'frontile';

const value = new Date(2026, 0, 20);

<template>
  <div class='grid gap-4 md:grid-cols-2'>
    <DateInput @label='Disabled' @defaultValue={{value}} @isDisabled={{true}} />
    <DateInput @label='Read-only' @defaultValue={{value}} @isReadOnly={{true}} />
  </div>
</template>
```

## Inside a Form

A `DateInput` given `@name` submits one field, and the wire value is the same
`yyyy-MM-dd` string `@value` accepts. An incomplete entry submits an empty string.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, DateInput, type FormResultData } from 'frontile';

export default class DateInputFormExample extends Component {
  @tracked submitted: FormResultData['data'] | null = null;

  handleSubmit = ({ data }: FormResultData) => {
    this.submitted = data;
  };

  <template>
    <div class='demo-stack'>
      <Form @onSubmit={{this.handleSubmit}}>
        <DateInput @label='Start date' @name='start' />
        <button type='submit'>Save</button>
      </Form>
      {{#if this.submitted}}
        <p class='text-sm'>Submitted: {{this.submitted.start}}</p>
      {{/if}}
    </div>
  </template>
}
```

`<form.Field>` yields a bound `DateInput` alongside the bound pickers, wiring the name,
value, errors and disabled state for you.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, type FormResultData } from 'frontile';

export default class DateInputFieldExample extends Component {
  @tracked submitted: FormResultData['data'] | null = null;

  handleSubmit = ({ data }: FormResultData) => {
    this.submitted = data;
  };

  <template>
    <div class='demo-stack'>
      <Form @onSubmit={{this.handleSubmit}} as |form|>
        <form.Field @name='birthday' as |field|>
          <field.DateInput @label='Birth date' @locale='en-US' />
        </form.Field>
        <button type='submit'>Save</button>
      </Form>
      {{#if this.submitted}}
        <p class='text-sm'>Submitted: {{this.submitted.birthday}}</p>
      {{/if}}
    </div>
  </template>
}
```

## Anatomy

The field's parts carry `data-part` attributes, and state that CSS can select on:

| Element                      | Attributes                                                                                                       |
| ---------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `[data-part="base"]`         | `data-component="date-input"`                                                                                    |
| `[data-part="inner-container"]` | `data-invalid`, `data-disabled` — the element that draws the field's border, background and focus ring        |
| `[data-part="group"]`        | `data-invalid`, `data-readonly`                                                                                  |
| `[data-part="segment"]`      | `data-type` (`year`, `month` or `day`), `data-placeholder`, `data-disabled`                                      |
| `[data-part="literal"]`      | the separators between segments                                                                                  |
| `[data-part="clear-button"]` | rendered only while `@isClearable` has something to clear                                                        |

`@classes` takes the matching slots: `base`, `innerContainer`, `group`, `segment`,
`literal`, `endContent` and `clearButton`.

```gts preview
import { DateInput } from 'frontile';
import { hash } from '@ember/helper';

<template>
  <div class='demo-stack'>
    <DateInput
      @label='Start date'
      @classes={{hash
        segment='data-[placeholder=true]:text-danger-soft'
        literal='text-danger'
      }}
    />
  </div>
</template>
```

## Accessibility

Each segment is a `role="spinbutton"` carrying `aria-label` (`month`, `day`, `year`, and
overridable through `@segmentLabels`), `aria-valuenow`, `aria-valuemin`, `aria-valuemax`
and `aria-valuetext`. `aria-valuetext` is what makes a month announce as "January" rather
than "1". The separators between them are `aria-hidden`.

The segments sit in a `role="group"` named by `@label` and described by `@description` and
any feedback. `role="group"` supports neither `aria-invalid` nor `aria-readonly` in ARIA
1.2, so the group carries `data-invalid` and `data-readonly` for styling while the real
`aria-invalid` and `aria-readonly` sit on the segments, where assistive technology reads
them.

Every segment is in the tab order, which is three tab stops for one field. This follows
`<input type="date">` in Chrome and Firefox.

| Key                     | Behaviour                                                                    |
| ----------------------- | ---------------------------------------------------------------------------- |
| `Tab` / `Shift+Tab`     | Move between segments                                                        |
| `←` / `→`               | Previous / next segment, skipping the literals; visual order in RTL          |
| `Home` / `End`          | First / last segment                                                         |
| `↑` / `↓`               | Increment / decrement, wrapping within the segment                           |
| `PageUp` / `PageDown`   | Larger step: day ±7, month ±3, year ±10                                      |
| digits                  | Fill the segment, advancing when it cannot take another digit                |
| `Backspace`             | Remove the last digit typed in this segment                                  |
| `Delete`                | Clear the segment                                                            |

`↑` and `↓` on an empty segment start from `@placeholderValue`, which defaults to today.
Arrow-key navigation and `Home`/`End` keep working on a read-only field; the editing keys
do not.

`@onBlur` fires when focus leaves the field, not when it moves from one segment to the
next.

## Testing

`fillIn` does not work on this field — and, importantly, **it does not fail either**.
The segments are `contenteditable`, so `fillIn` writes their text and fires `input`
without complaint, but the component renders from its own segments and listens only to
`beforeinput`/`keydown`. Nothing reaches the value. A test written that way reads green,
its `assert.dom(...).hasText('01')` passes, and the component's value is still `null`.

Use `fillDate` instead. It types the digits segment by segment the way a person does, so
the value composes through the same path as real input.

```js
import { fillDate, fillDateRange } from 'frontile/test-support';

await fillDate('[data-test-due]', '2026-01-20');
await fillDate('[data-test-due]', new Date(2026, 0, 20));

// DatePicker @mode="range"
await fillDateRange('[data-test-trip]', '2026-01-20', '2026-01-25');
```

The selector points at any element containing the field, not at a segment. Both helpers
accept a `Date` or a `yyyy-MM-dd` string, and route each run of digits by segment type —
so the same call works whatever order the locale puts them in.

Pointing `fillDate` at a `DatePicker` rendering its button trigger throws, and says so:
there is nothing to type into on that path, so click the trigger and pick from the
calendar instead.

## API

<Signature @component="DateInput" />
