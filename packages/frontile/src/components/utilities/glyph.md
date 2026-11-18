---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Glyph

Draws one icon from an icon font you supply.

Frontile ships no icon fonts. Glyph turns `@name` into an `icon-<name>` class and
sizes it, and your own `@font-face`, Font Awesome kit or any other icon font
provides the drawing.

## Import

```js
import { Glyph } from 'frontile';
```

## Setup

Define the icons in your own CSS. Glyph adds the `icon` class to every glyph and
`icon-<name>` for the name you pass, so these are the two hooks to style:

```css
@font-face {
  font-family: 'My Icons';
  src: url('/fonts/my-icons.woff2') format('woff2');
}

.icon {
  font-family: 'My Icons';
}

.icon-check::before {
  content: '\e001';
}

.icon-chevron-down::before {
  content: '\e002';
}
```

An icon kit that already defines `.icon-*` classes needs only its stylesheet
loaded.

## Usage

Pass the icon's name. A glyph follows the text color around it.

```gts
import { Glyph } from 'frontile';

<template>
  <Glyph @name='chevron-down' />
</template>
```

## Sizes

`@size` takes the ten steps `4xs`, `3xs`, `2xs`, `xs`, `sm`, `md`, `lg`, `xl`,
`2xl` and `3xl`. They are the same names as the label sizes on Button, Badge and
Chip, and a glyph at a step is the same size as text at that step, so an icon
beside a label lines up without adjustment. The default is `md`.

```gts
import { Glyph } from 'frontile';

<template>
  <Glyph @name='check' @size='xs' />
  <Glyph @name='check' />
  <Glyph @name='check' @size='2xl' />
</template>
```

Use `@size='inherit'` to take the size of the surrounding text instead of a
step. A glyph inside a Button, Chip or Badge then matches that component's label
at whatever size it is.

```gts
import { Button, Glyph } from 'frontile';

<template>
  <Button @size='xs'>
    <Glyph @name='check' @size='inherit' />
    Save
  </Button>
</template>
```

## Color

A glyph uses the current text color. Set it with `@class`.

```gts
import { Glyph } from 'frontile';

<template>
  <Glyph @name='alert' @class='text-warning-strong' />
</template>
```

## Patterns

Glyph has no variants of its own for these; compose it with other components.

### Field handle

Put a glyph in an Input's start or end content.

```gts
import { Input, Glyph } from 'frontile';

<template>
  <Input @label='Search'>
    <:startContent><Glyph @name='search' /></:startContent>
  </Input>
</template>
```

### Label handle

Place a glyph next to a label to mark or explain it.

```gts
import { Glyph } from 'frontile';

<template>
  <label class='inline-flex items-center gap-1'>
    Password
    <Glyph @name='lock' @size='xs' />
  </label>
</template>
```

## Accessibility

A glyph is decorative by default and is hidden from assistive technology
(`aria-hidden="true"`). That is right when text beside it says the same thing, as
with a chevron on a labelled button.

When a glyph is the only thing conveying meaning, give it `@label`. It then
renders with `role="img"` and that label as its accessible name.

```gts
import { Glyph } from 'frontile';

<template>
  <Glyph @name='alert' @label='Needs attention' />
</template>
```

A glyph is not focusable and does nothing on click. For an icon that acts as a
button, use a Button or CloseButton with an accessible name.

## API

<Signature @component="Glyph" />
