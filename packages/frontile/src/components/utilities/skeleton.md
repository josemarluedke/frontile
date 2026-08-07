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
  <div class="p-2 not-prose">
    <Skeleton @class="h-32 rounded-lg" />
  </div>
</template>
```

## Composing a layout

Compose several to sketch the shape of the real content.

```gts preview
import { Skeleton } from 'frontile';

<template>
  <div class="flex items-center gap-3 p-2 not-prose">
    <Skeleton @class="h-10 w-10 shrink-0 rounded-full" />
    <div class="flex-1 space-y-2">
      <Skeleton @class="h-3 w-36" />
      <Skeleton @class="h-3 w-24" />
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
  <div class="space-y-3 p-2 not-prose">
    <Skeleton @class="h-4" @animation="shimmer" />
    <Skeleton @class="h-4" @animation="pulse" />
    <Skeleton @class="h-4" @animation="none" />
  </div>
</template>
```

## Accessibility

Skeleton renders `aria-hidden="true"`. It is decorative — announce the loading
state on the container that owns it, not on each placeholder.

## API

<Signature @component="Skeleton" />
