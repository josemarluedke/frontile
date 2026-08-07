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

A Skeleton is a self-contained element. Size and shape come from `@class`.

```gts preview
import { Skeleton } from 'frontile';

<template>
  <div class="not-prose w-80 space-y-3">
    <Skeleton @class="h-32 rounded-lg" />
    <Skeleton @class="h-3" />
    <Skeleton @class="h-3 w-2/3" />
  </div>
</template>
```

The base style is `w-full`, so a Skeleton fills its container. Give the
container a width — or set one on the Skeleton with `@class` — since a
`width: 100%` element inside a content-sized parent collapses to nothing.

## Composing a layout

Compose several to sketch the shape of the real content.

```gts preview
import { Skeleton } from 'frontile';

<template>
  <div class="not-prose flex w-80 items-center gap-3">
    <Skeleton @class="h-10 w-10 shrink-0 rounded-full" />
    <div class="flex-1 space-y-2">
      <Skeleton @class="h-3" />
      <Skeleton @class="h-3 w-2/3" />
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
  <div class="not-prose w-80 space-y-4">
    <div>
      <p class="mb-1 text-body-micro text-neutral-soft">shimmer (default)</p>
      <Skeleton @class="h-4" @animation="shimmer" />
    </div>
    <div>
      <p class="mb-1 text-body-micro text-neutral-soft">pulse</p>
      <Skeleton @class="h-4" @animation="pulse" />
    </div>
    <div>
      <p class="mb-1 text-body-micro text-neutral-soft">none</p>
      <Skeleton @class="h-4" @animation="none" />
    </div>
  </div>
</template>
```

## Accessibility

Skeleton renders `aria-hidden="true"`. It is decorative — announce the loading
state on the container that owns it, not on each placeholder.

## API

<Signature @component="Skeleton" />
