---
title: Borders & Radius
order: 5
category: theming
subcategory: design-tokens
---

# Borders & Radius

Frontile provides border width and radius tokens for consistent UI styling across your application.

## Border Widths

Control border thickness with semantic width tokens. These tokens provide meaningful names that describe the visual weight of borders.

### Available Widths

```gts preview
<template>
  <div class='flex gap-6 flex-wrap items-center'>
    <div class='border-thin border-neutral-medium bg-surface-canvas p-6 rounded'>
      <div class='text-label-sm mb-1'>Thin</div>
      <div class='text-body-xs text-neutral-strong'>Subtle borders</div>
    </div>
    <div class='border border-neutral-medium bg-surface-canvas p-6 rounded'>
      <div class='text-label-sm mb-1'>Default</div>
      <div class='text-body-xs text-neutral-strong'>Standard borders</div>
    </div>
    <div class='border-heavy border-neutral-medium bg-surface-canvas p-6 rounded'>
      <div class='text-label-sm mb-1'>Heavy</div>
      <div class='text-body-xs text-neutral-strong'>Emphasized borders</div>
    </div>
    <div class='border-aggressive border-neutral-medium bg-surface-canvas p-6 rounded'>
      <div class='text-label-sm mb-1'>Aggressive</div>
      <div class='text-body-xs text-neutral-strong'>Strong emphasis</div>
    </div>
  </div>
</template>
```

| Width | Utility | Common Uses |
|-------|---------|-------------|
| Thin | `border-thin` | Subtle dividers, table borders, minimal separation |
| Default | `border` | Standard card borders, input fields, default UI elements |
| Heavy | `border-heavy` | Focus states, selected items, emphasized borders |
| Aggressive | `border-aggressive` | High-contrast borders, debug indicators, strong emphasis |

### Border Width Examples

```gts preview
<template>
  <div class='space-y-4'>
    {{! Subtle card }}
    <div class='border-thin border-neutral-medium rounded p-4'>
      <h3 class='text-header-sm mb-2'>Subtle Card</h3>
      <p class='text-body-sm text-neutral-strong'>Uses thin border for minimal visual weight</p>
    </div>

    {{! Standard input }}
    <input
      type='text'
      placeholder='Standard input field'
      class='w-full border border-neutral-medium rounded px-4 py-2 focus:outline-none focus:ring-2 focus:ring-brand-medium'
    />

    {{! Selected item with heavy border }}
    <div class='border-heavy border-brand-medium rounded p-4 bg-brand-subtle'>
      <h3 class='text-header-sm mb-2 text-brand-strong'>Selected Item</h3>
      <p class='text-body-sm text-brand-strong'>Uses heavy border to show selection</p>
    </div>
  </div>
</template>
```

## Border Radius

Control corner rounding with radius tokens that range from sharp edges to fully rounded elements.

### Available Radii

```gts preview
<template>
  <div class='grid grid-cols-2 md:grid-cols-4 gap-4'>
    <div class='rounded-none bg-brand-subtle p-4 flex items-center justify-center min-h-24'>
      <span class='text-label-sm'>None</span>
    </div>
    <div class='rounded-sm bg-brand-subtle p-4 flex items-center justify-center min-h-24'>
      <span class='text-label-sm'>SM</span>
    </div>
    <div class='rounded-md bg-brand-subtle p-4 flex items-center justify-center min-h-24'>
      <span class='text-label-sm'>MD</span>
    </div>
    <div class='rounded bg-brand-subtle p-4 flex items-center justify-center min-h-24'>
      <span class='text-label-sm'>Default</span>
    </div>
    <div class='rounded-xl bg-brand-subtle p-4 flex items-center justify-center min-h-24'>
      <span class='text-label-sm'>XL</span>
    </div>
    <div class='rounded-2xl bg-brand-subtle p-4 flex items-center justify-center min-h-24'>
      <span class='text-label-sm'>2XL</span>
    </div>
    <div class='rounded-default bg-brand-subtle p-4 flex items-center justify-center min-h-24'>
      <span class='text-label-sm'>Default (Custom)</span>
    </div>
    <div class='rounded-pill bg-brand-subtle px-6 py-4 flex items-center justify-center min-h-24'>
      <span class='text-label-sm'>Pill</span>
    </div>
  </div>
</template>
```

| Radius | Utility | Common Uses |
|--------|---------|-------------|
| None | `rounded-none` | Sharp corners, technical interfaces, no rounding |
| SM | `rounded-sm` | Subtle rounding, tight layouts |
| MD | `rounded-md` | Medium rounding, cards with more visual softness |
| Default | `rounded` | Standard UI elements, buttons, inputs |
| XL | `rounded-xl` | Large cards, prominent panels |
| 2XL | `rounded-2xl` | Hero sections, feature cards |
| Default (Custom) | `rounded-default` | Custom default radius value, soft friendly corners |
| Pill | `rounded-pill` | Pills, badges, fully rounded buttons |

## Combining Borders and Radius

Use border widths and radius together to create various UI patterns:

```gts preview
<template>
  <div class='space-y-4'>
    {{! Alert with thin border and soft corners }}
    <div class='border-thin border-success-soft bg-success-subtle rounded-xl p-4'>
      <h4 class='text-label-md text-success-strong mb-1'>Success</h4>
      <p class='text-body-sm text-success-strong'>Your changes have been saved successfully.</p>
    </div>

    {{! Warning with heavy border and default corners }}
    <div class='border-heavy border-warning-medium bg-warning-subtle rounded p-4'>
      <h4 class='text-label-md text-warning-strong mb-1'>Warning</h4>
      <p class='text-body-sm text-warning-strong'>This action cannot be undone.</p>
    </div>

    {{! Error with aggressive border and sharp corners }}
    <div class='border-aggressive border-danger-medium bg-danger-subtle rounded-sm p-4'>
      <h4 class='text-label-md text-danger-strong mb-1'>Error</h4>
      <p class='text-body-sm text-danger-strong'>Failed to save changes. Please try again.</p>
    </div>
  </div>
</template>
```

## Best Practices

### Maintain Consistency

Use consistent border styles for similar UI elements throughout your application:

- **Forms**: Use default border width with default or small radius
- **Cards**: Use thin borders with medium to large radius
- **Alerts**: Use thin to heavy borders with appropriate radius for the context
- **Buttons**: Use default radius or pill for interactive elements

### Visual Hierarchy

Use border weights to establish hierarchy:

- **Thin**: Background elements, subtle divisions
- **Default**: Primary UI elements
- **Heavy**: Active states, selections, focus indicators
- **Aggressive**: Critical states, errors, important boundaries

### Radius and Component Size

Pair border radius with component size:

- **Small components** (badges, small buttons): Use `rounded` or `rounded-sm`
- **Medium components** (buttons, inputs): Use `rounded` or `rounded-md`
- **Large components** (cards, panels): Use `rounded-lg` or `rounded-xl`
- **Extra large components** (heroes, features): Use `rounded-xl` or `rounded-2xl`

## Customization

Override border widths and radius using CSS variables:

```css
@import "@frontile/theme";

@theme {
  /* Customize border widths */
  --border-width-thin: 1px;
  --border-width-default: 1.5px;
  --border-width-heavy: 3px;

  /* Customize border radius */
  --radius: 6px;
  --radius-xl: 16px;
  --radius-default: 8px;
  --radius-pill: 9999px;
}
```

For more customization options, see the [Configuration Guide](../configuration/customization.md).
