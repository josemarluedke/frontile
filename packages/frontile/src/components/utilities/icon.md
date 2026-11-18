---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Icon

Sizes an icon, and can put it in a circle.

The icon is the block you pass in, so it works with whatever icon source you
use: inline SVGs, ember-fontawesome's `FaIcon`, or your own components. By
default there is no circle, only the icon at the size you ask for.

## Import

```js
import { Icon } from 'frontile';
```

## Usage

Put the icon in the block. A plain icon takes the color of the surrounding text.

```gts preview
import { Icon } from 'frontile';
import { StarIcon } from 'site/components/icons';

<template>
  <p class='flex items-center gap-2 text-primary-strong'>
    <Icon @size='xs'><StarIcon /></Icon>
    Starred
  </p>
</template>
```

## Sizes

`@size` takes `4xs`, `3xs`, `2xs`, `xs`, `sm`, `md`, `lg`, `xl`, `2xl` and `3xl`.
The default is `md`. The size sets the diameter of the circle, and the icon
inside scales with it:

| Size      | 4xs | 3xs | 2xs | xs  | sm  | md  | lg  | xl  | 2xl | 3xl |
| --------- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Circle    | 16  | 20  | 24  | 32  | 40  | 48  | 64  | 64  | 80  | 96  |
| Plain box | 12  | 14  | 16  | 20  | 24  | 32  | 40  | 40  | 48  | 56  |
| Icon      | 8   | 10  | 12  | 16  | 20  | 28  | 32  | 40  | 48  | 56  |

All values are in pixels. These sizes are fixed and do not follow the text
size, unlike the icon inside a Button.

```gts preview
import { Icon } from 'frontile';
import { CheckIcon } from 'site/components/icons';

<template>
  <div class='flex items-center gap-3'>
    <Icon @variant='solid' @color='primary' @size='4xs'><CheckIcon /></Icon>
    <Icon @variant='solid' @color='primary' @size='3xs'><CheckIcon /></Icon>
    <Icon @variant='solid' @color='primary' @size='2xs'><CheckIcon /></Icon>
    <Icon @variant='solid' @color='primary' @size='xs'><CheckIcon /></Icon>
    <Icon @variant='solid' @color='primary' @size='sm'><CheckIcon /></Icon>
    <Icon @variant='solid' @color='primary'><CheckIcon /></Icon>
    <Icon @variant='solid' @color='primary' @size='lg'><CheckIcon /></Icon>
    <Icon @variant='solid' @color='primary' @size='xl'><CheckIcon /></Icon>
    <Icon @variant='solid' @color='primary' @size='2xl'><CheckIcon /></Icon>
    <Icon @variant='solid' @color='primary' @size='3xl'><CheckIcon /></Icon>
  </div>
</template>
```

## Variants

`@variant` defaults to `plain`, which draws no circle and has a tighter box.
`solid`, `soft` and `subtle` fill the circle at decreasing strength, and
`outline` draws a ring in the icon color, thicker at larger sizes.

```gts preview
import { Icon } from 'frontile';
import { StarIcon } from 'site/components/icons';

<template>
  <div class='flex items-center gap-3'>
    <Icon @variant='plain' @color='primary'><StarIcon /></Icon>
    <Icon @variant='solid' @color='primary'><StarIcon /></Icon>
    <Icon @variant='soft' @color='primary'><StarIcon /></Icon>
    <Icon @variant='subtle' @color='primary'><StarIcon /></Icon>
    <Icon @variant='outline' @color='primary'><StarIcon /></Icon>
  </div>
</template>
```

## Colors

`@color` takes `neutral`, `primary`, `secondary`, `tertiary`, `success`,
`warning` and `danger`. A filled or outlined icon with no `@color` is
`neutral`. A plain icon with no `@color` uses the surrounding text color
instead.

```gts preview
import { Icon } from 'frontile';
import { CheckIcon } from 'site/components/icons';

<template>
  <div class='flex items-center gap-3'>
    <Icon @variant='soft' @color='neutral'><CheckIcon /></Icon>
    <Icon @variant='soft' @color='primary'><CheckIcon /></Icon>
    <Icon @variant='soft' @color='secondary'><CheckIcon /></Icon>
    <Icon @variant='soft' @color='tertiary'><CheckIcon /></Icon>
    <Icon @variant='soft' @color='success'><CheckIcon /></Icon>
    <Icon @variant='soft' @color='warning'><CheckIcon /></Icon>
    <Icon @variant='soft' @color='danger'><CheckIcon /></Icon>
  </div>
</template>
```

## Inverse

`@inverse` draws the icon in the opposite light or dark scheme, for an icon on
a surface of the other scheme.

```gts preview
import { Icon } from 'frontile';
import { CheckIcon } from 'site/components/icons';

<template>
  <div class='flex items-center gap-3'>
    <Icon @variant='solid' @color='neutral'><CheckIcon /></Icon>
    <Icon @variant='solid' @color='neutral' @inverse={{true}}><CheckIcon
      /></Icon>
  </div>
</template>
```

## Next to text

An icon used as a bullet, with the text beside it.

```gts preview
import { Icon } from 'frontile';
import { CheckIcon } from 'site/components/icons';

<template>
  <ul class='flex flex-col gap-2'>
    <li class='flex items-center gap-2'>
      <Icon @variant='soft' @color='success' @size='2xs'><CheckIcon /></Icon>
      Invoice sent
    </li>
    <li class='flex items-center gap-2'>
      <Icon @variant='soft' @color='success' @size='2xs'><CheckIcon /></Icon>
      Payment received
    </li>
  </ul>
</template>
```

## Accessibility

An icon with no `@label` is decorative: it is hidden from screen readers with
`aria-hidden="true"`. That is right when text beside it says the same thing.

When the icon carries meaning on its own, set `@label`. The icon then has
`role="img"` and that name, and is no longer hidden. Name what it means
("Warning"), not what it looks like ("Triangle").

```gts preview
import { Icon } from 'frontile';
import { CheckIcon } from 'site/components/icons';

<template>
  <Icon @label='Verified' @variant='soft' @color='success'><CheckIcon /></Icon>
</template>
```

An icon is not interactive. To make one a button, use
[IconButton](/docs/components/buttons/icon-button).

## API

<Signature @component="Icon" />
