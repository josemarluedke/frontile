---
imports:
  - import Signature from 'site/components/signature';
---

# Avatar

Represents a user by displaying their initials or an image. Supports customizable size and shape.

## Import

```js
import { Avatar } from 'frontile';
```

## Usage

### Basic

By default, Avatar displays initials derived from the `@name`, `@firstName`, and `@lastName` arguments.

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

If `@src` is provided, the avatar displays the image instead of initials.

```gts preview
import { Avatar } from 'frontile';

<template>
  <Avatar @src='https://i.pravatar.cc/150?img=5' @alt='Jon Snow' />
</template>
```

If the image fails to load, the avatar shows the initials instead, or an empty
plate when there is no name. A new `@src` is tried again.

```gts preview
import { Avatar } from 'frontile';

<template>
  <div class='flex items-center space-x-4 py-2'>
    <Avatar @src='https://example.invalid/missing.jpg' @name='Jon Snow' />
    <Avatar @src='https://example.invalid/missing.jpg' />
  </div>
</template>
```

### Photos

By default the image covers the avatar: it fills the whole shape and is
cropped to fit, so a photo that is not square keeps its proportions.

```gts preview
import { Avatar } from 'frontile';

<template>
  <div class='flex items-center space-x-4 py-2'>
    <Avatar @src='https://picsum.photos/id/64/300/200' @size='lg' />
    <Avatar @src='https://picsum.photos/id/64/300/200' @size='xl' />
  </div>
</template>
```

### Logos

`@fit='contain'` shows the whole image, with a small inset from the edge that
scales with `@size`. Use it for logos and wordmarks, which must not be cropped.
A square logo that brings its own background can keep the default `cover`.

```gts preview
import { Avatar } from 'frontile';

<template>
  <div class='flex items-center space-x-4 py-2'>
    <Avatar @src='/images/avatar/logo-mark.svg' @size='xl' @alt='Teal Peak' />
    <Avatar
      @src='/images/avatar/logo-wordmark.svg'
      @size='xl'
      @fit='contain'
      @alt='Northwind'
    />
  </div>
</template>
```

The avatar does not choose a background for the image. A dark logo on a
transparent background disappears against the dark-mode plate, so give it a
light background through `@classes.base`:

```gts preview
import { Avatar } from 'frontile';
import { hash } from '@ember/helper';

<template>
  <Avatar
    @src='/images/avatar/logo-wordmark.svg'
    @size='xl'
    @fit='contain'
    @alt='Northwind'
    @classes={{hash base='bg-white'}}
  />
</template>
```

### Bordered

`@isBordered` draws a ring around the avatar, offset by a gap in the page
background colour. It separates the avatar from a busy background, or from its
neighbours in an overlapping stack.

```gts preview
import { Avatar } from 'frontile';

<template>
  <div class='flex items-center space-x-4 py-2'>
    <Avatar @name='Jon Snow' @isBordered={{true}} />
    <Avatar @src='https://i.pravatar.cc/150?img=5' @isBordered={{true}} />
  </div>
</template>
```

Before v0.19 every avatar had this ring. It is now off by default; pass
`@isBordered={{true}}` to keep the previous look.

### Different Sizes

`@size` sets the avatar's size.

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

`@shape` changes the avatar's shape.

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

Two limits:

- **An avatar is never focusable or interactive.** It renders a `<span>` and
  takes no key handling. If the avatar should open a menu or a profile, wrap it
  in a `Button` or a link and put the accessible name there — an avatar with a
  click handler on the `<span>` cannot be reached by keyboard at all.
- **A broken `@src` falls back to the initials only when there is a name.**
  Pass `@name` (and `@alt` when the avatar stands alone) alongside `@src`, so a
  failed image still leaves something to read.

Colour alone should not carry status. An avatar tinted to mean "online" is
invisible to anyone who cannot see it, so pair the treatment with text — a
`VisuallyHidden` note or a visible label.

## API

<Signature @component="Avatar" />
