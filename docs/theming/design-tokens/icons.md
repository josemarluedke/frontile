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

## Pairing with Typography

Icon sizes are designed to pair harmoniously with text styles. Use these recommended pairings for visual alignment:

```gts preview
<template>
  <div class='flex flex-col gap-4'>
    {{! Small text with small icon }}
    <div class='flex items-center gap-2'>
      <svg class='size-icon-xs text-success-medium' fill='currentColor' viewBox='0 0 20 20'>
        <path
          fill-rule='evenodd'
          d='M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z'
          clip-rule='evenodd'
        ></path>
      </svg>
      <span class='text-body-sm'>Small body text with size-icon-xs</span>
    </div>

    {{! Medium text with medium icon }}
    <div class='flex items-center gap-2'>
      <svg class='size-icon-md text-brand-medium' fill='currentColor' viewBox='0 0 20 20'>
        <path
          fill-rule='evenodd'
          d='M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z'
          clip-rule='evenodd'
        ></path>
      </svg>
      <span class='text-body-md'>Default body text with size-icon-md</span>
    </div>

    {{! Large text with large icon }}
    <div class='flex items-center gap-2'>
      <svg class='size-icon-lg text-warning-medium' fill='currentColor' viewBox='0 0 20 20'>
        <path
          fill-rule='evenodd'
          d='M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z'
          clip-rule='evenodd'
        ></path>
      </svg>
      <span class='text-body-lg'>Large body text with size-icon-lg</span>
    </div>

    {{! Header with large icon }}
    <div class='flex items-center gap-3'>
      <svg class='size-icon-xl text-danger-medium' fill='currentColor' viewBox='0 0 20 20'>
        <path
          fill-rule='evenodd'
          d='M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z'
          clip-rule='evenodd'
        ></path>
      </svg>
      <h2 class='text-header-lg'>Header text with size-icon-xl</h2>
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

## Common Use Cases

### Buttons with Icons

```gts preview
<template>
  <div class='flex gap-4 flex-wrap'>
    <button class='flex items-center gap-2 bg-brand-medium text-on-brand-medium px-4 py-2 rounded hover:bg-brand-soft'>
      <svg class='size-icon-sm' fill='currentColor' viewBox='0 0 20 20'>
        <path d='M10 5a1 1 0 011 1v3h3a1 1 0 110 2h-3v3a1 1 0 11-2 0v-3H6a1 1 0 110-2h3V6a1 1 0 011-1z'></path>
      </svg>
      <span class='text-label-sm'>Add Item</span>
    </button>

    <button class='flex items-center gap-2 border border-neutral-medium px-4 py-2 rounded hover:bg-neutral-subtle'>
      <svg class='size-icon-sm text-neutral-medium' fill='currentColor' viewBox='0 0 20 20'>
        <path
          fill-rule='evenodd'
          d='M3 17a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm3.293-7.707a1 1 0 011.414 0L9 10.586V3a1 1 0 112 0v7.586l1.293-1.293a1 1 0 111.414 1.414l-3 3a1 1 0 01-1.414 0l-3-3a1 1 0 010-1.414z'
          clip-rule='evenodd'
        ></path>
      </svg>
      <span class='text-label-sm text-neutral-strong'>Download</span>
    </button>
  </div>
</template>
```

### List Items with Icons

```gts preview
<template>
  <ul class='space-y-2'>
    <li class='flex items-center gap-2'>
      <svg class='size-icon-sm text-success-medium' fill='currentColor' viewBox='0 0 20 20'>
        <path
          fill-rule='evenodd'
          d='M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z'
          clip-rule='evenodd'
        ></path>
      </svg>
      <span class='text-body-md'>Task completed successfully</span>
    </li>
    <li class='flex items-center gap-2'>
      <svg class='size-icon-sm text-warning-medium' fill='currentColor' viewBox='0 0 20 20'>
        <path
          fill-rule='evenodd'
          d='M10 18a8 8 0 100-16 8 8 0 000 16zM9 7a1 1 0 112 0v4a1 1 0 11-2 0V7zm1 8a1 1 0 100-2 1 1 0 000 2z'
          clip-rule='evenodd'
        ></path>
      </svg>
      <span class='text-body-md'>Warning: Review required</span>
    </li>
    <li class='flex items-center gap-2'>
      <svg class='size-icon-sm text-danger-medium' fill='currentColor' viewBox='0 0 20 20'>
        <path
          fill-rule='evenodd'
          d='M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z'
          clip-rule='evenodd'
        ></path>
      </svg>
      <span class='text-body-md'>Error: Action failed</span>
    </li>
  </ul>
</template>
```

### Input Fields with Icons

```gts preview
<template>
  <div class='space-y-3'>
    <div class='relative'>
      <svg
        class='size-icon-sm text-neutral-soft absolute left-3 top-1/2 -translate-y-1/2'
        fill='currentColor'
        viewBox='0 0 20 20'
      >
        <path
          fill-rule='evenodd'
          d='M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z'
          clip-rule='evenodd'
        ></path>
      </svg>
      <input
        type='text'
        placeholder='Search...'
        class='w-full pl-10 pr-4 py-2 border border-neutral-medium rounded focus:outline-none focus:ring-2 focus:ring-brand-medium'
      />
    </div>
  </div>
</template>
```

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
