---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Avatar

The Avatar component is used to represent a user by displaying either their initials or an image. It supports customization of size and shape.

## Import

```js
import { Avatar } from 'frontile';
```

## Usage

### Basic

By default, the Avatar component will display initials derived from the `@name`, `@firstName`, and `@lastName` arguments.

```gts preview
import { Avatar } from 'frontile';

<template>
  <div class='flex items-center space-x-4 py-2'>
    <Avatar @name='Jon Snow' />
    <Avatar @firstName='Arya' @lastName='Stark' />
  </div>
</template>
```

### With an Image

If an `@src` is provided, the avatar will display the image instead of initials.

```gts preview
import { Avatar } from 'frontile';

<template>
  <Avatar @src='https://i.pravatar.cc/150?img=5' @alt='Jon Snow' />
</template>
```

### Different Sizes

The `@size` property allows you to customize the avatar's size.

```gts preview
import { Avatar } from 'frontile';

<template>
  <div class='flex items-center space-x-4 py-2'>
    <Avatar @name='Jon Snow' @size='xs' />
    <Avatar @name='Jon Snow' @size='sm' />
    <Avatar @name='Jon Snow' @size='md' />
    <Avatar @name='Jon Snow' @size='lg' />
    <Avatar @name='Jon Snow' @size='xl' />
  </div>

  <div class='flex items-center space-x-4 py-2'>
    <Avatar @size='xs' @src='https://i.pravatar.cc/150?img=1' />
    <Avatar @size='sm' @src='https://i.pravatar.cc/150?img=2' />
    <Avatar @size='md' @src='https://i.pravatar.cc/150?img=3' />
    <Avatar @size='lg' @src='https://i.pravatar.cc/150?img=4' />
    <Avatar @size='xl' @src='https://i.pravatar.cc/150?img=5' />
  </div>
</template>
```

### Shapes

The `@shape` property changes the avatar shape.

```gts preview
import { Avatar } from 'frontile';

<template>
  <div class='flex items-center space-x-4 py-2'>
    <Avatar @name='Jon Snow' @shape='circle' />
    <Avatar @name='Jon Snow' @shape='square' />
  </div>
</template>
```

### Custom Styling

You can pass custom `@classes` to override styling:

```gts preview
import { Avatar } from 'frontile';
import { hash } from '@ember/helper';

<template>
  <Avatar
    @name='Jon Snow'
    @classes={{hash
      base='bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500 text-white'
    }}
  />
</template>
```

## Accessibility

An avatar is a picture of an identity, and almost always sits beside that
identity written out — a name in a row, a byline, a comment header. That makes
`@alt` a question about duplication rather than about labelling.

**Leave `@alt` off when the name is already visible.** The image then renders
with `alt=""`, marking it decorative so it is skipped rather than announced
twice, and the initials render as plain text. Both are read correctly by the
surrounding content.

```gts preview
import { Avatar } from 'frontile';

<template>
  <ul role='list' class='not-prose flex flex-col gap-3'>
    <li class='flex items-center gap-3'>
      <Avatar @src='https://i.pravatar.cc/150?img=5' />
      <span class='text-neutral-strong'>Jon Snow</span>
    </li>
    <li class='flex items-center gap-3'>
      <Avatar @name='Arya Stark' />
      <span class='text-neutral-strong'>Arya Stark</span>
    </li>
  </ul>
</template>
```

**Pass `@alt` when the avatar stands alone**, as it does in a header or a
compact list where the name is not written out. With `@alt` the initials gain
`role="img"` and are announced as that one name rather than spelled out letter
by letter.

```gts preview
import { Avatar } from 'frontile';

<template>
  <div class='flex items-center gap-4'>
    <Avatar @src='https://i.pravatar.cc/150?img=5' @alt='Jon Snow' />
    <Avatar @name='Arya Stark' @alt='Arya Stark' />
  </div>
</template>
```

The `@alt` should name the person, not the picture. "Jon Snow" is useful;
"User profile picture" and "Avatar" describe the widget, which the reader already
knows and cannot act on.

Two limits worth knowing:

- **An avatar is never focusable or interactive.** It renders a `<span>` and
  takes no key handling. If the avatar should open a menu or a profile, wrap it
  in a `Button` or a link and put the accessible name there — an avatar with a
  click handler on the `<span>` cannot be reached by keyboard at all.
- **A broken `@src` leaves an empty avatar.** There is no automatic fallback to
  initials, so if the URL may fail, pass both a `@name` and no `@src` until you
  know the image loads, or handle the failure yourself.

Colour alone should not carry status. An avatar tinted to mean "online" is
invisible to anyone who cannot see it, so pair the treatment with text — a
`VisuallyHidden` note or a visible label.

## API

<Signature @component="Avatar" />
