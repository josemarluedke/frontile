---
order: 3
category: theme
---

# Typography System

Frontile's typography system provides a comprehensive, scalable type system built on semantic text styles and a modular scale. It uses Tailwind v4's `@theme` directive to automatically generate utility classes.

## Overview

The typography system includes:

- **6 text style categories**: Marquee, Header, Body, Code, Caption, and Label
- **Multiple size variants** for each category
- **Modular scale** based on a mathematical ratio for harmonic sizing
- **Automatic utility generation** via Tailwind's `@theme` block
- **Full customization** through CSS variables

## Text Style Categories

### Marquee

Large, bold display text for hero sections and prominent headings.

```gts preview
<template>
  <div class='flex flex-col gap-6'>
    <div class='text-marquee-xl'>Marquee XL: Hero Heading</div>
    <div class='text-marquee-lg'>Marquee LG: Large Display</div>
    <div class='text-marquee-md'>Marquee MD: Medium Display</div>
    <div class='text-marquee-sm'>Marquee SM: Small Display</div>
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
    <h1 class='text-header-3xl'>Header 3XL: Page Title</h1>
    <h2 class='text-header-2xl'>Header 2XL: Major Section</h2>
    <h3 class='text-header-xl'>Header XL: Section Title</h3>
    <h4 class='text-header-lg'>Header LG: Subsection</h4>
    <h5 class='text-header-md'>Header MD: Subheading</h5>
    <h6 class='text-header-sm'>Header SM: Minor Heading</h6>
    <div class='text-header-xs'>Header XS: Small Heading</div>
    <div class='text-header-2xs'>Header 2XS: Tiny Heading</div>
    <div class='text-header-micro'>Header Micro: Micro Heading</div>
    <div class='text-header-nano'>Header Nano: Nano Heading</div>
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
    <p class='text-body-xl'>
      Body XL: The quick brown fox jumps over the lazy dog. This is extra large body text with spacious line height for comfortable reading.
    </p>
    <p class='text-body-lg'>
      Body LG: The quick brown fox jumps over the lazy dog. This is large body text with spacious line height for comfortable reading.
    </p>
    <p class='text-body-md'>
      Body MD: The quick brown fox jumps over the lazy dog. This is default body text with spacious line height for comfortable reading.
    </p>
    <p class='text-body-sm'>
      Body SM: The quick brown fox jumps over the lazy dog. This is small body text with spacious line height for comfortable reading.
    </p>
    <p class='text-body-xs'>
      Body XS: The quick brown fox jumps over the lazy dog. This is extra small body text.
    </p>
    <p class='text-body-2xs'>
      Body 2XS: The quick brown fox jumps over the lazy dog. This is 2XS body text.
    </p>
    <p class='text-body-3xs'>
      Body 3XS: The quick brown fox jumps over the lazy dog. This is 3XS body text.
    </p>
    <p class='text-body-micro'>
      Body Micro: The quick brown fox jumps over the lazy dog. This is micro body text.
    </p>
    <p class='text-body-nano'>
      Body Nano: The quick brown fox jumps over the lazy dog. This is nano body text.
    </p>
    <p class='text-body-pico'>
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
    <code class='text-code-md bg-neutral-subtle px-2 py-1 rounded'>
      const greeting = "Hello, World!";
    </code>
    <code class='text-code-sm bg-neutral-subtle px-2 py-1 rounded'>
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
      <div class='bg-neutral-subtle rounded mb-2 h-32 flex items-center justify-center text-neutral-soft'>
        Example Image
      </div>
      <span class='text-caption-md text-neutral-soft'>Caption MD: Figure 1 - Example image caption with medium size</span>
    </div>
    <div>
      <span class='text-caption-sm text-neutral-soft'>Caption SM: Small caption text for supplementary information</span>
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
    <div class='text-label-3xl'>Label 3XL: Extra Large Label</div>
    <div class='text-label-2xl'>Label 2XL: Double Extra Large Label</div>
    <div class='text-label-xl'>Label XL: Extra Large Label</div>
    <div class='text-label-lg'>Label LG: Large Label</div>
    <div class='text-label-md'>Label MD: Medium Label</div>
    <div class='text-label-sm'>Label SM: Small Label</div>
    <div class='text-label-xs'>Label XS: Extra Small Label</div>
    <div class='text-label-2xs'>Label 2XS: Double Extra Small Label</div>
    <div class='text-label-micro'>Label Micro: Micro Label</div>
    <div class='text-label-nano'>Label Nano: Nano Label</div>
  </div>
</template>
```

**Available sizes:** `nano`, `micro`, `2xs`, `xs`, `sm`, `md`, `lg`, `xl`, `2xl`, `3xl`
**Best for:** Form labels, UI labels, buttons, navigation items, badges

## Default Sizes

Each text style category has a default size that can be used without specifying the size modifier:

```html
<!-- These are equivalent -->
<h1 class="text-marquee">...</h1>
<h1 class="text-marquee-md">...</h1>

<h2 class="text-header">...</h2>
<h2 class="text-header-md">...</h2>

<p class="text-body">...</p>
<p class="text-body-md">...</p>
```

## Combining with Other Utilities

Typography utilities work seamlessly with other Tailwind utilities:

```gts preview
<template>
  <div class='flex flex-col gap-4'>
    {{! Colored header }}
    <h2 class='text-header-xl text-brand-strong'>Colored Header</h2>

    {{! Truncated body text }}
    <p class='text-body-md truncate max-w-md'>
      This is a very long paragraph that will be truncated with an ellipsis when it exceeds the maximum width.
    </p>

    {{! Centered caption }}
    <span class='text-caption-md text-center block text-neutral-soft'>
      Centered caption text
    </span>

    {{! Responsive header }}
    <h1 class='text-header-lg md:text-header-xl lg:text-header-2xl'>
      Responsive Heading
    </h1>
  </div>
</template>
```

## How It Works

The typography system uses Tailwind v4's `@theme` directive with CSS variables. Each text style is defined with multiple properties that get automatically applied:

```css
@theme {
  /* Example: header-md style */
  --text-header-md: var(--font-size-14);
  --text-header-md--font-family: var(--font-family-header);
  --text-header-md--font-weight: var(--font-weight-bold);
  --text-header-md--letter-spacing: var(--letter-spacing-condensed);
  --text-header-md--line-height: var(--line-height-comfy);
}
```

When you use `.text-header-md`, Tailwind automatically applies all these properties. The system uses a modular scale to ensure harmonious sizing relationships across all text styles.

## Customization

### Using CSS Variables

Customize typography by overriding CSS variables in your app's CSS file:

```css
@import "@frontile/theme";

/* Override font families */
@theme {
  --font-family-header: "Inter", system-ui, sans-serif;
  --font-family-body: "Inter", system-ui, sans-serif;
  --font-family-code: "JetBrains Mono", monospace;
}
```

### Theme-Specific Typography

Customize for light and dark themes using theme selectors:

```css
/* Light theme customization */
.light,
.dark .theme-inverse {
  --font-family-body: "Inter", system-ui, sans-serif;
}

/* Dark theme customization */
.dark,
.light .theme-inverse {
  --font-family-body: "Geist", system-ui, sans-serif;
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
  --font-family-header: 'Inter', system-ui, sans-serif;
  --font-family-body: 'Inter', system-ui, sans-serif;
  --font-family-label: 'Inter', system-ui, sans-serif;
}
```

## Best Practices

### Use Semantic Text Styles

Always prefer semantic text style utilities over combining individual properties:

```gts preview
<template>
  <div class='flex flex-col gap-4'>
    {{! Good - semantic text style }}
    <h2 class='text-header-lg text-brand-strong'>
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
    <h1 class='text-header-3xl text-neutral-strong'>Article Title</h1>
    <p class='text-body-md text-neutral-soft'>Published on December 7, 2024</p>

    <div class='space-y-3'>
      <h2 class='text-header-xl text-neutral-strong'>Major Section</h2>
      <p class='text-body-md text-neutral-medium'>
        This is the main body content with comfortable line height for easy reading. The text flows naturally and maintains good readability.
      </p>

      <h3 class='text-header-lg text-neutral-strong'>Subsection</h3>
      <p class='text-body-md text-neutral-medium'>
        Subsection content continues the hierarchy with appropriately sized headers.
      </p>

      <span class='text-caption-sm text-neutral-soft block'>
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
    <h1 class='text-header-lg md:text-header-xl lg:text-header-2xl text-neutral-strong'>
      Responsive Heading
    </h1>
    <p class='text-body-sm md:text-body-md lg:text-body-lg text-neutral-medium'>
      Body text that scales up on larger screens for better readability across all devices.
    </p>
  </div>
</template>
```
