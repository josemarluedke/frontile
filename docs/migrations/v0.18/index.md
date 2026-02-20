---
title: Upgrading to v0.18
order: 1
category: migrations
subcategory: v0.18
---

# Upgrading to v0.18

Frontile v0.18 is a major release that includes several breaking changes aimed at improving the design system's consistency, accessibility, and developer experience. This guide provides an overview of all breaking changes and links to detailed migration guides for each.

## Overview of Breaking Changes

v0.18 introduces the following breaking changes:

1. **[Package Consolidation](./package-consolidation.md)** - Seven `@frontile/*` packages consolidated into a single `frontile` package
2. **[Semantic Colors v2](./semantic-colors.md)** - Complete redesign of the color system
3. **[Theme Configuration](./theme-configuration.md)** - Updated configuration structure and CSS imports
4. **OKLCH Color Format** - Colors now use OKLCH instead of HSL for better perceptual uniformity
5. **Surface Colors** - `bg-background` renamed to `bg-surface-canvas`

## Migration Priority

We recommend migrating in this order:

### 1. Package Consolidation (Recommended First)

Seven individual `@frontile/*` component packages have been consolidated into the single `frontile` package. The old packages now re-export from `frontile` with deprecation warnings, and will be removed in 0.19.0.

**Impact:** Medium - import paths change, but old paths continue to work during 0.18.x

**Time Required:** 10-30 minutes (automated script available)

**Key Changes:**
- `@frontile/buttons`, `@frontile/forms`, `@frontile/collections`, `@frontile/overlays`, `@frontile/notifications`, `@frontile/status`, and `@frontile/utilities` are now deprecated
- Import from `frontile` or `frontile/<scope>` instead (e.g. `frontile/buttons`, `frontile/overlays`)
- Sub-path imports like `@frontile/overlays/components/modal` become `frontile/components/overlays/modal`
- `@frontile/theme` is **not** affected and remains a separate package

**See:** [Package Consolidation Migration Guide](./package-consolidation.md)

### 2. Theme Configuration (Required)

The theme configuration structure has been updated to support Tailwind v4's CSS-first approach. This must be done before color migration as it affects the entire theme system.

**Impact:** Medium - only affects apps with custom theme configurations, but required for v0.18

**Time Required:** 15-30 minutes

**Key Changes:**
- CSS variable names are now unprefixed (remove `--frontile-` prefix)
- LayoutTheme interface changed from flat to nested structure
- Must add `@import "@frontile/theme"` to your app.css

**See:** [Theme Configuration Migration Guide](./theme-configuration.md)

### 3. Semantic Colors v2 (Required)

The semantic color system has been completely redesigned with named levels instead of numbered scales. This affects all components that use colors.

**Impact:** High - affects all color-related classes throughout your application

**Time Required:** Varies based on codebase size (1-4 hours for small apps, 1-2 days for large apps)

**Key Changes:**
- Renamed `default-*` to `neutral-*` and `primary-*` to `brand-*`
- Replaced numbered scales (50, 100, 200...) with named levels (subtle, soft, medium, strong)
- Removed legacy `text-foreground` classes
- Removed `inverse` color category (use `neutral` instead)
- Replaced `contrast-1`/`contrast-2` with automatic `on-{color}-{level}` classes

**See:** [Semantic Colors Migration Guide](./semantic-colors.md)

### 4. OKLCH Color Format (Automatic)

Colors now use the OKLCH color format instead of HSL for improved perceptual uniformity and consistency across color scales.

**Impact:** Low - colors are converted automatically, may see minor visual differences

**Time Required:** No action required (automatic)

**Key Changes:**
- CSS variables now contain complete OKLCH values: `--color-brand-subtle: oklch(65.27% 0.1234 240.50)`
- Color variable names now use `--color-` prefix: `--color-brand-subtle` instead of `--brand-subtle`
- Tailwind v4 with Lightning CSS automatically generates RGB fallbacks for older browsers
- Minor perceptual differences in colors (OKLCH is perceptually uniform, HSL is not)

**No Manual Migration Required:** The color system automatically converts colors to OKLCH format. If you're overriding colors via CSS, update variable names to include the `--color-` prefix.

### 5. Surface Colors Rename (Find & Replace)

The `background` color token has been renamed to `surface-canvas` for better semantic clarity.

**Impact:** Low - simple find and replace

**Time Required:** 5-10 minutes

**Migration:**

```bash
# Find all instances
grep -r "bg-background" .

# Replace in your codebase
find . -type f \( -name "*.hbs" -o -name "*.gts" -o -name "*.gjs" -o -name "*.html" \) \
  -exec sed -i '' 's/bg-background/bg-surface-canvas/g' {} +
```

**Examples:**

```html
<!-- Before -->
<body class="bg-background text-neutral-strong">

<!-- After -->
<body class="bg-surface-canvas text-neutral-strong">
```

```html
<!-- Before -->
<div class="theme-inverse p-6 bg-background rounded-lg">

<!-- After -->
<div class="theme-inverse p-6 bg-surface-canvas rounded-lg">
```

## Migration Strategy

### For Existing Projects

1. **Start with Package Consolidation** - Update imports from `@frontile/*` to `frontile` (automated script available)
2. **Update Theme Configuration** - Update your theme configuration and CSS imports
3. **Update Colors** - Migrate to the new semantic color system
4. **Test thoroughly** - Verify visual appearance, accessibility, and functionality after each step
5. **Use migration scripts** - Automated scripts are available to help with both package and color migrations

### For New Projects

If you're starting a new project, you can use v0.18 directly without migration concerns. Follow the [Getting Started](../../get-started/index.md) guide to begin with the latest version.

## Breaking Changes Checklist

Use this checklist to track your migration progress:

- [ ] Package Consolidation - Update imports from `@frontile/*` to `frontile`
- [ ] Theme Configuration - Update CSS imports and variable names
- [ ] Semantic Colors v2 - Replace numbered color scales with named levels
- [ ] OKLCH Color Format - Update CSS variable overrides to use `--color-` prefix (if applicable)
- [ ] Surface Colors - Replace `bg-background` with `bg-surface-canvas`

## Need Help?

If you encounter issues during migration:

- Check the individual migration guides linked above
- Review the [documentation](../../index.md) for updated usage examples
- Search or create an issue on [GitHub](https://github.com/josemarluedke/frontile)
- Join our community discussions for support
