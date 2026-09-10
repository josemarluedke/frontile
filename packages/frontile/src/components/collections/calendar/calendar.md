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

## Min and max

`@minValue` and `@maxValue` bound which days are selectable. Navigation is bounded too: the
previous/next buttons disable once paging would leave no selectable month in view.

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

## Month and year dropdowns

`@captionLayout="dropdown"` replaces the plain month/year caption with a native month
`<select>` and a year trigger that opens a year-grid picker.

```gts preview
import { Calendar } from 'frontile/collections';

<template>
  <Calendar @captionLayout='dropdown' />
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

The `<:day>` block replaces a day cell's content entirely, receiving the day's state
(selection, availability, focus, and more). By default a day fills a circular cell —
`--calendar-cell-radius` is the CSS variable that shapes it, so custom content that needs
more than a numeral, like a price, can set it to a smaller radius instead of being cropped
to a circle.

```gts preview
import { Calendar } from 'frontile/collections';
import { get } from '@ember/helper';

const prices: Record<number, number> = { 5: 120, 6: 120, 12: 95, 13: 95, 19: 140, 20: 140 };
const septemberFirst = new Date(2026, 8, 1);

<template>
  <Calendar
    @defaultMonth={{septemberFirst}}
    style='--calendar-cell-radius: var(--radius-lg)'
  >
    <:day as |day|>
      <span class='text-body-sm'>{{day.dayOfMonth}}</span>
      {{#if (get prices day.dayOfMonth)}}
        <span class='text-caption-2xs text-neutral'>
          ${{get prices day.dayOfMonth}}
        </span>
      {{/if}}
    </:day>
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

Each month grid has `role="grid"` with an accessible label naming the month and year, and
day cells use `role="gridcell"` with `aria-selected`. The month caption is also announced
through a visually hidden live region when navigation changes it, so month changes reach
screen reader users even though focus stays on the grid. `@autofocus` moves DOM focus into
the grid on insert — it's the only thing that may do so, since rendering a calendar must
never otherwise steal focus.

Replacing the header with a `<:header>` block hands you the same context Calendar uses
internally — `month`, `title`, `goToPrevious`, `goToNext`, `canGoPrevious`, `canGoNext`,
`setMonth`, `setYear`, `isYearGridOpen`, and `toggleYearGrid` — but you're then responsible
for rebuilding any year-picker trigger yourself if you want one.

## API

<Signature @component="Calendar" />
