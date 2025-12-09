---
title: CSS Variables
order: 11
category: theming
subcategory: configuration
---

# CSS Variables Reference

Complete reference of CSS variables available in Frontile's theme system for customization.

## How CSS Variables Work

Frontile uses CSS variables in two ways:

### 1. Theme Variables (`@theme` block)

Variables defined in the `@theme` block automatically generate Tailwind utility classes:

```css
@theme {
  --radius: 8px;        /* Generates: rounded utility */
  --radius-xl: 12px;    /* Generates: rounded-xl utility */
}
```

These are the primary customization points for design tokens.

### 2. Component Variables (`:root` or theme selectors)

Variables defined in `:root` or theme-specific selectors are for component-specific values:

```css
:root {
  --modal-lg: 32rem;    /* Used by Modal component */
  --drawer-md: 28rem;   /* Used by Drawer component */
}
```

## Typography Variables

### Font Families

```css
@theme {
  --font-family-header: system-ui, sans-serif;
  --font-family-body: system-ui, sans-serif;
  --font-family-code: 'Courier New', monospace;
  --font-family-label: system-ui, sans-serif;
  --font-family-caption: system-ui, sans-serif;
  --font-family-marquee: system-ui, sans-serif;
}
```

### Text Styles

Frontile provides comprehensive text style variables. Each text style category has multiple size variants:

- **Marquee**: `--text-marquee-sm` through `--text-marquee-xl`
- **Header**: `--text-header-nano` through `--text-header-3xl`
- **Body**: `--text-body-pico` through `--text-body-xl`
- **Code**: `--text-code-sm`, `--text-code-md`
- **Caption**: `--text-caption-sm`, `--text-caption-md`
- **Label**: `--text-label-nano` through `--text-label-3xl`

Each text style includes font-size, font-family, font-weight, letter-spacing, and line-height properties.

See [Typography documentation](../design-tokens/typography.md) for detailed information.

## Layout Variables

### Border Width

```css
@theme {
  --border-width-thin: 0.5px;
  --border-width-default: 1px;
  --border-width-heavy: 2px;
  --border-width-aggressive: 4px;
}
```

**Generated utilities:** `border-thin`, `border`, `border-heavy`, `border-aggressive`

### Border Radius

```css
@theme {
  --radius-none: 0px;
  --radius-sm: 2px;
  --radius-md: 4px;
  --radius: 8px;          /* Default */
  --radius-xl: 12px;
  --radius-2xl: 16px;
  --radius-default: 20px;
  --radius-pill: 9999px;
}
```

**Generated utilities:** `rounded-none`, `rounded-sm`, `rounded-md`, `rounded`, `rounded-xl`, `rounded-2xl`, `rounded-default`, `rounded-pill`

### Icon Sizes

```css
@theme {
  --size-icon-pico: /* ... */;
  --size-icon-nano: /* ... */;
  --size-icon-micro: /* ... */;
  --size-icon-3xs: /* ... */;
  --size-icon-2xs: /* ... */;
  --size-icon-xs: /* ... */;
  --size-icon-sm: /* ... */;
  --size-icon-md: /* ... */;
  --size-icon-lg: /* ... */;
  --size-icon-xl: /* ... */;
  --size-icon-2xl: /* ... */;
  --size-icon-3xl: /* ... */;
  --size-icon-kilo: /* ... */;
  --size-icon-mega: /* ... */;
}
```

**Generated utilities:** `size-icon-pico` through `size-icon-mega`

See [Icon Sizes documentation](../design-tokens/icons.md) for usage guidelines.

### Elevation Shadows

```css
@theme {
  --shadow-elevation-0: /* ... */;
  --shadow-elevation-1: /* ... */;
  --shadow-elevation-2: /* ... */;
  --shadow-elevation-3: /* ... */;
  --shadow-elevation-4: /* ... */;
  --shadow-elevation-5: /* ... */;
}
```

**Generated utilities:** `shadow-elevation-0` through `shadow-elevation-5`

See [Elevation documentation](../design-tokens/elevation.md) for usage guidelines.

### Opacity

```css
@theme {
  --opacity-hover: .8;
  --opacity-disabled: .5;
}
```

**Generated utilities:** `opacity-hover`, `opacity-disabled`

## Component Variables

These variables are used by specific Frontile components and should be defined in `:root` or theme-specific selectors (not in `@theme` block):

### Modal Sizes

```css
:root {
  --modal-xs: 20rem;
  --modal-sm: 24rem;
  --modal-md: 28rem;
  --modal-lg: 32rem;
  --modal-xl: 36rem;
  --modal-full: 100%;
}
```

### Drawer Sizes

```css
:root {
  --drawer-xs: 20rem;
  --drawer-sm: 24rem;
  --drawer-md: 28rem;
  --drawer-lg: 32rem;
  --drawer-xl: 36rem;
  --drawer-full: 100%;
}
```

## Color Variables

**Important:** Color variables should be customized using JavaScript configuration, not CSS variables directly. See [Color Customization](customization.md#colors) for details.

Frontile's semantic colors use a sophisticated system that automatically calculates:
- Light and dark theme variations
- Contrasting text colors (`on-{color}` classes)
- Proper HSL values for theme compatibility

## Overriding Variables

### Global Overrides

Override in the `@theme` block for design tokens:

```css
@import "@frontile/theme";

@theme {
  --radius: 12px;
  --border-width-default: 2px;
  --opacity-hover: .9;
  --size-icon-md: 20px;
}
```

### Theme-Specific Overrides

Use theme selectors for per-theme customization:

```css
/* Light theme - targets .light AND .theme-inverse within .dark */
.light,
.dark .theme-inverse {
  --opacity-hover: .85;
  --shadow-elevation-2: 0px 4px 12px rgba(0, 0, 0, 0.1);
}

/* Dark theme - targets .dark AND .theme-inverse within .light */
.dark,
.light .theme-inverse {
  --opacity-hover: .75;
  --shadow-elevation-2: 0px 4px 12px rgba(0, 0, 0, 0.3);
}
```

**Why both selectors?** This ensures customizations apply to:
- Regular theme usage (`.light` or `.dark`)
- Theme-inverse sections (`.theme-inverse` within opposite theme)

### Component-Specific Overrides

Override component variables in `:root`:

```css
:root {
  --modal-lg: 48rem;
  --drawer-md: 32rem;
}
```

Or per-theme:

```css
.dark {
  --modal-lg: 56rem;
}
```

## Usage Examples

### Example 1: Customize Border Radius

```css
@theme {
  /* Softer corners throughout the app */
  --radius: 12px;
  --radius-xl: 20px;
  --radius-pill: 9999px;
}
```

### Example 2: Adjust Icon Sizes

```css
@theme {
  /* Slightly larger icons */
  --size-icon-sm: 15px;
  --size-icon-md: 19px;
  --size-icon-lg: 23px;
}
```

### Example 3: Theme-Specific Shadows

```css
/* Subtler shadows in light mode */
.light,
.dark .theme-inverse {
  --shadow-elevation-1: 0px 1px 3px rgba(0, 0, 0, 0.05);
  --shadow-elevation-2: 0px 2px 8px rgba(0, 0, 0, 0.08);
}

/* Stronger shadows in dark mode */
.dark,
.light .theme-inverse {
  --shadow-elevation-1: 0px 2px 4px rgba(0, 0, 0, 0.3);
  --shadow-elevation-2: 0px 4px 12px rgba(0, 0, 0, 0.4);
}
```

### Example 4: Custom Font Families

```css
@font-face {
  font-family: 'Inter';
  src: url('/fonts/inter-var.woff2') format('woff2');
  font-weight: 100 900;
}

@theme {
  --font-family-header: 'Inter', system-ui, sans-serif;
  --font-family-body: 'Inter', system-ui, sans-serif;
  --font-family-label: 'Inter', system-ui, sans-serif;
}
```

### Example 5: Adjust Component Sizes

```css
:root {
  /* Larger modals for desktop */
  --modal-md: 36rem;
  --modal-lg: 48rem;
  --modal-xl: 64rem;
}

/* Smaller on mobile */
@media (max-width: 768px) {
  :root {
    --modal-md: 90vw;
    --modal-lg: 90vw;
  }
}
```

## Best Practices

### Use @theme for Design Tokens

Always use `@theme` block for variables that should generate utility classes:

```css
/* ✓ Good */
@theme {
  --radius: 10px;
}

/* ✗ Avoid */
:root {
  --radius: 10px;  /* Won't generate rounded utility */
}
```

### Use :root for Component Values

Use `:root` for component-specific values that don't need utilities:

```css
/* ✓ Good */
:root {
  --modal-lg: 48rem;
  --drawer-md: 32rem;
}
```

### Keep Theme Selectors Consistent

Always use both selectors for theme-specific overrides:

```css
/* ✓ Good - covers all cases */
.light,
.dark .theme-inverse {
  --opacity-hover: .85;
}

/* ✗ Incomplete - misses .theme-inverse */
.light {
  --opacity-hover: .85;
}
```

### Document Your Customizations

Add comments to explain custom values:

```css
@theme {
  /* Brand requires 16px minimum for icon clarity */
  --size-icon-md: 20px;

  /* Softer corners match brand guidelines */
  --radius: 12px;
}
```

## Runtime Customization

CSS variables can be changed at runtime using JavaScript:

```js
// Change globally
document.documentElement.style.setProperty('--radius', '16px');

// Change for specific element
element.style.setProperty('--opacity-hover', '0.9');

// Read current value
const radius = getComputedStyle(document.documentElement)
  .getPropertyValue('--radius');
```

This is useful for user preferences, theme builders, or dynamic customization features.

## Next Steps

- [Customization Guide](customization.md) - Detailed customization examples
- [Theme Switching](theme-switching.md) - Light/dark mode implementation
- [Design Tokens](../design-tokens/overview.md) - Understanding design tokens
