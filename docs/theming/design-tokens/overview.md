---
title: Design Tokens Overview
order: 1
category: theming
subcategory: design-tokens
---

# Design Tokens

Frontile extends Tailwind CSS with additional design tokens for building consistent, accessible user interfaces. These tokens automatically generate Tailwind utility classes.

## What are Design Tokens?

Design tokens are named entities that store visual design attributes. They provide a consistent language for design decisions across your application. Frontile's tokens use Tailwind v4's `@theme` directive to define CSS variables that automatically generate utility classes.

For example, defining `--radius: 8px` in your theme automatically generates the `rounded` utility class.

## Token Categories

Frontile adds these design token categories to Tailwind:

### [Colors](colors.md)

Semantic color system with six categories (neutral, brand, success, danger, warning, info) that automatically adapt between light and dark themes.

**Generated utilities:** `bg-brand-medium`, `text-danger-strong`, `border-success-soft`

### [Typography](typography.md)

Text styles with semantic sizing across six categories (marquee, header, body, code, caption, label) built on a modular scale.

**Generated utilities:** `text-header-lg`, `text-body-md`, `text-label-sm`

### [Icons](icons.md)

Consistent icon sizing scale that pairs harmoniously with typography.

**Generated utilities:** `size-icon-sm`, `size-icon-md`, `size-icon-lg`

### [Borders](borders.md)

Border widths and radius tokens for consistent UI styling.

**Generated utilities:** `border-thin`, `border-heavy`, `rounded-xl`, `rounded-pill`

### [Elevation](elevation.md)

Shadow system for creating visual depth with six elevation levels (0-5).

**Generated utilities:** `shadow-elevation-1`, `shadow-elevation-3`

### [Surfaces](surfaces.md)

Background color system for creating distinct surface layers in your UI.

**Generated utilities:** `bg-surface-solid-1`, `bg-surface-soft-2`

## How Tokens Work

Frontile uses Tailwind v4's `@theme` directive to define tokens as CSS variables:

```css
@theme {
  --radius: 8px;           /* Generates: rounded */
  --radius-xl: 12px;       /* Generates: rounded-xl */
  --size-icon-md: 16px;    /* Generates: size-icon-md */
}
```

These variables:
- Automatically generate Tailwind utility classes
- Can be customized globally or per-theme
- Maintain consistency across your application
- Support light and dark theme variations

## Standard Tailwind Utilities

For layout, spacing, flexbox, grid, and other standard utilities, refer to the [Tailwind CSS documentation](https://tailwindcss.com/docs). Frontile uses Tailwind as-is for these utilities and only documents the design tokens it adds.
