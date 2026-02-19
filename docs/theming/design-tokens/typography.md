---
title: Typography
order: 3
category: theming
subcategory: design-tokens
---

# Typography System

Frontile's typography system provides a comprehensive, scalable type system built on semantic text styles and a modular scale. It uses Tailwind v4's `@theme` directive for base tokens and `@layer utilities` for explicit utility classes.

## Overview

The typography system includes:

- **6 text style categories**: Marquee, Header, Body, Code, Caption, and Label
- **Multiple size variants** for each category
- **Modular scale** based on a mathematical ratio for harmonic sizing
- **Composite utility classes** that bundle all typography properties together
- **Full customization** through CSS variables

## Text Style Categories

### Marquee

Large, bold display text for hero sections and prominent headings.

```gts preview
<template>
  <div class='flex flex-col gap-6'>
    <div class='font-marquee text-marquee-xl'>Marquee XL: Hero Heading</div>
    <div class='font-marquee text-marquee-lg'>Marquee LG: Large Display</div>
    <div class='font-marquee text-marquee-md'>Marquee MD: Medium Display</div>
    <div class='font-marquee text-marquee-sm'>Marquee SM: Small Display</div>
  </div>
</template>
```

**Available sizes:** `sm`, `md`, `lg`, `xl`
**Best for:** Hero sections, landing page titles, major marketing headings

### Header

Semantic headings for content hierarchy with bold weight and condensed letter spacing.

```gts preview
<template>
  <div class='flex flex-col gap-4'>
    <h1 class='font-header text-header-3xl'>Header 3XL: Page Title</h1>
    <h2 class='font-header text-header-2xl'>Header 2XL: Major Section</h2>
    <h3 class='font-header text-header-xl'>Header XL: Section Title</h3>
    <h4 class='font-header text-header-lg'>Header LG: Subsection</h4>
    <h5 class='font-header text-header-md'>Header MD: Subheading</h5>
    <h6 class='font-header text-header-sm'>Header SM: Minor Heading</h6>
    <div class='font-header text-header-xs'>Header XS: Small Heading</div>
    <div class='font-header text-header-2xs'>Header 2XS: Tiny Heading</div>
    <div class='font-header text-header-micro'>Header Micro: Micro Heading</div>
    <div class='font-header text-header-nano'>Header Nano: Nano Heading</div>
  </div>
</template>
```

**Available sizes:** `nano`, `micro`, `2xs`, `xs`, `sm`, `md`, `lg`, `xl`, `2xl`, `3xl`
**Best for:** Content headings (h1-h6), section titles, hierarchical structure

### Body

Standard body text with spacious line height optimized for readability.

```gts preview
<template>
  <div class='flex flex-col gap-6'>
    <p class='font-body text-body-xl'>
      Body XL: The quick brown fox jumps over the lazy dog. This is extra large body text with spacious line height for comfortable reading.
    </p>
    <p class='font-body text-body-lg'>
      Body LG: The quick brown fox jumps over the lazy dog. This is large body text with spacious line height for comfortable reading.
    </p>
    <p class='font-body text-body-md'>
      Body MD: The quick brown fox jumps over the lazy dog. This is default body text with spacious line height for comfortable reading.
    </p>
    <p class='font-body text-body-sm'>
      Body SM: The quick brown fox jumps over the lazy dog. This is small body text with spacious line height for comfortable reading.
    </p>
    <p class='font-body text-body-xs'>
      Body XS: The quick brown fox jumps over the lazy dog. This is extra small body text.
    </p>
    <p class='font-body text-body-2xs'>
      Body 2XS: The quick brown fox jumps over the lazy dog. This is 2XS body text.
    </p>
    <p class='font-body text-body-3xs'>
      Body 3XS: The quick brown fox jumps over the lazy dog. This is 3XS body text.
    </p>
    <p class='font-body text-body-micro'>
      Body Micro: The quick brown fox jumps over the lazy dog. This is micro body text.
    </p>
    <p class='font-body text-body-nano'>
      Body Nano: The quick brown fox jumps over the lazy dog. This is nano body text.
    </p>
    <p class='font-body text-body-pico'>
      Body Pico: The quick brown fox jumps over the lazy dog. This is pico body text.
    </p>
  </div>
</template>
```

**Available sizes:** `pico`, `nano`, `micro`, `3xs`, `2xs`, `xs`, `sm`, `md`, `lg`, `xl`
**Best for:** Paragraphs, article content, descriptions, general text

### Code

Monospace text for code snippets and technical content.

```gts preview
<template>
  <div class='flex flex-col gap-3'>
    <code class='font-code text-code-md bg-neutral-subtle px-2 py-1 rounded'>
      const greeting = "Hello, World!";
    </code>
    <code class='font-code text-code-sm bg-neutral-subtle px-2 py-1 rounded'>
      npm install frontile
    </code>
  </div>
</template>
```

**Available sizes:** `sm`, `md`
**Best for:** Code blocks, inline code, technical identifiers

### Caption

Secondary descriptive text with relaxed letter spacing.

```gts preview
<template>
  <div class='flex flex-col gap-3'>
    <div>
      <div class='bg-neutral-subtle rounded mb-2 h-32 flex items-center justify-center text-neutral-strong'>
        Example Image
      </div>
      <span class='font-caption text-caption-md text-neutral-strong'>Caption MD: Figure 1 - Example image caption with medium size</span>
    </div>
    <div>
      <span class='font-caption text-caption-sm text-neutral-strong'>Caption SM: Small caption text for supplementary information</span>
    </div>
  </div>
</template>
```

**Available sizes:** `sm`, `md`
**Best for:** Image captions, figure labels, supplementary text

### Label

UI labels and form labels with bold weight and tight letter spacing.

```gts preview
<template>
  <div class='flex flex-col gap-3'>
    <div class='font-label text-label-3xl'>Label 3XL: Extra Large Label</div>
    <div class='font-label text-label-2xl'>Label 2XL: Double Extra Large Label</div>
    <div class='font-label text-label-xl'>Label XL: Extra Large Label</div>
    <div class='font-label text-label-lg'>Label LG: Large Label</div>
    <div class='font-label text-label-md'>Label MD: Medium Label</div>
    <div class='font-label text-label-sm'>Label SM: Small Label</div>
    <div class='font-label text-label-xs'>Label XS: Extra Small Label</div>
    <div class='font-label text-label-2xs'>Label 2XS: Double Extra Small Label</div>
    <div class='font-label text-label-micro'>Label Micro: Micro Label</div>
    <div class='font-label text-label-nano'>Label Nano: Nano Label</div>
  </div>
</template>
```

**Available sizes:** `nano`, `micro`, `2xs`, `xs`, `sm`, `md`, `lg`, `xl`, `2xl`, `3xl`
**Best for:** Form labels, UI labels, buttons, navigation items, badges

## Available Utilities

All text style utilities require both a font-family utility and a sized text style utility:

```html
<!-- Complete typography requires both font-family and sized text style -->
<h1 class="font-marquee text-marquee-xl">...</h1>
<h2 class="font-header text-header-md">...</h2>
<p class="font-body text-body-md">...</p>
<code class="font-code text-code-sm">...</code>
<span class="font-caption text-caption-md">...</span>
<label class="font-label text-label-sm">...</label>
```

## Combining with Other Utilities

Typography utilities work seamlessly with other Tailwind utilities:

```gts preview
<template>
  <div class='flex flex-col gap-4'>
    {{! Colored header }}
    <h2 class='font-header text-header-xl text-brand-strong'>Colored Header</h2>

    {{! Truncated body text }}
    <p class='font-body text-body-md truncate max-w-md'>
      This is a very long paragraph that will be truncated with an ellipsis when it exceeds the maximum width.
    </p>

    {{! Centered caption }}
    <span class='font-caption text-caption-md text-center block text-neutral-strong'>
      Centered caption text
    </span>

    {{! Responsive header }}
    <h1 class='font-header text-header-lg md:text-header-xl lg:text-header-2xl'>
      Responsive Heading
    </h1>
  </div>
</template>
```

## How It Works

The typography system uses Tailwind v4's `@theme` directive to automatically generate utilities from CSS variables:

1. **Base tokens** defined in `@theme` automatically generate individual utilities:
   - `--font-header` → `font-header` utility
   - `--font-size-14` → `text-14` utility
   - `--font-weight-bold` → `font-bold` utility
   - `--letter-spacing-condensed` → `tracking-condensed` utility
   - `--line-height-comfy` → `leading-comfy` utility

2. **Composite text style tokens** generate size/weight/spacing utilities (but NOT font-family):
   - `--text-header-md` → `text-header-md` utility (sets size, weight, spacing, line-height)
   - `--text-body-lg` → `text-body-lg` utility (sets size, weight, spacing, line-height)

**Usage pattern:** Combine font-family with text style for complete typography:

```html
<!-- ✓ Correct: Combine font-family with text style -->
<h2 class="font-header text-header-md">Heading Text</h2>
<p class="font-body text-body-lg">Body text with larger size</p>
<span class="font-label text-label-sm">Small label</span>

<!-- ✗ Incomplete: Missing font-family -->
<h2 class="text-header-md">Heading Text</h2>
```

The separation of font-family from text styles provides flexibility to mix font families with different text styles while maintaining consistent sizing, weight, spacing, and line-height.

## Customization

### Using CSS Variables

Customize typography by overriding CSS variables in your app's CSS file:

```css
@import "@frontile/theme";

/* Override font families */
@theme {
  --font-header: "Inter", system-ui, sans-serif;
  --font-body: "Inter", system-ui, sans-serif;
  --font-code: "JetBrains Mono", monospace;
}
```

### Theme-Specific Typography

Customize for light and dark themes using theme selectors:

```css
/* Light theme customization */
.light,
.dark .theme-inverse {
  --font-body: "Inter", system-ui, sans-serif;
}

/* Dark theme customization */
.dark,
.light .theme-inverse {
  --font-body: "Geist", system-ui, sans-serif;
}
```

## Using Custom Fonts

Add custom fonts by declaring them with `@font-face` and overriding the font family variables:

```css
@font-face {
  font-family: 'Inter';
  src: url('/fonts/inter-var.woff2') format('woff2');
  font-weight: 100 900;
  font-display: swap;
}

@theme {
  --font-header: 'Inter', system-ui, sans-serif;
  --font-body: 'Inter', system-ui, sans-serif;
  --font-label: 'Inter', system-ui, sans-serif;
}
```

## Best Practices

### Use Semantic Text Styles

Always prefer semantic text style utilities over combining individual properties:

```gts preview
<template>
  <div class='flex flex-col gap-4'>
    {{! Good - semantic text style }}
    <h2 class='font-header text-header-lg text-brand-strong'>
      ✓ Semantic: Easy to maintain
    </h2>

    {{! Avoid - manual combination }}
    <h2 class='text-2xl font-bold leading-tight tracking-tight text-brand-strong'>
      ✗ Manual: Harder to maintain
    </h2>
  </div>
</template>
```

### Maintain Visual Hierarchy

Use size variants to create clear content hierarchy:

```gts preview
<template>
  <article class='space-y-4'>
    <h1 class='font-header text-header-3xl text-neutral-strong'>Article Title</h1>
    <p class='font-body text-body-md text-neutral-strong'>Published on December 7, 2024</p>

    <div class='space-y-3'>
      <h2 class='font-header text-header-xl text-neutral-strong'>Major Section</h2>
      <p class='font-body text-body-md text-neutral-firm'>
        This is the main body content with comfortable line height for easy reading. The text flows naturally and maintains good readability.
      </p>

      <h3 class='font-header text-header-lg text-neutral-strong'>Subsection</h3>
      <p class='font-body text-body-md text-neutral-firm'>
        Subsection content continues the hierarchy with appropriately sized headers.
      </p>

      <span class='font-caption text-caption-sm text-neutral-strong block'>
        Figure 1: Caption providing additional context
      </span>
    </div>
  </article>
</template>
```

### Responsive Typography

Scale typography for different screen sizes:

```gts preview
<template>
  <div class='space-y-4'>
    <h1 class='font-header text-header-lg md:text-header-xl lg:text-header-2xl text-neutral-strong'>
      Responsive Heading
    </h1>
    <p class='font-body text-body-sm md:text-body-md lg:text-body-lg text-neutral-firm'>
      Body text that scales up on larger screens for better readability across all devices.
    </p>
  </div>
</template>
```
