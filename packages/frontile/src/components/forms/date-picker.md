---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# DatePicker

A date field: a button trigger showing the formatted value, and a [Calendar](../collections/calendar)
in a popover. Use it for picking a single day or, with `@mode="range"`, a start/end range.

## Import

```js
import { DatePicker } from 'frontile';
```

## Usage

```gts preview
import { DatePicker } from 'frontile';

<template>
  <div class='demo-stack'>
    <DatePicker @label='Start date' @placeholder='Pick a date' />
  </div>
</template>
```

## Controlled vs Uncontrolled

`@value` accepts a `Date` or a `yyyy-MM-dd` string. Passed alongside `@onChange`, it puts the
picker in controlled mode — but only once it resolves to something other than `undefined`.
An `undefined` `@value` (as opposed to omitting the argument) still leaves the picker
uncontrolled, so `@defaultValue` seeds it. This differs from `Calendar`, whose own `@value`
controls as soon as the argument is passed at all, `undefined` included.

`@onChange` always hands back `Date`s, regardless of what `@value` was given.

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

A range that only has its start chosen stays open — the trigger shows the anchor alone until
a second click completes it.

## Presets

There is no `@presets` argument. Presets are ordinary buttons composed into the `:footer`
block, which yields `{ setValue, close, value, isOpen }`. `setValue` behaves exactly like
clicking a day: it fires `@onChange` and closes the popover once the value is complete.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import { DatePicker } from 'frontile';

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

  handleChange = (value: Date | null) => {
    this.value = value;
  };

  <template>
    <div class='demo-stack'>
      <DatePicker
        @label='Due date'
        @placeholder='Pick a date'
        @value={{this.value}}
        @onChange={{this.handleChange}}
      >
        <:footer as |f|>
          <button
            type='button'
            class='text-sm text-primary'
            {{on 'click' (fn f.setValue (startOfToday))}}
          >Today</button>
          <button
            type='button'
            class='text-sm text-primary'
            {{on 'click' (fn f.setValue (daysFromToday 7))}}
          >In a week</button>
          <button
            type='button'
            class='text-sm text-neutral-soft'
            {{on 'click' f.close}}
          >Close</button>
        </:footer>
      </DatePicker>
    </div>
  </template>
}
```

## Custom Trigger Content

The `:value` block replaces everything the trigger renders, receiving
`{ value, formatted, isEmpty }`. Because the block may render nothing readable — an icon
alone, for instance — the trigger is given an explicit `aria-label` composed from `@label`
and the formatted value whenever the block is supplied.

```gts preview
import { DatePicker } from 'frontile';

const value = new Date(2026, 0, 20);

<template>
  <div class='demo-stack'>
    <DatePicker @label='Start date' @value={{value}} @locale='en-US'>
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

`@formatOptions` is passed to `Intl.DateTimeFormat` alongside `@locale`, and defaults to
`{ dateStyle: 'medium' }`.

```gts preview
import { DatePicker } from 'frontile';

const value = new Date(2026, 0, 20);
const full = { dateStyle: 'full' } as const;
const numeric = { day: '2-digit', month: '2-digit', year: 'numeric' } as const;

<template>
  <div class='demo-stack'>
    <div class='grid gap-4 md:grid-cols-3'>
      <DatePicker @label='Default' @value={{value}} @locale='en-US' />
      <DatePicker
        @label='Full'
        @value={{value}}
        @locale='en-US'
        @formatOptions={{full}}
      />
      <DatePicker
        @label='Numeric'
        @value={{value}}
        @locale='en-US'
        @formatOptions={{numeric}}
      />
    </div>
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

`@isClearable` swaps the calendar icon for a clear button once there is a value. It never
renders on a disabled picker.

```gts preview
import { DatePicker } from 'frontile';

const defaultValue = new Date(2026, 0, 20);

<template>
  <div class='demo-stack'>
    <DatePicker
      @label='Start date'
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

## Accessibility

| Element | What it exposes |
| --- | --- |
| Trigger | A `<button>` with `aria-haspopup="dialog"`. When a `:value` block is supplied, it also carries an explicit `aria-label` composed from `@label` and the formatted value, since the block's content may not be readable text on its own. |
| Popover content | `role="dialog"`, labeled by `@label`. |
| Calendar grid | Labeled by the field's own id, so the default calendar is always labelled. A consumer rendering their own calendar from the `:calendar` block must pass `@id` to `DatePicker` for the grid to be labelled — the block's `labelledBy` reflects `@id`, not the id `FormControl` would otherwise generate. |
| Clear button | Announced as "Clear". |

Opening the picker moves focus onto the selected (or today's) day inside the grid. `Escape`
closes the calendar and returns focus to the trigger, as does completing a selection or
clicking outside. `@onBlur` fires only once focus leaves the whole control — the trigger and
its popover — not on the way into the calendar.

## API

<Signature @component="DatePicker" />
