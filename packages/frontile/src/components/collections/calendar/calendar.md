---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Calendar

A month-grid date picker for choosing a single day or a range, with full keyboard
navigation and localization through `Intl`. Calendar renders no popover, trigger, or text
input of its own — it's the primitive the date-picker components build their input and
popover around.

## Import

```js
import { Calendar } from 'frontile/collections';
```

## Usage

```gts preview
import { Calendar } from 'frontile/collections';

const today = new Date();

<template>
  <Calendar @defaultValue={{today}} />
</template>
```

The first visible month is resolved in this order: `@defaultMonth`, then the month of
`@defaultValue`, then the month of `@value`, then today. A calendar seeded with a selection
opens showing that selection rather than today.

## Controlled

Pass `@value` and `@onChange` to own the selection yourself. Passing `@value` at all —
including as `undefined` — puts selection in controlled mode; omit it entirely for
uncontrolled use as in the demo above.

```gts preview
import { Calendar } from 'frontile/collections';
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';

export default class ControlledExample extends Component {
  @tracked value: Date | null = new Date();

  get label(): string {
    return this.value ? `Selected: ${this.value.toDateString()}` : 'No date selected';
  }

  handleChange = (value: Date | null): void => {
    this.value = value;
  };

  <template>
    <p class='mb-2 text-body-sm text-neutral'>{{this.label}}</p>
    <Calendar @value={{this.value}} @onChange={{this.handleChange}} />
  </template>
}
```

## Range

Set `@mode="range"` to select a start and end day; the first click sets the anchor and the
second commits the range. `@visibleMonths={{2}}` shows two months side by side, which is
the usual pairing for a range picker.

```gts preview
import { Calendar } from 'frontile/collections';

<template>
  <Calendar @mode='range' @visibleMonths={{2}} />
</template>
```

A controlled range `@value` whose `end` is `null` is a half-open, mid-interaction state —
Calendar won't paint a range from it. Pass a full `{ start, end }` object once both ends
are chosen.

`@showOutsideDays` defaults to `true` with one visible month and `false` once
`@visibleMonths` is greater than one, where a boundary date would otherwise appear in both
grids. Passing an explicit value always wins, in either direction.

`@pageBehavior` controls how far the previous/next buttons move: `'visible'` (the default)
pages by the whole window, `'single'` always by one month. `@fixedWeeks` renders six week
rows in every month, so the calendar's height doesn't change as you page.

## Min and max

`@minValue` and `@maxValue` bound which days are selectable. Navigation is bounded too: the
previous/next buttons disable once paging would land entirely outside the bounds, and the
month and year pickers offer only the months and years the bounds allow.
`@isDateUnavailable` does not affect navigation — you can still page to a month whose every
day is unavailable.

```gts preview
import { Calendar } from 'frontile/collections';

const septemberFirst = new Date(2026, 8, 1);
const minValue = new Date(2026, 8, 5);
const maxValue = new Date(2026, 8, 20);

<template>
  <Calendar
    @defaultMonth={{septemberFirst}}
    @minValue={{minValue}}
    @maxValue={{maxValue}}
  />
</template>
```

## Unavailable dates

`@isDateUnavailable` marks specific days as present but not selectable — a holiday, a
booked night — shown struck through rather than dimmed. It's distinct from `@minValue`/
`@maxValue`: an unavailable day is still in range, just not choosable.

```gts preview
import { Calendar } from 'frontile/collections';

function isWeekend(date: Date): boolean {
  const day = date.getDay();
  return day === 0 || day === 6;
}

<template>
  <Calendar @isDateUnavailable={{isWeekend}} />
</template>
```

In range mode, an unavailable date also blocks any range from being drawn across it — once
one endpoint is chosen, days on the far side of an unavailable day become unreachable.

Three kinds of day look muted, and they don't all behave the same way:

| Day | Looks | Selectable |
| --- | --- | --- |
| Outside `@minValue`/`@maxValue` | Dimmed | No |
| Matched by `@isDateUnavailable` | Struck through | No |
| Belonging to a neighbouring month | Dimmed | Yes — selecting it pages the calendar to that month |

## Month and year dropdowns

`@captionLayout="dropdown"` replaces the plain month/year caption with a native month
`<select>` and a year trigger that opens a year-grid picker.

```gts preview
import { Calendar } from 'frontile/collections';

<template>
  <Calendar @captionLayout='dropdown' />
</template>
```

## Intents and sizes

`@intent` sets the color of the selected day and the range band; `@size` scales the cells
and caption together.

```gts preview
import { Calendar } from 'frontile/collections';
import { array } from '@ember/helper';

const today = new Date();

<template>
  <div class='flex flex-wrap gap-6'>
    {{#each (array 'primary' 'success' 'danger') as |intent|}}
      <Calendar @intent={{intent}} @size='sm' @defaultValue={{today}} />
    {{/each}}
  </div>
</template>
```

```gts preview
import { Calendar } from 'frontile/collections';
import { array } from '@ember/helper';

const today = new Date();

<template>
  <div class='flex flex-wrap items-start gap-6'>
    {{#each (array 'sm' 'md' 'lg') as |size|}}
      <Calendar @size={{size}} @defaultValue={{today}} />
    {{/each}}
  </div>
</template>
```

## Custom weekday labels

The `<:weekday>` block replaces the column headers, receiving `short`, `long`, `narrow`, and
the weekday `index`. Pairing the narrow label with a [Tooltip](../overlays/tooltip.md)
carrying the long one keeps the columns tight without losing the full weekday name.

```gts preview
import { Calendar } from 'frontile/collections';
import { Tooltip } from 'frontile';

<template>
  <Calendar>
    <:weekday as |weekday|>
      <Tooltip @content={{weekday.long}} as |t|>
        <span {{t.trigger}}>{{weekday.narrow}}</span>
      </Tooltip>
    </:weekday>
  </Calendar>
</template>
```

## Presets

The `<:footer>` block renders below the grid. Combine it with `@month`/`@onMonthChange` and
`@value`/`@onChange` to drive the calendar from preset buttons.

```gts preview
import { Calendar } from 'frontile/collections';
import { Button } from 'frontile';
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';

function addDays(date: Date, amount: number): Date {
  const result = new Date(date);
  result.setDate(result.getDate() + amount);
  result.setHours(0, 0, 0, 0);
  return result;
}

export default class PresetsExample extends Component {
  @tracked month = addDays(new Date(), 0);
  @tracked value: Date | null = null;

  applyPreset = (offset: number): void => {
    const date = addDays(new Date(), offset);
    this.month = date;
    this.value = date;
  };

  handleMonthChange = (month: Date): void => {
    this.month = month;
  };

  handleChange = (value: Date | null): void => {
    this.value = value;
  };

  <template>
    <Calendar
      @month={{this.month}}
      @onMonthChange={{this.handleMonthChange}}
      @value={{this.value}}
      @onChange={{this.handleChange}}
    >
      <:footer>
        <div class='flex gap-2 pt-2'>
          <Button @size='sm' @appearance='outlined' {{on 'click' (fn this.applyPreset 0)}}>
            Today
          </Button>
          <Button @size='sm' @appearance='outlined' {{on 'click' (fn this.applyPreset 1)}}>
            Tomorrow
          </Button>
          <Button @size='sm' @appearance='outlined' {{on 'click' (fn this.applyPreset 7)}}>
            In a week
          </Button>
        </div>
      </:footer>
    </Calendar>
  </template>
}
```

## Custom day content

The `<:day>` block replaces a day cell's content, receiving the day's state (selection,
availability, focus, and more). It renders inside the cell's content wrapper, so a numeral
plus a second line stacks and centres without you rebuilding that layout.

Two CSS variables size the cell around it. `--calendar-cell-radius` shapes it — a day is a
circle by default, which crops anything wider than a numeral, so content like a price wants
a smaller radius. `--calendar-cell-size` scales the whole grid, and content with a second
line needs the extra room.

Let custom content **inherit its color** rather than setting a fixed one. A selected day
swaps its text to the contrast color for the current `@intent`, and anything inside it
inherits that automatically — so `opacity-70` gives you a muted second line that stays
readable on both the resting surface and the selected fill. A fixed color like
`text-neutral` looks right until the day is selected, then sits grey on a saturated
background.

```gts preview
import { Calendar } from 'frontile/collections';
import { get } from '@ember/helper';

const prices: Record<number, number> = { 5: 120, 6: 120, 12: 95, 13: 95, 19: 140, 20: 140 };
const septemberFirst = new Date(2026, 8, 1);

<template>
  <Calendar
    @defaultMonth={{septemberFirst}}
    style='--calendar-cell-radius: var(--radius-lg); --calendar-cell-size: 3.5rem'
  >
    <:day as |day|>
      <span class='text-body-sm'>{{day.dayOfMonth}}</span>
      {{#if (get prices day.dayOfMonth)}}
        <span class='text-caption-sm opacity-70'>
          ${{get prices day.dayOfMonth}}
        </span>
      {{/if}}
    </:day>
  </Calendar>
</template>
```

## Custom header

The `<:header>` block replaces the month caption and navigation entirely. It receives
`month`, `title`, `goToPrevious`, `goToNext`, `canGoPrevious`, `canGoNext`, `setMonth`,
`setYear`, `isYearGridOpen`, and `toggleYearGrid` — the same context the default header
uses, so nothing about paging or bounds has to be reimplemented.

Nothing is rendered for you, including the year-grid trigger: call `toggleYearGrid` from
your own control to keep it, as below, or leave it out for a calendar with no year picker.

```gts preview
import { Calendar } from 'frontile/collections';
import { Button } from 'frontile';
import { on } from '@ember/modifier';

<template>
  <Calendar>
    <:header as |header|>
      <div class='flex items-center justify-between gap-2 pb-2'>
        <Button
          @size='sm'
          @appearance='outlined'
          disabled={{unless header.canGoPrevious true false}}
          {{on 'click' header.goToPrevious}}
        >
          Back
        </Button>

        <Button
          @size='sm'
          @appearance='minimal'
          aria-expanded={{if header.isYearGridOpen 'true' 'false'}}
          {{on 'click' header.toggleYearGrid}}
        >
          {{header.title}}
        </Button>

        <Button
          @size='sm'
          @appearance='outlined'
          disabled={{unless header.canGoNext true false}}
          {{on 'click' header.goToNext}}
        >
          Next
        </Button>
      </div>
    </:header>
  </Calendar>
</template>
```

## Localization

`@locale` is a BCP-47 language tag (`"nl-NL"`, `"ja-JP"`) — Calendar formats months,
weekdays, and captions through `Intl.DateTimeFormat`, not a date-fns `Locale` object.
`@weekStartsOn` overrides the first day of the week the locale would otherwise imply.

```gts preview
import { Calendar } from 'frontile/collections';

<template>
  <Calendar @locale='nl-NL' @weekStartsOn={{1}} />
</template>
```

## Disabled and read-only

`@isDisabled` blocks navigation and selection entirely. `@isReadOnly` still allows paging
between months but blocks selecting a day.

```gts preview
import { Calendar } from 'frontile/collections';

const today = new Date();

<template>
  <div class='flex flex-wrap gap-6'>
    <Calendar @isDisabled={{true}} @visibleMonths={{1}} />
    <Calendar @isReadOnly={{true}} @defaultValue={{today}} />
  </div>
</template>
```

## Accessibility

The day grid is a single tab stop: `Tab` moves focus onto the currently focused day, and
arrow keys move within the grid without adding extra stops. Moving past the edge of a
visible month pages the calendar to bring the new day into view.

| Key | Action |
| --- | --- |
| `←` / `→` | Move focus one day back / forward |
| `↑` / `↓` | Move focus one week back / forward |
| `Home` / `End` | Move to the start / end of the current week |
| `Page Up` / `Page Down` | Move back / forward one month |
| `Shift + Page Up` / `Shift + Page Down` | Move back / forward one year |
| `Enter` / `Space` | Select the focused day |
| `Escape` | Cancel a pending range selection |

`Escape` works no matter which control inside the calendar has focus — a day cell, the
Previous/Next buttons, or the month `<select>` — so a pending range can always be
canceled without first tabbing back into the grid.

In range mode the first click emits a half-open `{ start, end: null }`, and `Escape` emits
`null` to retract it — so a controlled `@value` is cleared rather than left holding a start
date.

Each month grid has `role="grid"` with an accessible label naming the month and year, and
day cells use `role="gridcell"` with `aria-selected`. Each day button also carries a full
`aria-label` (weekday, month, day, and year) built from `Intl.DateTimeFormat`, so crossing
a month boundary with the arrow keys announces the complete new date rather than a bare
day-of-month number. The month caption is also announced through a visually hidden live
region when navigation changes it, so month changes reach screen reader users even though
focus stays on the grid. `@autofocus` moves DOM focus into the grid on insert and
only then; rendering a calendar otherwise never moves focus. `@isReadOnly` marks each grid
`aria-readonly="true"` so assistive technology knows the days are inert.

## API

<Signature @component="Calendar" />
