---
title: Theme Configuration Migration
order: 3
category: migrations
subcategory: v0.18
---

# Theme Configuration Migration Guide

This guide helps you migrate your Frontile theme configuration to v0.18, which adopts Tailwind v4's CSS-first configuration approach.

## Overview

Frontile v0.18 updates the theme system to align with Tailwind CSS v4's new CSS-first approach. This brings several benefits:

- **Simpler configuration**: CSS variables are easier to understand and customize
- **Better performance**: CSS-first approach eliminates JavaScript config processing
- **Direct CSS control**: Override theme values directly in your stylesheets
- **Cleaner variable names**: Removed `--frontile-` prefix for shorter, cleaner names

## Breaking Changes

### 1. CSS Import Required

**You must add** `@import "@frontile/theme"` to your application's entry
stylesheet — `app/styles/app.css` on a classic Ember build, `app/app.css` under
Vite. It has to come after the `@plugin` line.

#### Before (v0.17)

```css
@import 'tailwindcss' source('../../');
@plugin "@frontile/theme/plugin/default";
```

#### After (v0.18)

```css
@import 'tailwindcss' source('../../');
@plugin "@frontile/theme/plugin/default";
@import "@frontile/theme";
```

**Why:** The `@import "@frontile/theme"` statement loads Frontile's base CSS styles, custom variants, and animations that are now CSS-based rather than plugin-generated.

### 2. Tailwind Content Detection

This one is a consequence of [package
consolidation](./package-consolidation.md) rather than of the theme itself, and
it is the easiest to miss.

Tailwind v4 skips `node_modules` when it scans for classes. Frontile's own
component templates live there, so they have to be pointed at explicitly or
their classes are purged and components render unstyled — with no error, since a
purged class is simply a class that no longer exists.

In v0.17 one `@source` covered everything, because every component shipped under
the `@frontile` scope:

```css
@source '../../node_modules/@frontile';
```

In v0.18 the components moved to the unscoped `frontile` package, so that line no
longer reaches them:

```css
@source '../../node_modules/frontile';
/* Keep the scoped line too if you use @frontile/forms-legacy or
   @frontile/changeset-form, which remain separate packages. */
@source '../../node_modules/@frontile';
```

Paths are relative to the CSS file, so adjust the depth to match where yours
lives. This applies whether or not you have migrated your imports: the classes
come from `frontile` either way, because the old packages only re-export from it.

**If components look unstyled after upgrading and the theme import is present,
this is almost always why.**

### 3. CSS Variable Names

The `--frontile-` prefix is gone. What replaces it depends on the kind of token:

| Token kind | v0.17 | v0.18 |
| --- | --- | --- |
| Colors | `--frontile-primary-500` | `--color-primary-firm` (a `--color-` prefix, and a named level) |
| Everything else | `--frontile-hover-opacity` | `--opacity-hover` (no prefix) |

Colors are the case to watch. They did not simply lose a prefix — they gained
`--color-`, and the numbered scale they used is gone, so there is no
`--color-primary-500` either. Pick the level that matches the emphasis you
wanted; see the [semantic colors guide](./semantic-colors.md) for the mapping.

#### Before (v0.17)

```css
.my-component {
  background: var(--frontile-primary-500);
  opacity: var(--frontile-hover-opacity);
}
```

#### After (v0.18)

```css
.my-component {
  background: var(--color-primary);
  opacity: var(--opacity-hover);
}
```

**Migration:** search your codebase for `--frontile-`. Nothing errors if you
miss one — an undefined custom property silently resolves to nothing, so the
declaration is simply dropped:

```bash
grep -rn -- "--frontile-" --include="*.css" --include="*.scss" \
  --include="*.gts" --include="*.gjs" --include="*.ts" --include="*.js" .
```

### 4. LayoutTheme Interface (Nested Structure)

If you're using TypeScript and customizing the theme configuration, the `LayoutTheme` interface has changed from flat to nested.

#### Before (v0.17)

```typescript
import { frontile } from '@frontile/theme/plugin';

module.exports = frontile({
  hoverOpacity: 0.9,
  disabledOpacity: 0.4
});
```

#### After (v0.18)

```typescript
import { frontile } from '@frontile/theme/plugin';

module.exports = frontile({
  opacity: {
    hover: 0.9,
    disabled: 0.4
  }
});
```

**Why:** The nested structure provides better organization for related theme properties and aligns with CSS custom property conventions.

### 5. Border Radius Is Now a Derived Scale

Every `rounded-*` step is now `calc(var(--radius) * n)` instead of a hardcoded
value, so `--radius` is a single knob for how round the whole library looks.

#### Before (v0.17)

```css
--radius-xs: 1px;
--radius-sm: 2px;
--radius-md: 4px;
--radius: 8px;
--radius-xl: 12px;
--radius-2xl: 16px;
--radius-default: 20px;
```

#### After (v0.18)

```css
--radius: 0.5rem;                            /* 8px — the base */
--radius-xs: calc(var(--radius) * 0.25);     /* 2px */
--radius-sm: calc(var(--radius) * 0.5);      /* 4px */
--radius-md: calc(var(--radius) * 0.75);     /* 6px */
--radius-lg: calc(var(--radius) * 1);        /* 8px */
--radius-xl: calc(var(--radius) * 1.5);      /* 12px */
--radius-2xl: calc(var(--radius) * 2);       /* 16px */
--radius-3xl: calc(var(--radius) * 3);       /* 24px */
--radius-4xl: calc(var(--radius) * 4);       /* 32px */
--radius-default: calc(var(--radius) * 2.5); /* 20px */
```

**What actually changes visually.** Three steps got slightly larger, bringing the
scale back in line with stock Tailwind v4:

| Utility | v0.17 | v0.18 |
| --- | --- | --- |
| `rounded-xs` | 1px | 2px |
| `rounded-sm` | 2px | 4px |
| `rounded-md` | 4px | 6px |

Everything from `rounded` upward keeps its value. If you relied on `rounded-sm`
being 2px, use `rounded-xs`, or pin the step explicitly:

```css
@theme {
  --radius-sm: 2px; /* opt this one step out of the derived scale */
}
```

**Popover surfaces are rounder.** Dropdown and Popover panels moved from
`rounded-sm` (2px) to `rounded-xl` (12px), Listbox and menu items to
`rounded-lg` (8px), and NotificationCard to `rounded-xl`. Select and
Autocomplete inherit the change through Popover. This is a visual change only —
no API moved. To go back to square-ish menus, set `--radius: 0`, or override the
component classes via `@classes`.

**Why:** The old scale was smaller than stock Tailwind at every step, which made
`rounded-sm` a surprise for anyone reading the class name, and left popover
surfaces visibly sharper than the Modal and Drawer they sit alongside. Deriving
the scale from one value fixes the inconsistency and makes overall roundness a
one-line theme decision.

**Dialing it from the plugin config**, including per theme:

```typescript
module.exports = frontile({
  layout: {
    radius: { DEFAULT: '0.75rem' }
  }
});
```

## Migration Steps

### Step 1: Update CSS Imports

Add the `@import "@frontile/theme"` statement to your entry stylesheet:

```css
@import 'tailwindcss' source('../../');
@plugin "@frontile/theme/plugin/default";
@import "@frontile/theme";

/* Your custom styles */
```

**For custom theme configurations**, update to reference your custom config file:

```css
@import 'tailwindcss' source('../../');
@plugin "./../../frontile.js";
@import "@frontile/theme";
```

### Step 2: Update CSS Variable References

If you reference Frontile's CSS variables directly in your own stylesheets or
components:

1. **Find all references:**

```bash
grep -rn -- "--frontile-" --include="*.css" --include="*.scss" \
  --include="*.gts" --include="*.gjs" .
```

2. **Rename them.** Colors take a `--color-` prefix and a named level; other
   tokens just drop the prefix:

```diff
- background: var(--frontile-primary);
+ background: var(--color-primary);

- border-color: var(--frontile-primary-700);
+ border-color: var(--color-primary-firm);

- opacity: var(--frontile-hover-opacity);
+ opacity: var(--opacity-hover);
```

3. **Update computed styles in JavaScript:**

```diff
- const color = getComputedStyle(el).getPropertyValue('--frontile-primary-500');
+ const color = getComputedStyle(el).getPropertyValue('--color-primary');
```

   `getPropertyValue` returns an empty string for a variable that doesn't
   exist, so a missed rename here reads as "no color" rather than throwing.

### Step 3: Update Theme Configuration (If Customized)

If you have a custom `frontile.js` configuration file, update the structure:

#### Before (v0.17)

```javascript
const { frontile } = require('@frontile/theme/plugin');

module.exports = frontile({
  hoverOpacity: 0.9,
  disabledOpacity: 0.4,
  // other flat properties
});
```

#### After (v0.18)

```javascript
const { frontile } = require('@frontile/theme/plugin');

module.exports = frontile({
  opacity: {
    hover: 0.9,
    disabled: 0.4
  },
  // other nested properties
});
```

**Common property mappings:**

| Old Property (v0.17) | New Property (v0.18) |
| --- | --- |
| `hoverOpacity` | `opacity.hover` |
| `disabledOpacity` | `opacity.disabled` |

### Step 4: Test Your Application

After making these changes:

1. **Rebuild your application** to ensure all changes are applied
2. **Test interactive states** (hover, disabled) to verify opacity values
3. **Check custom styled components** that reference CSS variables directly
4. **Verify in both light and dark modes** if your app supports theming

## Common Issues and Solutions

### Issue: Styles Not Applied

**Problem:** Components don't have expected Frontile styles

**Solution:** Ensure you've added `@import "@frontile/theme"` to your CSS file. This import is now required.

### Issue: CSS Variables Undefined

**Problem:** Browser console shows `undefined` for CSS variables

**Solution:**
1. Check that you removed the `--frontile-` prefix
2. Verify the import order in your CSS file (plugin first, then theme import)
3. Rebuild your application

### Issue: TypeScript Errors in Config

**Problem:** TypeScript errors in `frontile.js` configuration

**Solution:** Update to the nested structure. Ensure you're using `opacity.hover` instead of `hoverOpacity`.

## Migration Checklist

Use this checklist to track your theme configuration migration:

- [ ] Added `@import "@frontile/theme"` to app.css
- [ ] Removed `--frontile-` prefix from all CSS variable references
- [ ] Updated `frontile.js` config to use nested structure (if applicable)
- [ ] Rebuilt application and verified styles are applied
- [ ] Tested hover and disabled states
- [ ] Verified custom components using CSS variables
- [ ] Tested in both light and dark modes (if applicable)

## Need Help?

If you encounter issues:

- Review the [Theme documentation](../../theming/overview.md) for the latest configuration options
- Check the [Getting Started guide](../../get-started/index.md) for setup examples
- Search or create an issue on [GitHub](https://github.com/josemarluedke/frontile/issues)
