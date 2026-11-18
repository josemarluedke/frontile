---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# IconButton

A button that shows only an icon.

The icon is the block you pass in, so it works with whatever icon source you
use: inline SVGs, ember-fontawesome's `FaIcon`, or your own components. It
takes the same sizes, colors and variants as
[Button](/docs/components/buttons/button). It is a circle.

## Import

```js
import { IconButton } from 'frontile';
```

## Usage

Put the icon in the block and name the button with `@label`. The label is
required.

```gts preview
import { IconButton } from 'frontile';
import { DeleteIcon } from 'site/components/icons';

<template>
  <IconButton @label='Delete item'><DeleteIcon /></IconButton>
</template>
```

## Sizes

`@size` takes `xs`, `sm`, `md`, `lg`, `xl` and `2xl`, the same names as Button.
The default is `md`. The icon grows with the button.

| Size | Button | Icon |
| ---- | ------ | ---- |
| `xs` | 24px | 10px |
| `sm` | 34px | 12px |
| `md` | 42px | 16px |
| `lg` | 52px | 20px |
| `xl` | 68px | 28px |
| `2xl` | 80px | 32px |

```gts preview
import { IconButton } from 'frontile';
import { EditIcon } from 'site/components/icons';

<template>
  <div class='flex items-center gap-3'>
    <IconButton @label='Edit' @size='xs'><EditIcon /></IconButton>
    <IconButton @label='Edit' @size='sm'><EditIcon /></IconButton>
    <IconButton @label='Edit'><EditIcon /></IconButton>
    <IconButton @label='Edit' @size='lg'><EditIcon /></IconButton>
    <IconButton @label='Edit' @size='xl'><EditIcon /></IconButton>
    <IconButton @label='Edit' @size='2xl'><EditIcon /></IconButton>
  </div>
</template>
```

## Colors and variants

`@color` and `@variant` take the same values as Button.

```gts preview
import { IconButton } from 'frontile';
import { DeleteIcon, DuplicateIcon, ShareIcon } from 'site/components/icons';

<template>
  <div class='flex items-center gap-3'>
    <IconButton @label='Delete' @color='danger'><DeleteIcon /></IconButton>
    <IconButton @label='Copy' @variant='outline'><DuplicateIcon /></IconButton>
    <IconButton @label='Share' @variant='ghost' @color='primary'><ShareIcon
      /></IconButton>
  </div>
</template>
```

## Loading and disabled

`@isLoading` swaps the icon for a spinner and disables the button. The button
keeps its name. Use the native `disabled` attribute to disable it otherwise.

```gts preview
import { IconButton } from 'frontile';
import { DownloadIcon } from 'site/components/icons';

<template>
  <div class='flex items-center gap-3'>
    <IconButton @label='Download' @isLoading={{true}}><DownloadIcon
      /></IconButton>
    <IconButton @label='Download' disabled><DownloadIcon /></IconButton>
  </div>
</template>
```

## Handling presses

`@onPress` works as it does on Button and fires for mouse, touch and keyboard.

```gts
import { IconButton } from 'frontile';
import { ArchiveIcon } from 'site/components/icons';

<template>
  <IconButton @label='Archive' @onPress={{this.archive}}><ArchiveIcon
    /></IconButton>
</template>
```

## Accessibility

An icon has no text, so `@label` is required and must not be empty. It becomes
the button's `aria-label`. Name the action ("Delete item"), not the picture
("Trash can"). Hide the icon from assistive technology with `aria-hidden="true"`
so it is not announced as well.

The button is a native `<button>`. It takes focus with Tab and activates with
Enter or Space, and it shows the same focus ring as Button. While loading it
is disabled and reports `aria-busy`.

## API

<Signature @component="IconButton" />
