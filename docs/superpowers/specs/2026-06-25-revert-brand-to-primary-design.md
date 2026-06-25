# Revert `brand` → `primary` Color Naming — Design

**Date:** 2026-06-25
**Status:** Approved (design)

## Summary

The v0.18-alpha work renamed two semantic color categories: `default → neutral` and
`primary → brand`. This change reverts **only** the `primary → brand` rename, moving the
color naming back to `primary`. The `neutral` rename (formerly `default`) and the new
named-level system (`subtle / soft / medium / strong`, plus `on-{color}-{level}`) are kept.

Because `brand` only ever shipped in v0.18 pre-release (alpha), this is a **clean
replacement**: `brand` and `on-brand` are removed entirely, with no backward-compat alias.
The v0.18 migration guide is rewritten to present `primary` as if `brand` never existed.

## The Rename, Precisely

Change the color **token/category** name:

- Color category key `brand` → `primary`
- Auto-generated contrast category `on-brand` → `on-primary`
- Tailwind token usages, everywhere:
  - `bg-brand`, `bg-brand-{level}` → `bg-primary`, `bg-primary-{level}`
  - `text-brand`, `text-brand-{level}` → `text-primary`, `text-primary-{level}`
  - `border-brand-{level}` → `border-primary-{level}`
  - `ring-brand-{level}` → `ring-primary-{level}`
  - `fill-brand` → `fill-primary`
  - `text-on-brand-{level}`, `border-on-brand-{level}` → `text-on-primary-{level}`, `border-on-primary-{level}`
- Generated theme/CSS color path `colors.brand.*` → `colors.primary.*`
  (e.g. site `--color-brand: theme(colors.brand.medium)` → `--color-primary: theme(colors.primary.medium)`)
- Site decorative class `.hero-glow-orb--brand` → `.hero-glow-orb--primary` (consistency)
- Site swatch display label `'Brand'` → `'Primary'`

## What Does NOT Change (prose / unrelated)

These are uses of the English word "brand", not the color token, and must be left alone:

- `packages/theme/src/colors/types.ts:48` — "...that match your brand or design requirements."
- `packages/theme/README.md:132` — same phrasing in the on-color override section.
- `docs/theming/configuration/css-variables.md:384,387` — comments about brand guidelines.
- `site/app/utils/theme-colors.ts:96-97` — swatch *descriptions* ("Primary brand colors for
  important actions…", "Secondary brand colors for highlights…"). These descriptions read
  naturally and are not token references.

Also unchanged: component **variant keys** already named `primary` that happened to map to
`brand` tokens — the key stays `primary`, only the token value flips. Examples:
- `button.ts:24` `primary: 'focus-visible:ring-brand-soft'` → `primary: 'focus-visible:ring-primary-soft'`
- `spinner.ts:14` `primary: 'fill-brand'` → `primary: 'fill-primary'`
- `forms.ts:43` `primary: 'text-brand'` → `primary: 'text-primary'`

## Affected Areas

### 1. Theme core (source of truth)
- `packages/theme/src/colors/semantic.ts` — `brand:` block in both `themeColorsLight` and
  `themeColorsDark`.
- `packages/theme/src/colors/types.ts` — `brand: SemanticColorCategory`, `'on-brand'?: OnColorCategory`,
  and the code example in the doc comment (`brand: { ... }`, `'on-brand': { ... }`).
- `packages/theme/src/plugin/resolve.ts` — `'brand'` entry in `SEMANTIC_COLOR_PREFIXES`.

### 2. Theme component styles
`button.ts`, `chip.ts`, `listbox.ts`, `table.ts`, `forms/forms.ts`, `progress-bar.ts`,
`spinner.ts` — all `*-brand*` / `*-on-brand*` token usages.

### 3. Documentation
- `docs/migrations/v0.18/semantic-colors.md` — rewrite the "Brand (formerly Primary)" section
  and the `primary-* → brand-*` breaking-change row so the new system is documented as
  `primary` (old numbered `primary-{n}` → new `primary-{level}`). Update all `*-brand` examples,
  the theme-config example, and the automated-migration `sed` snippet.
- `docs/migrations/v0.18/theme-configuration.md`, `docs/migrations/v0.18/index.md`.
- `docs/theming/**` — `overview.md`, `configuration/{overview,customization,css-variables,theme-switching}.md`,
  `design-tokens/{colors,icons,borders,typography,elevation,surfaces,overview}.md`,
  `accessibility/focus-management.md`.
- `packages/theme/README.md` — color override examples and `on-{color}` list.
- Component docs under `packages/frontile/src/**/*.md` that reference `*-brand` classes.

### 4. Site (frontile.dev)
- `site/app/styles/app.css` (`--color-brand`, `.hero-glow-orb--brand`, prose-link tokens),
  `site/app/styles/docfy-demo.css`.
- `site/app/utils/theme-colors.ts` — category key `'brand'` → `'primary'`, label `'Brand'` →
  `'Primary'` (leave the descriptions).
- `site/app/components/theme-docs/color-swatch.gts` and docfy components/templates using
  `*-brand` classes.

### 5. Test-app
`*-brand` class usages in `test-app/app/components/**` and `test-app/app/templates/**`.

## Verification

Per the project pre-commit checklist:

1. `pnpm --filter @frontile/theme build` (then dependent packages / `pnpm build`).
2. `cd test-app && pnpm ember test`.
3. `pnpm lint:js --fix` and `pnpm lint:hbs --fix`.
4. `pnpm --filter <pkg> lint:types` and `cd test-app && pnpm lint:types`.
5. Final sweep: `git grep -wi brand` — confirm only the intentional prose uses listed above remain.

## Out of Scope

- The `default → neutral` rename (stays).
- The named-level system and `on-{color}` contrast generation (stays).
- Any backward-compat alias for `brand` (explicitly not provided).
