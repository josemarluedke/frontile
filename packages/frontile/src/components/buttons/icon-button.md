---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# IconButton

A button that shows only an icon.

The icon is a [Glyph](/docs/components/utilities/glyph), so it comes from an icon
font you supply. IconButton takes the same sizes, colors and variants as
[Button](/docs/components/buttons/button), with padding sized for an icon alone.

## Import

```js
import { IconButton } from 'frontile';
```

## Usage

`@icon` names the icon and `@label` names the button. Both are required.

```gts
import { IconButton } from 'frontile';

<template>
  <IconButton @icon='trash' @label='Delete item' />
</template>
```

## Sizes

`@size` takes `xs`, `sm`, `md`, `lg`, `xl` and `2xl`, the same names as Button.
The default is `md`. The icon scales with the button.

```gts
import { IconButton } from 'frontile';

<template>
  <IconButton @icon='edit' @label='Edit' @size='xs' />
  <IconButton @icon='edit' @label='Edit' />
  <IconButton @icon='edit' @label='Edit' @size='2xl' />
</template>
```

## Colors and variants

`@color` and `@variant` take the same values as Button.

```gts
import { IconButton } from 'frontile';

<template>
  <IconButton @icon='trash' @label='Delete' @color='danger' />
  <IconButton @icon='copy' @label='Copy' @variant='outline' />
  <IconButton @icon='share' @label='Share' @variant='ghost' @color='primary' />
</template>
```

## Loading

`@isLoading` swaps the icon for a spinner and disables the button. The button
keeps its name. Use the native `disabled` attribute to disable it otherwise.

```gts
import { IconButton } from 'frontile';

<template>
  <IconButton @icon='download' @label='Download' @isLoading={{true}} />
  <IconButton @icon='download' @label='Download' disabled />
</template>
```

## Handling presses

`@onPress` works as it does on Button and fires for mouse, touch and keyboard.

```gts
import { IconButton } from 'frontile';

<template>
  <IconButton @icon='archive' @label='Archive' @onPress={{this.archive}} />
</template>
```

## Accessibility

An icon has no text, so `@label` is required. It becomes the button's
`aria-label`, and the icon itself is hidden from assistive technology. Name the
action ("Delete item"), not the picture ("Trash can").

The button is a native `<button>`. It takes focus with Tab and activates with
Enter or Space, and it shows the same focus ring as Button. While loading it
is disabled and reports `aria-busy`.

## API

<Signature @component="IconButton" />
