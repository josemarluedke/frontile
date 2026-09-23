---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# DatePicker

A date field: segments the value can be typed into, and a [Calendar](../collections/calendar)
in a popover behind a calendar button. Use it for picking a single day or, with
`@mode="range"`, a start/end range. `@isEditable={{false}}` swaps the segments for a button
trigger showing the formatted value.

The segments are the same ones [DateInput](./date-input) renders, and behave the same way —
that page documents typing, pasting and the keyboard in full.

## Import

```js
import { DatePicker } from 'frontile';
```

## Usage

```gts preview
import { DatePicker } from 'frontile';

<template>
  <div class='demo-stack'>
    <DatePicker @label='Start date' />
  </div>
</template>
```

## Editable vs Button Trigger

`@isEditable` defaults to `true`, which renders the segmented field above: the value is
typed, and the calendar button at the end of the field opens the popover.

`@isEditable={{false}}` restores the button trigger, where the whole field is one
`<button>` showing the formatted value and clicking anywhere in it opens the calendar.
`@placeholder`, `@formatOptions` and the `:value` block all describe that button — a
segmented field has its own per-segment placeholders and takes its format from
`@formatOptions` differently, as *Formatting* below explains.

```gts preview
import { DatePicker } from 'frontile';

<template>
  <div class='grid gap-4 md:grid-cols-2'>
    <DatePicker @label='Editable' @locale='en-US' />
    <DatePicker
      @label='Button trigger'
      @locale='en-US'
      @isEditable={{false}}
      @placeholder='Pick a date'
    />
  </div>
</template>
```

## Controlled vs Uncontrolled

`@value` accepts a `Date` or a `yyyy-MM-dd` string, and `@defaultValue` seeds an uncontrolled
picker. `@onChange` always hands back `Date`s, regardless of which form `@value` was given in.

The field keeps its own selection and treats `@value` as something to sync *from*: setting it
replaces what is displayed, and picking a date updates the field immediately without waiting
for `@value` to come back. Passing `undefined` changes nothing, so a picker whose `@value` has
no data yet still honours `@defaultValue`. This is how `Select` behaves, and it is what lets
the field work inside a `<Form>`, where `@value` is bound to data the field is itself the only
source of.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { DatePicker } from 'frontile';

export default class ControlledDatePicker extends Component {
  @tracked value: Date | null = new Date(2026, 0, 20);

  handleChange = (value: Date | null) => {
    this.value = value;
  };

  get valueLabel(): string {
    return this.value ? this.value.toDateString() : 'No date selected';
  }

  <template>
    <div class='demo-stack'>
      <DatePicker
        @label='Start date'
        @value={{this.value}}
        @onChange={{this.handleChange}}
      />
      <p class='text-sm text-neutral-soft'>{{this.valueLabel}}</p>
    </div>
  </template>
}
```

## Range Mode

`@mode="range"` switches the calendar and the value shape to `{ start, end }`. `@visibleMonths`
shows more than one month at a time, which is typical for a range picker.

An editable range renders two groups of segments with a separator between them, one group
per end. Both are typed into, and pasting text that reads as two dates — `2026-01-20 –
2026-02-09` — into the *start* group fills both. A range is anchored at its start: segments
that compose no start compose no range at all, however complete the end group is, and
clearing the start reports `null`.

The popover sizes itself to the calendar, so showing a second month widens it automatically —
there is nothing to adjust. Pass `@popoverSize` if you need a fixed width (`"sm"`, `"md"`,
`"lg"`, `"xl"`) or want it to match the field (`"trigger"`); note that a fixed width narrower
than the grid will clip it.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { DatePicker } from 'frontile';
import type { DateRange } from 'frontile';

export default class RangeDatePicker extends Component {
  @tracked value: DateRange | null = {
    start: new Date(2026, 0, 20),
    end: new Date(2026, 1, 9)
  };

  handleChange = (value: DateRange | null) => {
    this.value = value;
  };

  <template>
    <div class='demo-stack'>
      <DatePicker
        @label='Stay'
        @mode='range'
        @visibleMonths={{2}}
        @value={{this.value}}
        @onChange={{this.handleChange}}
      />
    </div>
  </template>
}
```

A range with only its start chosen leaves the calendar open: the field shows the anchor in
its start group and waits for the second click.

## Presets

There is no `@presets` argument. Presets are ordinary buttons composed into the `:footer`
block, which yields `{ setValue, close, value, isOpen }`. `setValue` behaves exactly like
clicking a day: it fires `@onChange` and closes the popover once the value is complete.

```gts preview collapsible
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { fn } from '@ember/helper';
import { Button, DatePicker } from 'frontile';

function startOfToday(): Date {
  const now = new Date();
  return new Date(now.getFullYear(), now.getMonth(), now.getDate());
}

function daysFromToday(days: number): Date {
  const date = startOfToday();
  date.setDate(date.getDate() + days);
  return date;
}

export default class DatePickerPresets extends Component {
  @tracked value: Date | null = null;

  presets = [
    { label: 'Today', date: startOfToday() },
    { label: 'Tomorrow', date: daysFromToday(1) },
    { label: 'In a week', date: daysFromToday(7) }
  ];

  handleChange = (value: Date | null) => {
    this.value = value;
  };

  <template>
    <div class='demo-stack'>
      <DatePicker
        @label='Due date'
        @value={{this.value}}
        @onChange={{this.handleChange}}
      >
        <:footer as |f|>
          {{#each this.presets as |preset|}}
            <Button
              @variant='subtle'
              @color='primary'
              @size='xs'
              @onPress={{fn f.setValue preset.date}}
            >{{preset.label}}</Button>
          {{/each}}

          <Button
            @variant='plain'
            @size='xs'
            @class='ml-auto'
            @onPress={{f.close}}
          >Close</Button>
        </:footer>
      </DatePicker>
    </div>
  </template>
}
```

## Custom Trigger Content

The `:value` block replaces everything the button trigger renders, receiving
`{ value, formatted, isEmpty }`. It describes the `@isEditable={{false}}` path only; an
editable field renders segments and no trigger for the block to fill. Because the block may
render nothing readable — an icon alone, for instance — the trigger is given an explicit
`aria-label` composed from `@label` and the formatted value whenever the block is
supplied.

```gts preview
import { DatePicker } from 'frontile';

const value = new Date(2026, 0, 20);

<template>
  <div class='demo-stack'>
    <DatePicker
      @label='Start date'
      @value={{value}}
      @locale='en-US'
      @isEditable={{false}}
    >
      <:value as |v|>
        {{#if v.isEmpty}}
          <span class='text-neutral-soft'>No date chosen</span>
        {{else}}
          <span class='font-medium'>{{v.formatted}}</span>
        {{/if}}
      </:value>
    </DatePicker>
  </div>
</template>
```

## Formatting

`@formatOptions` is passed to `Intl.DateTimeFormat` alongside `@locale`. On the button
trigger it formats the value for display and defaults to `{ dateStyle: 'medium' }`.

```gts preview collapsible
import { DatePicker } from 'frontile';

const value = new Date(2026, 0, 20);
const full = { dateStyle: 'full' } as const;
const numeric = { day: '2-digit', month: '2-digit', year: 'numeric' } as const;

<template>
  <div class='demo-stack'>
    <div class='grid gap-4 md:grid-cols-3'>
      <DatePicker
        @label='Default'
        @value={{value}}
        @locale='en-US'
        @isEditable={{false}}
      />
      <DatePicker
        @label='Full'
        @value={{value}}
        @locale='en-US'
        @isEditable={{false}}
        @formatOptions={{full}}
      />
      <DatePicker
        @label='Numeric'
        @value={{value}}
        @locale='en-US'
        @isEditable={{false}}
        @formatOptions={{numeric}}
      />
    </div>
  </div>
</template>
```

On the editable field the same argument decides which segments appear and in what order,
and defaults to `{ year: 'numeric', month: '2-digit', day: '2-digit' }` instead — a textual
month has no numeric segment to type into. A filled segment always shows its full width, so
`month: 'numeric'` and `month: '2-digit'` render the same field. A textual `@formatOptions`, including
the `{ dateStyle: 'medium' }` the button trigger defaults to, falls back to a numeric month
and warns; only the month is replaced, so a format naming other fields keeps them. A
`dateStyle` preset names no fields at all and so falls back to the numeric default in full.

```gts preview
import { DatePicker } from 'frontile';

const value = new Date(2026, 0, 5);
const monthAndDay = { month: '2-digit', day: '2-digit' } as const;

<template>
  <div class='grid gap-4 md:grid-cols-2'>
    <DatePicker @label='Default segments' @value={{value}} @locale='en-US' />
    <DatePicker
      @label='Month and day'
      @value={{value}}
      @locale='en-US'
      @formatOptions={{monthAndDay}}
    />
  </div>
</template>
```

## Color

`@color` picks the semantic color the calendar uses for the selected day and,
in range mode, the band between the two ends. It defaults to `primary`.

It colors the calendar only — the field itself is drawn from the form field
styles it shares with every other input, so a picker still looks like the rest
of the form.

```gts preview
import { DatePicker } from 'frontile';
import { array } from '@ember/helper';

const jan20 = new Date(2026, 0, 20);

<template>
  <div class='flex flex-wrap gap-4'>
    {{#each (array 'primary' 'success' 'warning' 'danger') as |color|}}
      <DatePicker
        @label='{{color}}'
        @color={{color}}
        @defaultValue={{jan20}}
        @locale='en-US'
      />
    {{/each}}
  </div>
</template>
```

## Restricting Selectable Dates

`@minValue` and `@maxValue` bound the range of selectable days; `@isDateUnavailable` marks
individual days unselectable within that range, such as weekends or already-booked nights.

```gts preview
import { DatePicker } from 'frontile';

const min = new Date(2026, 0, 1);
const max = new Date(2026, 0, 31);
const defaultValue = new Date(2026, 0, 20);
const isWeekend = (date: Date) => date.getDay() === 0 || date.getDay() === 6;

<template>
  <div class='demo-stack'>
    <DatePicker
      @label='Appointment date'
      @defaultValue={{defaultValue}}
      @locale='en-US'
      @minValue={{min}}
      @maxValue={{max}}
      @isDateUnavailable={{isWeekend}}
    />
  </div>
</template>
```

## Clearable

`@isClearable` adds a clear button once there is a value. It never renders on a disabled or
read-only picker.

On the editable field the clear button sits beside the calendar button, which is the only
way to open the popover there. On the button trigger the two are either/or: the trigger
itself opens the calendar, so the icon is decorative and the clear button takes its place.

```gts preview
import { DatePicker } from 'frontile';

const defaultValue = new Date(2026, 0, 20);

<template>
  <div class='grid gap-4 md:grid-cols-2'>
    <DatePicker
      @label='Editable'
      @defaultValue={{defaultValue}}
      @isClearable={{true}}
    />
    <DatePicker
      @label='Button trigger'
      @isEditable={{false}}
      @placeholder='Pick a date'
      @defaultValue={{defaultValue}}
      @isClearable={{true}}
    />
  </div>
</template>
```

## Forms

Inside a `<Form>`, a `DatePicker` given `@name` submits one field: the wire value is the same
`yyyy-MM-dd` string `@value` accepts. A range picker submits two dotted names,
`{{@name}}.start` and `{{@name}}.end`, which `Form` unflattens into one nested object.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, DatePicker, type FormResultData } from 'frontile';

export default class DatePickerFormExample extends Component {
  @tracked submitted: FormResultData['data'] | null = null;

  handleSubmit = ({ data }: FormResultData) => {
    this.submitted = data;
  };

  <template>
    <div class='demo-stack'>
      <Form @onSubmit={{this.handleSubmit}}>
        <DatePicker @label='Start date' @name='start' />
        <button type='submit'>Save</button>
      </Form>
      {{#if this.submitted}}
        <p class='text-sm'>Submitted: {{this.submitted.start}}</p>
      {{/if}}
    </div>
  </template>
}
```

`<form.Field>` yields both a bound `DatePicker` and a bound `DateRangePicker` — the same
component, curried to `@mode="range"`. A range field arrives at `onSubmit` as
`{ [name]: { start, end } }`.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, type FormResultData } from 'frontile';

export default class DateRangePickerFieldExample extends Component {
  @tracked submitted: FormResultData['data'] | null = null;

  handleSubmit = ({ data }: FormResultData) => {
    this.submitted = data;
  };

  <template>
    <div class='demo-stack'>
      <Form @onSubmit={{this.handleSubmit}} as |form|>
        <form.Field @name='stay' as |field|>
          <field.DateRangePicker @label='Stay' @locale='en-US' />
        </form.Field>
        <button type='submit'>Save</button>
      </Form>
      {{#if this.submitted}}
        <p class='text-sm'>
          Submitted: {{this.submitted.stay.start}} – {{this.submitted.stay.end}}
        </p>
      {{/if}}
    </div>
  </template>
}
```

## Anatomy

The field's parts carry `data-part` attributes, and state that CSS can select on:

| Element                         | Attributes                                                                                       |
| ------------------------------- | ------------------------------------------------------------------------------------------------ |
| `[data-part="base"]`            | `data-component="date-picker"`                                                                   |
| `[data-part="inner-container"]` | `data-invalid`, `data-disabled` — on the segmented path this is the element drawing the border, background and focus ring |
| `[data-part="group"]`           | `data-invalid`, `data-readonly`; one per end in range mode                                       |
| `[data-part="segment"]`         | `data-type` (`year`, `month` or `day`), `data-placeholder`, `data-disabled`                      |
| `[data-part="literal"]`         | the separators inside a group                                                                    |
| `[data-part="separator"]`       | between the two groups of an editable range                                                      |
| `[data-part="calendar-button"]` | the button opening the popover, on the segmented path                                            |
| `[data-part="clear-button"]`    | rendered only while `@isClearable` has something to clear                                        |
| `[data-part="input"]`           | the button trigger, under `@isEditable={{false}}`                                                |

`@classes` takes the matching slots, including `group`, `segment`, `literal`, `separator`
and `calendarButton`.

## Accessibility

| Element | What it exposes |
| --- | --- |
| Segment | `role="spinbutton"` with `aria-label` (`month`, `day`, `year`, overridable through `@segmentLabels`), `aria-valuenow`, `aria-valuemin`, `aria-valuemax` and `aria-valuetext` — which is what makes a month announce as "January" rather than "1". Carries the field's `aria-invalid` and `aria-readonly`. |
| Segment group | `role="group"`, named by `@label` and described by `@description` and any feedback. In range mode there are two, named `"<label> start"` and `"<label> end"`. |
| Calendar button | A `<button>` labelled `"Choose date, <label>"`, carrying the `aria-haspopup`, `aria-expanded` and `aria-controls` the popover trigger applies. |
| Trigger | Under `@isEditable={{false}}`, a `<button>` carrying the same popover trigger attributes. When a `:value` block is supplied, it also carries an explicit `aria-label` composed from `@label` and the formatted value, since the block's content may not be readable text on its own. |
| Popover content | `role="dialog"`, labeled by `@label`. |
| Calendar grid | Labeled by the field's own id, so the default calendar is always labelled. A consumer rendering their own calendar from the `:calendar` block must pass `@id` to `DatePicker` for the grid to be labelled — the block's `labelledBy` reflects `@id`, not the id `FormControl` would otherwise generate. |
| Clear button | Announced as "Clear". |

The segments take the same keys as [DateInput](./date-input#accessibility), and every one
of them is a tab stop — three for a single field, six for a range.

`role="group"` supports neither `aria-invalid` nor `aria-readonly` in ARIA 1.2, so the
group carries `data-invalid` and `data-readonly` for styling while the real ARIA sits on
the segments.

A `role="group"` is not a labelable element, so the visible `<label>` does not associate
with the segments through `for`. Each group is named by `aria-label` instead, derived from
`@label`.

Opening the picker moves focus onto the selected (or today's) day inside the grid. `Escape`
closes the calendar and returns focus to the segment that had it — or to the button trigger
— as does completing a selection or clicking outside. `@onBlur` fires only once focus
leaves the whole control — the field and its popover — not on the way into the calendar.

## Testing

The segmented trigger cannot be filled with `fillIn`, which fails silently rather than
throwing. Use `fillDate` (or `fillDateRange` for `@mode="range"`) from
`frontile/test-support`; see [DateInput](./date-input#testing) for the details and the
reason.

```js
import { fillDate, fillDateRange } from 'frontile/test-support';

await fillDate('[data-test-due]', '2026-01-20');
await fillDateRange('[data-test-trip]', '2026-01-20', '2026-01-25');
```

With `@isEditable={{false}}` there is nothing to type into: click the trigger and pick
from the calendar, as before.

## API

<Signature @component="DatePicker" />
