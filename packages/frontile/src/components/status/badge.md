---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Badge

A small, non-interactive label for status or metadata — a state on a record, a plan
name, a count next to a heading.

## Import

```js
import { Badge } from 'frontile';
```

## Usage

```gts preview
import { Badge } from 'frontile';

<template>
  <Badge>Draft</Badge>
</template>
```

## Badge Variants

`soft` is a tinted surface with color-tinted text, and is the default. `outline`
draws the color as a border on the page background. There is no `solid` variant; a
filled, saturated block reads as a button, so use a [Chip](/docs/components/buttons/chip)
if you need one.

```gts preview
import { Badge } from 'frontile';

<template>
  <div class='flex flex-wrap items-center gap-3'>
    <Badge @variant='soft' @color='primary'>Soft</Badge>
    <Badge @variant='outline' @color='primary'>Outline</Badge>
  </div>
</template>
```

## Badge Colors

Every color is available in both variants. The label on each row is the `@variant`
value; the badge labels are the `@color` values.

```gts preview collapsible
import { Badge } from 'frontile';
import { array } from '@ember/helper';

const colors = [
  'neutral',
  'primary',
  'secondary',
  'tertiary',
  'success',
  'danger'
];

<template>
  <div class='flex flex-col gap-6'>
    {{#each (array 'soft' 'outline') as |variant|}}
      <div>
        <p class='font-code text-code-sm text-neutral-strong mb-2'>
          @variant='{{variant}}'
        </p>
        <div class='flex flex-wrap items-center gap-3'>
          {{#each colors as |color|}}
            <Badge @variant={{variant}} @color={{color}}>
              {{color}}
            </Badge>
          {{/each}}
        </div>
      </div>
    {{/each}}
  </div>
</template>
```

## Badge Sizes

The second row shows each size with an icon and a value.

```gts preview
import { Badge } from 'frontile';
import { array } from '@ember/helper';
import { StarIcon } from 'site/components/icons';

<template>
  <div class='flex flex-col gap-4'>
    <div class='flex flex-wrap items-center gap-3'>
      {{#each (array 'xs' 'sm' 'md' 'lg') as |size|}}
        <Badge @size={{size}}>Badge {{size}}</Badge>
      {{/each}}
    </div>
    <div class='flex flex-wrap items-center gap-3'>
      {{#each (array 'xs' 'sm' 'md' 'lg') as |size|}}
        <Badge @size={{size}} @color='primary' @value='4.8'>
          <:startIcon><StarIcon /></:startIcon>
          <:default>Rating {{size}}</:default>
        </Badge>
      {{/each}}
    </div>
  </div>
</template>
```

## Value and Unit

`@value` shows a figure after the label, such as a price or a count, in a heavier
tabular style. It takes a string or a number, and a count of `0` still renders.
`@unit` adds a unit after the value. Both are optional and render only when set.

```gts preview
import { Badge } from 'frontile';

<template>
  <div class='flex flex-wrap items-center gap-3'>
    <Badge @color='primary' @value={{12}}>Open</Badge>
    <Badge @color='success' @value='$49' @unit='/mo'>Pro</Badge>
    <Badge @variant='outline' @color='danger' @value={{0}}>Failed</Badge>
  </div>
</template>
```

## Icons

The `<:startIcon>` block places an icon before the label and `<:endIcon>` places one
after the value and unit. Once you use a named block, loose content is no longer the
default block, so put the label in `<:default>`.

```gts preview
import { Badge } from 'frontile';
import { CheckIcon, StarIcon } from 'site/components/icons';

<template>
  <div class='flex flex-wrap items-center gap-3'>
    <Badge @color='success'>
      <:startIcon><CheckIcon /></:startIcon>
      <:default>Verified</:default>
    </Badge>
    <Badge @color='primary' @value='4.8'>
      <:default>Rating</:default>
      <:endIcon><StarIcon /></:endIcon>
    </Badge>
  </div>
</template>
```

## Badge with Dots

`@withDot` adds a small dot before the content, colored by `@color`.

```gts preview collapsible
import { Badge } from 'frontile';
import { array } from '@ember/helper';

const colors = [
  'neutral',
  'primary',
  'secondary',
  'tertiary',
  'success',
  'danger'
];

<template>
  <div class='flex flex-col gap-6'>
    {{#each (array 'soft' 'outline') as |variant|}}
      <div>
        <p class='font-code text-code-sm text-neutral-strong mb-2'>
          @variant='{{variant}}'
        </p>
        <div class='flex flex-wrap items-center gap-3'>
          {{#each colors as |color|}}
            <Badge @variant={{variant}} @color={{color}} @withDot={{true}}>
              {{color}}
            </Badge>
          {{/each}}
        </div>
      </div>
    {{/each}}
  </div>
</template>
```

## Chip vs Badge

Neither responds to a click. A Badge is a squared label for a status or a count. A
[Chip](/docs/components/buttons/chip) is a pill for a value the user can remove, and
its close button is the only part that does anything.

```gts preview
import { Badge, Chip } from 'frontile';

const noop = (): void => {};

<template>
  <div class='flex flex-wrap items-center gap-3'>
    <Badge @color='success' @withDot={{true}}>Badge</Badge>
    <Chip
      @variant='soft'
      @color='primary'
      @withDot={{true}}
      @onClose={{noop}}
      @closeButtonTitle='Remove Fiber'
    >
      Chip
    </Chip>
  </div>
</template>
```

## Accessibility

A `Badge` is a `<span>` holding plain text. It has no role and is not focusable.

- Do not convey status by color alone. `@color='danger'` reads as "failed" to a
  sighted user and as nothing at all to a screen reader, so put the meaning in the
  text.
- Icons in `<:startIcon>` and `<:endIcon>` are yours to label. If an icon carries
  meaning the text does not, give it a label; if it only decorates, hide it from
  assistive technology with `aria-hidden='true'`.

## API

<Signature @component="Badge" />
