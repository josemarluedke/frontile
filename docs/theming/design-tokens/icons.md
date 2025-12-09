---
title: Icon Sizes
order: 4
category: theming
subcategory: design-tokens
---

# Icon Sizes

Frontile provides a comprehensive icon sizing scale that pairs harmoniously with typography for consistent visual alignment.

## Overview

Icon sizes ensure visual consistency between icons and text throughout your interface. They use the same modular scale as typography, making it easy to pair icons with text styles.

The scale ranges from `pico` (smallest) to `mega` (largest), providing 14 distinct sizes for different UI contexts.

## Using Icon Sizes

Apply icon sizes using the `size-icon-*` utilities, which set both width and height:

```gts preview
<template>
  <div class='flex items-center gap-6'>
    <svg class='size-icon-sm text-brand-medium' fill='currentColor' viewBox='0 0 20 20'>
      <path d='M10 12a2 2 0 100-4 2 2 0 000 4z'></path>
      <path
        fill-rule='evenodd'
        d='M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z'
        clip-rule='evenodd'
      ></path>
    </svg>
    <svg class='size-icon-md text-brand-medium' fill='currentColor' viewBox='0 0 20 20'>
      <path d='M10 12a2 2 0 100-4 2 2 0 000 4z'></path>
      <path
        fill-rule='evenodd'
        d='M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z'
        clip-rule='evenodd'
      ></path>
    </svg>
    <svg class='size-icon-lg text-brand-medium' fill='currentColor' viewBox='0 0 20 20'>
      <path d='M10 12a2 2 0 100-4 2 2 0 000 4z'></path>
      <path
        fill-rule='evenodd'
        d='M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z'
        clip-rule='evenodd'
      ></path>
    </svg>
    <svg class='size-icon-xl text-brand-medium' fill='currentColor' viewBox='0 0 20 20'>
      <path d='M10 12a2 2 0 100-4 2 2 0 000 4z'></path>
      <path
        fill-rule='evenodd'
        d='M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z'
        clip-rule='evenodd'
      ></path>
    </svg>
  </div>
</template>
```

## Available Sizes

| Size | Utility | Usage Context |
|------|---------|---------------|
| Pico | `size-icon-pico` | Extremely small UI elements |
| Nano | `size-icon-nano` | Tiny decorative icons |
| Micro | `size-icon-micro` | Very small inline icons |
| 3XS | `size-icon-3xs` | Extra extra small icons |
| 2XS | `size-icon-2xs` | Extra small icons |
| XS | `size-icon-xs` | Small inline icons |
| SM | `size-icon-sm` | Small UI icons |
| MD | `size-icon-md` | Default icon size |
| LG | `size-icon-lg` | Large prominent icons |
| XL | `size-icon-xl` | Extra large icons |
| 2XL | `size-icon-2xl` | Double extra large icons |
| 3XL | `size-icon-3xl` | Triple extra large icons |
| Kilo | `size-icon-kilo` | Very large decorative icons |
| Mega | `size-icon-mega` | Largest decorative icons |

## All Icon Sizes

Here are all available icon sizes with visual examples:

```gts preview
import { CheckIcon } from 'site/components/icons';

<template>
  <div class='grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4'>
    <div class='flex items-center gap-3 p-3 border border-neutral-medium rounded'>
      <CheckIcon class='size-icon-pico text-brand-medium' />
      <div>
        <div class='font-medium'>Pico</div>
        <code class='text-xs'>size-icon-pico</code>
      </div>
    </div>
    <div class='flex items-center gap-3 p-3 border border-neutral-medium rounded'>
      <CheckIcon class='size-icon-nano text-brand-medium' />
      <div>
        <div class='font-medium'>Nano</div>
        <code class='text-xs'>size-icon-nano</code>
      </div>
    </div>
    <div class='flex items-center gap-3 p-3 border border-neutral-medium rounded'>
      <CheckIcon class='size-icon-micro text-brand-medium' />
      <div>
        <div class='font-medium'>Micro</div>
        <code class='text-xs'>size-icon-micro</code>
      </div>
    </div>
    <div class='flex items-center gap-3 p-3 border border-neutral-medium rounded'>
      <CheckIcon class='size-icon-3xs text-brand-medium' />
      <div>
        <div class='font-medium'>3XS</div>
        <code class='text-xs'>size-icon-3xs</code>
      </div>
    </div>
    <div class='flex items-center gap-3 p-3 border border-neutral-medium rounded'>
      <CheckIcon class='size-icon-2xs text-brand-medium' />
      <div>
        <div class='font-medium'>2XS</div>
        <code class='text-xs'>size-icon-2xs</code>
      </div>
    </div>
    <div class='flex items-center gap-3 p-3 border border-neutral-medium rounded'>
      <CheckIcon class='size-icon-xs text-brand-medium' />
      <div>
        <div class='font-medium'>XS</div>
        <code class='text-xs'>size-icon-xs</code>
      </div>
    </div>
    <div class='flex items-center gap-3 p-3 border border-neutral-medium rounded'>
      <CheckIcon class='size-icon-sm text-brand-medium' />
      <div>
        <div class='font-medium'>SM</div>
        <code class='text-xs'>size-icon-sm</code>
      </div>
    </div>
    <div class='flex items-center gap-3 p-3 border border-neutral-medium rounded'>
      <CheckIcon class='size-icon-md text-brand-medium' />
      <div>
        <div class='font-medium'>MD</div>
        <code class='text-xs'>size-icon-md</code>
      </div>
    </div>
    <div class='flex items-center gap-3 p-3 border border-neutral-medium rounded'>
      <CheckIcon class='size-icon-lg text-brand-medium' />
      <div>
        <div class='font-medium'>LG</div>
        <code class='text-xs'>size-icon-lg</code>
      </div>
    </div>
    <div class='flex items-center gap-3 p-3 border border-neutral-medium rounded'>
      <CheckIcon class='size-icon-xl text-brand-medium' />
      <div>
        <div class='font-medium'>XL</div>
        <code class='text-xs'>size-icon-xl</code>
      </div>
    </div>
    <div class='flex items-center gap-3 p-3 border border-neutral-medium rounded'>
      <CheckIcon class='size-icon-2xl text-brand-medium' />
      <div>
        <div class='font-medium'>2XL</div>
        <code class='text-xs'>size-icon-2xl</code>
      </div>
    </div>
    <div class='flex items-center gap-3 p-3 border border-neutral-medium rounded'>
      <CheckIcon class='size-icon-3xl text-brand-medium' />
      <div>
        <div class='font-medium'>3XL</div>
        <code class='text-xs'>size-icon-3xl</code>
      </div>
    </div>
    <div class='flex items-center gap-3 p-3 border border-neutral-medium rounded'>
      <CheckIcon class='size-icon-kilo text-brand-medium' />
      <div>
        <div class='font-medium'>Kilo</div>
        <code class='text-xs'>size-icon-kilo</code>
      </div>
    </div>
    <div class='flex items-center gap-3 p-3 border border-neutral-medium rounded'>
      <CheckIcon class='size-icon-mega text-brand-medium' />
      <div>
        <div class='font-medium'>Mega</div>
        <code class='text-xs'>size-icon-mega</code>
      </div>
    </div>
  </div>
</template>
```

## Pairing with Typography

Icon sizes are designed to pair harmoniously with text styles. Use these recommended pairings for visual alignment:

```gts preview
import { CheckIcon, ViewIcon, StarIcon } from 'site/components/icons';

<template>
  <div class='flex flex-col gap-4'>
    {{! Small icon pairing }}
    <div class='flex items-center gap-2'>
      <CheckIcon class='size-icon-xs text-success-medium' />
      <span>Small text with size-icon-xs</span>
    </div>

    {{! Medium icon pairing }}
    <div class='flex items-center gap-2'>
      <ViewIcon class='size-icon-md text-brand-medium' />
      <span>Default text with size-icon-md</span>
    </div>

    {{! Large icon pairing }}
    <div class='flex items-center gap-2'>
      <StarIcon class='size-icon-lg text-warning-medium' />
      <span>Larger text with size-icon-lg</span>
    </div>

    {{! Extra large icon pairing }}
    <div class='flex items-center gap-3'>
      <CheckIcon class='size-icon-xl text-danger-medium' />
      <h2>Header with size-icon-xl</h2>
    </div>
  </div>
</template>
```

### Recommended Pairings

| Text Style | Recommended Icon Size |
|------------|----------------------|
| `text-body-sm` | `size-icon-xs` or `size-icon-sm` |
| `text-body-md` | `size-icon-sm` or `size-icon-md` |
| `text-body-lg` | `size-icon-md` or `size-icon-lg` |
| `text-header-sm` | `size-icon-md` |
| `text-header-md` | `size-icon-md` or `size-icon-lg` |
| `text-header-lg` | `size-icon-lg` or `size-icon-xl` |
| `text-header-xl` | `size-icon-xl` or `size-icon-2xl` |

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
