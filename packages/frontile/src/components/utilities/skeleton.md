---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Skeleton

A Skeleton is a placeholder that stands in for content while it loads. It gives
the eye the shape of what is coming, which an empty region cannot.

## Import

```js
import { Skeleton } from 'frontile';
```

## Usage

A Skeleton is a self-contained element. Reach for `@shape` and `@size` first,
and use `@class` for anything they don't cover.

```gts preview
import { Skeleton } from 'frontile';

<template>
  <div class='not-prose w-80 space-y-3'>
    <Skeleton @shape='rounded' @class='h-32' />
    <Skeleton @size='sm' />
    <Skeleton @size='sm' @class='w-2/3' />
  </div>
</template>
```

`text`, `rounded`, and `rect` fill their container's width. Give the container a
width — or set one with `@class` — since a `width: 100%` element inside a
content-sized parent collapses to nothing.

## Shapes

`@shape` sets the radius and proportions so you don't hand-assemble them.
`text` is the default.

```gts preview
import { Skeleton } from 'frontile';

<template>
  <div class='not-prose flex w-96 items-end gap-4'>
    <div class='flex-1 space-y-2'>
      <Skeleton @shape='text' />
      <Skeleton @shape='text' @class='w-2/3' />
    </div>
    <Skeleton @shape='circle' @size='xl' />
    <Skeleton @shape='square' @size='xl' />
  </div>
</template>
```

| Shape     | Use for                    | Sizing                           |
| --------- | -------------------------- | -------------------------------- |
| `text`    | Lines of copy, table cells | Fills width, `@size` sets height |
| `circle`  | Avatars, icon buttons      | Equal-sided from `@size`         |
| `square`  | Square avatars, thumbnails | Equal-sided from `@size`         |
| `rounded` | Images, cards, media       | Fills width, give it a height    |
| `rect`    | Flush-edged blocks         | Fills width, give it a height    |

`circle` and `square` reuse Avatar's radii and size scale, so a placeholder
lines up with the real thing it stands in for:

```gts preview
import { Skeleton, Avatar } from 'frontile';

<template>
  <div class='not-prose flex items-center gap-4'>
    <Skeleton @shape='circle' @size='lg' />
    <Avatar @name='Ada Lovelace' @size='lg' />
    <Skeleton @shape='square' @size='lg' />
    <Avatar @name='Ada Lovelace' @shape='square' @size='lg' />
  </div>
</template>
```

## Sizes

`@size` accepts `xs`, `sm`, `md` (default), `lg`, and `xl`. For `circle` and
`square` it sets both dimensions; for the other shapes it sets the height.
Every shape has an intrinsic height at every size — a zero-height skeleton is
invisible, which makes a loading state look like an empty one.

```gts preview
import { Skeleton } from 'frontile';

<template>
  <div class='not-prose flex w-96 items-center gap-4'>
    <Skeleton @shape='circle' @size='xs' />
    <Skeleton @shape='circle' @size='sm' />
    <Skeleton @shape='circle' @size='md' />
    <Skeleton @shape='circle' @size='lg' />
    <Skeleton @shape='circle' @size='xl' />
  </div>
</template>
```

## Images and cards

`rounded` and `rect` fill their container; give them a height with `@class`.

```gts preview
import { Skeleton } from 'frontile';

<template>
  <div class='not-prose w-72 space-y-3'>
    <Skeleton @shape='rounded' @class='h-40' />
    <Skeleton @shape='text' @size='lg' @class='w-3/4' />
    <Skeleton @shape='text' @size='sm' />
    <Skeleton @shape='text' @size='sm' @class='w-1/2' />
  </div>
</template>
```

## Composing a layout

Compose several to sketch the shape of the real content.

```gts preview
import { Skeleton } from 'frontile';

<template>
  <div class='not-prose flex w-80 items-center gap-3'>
    <Skeleton @shape='circle' @size='lg' @class='shrink-0' />
    <div class='flex-1 space-y-2'>
      <Skeleton @size='sm' />
      <Skeleton @size='sm' @class='w-2/3' />
    </div>
  </div>
</template>
```

## Animation

`shimmer` is the default. It uses a Frontile-defined keyframe, so it is
unaffected by an app that redefines Tailwind's `pulse`.

```gts preview
import { Skeleton } from 'frontile';

<template>
  <div class='not-prose w-80 space-y-4'>
    <div>
      <p class='mb-1 text-body-2xs text-neutral-soft'>shimmer (default)</p>
      <Skeleton @class='h-4' @animation='shimmer' />
    </div>
    <div>
      <p class='mb-1 text-body-2xs text-neutral-soft'>pulse</p>
      <Skeleton @class='h-4' @animation='pulse' />
    </div>
    <div>
      <p class='mb-1 text-body-2xs text-neutral-soft'>none</p>
      <Skeleton @class='h-4' @animation='none' />
    </div>
  </div>
</template>
```

## Accessibility

Skeleton renders `aria-hidden="true"`. It is decorative — announce the loading
state on the container that owns it, not on each placeholder.

## In Table

[`Table`](/docs/components/collections/table#built-in-skeleton-rows) renders
`Skeleton` for you when you set `@isLoading` and `@skeletonRows` — you rarely
need to compose it by hand for that case.

## API

<Signature @component="Skeleton" />
