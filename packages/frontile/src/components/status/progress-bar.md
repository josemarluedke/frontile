---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# ProgressBar

ProgressBars shows visually the progression of a process or task

## Import

```js
import { ProgressBar } from 'frontile';
```

## Usage

```gts preview
import { ProgressBar } from 'frontile';

<template><ProgressBar @progress={{50}} @label='Progress' /></template>
```

## ProgressBar Intents

```gts preview
import { ProgressBar } from 'frontile';

<template>
  <div class='grid grid-cols-6 gap-4'>
    <ProgressBar @progress={{50}} @label='Default' @showValueLabel={{false}} />
    <ProgressBar
      @progress={{50}}
      @label='Primary'
      @intent='primary'
      @showValueLabel={{false}}
    />
    <ProgressBar
      @progress={{50}}
      @label='Secondary'
      @intent='secondary'
      @showValueLabel={{false}}
    />
    <ProgressBar
      @progress={{50}}
      @label='Success'
      @intent='success'
      @showValueLabel={{false}}
    />
    <ProgressBar
      @progress={{50}}
      @label='Warning'
      @intent='warning'
      @showValueLabel={{false}}
    />
    <ProgressBar
      @progress={{50}}
      @label='Danger'
      @intent='danger'
      @showValueLabel={{false}}
    />
  </div>
</template>
```

## ProgressBar Sizes

```gts preview
import { ProgressBar } from 'frontile';

<template>
  <div class='mt-6 grid grid-cols-4 gap-4 items-center'>
    <ProgressBar
      @progress={{50}}
      @size='xs'
      @label='XSmall'
      @showValueLabel={{false}}
    />
    <ProgressBar
      @progress={{50}}
      @size='sm'
      @label='Small'
      @showValueLabel={{false}}
    />
    <ProgressBar @progress={{50}} @label='Normal' @showValueLabel={{false}} />
    <ProgressBar
      @progress={{50}}
      @size='lg'
      @label='Large'
      @showValueLabel={{false}}
    />
  </div>
</template>
```

## ProgressBar Radius

```gts preview
import { ProgressBar } from 'frontile';

<template>
  <div class='mt-6 grid grid-cols-4 gap-4'>
    <ProgressBar
      @size='lg'
      @progress={{50}}
      @radius='none'
      @label='None'
      @showValueLabel={{false}}
    />
    <ProgressBar
      @size='lg'
      @progress={{50}}
      @radius='sm'
      @label='Small'
      @showValueLabel={{false}}
    />
    <ProgressBar
      @size='lg'
      @progress={{50}}
      @radius='lg'
      @label='Large'
      @showValueLabel={{false}}
    />
    <ProgressBar
      @size='lg'
      @progress={{50}}
      @radius='full'
      @label='Full'
      @showValueLabel={{false}}
    />
  </div>
</template>
```

## ProgressBar Labels

```gts preview
import { ProgressBar } from 'frontile';
import { hash } from '@ember/helper';

<template>
  <div class='mt-6 grid grid-cols-2 gap-4 items-end'>
    <ProgressBar @progress={{50}} @label='With label' />
    <ProgressBar
      @progress={{50}}
      @label='Hiding label value'
      @showValueLabel={{false}}
    />
    <ProgressBar
      @progress={{50}}
      @label='Custom label value'
      @valueLabel='4 out of 8'
    />
    <ProgressBar
      @progress={{50}}
      @label='Custom formatter'
      @formatOptions={{(hash style='currency' currency='USD')}}
    />
  </div>
</template>
```

### `@formatOptions`

`@formatOptions` is passed straight to `Intl.NumberFormat`, and which number it
formats depends on the `style`:

| `style`                          | What is formatted                        | `@progress={{50}}` on a 0–100 scale |
| -------------------------------- | ---------------------------------------- | ----------------------------------- |
| `percent`                        | The position on the scale, as a fraction | `50%`                               |
| `decimal`, `currency`, `unit`, … | The raw `@progress` value                | `50`, `$50.00`, …                   |

`Intl` scales a `percent` style by 100 itself, so it is handed the fraction
rather than the already-computed percentage — otherwise `50` would be announced
as `5,000%`. Because it formats the _position_, a `percent` style respects
`@minValue`/`@maxValue`: `@progress={{20}}` on a 10–30 scale reads `50%`.

```gts preview
import { ProgressBar } from 'frontile';
import { hash } from '@ember/helper';

<template>
  <div class='mt-6 grid grid-cols-2 gap-4 items-end'>
    <ProgressBar
      @progress={{50}}
      @label='Percent style'
      @formatOptions={{(hash style='percent')}}
    />
    <ProgressBar
      @progress={{20}}
      @minValue={{10}}
      @maxValue={{30}}
      @label='Percent style, 10–30 scale'
      @formatOptions={{(hash style='percent')}}
    />
  </div>
</template>
```

With no `@formatOptions` and no `@valueLabel`, the value label is the position
rounded to a whole percentage — `50%`.

## Out-of-range values

The rendered width is clamped to 0–100%, so a `@progress` above `@maxValue` fills
the track rather than overflowing it, and one below `@minValue` (or negative)
renders empty. A `@minValue` equal to `@maxValue` has no meaningful position and
renders at 0% instead of emitting an invalid width.

`aria-valuenow` is clamped to the same range. Assistive technology derives the
percentage it announces from `aria-valuenow` against
`aria-valuemin`/`aria-valuemax`, so reporting a raw `150` would announce "150%"
to a screen-reader user while the bar sits pinned at 100% for everyone else —
the people who cannot see the bar would be the only ones given the wrong
number. ARIA also requires `aria-valuenow` to fall within the declared range.

In the demo below, both bars report a value on the scale — `100` and `0` —
matching what they render.

```gts preview
import { ProgressBar } from 'frontile';

<template>
  <div class='grid grid-cols-2 gap-4 items-end'>
    <ProgressBar @progress={{150}} @label='Progress of 150' />
    <ProgressBar @progress={{-20}} @label='Progress of -20' />
  </div>
</template>
```

Clamping is a display safeguard, not validation — nothing warns about an
out-of-range value, since a legitimately jittery source (a byte count
overshooting its total) would warn on every render. A bar pinned at 100% is the
signal.

## ProgressBar Description

```gts preview
import { ProgressBar } from 'frontile';

<template>
  <ProgressBar
    @progress={{50}}
    @label='Uploading'
    @description='Estimated time left'
  />
</template>
```

## Indeterminate

You can pass the argument `@isIndeterminate` to represent when the effort or duration can not be calculated

```gts preview
import { ProgressBar } from 'frontile';

<template>
  <ProgressBar @size='md' @label='Progress' @isIndeterminate={{true}} />
</template>
```

## Customization

`@class` merges into the track's own classes through Tailwind Merge, so a
conflicting utility replaces the theme's rather than fighting it.

```gts preview
import { ProgressBar } from 'frontile';

<template>
  <div class='grid grid-cols-2 gap-4'>
    <ProgressBar @progress={{70}} @label='Default track' />
    <ProgressBar
      @progress={{70}}
      @label='Taller track'
      @class='h-6 rounded-none'
    />
  </div>
</template>
```

## Accessibility

The filled element carries `role="progressbar"` with `aria-valuemin`,
`aria-valuemax`, and `aria-valuenow`, so assistive technology reports the
position on the scale you defined rather than a raw percentage.

| Argument                | What it does for assistive technology                                                            |
| ----------------------- | ------------------------------------------------------------------------------------------------ |
| `@label`                | Becomes the progress bar's accessible name, wired with `aria-labelledby`.                        |
| `@minValue`/`@maxValue` | Set the scale, so `@progress={{20}}` on a 10–30 scale is reported as halfway rather than as 20%. |
| `@description`          | Visible text only. It is **not** associated with the progress bar.                               |

`aria-valuenow` is clamped to `@minValue`/`@maxValue`; see
[Out-of-range values](#out-of-range-values).

### `@label` is what names it

There is no other way to name the progress bar. `...attributes` lands on the
outer wrapper, not on the `role="progressbar"` element, so an `aria-label`
passed from outside does not reach it — a bar with no `@label` is announced as
an unnamed progress bar.

If the label should not be visible, `@showValueLabel={{false}}` only hides the
value; keep `@label` and hide the whole row visually instead:

```gts preview
import { ProgressBar, VisuallyHidden } from 'frontile';

<template>
  <div class='flex flex-col gap-4'>
    <ProgressBar @progress={{40}} @label='Visible label' />

    <VisuallyHidden>
      <ProgressBar @progress={{40}} @label='Upload progress' />
    </VisuallyHidden>
    <p class='text-neutral'>
      The second bar above is present and named, but hidden — not a pattern to
      reach for often, since it hides the bar from sighted users too.
    </p>
  </div>
</template>
```

### Indeterminate bars report no value

When `@isIndeterminate` is set, `aria-valuenow` is omitted entirely rather than
sent as a number. That is what ARIA requires: a value of `0` would be announced
as "0%", which is a claim about progress, where the point of an indeterminate
bar is that no such claim can be made. See the
[Indeterminate](#indeterminate) demo above; the value label is suppressed in that
state too, for the same reason.

### Progress is not an announcement

A progress bar updating is a visual change; nothing announces it. Do not wrap it
in an `aria-live` region to compensate — a bar ticking from 1% to 100% would
interrupt the screen reader on every step. Announce the outcome instead, once,
when the work finishes.

Colour alone should not carry the meaning of `@intent`. A `danger` bar reads as
a problem to a sighted user and as an ordinary bar to everyone else, so put the
state in the `@label` or `@description` as well.

## API

<Signature @component="ProgressBar" />
