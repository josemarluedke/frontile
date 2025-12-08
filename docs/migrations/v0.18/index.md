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

1. **[Semantic Colors v2](./semantic-colors.md)** - Complete redesign of the color system
2. **[Theme Configuration](./theme-configuration.md)** - Updated configuration structure and CSS imports

## Migration Priority

We recommend migrating in this order:

### 1. Theme Configuration (Required First)

The theme configuration structure has been updated to support Tailwind v4's CSS-first approach. This must be done first as it affects the entire theme system.

**Impact:** Medium - only affects apps with custom theme configurations, but required for v0.18

**Time Required:** 15-30 minutes

**Key Changes:**
- CSS variable names are now unprefixed (remove `--frontile-` prefix)
- LayoutTheme interface changed from flat to nested structure
- Must add `@import "@frontile/theme"` to your app.css

**See:** [Theme Configuration Migration Guide](./theme-configuration.md)

### 2. Semantic Colors v2 (Required)

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

## Migration Strategy

### For Existing Projects

1. **Start with Theme Configuration** - Update your theme configuration and CSS imports first
2. **Update Colors** - Migrate to the new semantic color system
3. **Test thoroughly** - Verify visual appearance, accessibility, and functionality after each step
4. **Use migration scripts** - Automated scripts are available to help with the color migration

### For New Projects

If you're starting a new project, you can use v0.18 directly without migration concerns. Follow the [Getting Started](../../get-started/index.md) guide to begin with the latest version.

## Breaking Changes Checklist

Use this checklist to track your migration progress:

- [ ] Theme Configuration - Update CSS imports and variable names
- [ ] Semantic Colors v2 - Replace numbered color scales with named levels

## Need Help?

If you encounter issues during migration:

- Check the individual migration guides linked above
- Review the [documentation](../../index.md) for updated usage examples
- Search or create an issue on [GitHub](https://github.com/josemarluedke/frontile)
- Join our community discussions for support
