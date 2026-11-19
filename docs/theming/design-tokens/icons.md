---
title: Icon Sizes
order: 4
category: theming
subcategory: design-tokens
---

# Icon Sizes

Frontile provides an icon sizing scale that matches the text sizes on Button, Badge and Chip.

## Overview

Icon sizes ensure visual consistency between icons and text throughout your interface. Ten steps, `4xs` through `3xl`, are the same size as the label text at the step of the same name: a `size-icon-md` icon is as large as a `md` Button label, so an icon beside text at a step lines up without adjustment.

Five older sizes remain. `pico`, `nano` and `micro` fall between `3xs` and `2xs` (`micro` is the same size as `2xs`), so prefer the steps; `kilo` and `mega` are larger than `3xl`.

## Using Icon Sizes

Apply icon sizes using the `size-icon-*` utilities, which set both width and height:

```gts preview
import { StarIcon } from 'site/components/icons';

<template>
  <div class='flex items-center gap-6'>
    <StarIcon class='size-icon-sm text-primary' />
    <StarIcon class='size-icon-md text-primary' />
    <StarIcon class='size-icon-lg text-primary' />
    <StarIcon class='size-icon-xl text-primary' />
  </div>
</template>
```

## Available Sizes

| Size | Utility | Matches label text | Usage Context |
|------|---------|--------------------|---------------|
| Pico | `size-icon-pico` | | Between 3XS and 2XS |
| Nano | `size-icon-nano` | | Between 3XS and 2XS |
| Micro | `size-icon-micro` | | Same size as 2XS |
| 4XS | `size-icon-4xs` | `text-strong-4xs` | Smallest icon that stays legible |
| 3XS | `size-icon-3xs` | `text-strong-3xs` | Extra extra small icons |
| 2XS | `size-icon-2xs` | `text-strong-2xs` | Extra small icons |
| XS | `size-icon-xs` | `text-strong-xs` | Small inline icons |
| SM | `size-icon-sm` | `text-strong-sm` | Small UI icons |
| MD | `size-icon-md` | `text-strong-md` | Default icon size |
| LG | `size-icon-lg` | `text-strong-lg` | Large prominent icons |
| XL | `size-icon-xl` | `text-strong-xl` | Extra large icons |
| 2XL | `size-icon-2xl` | `text-strong-2xl` | Double extra large icons |
| 3XL | `size-icon-3xl` | `text-strong-3xl` | Triple extra large icons |
| Kilo | `size-icon-kilo` | | Very large decorative icons |
| Mega | `size-icon-mega` | | Largest decorative icons |

The ten matching steps read the label text tokens, so they follow those sizes if
you change them.

## All Icon Sizes

Here are all available icon sizes with visual examples:

```gts preview collapsible
import { CheckIcon } from 'site/components/icons';

<template>
  <div class='grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4'>
    <div class='flex items-center gap-3 p-3 border border-neutral rounded'>
      <CheckIcon class='size-icon-pico text-primary' />
      <div>
        <div class='font-medium'>Pico</div>
        <code class='text-xs'>size-icon-pico</code>
      </div>
    </div>
    <div class='flex items-center gap-3 p-3 border border-neutral rounded'>
      <CheckIcon class='size-icon-nano text-primary' />
      <div>
        <div class='font-medium'>Nano</div>
        <code class='text-xs'>size-icon-nano</code>
      </div>
    </div>
    <div class='flex items-center gap-3 p-3 border border-neutral rounded'>
      <CheckIcon class='size-icon-micro text-primary' />
      <div>
        <div class='font-medium'>Micro</div>
        <code class='text-xs'>size-icon-micro</code>
      </div>
    </div>
    <div class='flex items-center gap-3 p-3 border border-neutral rounded'>
      <CheckIcon class='size-icon-4xs text-primary' />
      <div>
        <div class='font-medium'>4XS</div>
        <code class='text-xs'>size-icon-4xs</code>
      </div>
    </div>
    <div class='flex items-center gap-3 p-3 border border-neutral rounded'>
      <CheckIcon class='size-icon-3xs text-primary' />
      <div>
        <div class='font-medium'>3XS</div>
        <code class='text-xs'>size-icon-3xs</code>
      </div>
    </div>
    <div class='flex items-center gap-3 p-3 border border-neutral rounded'>
      <CheckIcon class='size-icon-2xs text-primary' />
      <div>
        <div class='font-medium'>2XS</div>
        <code class='text-xs'>size-icon-2xs</code>
      </div>
    </div>
    <div class='flex items-center gap-3 p-3 border border-neutral rounded'>
      <CheckIcon class='size-icon-xs text-primary' />
      <div>
        <div class='font-medium'>XS</div>
        <code class='text-xs'>size-icon-xs</code>
      </div>
    </div>
    <div class='flex items-center gap-3 p-3 border border-neutral rounded'>
      <CheckIcon class='size-icon-sm text-primary' />
      <div>
        <div class='font-medium'>SM</div>
        <code class='text-xs'>size-icon-sm</code>
      </div>
    </div>
    <div class='flex items-center gap-3 p-3 border border-neutral rounded'>
      <CheckIcon class='size-icon-md text-primary' />
      <div>
        <div class='font-medium'>MD</div>
        <code class='text-xs'>size-icon-md</code>
      </div>
    </div>
    <div class='flex items-center gap-3 p-3 border border-neutral rounded'>
      <CheckIcon class='size-icon-lg text-primary' />
      <div>
        <div class='font-medium'>LG</div>
        <code class='text-xs'>size-icon-lg</code>
      </div>
    </div>
    <div class='flex items-center gap-3 p-3 border border-neutral rounded'>
      <CheckIcon class='size-icon-xl text-primary' />
      <div>
        <div class='font-medium'>XL</div>
        <code class='text-xs'>size-icon-xl</code>
      </div>
    </div>
    <div class='flex items-center gap-3 p-3 border border-neutral rounded'>
      <CheckIcon class='size-icon-2xl text-primary' />
      <div>
        <div class='font-medium'>2XL</div>
        <code class='text-xs'>size-icon-2xl</code>
      </div>
    </div>
    <div class='flex items-center gap-3 p-3 border border-neutral rounded'>
      <CheckIcon class='size-icon-3xl text-primary' />
      <div>
        <div class='font-medium'>3XL</div>
        <code class='text-xs'>size-icon-3xl</code>
      </div>
    </div>
    <div class='flex items-center gap-3 p-3 border border-neutral rounded'>
      <CheckIcon class='size-icon-kilo text-primary' />
      <div>
        <div class='font-medium'>Kilo</div>
        <code class='text-xs'>size-icon-kilo</code>
      </div>
    </div>
    <div class='flex items-center gap-3 p-3 border border-neutral rounded'>
      <CheckIcon class='size-icon-mega text-primary' />
      <div>
        <div class='font-medium'>Mega</div>
        <code class='text-xs'>size-icon-mega</code>
      </div>
    </div>
  </div>
</template>
```

## Pairing with Text

Match the step of the text next to the icon. The label text at a step
(`text-strong-<step>`, the text on Button, Badge and Chip) is the same size as the
icon at that step.

```gts preview
import { StarIcon } from 'site/components/icons';

<template>
  <div class='flex flex-col gap-3'>
    <div class='flex items-center gap-2 text-strong-xs'>
      <StarIcon class='size-icon-xs' />
      Extra small
    </div>
    <div class='flex items-center gap-2 text-strong-md'>
      <StarIcon class='size-icon-md' />
      Medium
    </div>
    <div class='flex items-center gap-2 text-strong-xl'>
      <StarIcon class='size-icon-xl' />
      Extra large
    </div>
  </div>
</template>
```

Inside a Button you don't need a size class: it sizes an icon placed in it to
match its own label.

For text that is not a Button label, pick the step whose label size is closest:

| Text Style | Closest Icon Size |
|------------|-------------------|
| `text-body-sm` | `size-icon-xs` or `size-icon-sm` |
| `text-body-md` | `size-icon-sm` or `size-icon-md` |
| `text-body-lg` | `size-icon-md` or `size-icon-lg` |
| `text-header-sm` | `size-icon-md` |
| `text-header-md` | `size-icon-md` or `size-icon-lg` |
| `text-header-lg` | `size-icon-lg` or `size-icon-xl` |
| `text-header-xl` | `size-icon-xl` or `size-icon-2xl` |

To follow whatever text surrounds the icon, use Tailwind's `size-[1em]`.

## Customization

Override icon sizes using CSS variables in your `@theme` block:

```css
@import "@frontile/theme";

@theme {
  /* Adjust specific sizes */
  --size-icon-sm: 14px;
  --size-icon-md: 18px;
  --size-icon-lg: 22px;
}
```

For more customization options, see the [Configuration Guide](../configuration/customization.md).
