---
title: Semantic Colors Migration
order: 2
category: migrations
subcategory: v0.18
---

# Semantic Colors v2 Migration Guide

This guide helps you migrate from the old numbered color system to the new semantic color levels in Frontile v0.18+.

## Overview

The semantic color system has been redesigned to use named levels instead of numbered scales. This provides:

- **Better semantic meaning**: Names describe the emphasis level (subtle, soft, medium, strong)
- **Improved accessibility**: Contrast colors are explicitly defined
- **Theme consistency**: Colors adapt better to light/dark modes
- **Clearer usage patterns**: Names indicate intended use cases

## Breaking Changes

### Color Categories Renamed

| Old Name    | New Name    | Notes                                                    |
| ----------- | ----------- | -------------------------------------------------------- |
| `default-*` | `neutral-*` | Renamed to better indicate non-semantic UI elements      |
| `primary-*` | `brand-*`   | Renamed to distinguish brand colors from semantic intent |
| `success-*` | `success-*` | ✓ No change                                              |
| `warning-*` | `warning-*` | ✓ No change                                              |
| `danger-*`  | `danger-*`  | ✓ No change                                              |

### New: Inverse Category

A new `inverse` category has been added for elements on inverted surfaces (dark surfaces in light mode):

```gts
// Dark card in light mode
<div class="bg-neutral-strong text-inverse-medium">
  Content with good contrast
</div>
```

### Color Scale Changed

The numbered scale (50, 100, 200, ..., 950) has been replaced with named levels:

| Old Pattern          | New Pattern           | Description                               |
| -------------------- | --------------------- | ----------------------------------------- |
| `{color}-{number}`   | `{color}-{level}`     | Named emphasis levels                     |
| `{color}-foreground` | `on-{color}-{level}`  | Automatic contrasting colors (black/white) |

## Color Level Mapping

### Understanding the New Levels

Each semantic color now has these levels:

- **`on-{color}-{level}`** — Automatic contrasting color (black or white) calculated for optimal WCAG contrast on the specified background level
- **`strong`** — Maximum emphasis, darkest/boldest color
- **`medium`** (DEFAULT) — Standard emphasis, the primary color
- **`soft`** — Moderate emphasis, lighter than medium
- **`subtle`** — Minimal emphasis, very light with transparency

### Migration Mapping Table

#### Neutral (formerly Default)

| Old Class                 | New Class                                      | Context                    |
| ------------------------- | ---------------------------------------------- | -------------------------- |
| `bg-default-50`           | `bg-neutral-subtle`                            | Very light backgrounds     |
| `bg-default-100`          | `bg-neutral-subtle`                            | Light backgrounds, borders |
| `bg-default-200`          | `bg-neutral-subtle`                            | Light surfaces             |
| `bg-default-300`          | `bg-neutral-soft`                              | Moderate backgrounds       |
| `bg-default-400`          | `bg-neutral-soft`                              | Borders, dividers          |
| `bg-default-500`          | `bg-neutral-soft` or `bg-neutral-medium`       | Medium emphasis            |
| `bg-default-600`          | `bg-neutral-medium`                            | Standard emphasis          |
| `bg-default-700`          | `bg-neutral-medium` or `bg-neutral-strong`     | Strong emphasis            |
| `bg-default-800`          | `bg-neutral-strong`                            | Maximum emphasis, buttons  |
| `bg-default-900`          | `bg-neutral-strong`                            | Darkest backgrounds        |
| `bg-default-950`          | `bg-neutral-strong`                            | Maximum contrast           |
| `text-default`            | `text-neutral-medium` or `text-neutral-strong` | Body text                  |
| `text-default-foreground` | `text-on-neutral-medium`                       | Contrasting text on bg     |
| `border-default`          | `border-neutral-soft`                          | Standard borders           |

#### Brand (formerly Primary)

| Old Class                 | New Class                              | Context                |
| ------------------------- | -------------------------------------- | ---------------------- |
| `bg-primary`              | `bg-brand-medium` or `bg-brand`        | Standard brand color   |
| `bg-primary-500`          | `bg-brand-soft` or `bg-brand-medium`   | Hover states           |
| `bg-primary-600`          | `bg-brand-medium`                      | Default buttons        |
| `bg-primary-700`          | `bg-brand-medium` or `bg-brand-strong` | Strong emphasis        |
| `bg-primary-800`          | `bg-brand-strong`                      | Active/pressed states  |
| `text-primary`            | `text-brand-medium` or `text-brand`    | Brand text             |
| `text-primary-foreground` | `text-on-brand-medium`                 | Contrasting text on bg |
| `border-primary`          | `border-brand-medium`                  | Brand borders          |
| `ring-primary-500`        | `ring-brand-soft`                      | Focus rings            |

#### Success

| Old Class                 | New Class                                  | Context                  |
| ------------------------- | ------------------------------------------ | ------------------------ |
| `bg-success`              | `bg-success-medium` or `bg-success`        | Standard success color   |
| `bg-success-100`          | `bg-success-subtle`                        | Alert backgrounds        |
| `bg-success-500`          | `bg-success-soft` or `bg-success-medium`   | Moderate emphasis        |
| `bg-success-600`          | `bg-success-medium` or `bg-success-strong` | Buttons, hover           |
| `bg-success-800`          | `bg-success-strong`                        | Active states            |
| `text-success`            | `text-success-medium` or `text-success`    | Success text             |
| `text-success-foreground` | `text-on-success-medium`                   | Contrasting text on bg   |
| `border-success`          | `border-success-medium`                    | Success borders          |
| `ring-success-500`        | `ring-success-soft`                        | Focus rings              |

#### Warning

| Old Class                 | New Class                                  | Context                  |
| ------------------------- | ------------------------------------------ | ------------------------ |
| `bg-warning`              | `bg-warning-medium` or `bg-warning`        | Standard warning color   |
| `bg-warning-100`          | `bg-warning-subtle`                        | Alert backgrounds        |
| `bg-warning-500`          | `bg-warning-soft` or `bg-warning-medium`   | Moderate emphasis        |
| `bg-warning-600`          | `bg-warning-medium` or `bg-warning-strong` | Buttons, hover           |
| `bg-warning-800`          | `bg-warning-strong`                        | Active states            |
| `text-warning`            | `text-warning-medium` or `text-warning`    | Warning text             |
| `text-warning-foreground` | `text-on-warning-medium`                   | Contrasting text on bg   |
| `border-warning`          | `border-warning-medium`                    | Warning borders          |

#### Danger

| Old Class                | New Class                                | Context                 |
| ------------------------ | ---------------------------------------- | ----------------------- |
| `bg-danger`              | `bg-danger-medium` or `bg-danger`        | Standard danger color   |
| `bg-danger-100`          | `bg-danger-subtle`                       | Alert backgrounds       |
| `bg-danger-500`          | `bg-danger-soft` or `bg-danger-medium`   | Moderate emphasis       |
| `bg-danger-600`          | `bg-danger-medium` or `bg-danger-strong` | Buttons, hover          |
| `bg-danger-800`          | `bg-danger-strong`                       | Active states           |
| `text-danger`            | `text-danger-medium` or `text-danger`    | Danger text             |
| `text-danger-foreground` | `text-on-danger-medium`                  | Contrasting text on bg  |
| `border-danger`          | `border-danger-medium`                   | Danger borders          |

## Common UI Pattern Migrations

### Buttons

#### Default Button

```gts
// Before
<button class="bg-default-800 text-default-100 hover:bg-default-800/80">
  Click me
</button>

// After
<button class="bg-neutral-strong text-on-neutral-strong hover:bg-neutral-medium">
  Click me
</button>
```

#### Primary/Brand Button

```gts
// Before
<button class="bg-primary text-primary-foreground hover:bg-primary-500">
  Submit
</button>

// After
<button class="bg-brand text-on-brand hover:bg-brand-soft">
  Submit
</button>
```

#### Outlined Button

```gts
// Before
<button class="border-primary text-primary hover:bg-primary hover:text-primary-foreground">
  Cancel
</button>

// After
<button class="border-brand text-brand hover:bg-brand hover:text-on-brand">
  Cancel
</button>
```

### Alerts and Notifications

#### Success Alert

```gts
// Before
<div class="bg-success-100 border-success-500 text-success-900">
  <Icon class="text-success" />
  <p>Success message</p>
</div>

// After
<div class="bg-success-subtle border-success-soft text-on-success-subtle">
  <Icon class="text-success-medium" />
  <p>Success message</p>
</div>
```

#### Error Alert

```gts
// Before
<div class="bg-danger-100 border-danger text-danger-foreground">
  Error occurred
</div>

// After
<div class="bg-danger-subtle border-danger-medium text-on-danger-subtle">
  Error occurred
</div>
```

### Form Inputs

```gts
// Before
<input class="border-default-700 focus:border-primary text-default-900" />

// After
<input class="border-neutral-soft focus:border-brand text-neutral-strong" />
```

### Text Hierarchy

```gts
// Before
<h1 class="text-default-900">Heading</h1>
<p class="text-default-700">Body text</p>
<span class="text-default-500">Caption</span>

// After
<h1 class="text-neutral-strong">Heading</h1>
<p class="text-neutral-medium">Body text</p>
<span class="text-neutral-soft">Caption</span>
```

### Badges

```gts
// Before
<span class="bg-success text-success-foreground">
  Active
</span>

// After
<span class="bg-success-strong text-on-success-strong">
  Active
</span>
```

## Dark Mode Considerations

The new semantic colors automatically adapt to dark mode. Key changes:

- In dark mode, `strong` becomes the **lightest** shade (inverted from light mode)
- `subtle` uses darker base colors with lower alpha
- `on-{color}-{level}` automatically maintains WCAG accessibility standards

**No changes needed** — your dark mode classes will work automatically:

```gts
// Both light and dark modes handled
<div class="bg-neutral-subtle text-neutral-strong">
  Content
</div>
```

## Migration Strategy

### Step 1: Identify Old Patterns

Search your codebase for old color patterns:

```bash
# Find numbered color classes
grep -r "default-[0-9]" --include="*.{tsx,ts,gts,gjs,md}"
grep -r "primary-[0-9]" --include="*.{tsx,ts,gts,gjs,md}"

# Find foreground classes
grep -r "foreground" --include="*.{tsx,ts,gts,gjs,md}"
```

### Step 2: Update Theme Configuration

If you've customized Frontile's theme, update your color definitions:

```typescript
// Before
import { themeColors } from '@frontile/theme';

colors: {
  default: themeColors.light.default,
  primary: themeColors.light.primary,
}

// After
import semanticColors from '@frontile/theme/colors/semantic';

colors: {
  neutral: semanticColors.light.neutral,
  brand: semanticColors.light.brand,
}
```

### Step 3: Update Component Styles

Replace old color classes with new semantic levels:

1. Start with theme components (highest impact)
2. Move to your custom components
3. Update documentation and examples
4. Update tests

### Step 4: Test Thoroughly

- **Visual regression**: Check all components in both light and dark modes
- **Accessibility**: Verify contrast ratios still meet WCAG AA standards
- **Interactive states**: Test hover, focus, active, and disabled states

## Automated Migration

For large codebases, consider creating a codemod or script:

```bash
# Example: Simple find and replace (use with caution)
find . -type f \( -name "*.ts" -o -name "*.gts" \) -exec sed -i '' \
  -e 's/bg-default-/bg-neutral-/g' \
  -e 's/text-default-/text-neutral-/g' \
  -e 's/border-default-/border-neutral-/g' \
  -e 's/bg-primary/bg-brand/g' \
  -e 's/text-primary/text-brand/g' \
  -e 's/border-primary/border-brand/g' \
  {} +
```

**Note**: Automated replacements won't handle the numbered scale correctly. Manual review is required for proper level mapping.

## Decision Guide

When choosing between levels, ask:

### Background Colors

- **Maximum emphasis button?** → `{color}-strong`
- **Standard button/element?** → `{color}-medium` or `{color}` (DEFAULT)
- **Hover state?** → `{color}-soft`
- **Light alert background?** → `{color}-subtle`

### Text Colors

- **On colored background?** → `on-{color}-{level}` (automatically white or black based on WCAG contrast)
- **On neutral background?** → `neutral-strong` (heading), `neutral-medium` (body), `neutral-soft` (caption)

### Borders

- **Colored semantic borders?** → `{color}-medium` or `{color}-soft`
- **Neutral dividers?** → `neutral-soft` or `neutral-subtle`
