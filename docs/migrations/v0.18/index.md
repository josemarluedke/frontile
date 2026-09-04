---
title: Upgrading to v0.18
order: 1
category: migrations
subcategory: v0.18
---

# Upgrading to v0.18

Frontile v0.18 is a major release that includes several breaking changes aimed at improving the design system's consistency, accessibility, and developer experience. This guide provides an overview of all breaking changes and links to detailed migration guides for each.

## What breaks, and how loudly

Two of these changes stop your app from working. The rest are cleanup, and one of
them is optional for the whole 0.18 line.

| Change | If you skip it | Fails how? |
| --- | --- | --- |
| Missing `@import "@frontile/theme"` | No Frontile styles at all | Loudly — the app is visibly unstyled |
| Numbered color classes (`bg-primary-500`) | Those elements render unstyled | **Silently** |
| `bg-background` → `bg-surface-canvas` | Those elements render unstyled | **Silently** |
| `--frontile-*` variable references | The declaration is dropped | **Silently** |
| Nested `LayoutTheme` config | Build or type error | Loudly, and only if you customize the theme |
| `@frontile/*` package imports | Nothing — they still work in 0.18.x | Deprecation warning only |
| Derived border-radius scale | Slightly rounder corners on menus and small marks | Visual only — nothing to fix |
| Multi-select renders chips | Multi-selects look different — selections become removable chips | Visual only — nothing to fix |
| `text-body-pico`/`-nano`/`-micro` | Those elements render unstyled | **Silently** |
| Body text-scale font sizes corrected | Body text (`xs` through `xl`) renders larger than intended | Visual only — nothing to fix |

**The silent ones are the reason to take this in order.** A class Tailwind can't
resolve produces no error, no warning, and no CSS — the element just renders
without the style you asked for. We hit this in Frontile's own documentation
during the 0.18 work: thirteen demos were shipping with `bg-success-50` and
`bg-warning-50`, rendering with no background at all, and nobody noticed until a
linter went looking. Budget time for looking at the result, not just for the
find-and-replace.

## Migration order

### 1. Theme configuration — do this first

Nothing else is verifiable until the theme loads. Add the CSS import, and update
your config shape if you customize it.

**Impact:** required. **Time:** 15–30 minutes.

- Add `@import "@frontile/theme"` to your `app/styles/app.css`
- `LayoutTheme` moved from a flat to a nested structure (`hoverOpacity` becomes
  `opacity: { hover }`)
- CSS variables lost the `--frontile-` prefix; colors gained `--color-`

**See:** [Theme Configuration](./theme-configuration.md)

### 2. Colors and surfaces — the bulk of the work

One pass over your classes and custom CSS. Everything in this step fails
silently, so verify visually as you go rather than at the end.

**Impact:** required, and touches every colored element. **Time:** an hour or two
for a small app, a day or more for a large one.

- Numbered scales (`50`, `100`, … `950`) become named levels (`subtle`, `muted`,
  `soft`, `mild`, DEFAULT, `firm`, `strong`, `bolder`)
- `default-*` becomes `neutral-*`
- `bg-background` becomes `bg-surface-canvas`
- `{color}-foreground` and `contrast-1`/`contrast-2` become `on-{color}-{level}`
- `text-foreground` is gone
- `theme-inverse` flips every semantic token in a region, for panels that should read as the opposite theme

Colors also moved from HSL to OKLCH. That part is automatic — you may notice
small perceptual differences, but there is nothing to change.

**See:** [Semantic Colors](./semantic-colors.md)

### 3. Package consolidation — optional, any time before 0.19

Seven `@frontile/*` component packages became the single `frontile` package. The
old packages still re-export everything and only log a deprecation warning, so
**your imports keep working for all of 0.18.x.**

Leave this until the app builds and looks right. It rewrites every Frontile
import in your codebase, and doing that first buries the changes above in a diff
you can't read — which matters precisely because those changes fail silently.

**Impact:** none until 0.19. **Time:** 10–30 minutes, mostly automated.

**See:** [Package Consolidation](./package-consolidation.md)

### 4. Multi-select renders chips — visual only

`Select` with `@selectionMode="multiple"` used to show its selections as a
comma-joined string inside the trigger. It now renders each selection as a
removable [Chip](https://frontile.dev/docs/buttons/chip), so users can drop one
selection without reopening the dropdown. The control grows taller as chips
wrap, and a chips field is deliberately the same height as a same-size single
select (46px at `md`).

Nothing breaks, but the field is taller and looks different. If a layout
depends on the old fixed-height appearance, opt back out per-select:

```gts
<Select @selectionMode='multiple' @selectedItemsDisplay='text' />
```

Chips inherit the Select's `@intent` and default to the `faded` appearance;
`@chip={{hash appearance='outlined' size='md'}}` tunes appearance, intent,
size, radius and `withDot`. `@allowEmpty` defaults to `false`, so the final
selection's chip renders with no close button; `@isClearable` clears
everything and ignores `@allowEmpty`. Chip close buttons are deliberately not
in the tab order — the combobox is the single tab stop, and `Backspace` on
the field removes the last chip in both filterable and non-filterable modes.
See the [Select docs](https://frontile.dev/docs/forms/select#multiple-selection)
for the full section.

**Impact:** visual only. **Time:** none required; a few minutes if you want to
opt out.

### 5. Body typography scale corrected

The `--text-body-*` tokens were mapped to the wrong steps of the modular scale,
so `xs` through `xl` rendered larger than the design spec (e.g. `md` shipped at
20.74px instead of 16px). These now match spec, and the scale gained `4xs`,
`5xs`, `2xl`, and `3xl` sizes to fill it out.

The non-standard `text-body-pico`, `text-body-nano`, and `text-body-micro`
tokens are gone — the body scale now uses the same `5xs`…`3xl` naming as every
other text-style category. Replace them with the equivalent standard size,
which renders at the same pixel value:

| Removed | Use instead |
| --- | --- |
| `text-body-pico` | `text-body-4xs` |
| `text-body-nano` | `text-body-3xs` |
| `text-body-micro` | `text-body-2xs` |

**Impact:** required only if you use `text-body-pico`/`-nano`/`-micro`
directly (silent — the class stops resolving to any style); otherwise visual
only, from the corrected sizes. **Time:** a few minutes; search your codebase
for `text-body-pico`, `text-body-nano`, and `text-body-micro`.

**See:** [Typography](../../theming/design-tokens/typography.md)

## Checklist

- [ ] `@import "@frontile/theme"` added to `app.css`
- [ ] `LayoutTheme` config nested, if you customize it
- [ ] `--frontile-*` variable references renamed (colors take `--color-`)
- [ ] Numbered color classes replaced with named levels
- [ ] `default-*` renamed to `neutral-*`
- [ ] `bg-background` replaced with `bg-surface-canvas`
- [ ] `{color}-foreground` / `contrast-*` replaced with `on-{color}-{level}`
- [ ] **Looked at the running app**, not just the diff
- [ ] Imports moved to `frontile` (optional until 0.19)
- [ ] Looked at any multi-selects — they now render chips and are taller
- [ ] Replaced `text-body-pico`/`-nano`/`-micro` with `text-body-4xs`/`-3xs`/`-2xs`

## New projects

Starting fresh on v0.18 needs no migration. Follow
[Getting Started](../../get-started/index.md).

## Need help?

- The individual guides linked above
- The [documentation](../../get-started/index.md) for current usage examples
- Search or open an issue on [GitHub](https://github.com/josemarluedke/frontile)
