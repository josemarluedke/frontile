# Frontile Semantic Color System

Frontile does not use a numbered Tailwind scale. Classes like `bg-primary-500`,
`text-danger-700`, `border-neutral-300` **do not exist and generate no CSS**. Tailwind silently
drops them (no error, no warning, just an unstyled element). Colors are **semantic categories
with named emphasis levels** instead.

## Categories

Verified against `SEMANTIC_COLOR_PREFIXES` in `packages/theme/src/plugin/resolve.ts`, which
drives class and CSS-variable generation:

```
neutral | primary | secondary | tertiary | success | warning | danger
```

plus these `surface-*` roles, which additionally get generated `on-surface-*` contrast text:

```
surface-input | surface-modal | surface-drawer
```

**There is no `inverse` category.** A category briefly named `brand` existed during the 0.18
alpha cycle and was reverted to `primary` before release. `primary` is correct; don't use
`brand`.

Other `surface-*` roles exist (`surface-app`, `surface-canvas`, `surface-card`, `surface-table`)
but are **not** in the on-color allowlist above. There is no auto-generated
`text-on-surface-card` etc. for them. Use `text-neutral-*` for body copy on those surfaces.

## Named levels (low → high emphasis)

Verified against `SurfaceBand`/`InkBand`/`SemanticColorCategory` in
`packages/theme/src/colors/types.ts` and the literal values in `packages/theme/src/colors/semantic.ts`.

A semantic category is the union of two bands:

**Surface band** (fills: backgrounds, decorative borders):

```
subtle → muted → soft → mild → DEFAULT → firm
```

**Ink band** (legible foregrounds: text, outlined-control borders):

```
strong → bolder
```

So the full emphasis order for one category, low to high, is:

```
subtle, muted, soft, mild, DEFAULT, firm, strong, bolder
```

- `subtle` — faintest tint, hairline backgrounds / tonal resting fills
- `muted` — light tint, hover on tonal fills
- `soft` — the hover step for solid fills
- `mild` — between `soft` and `DEFAULT`, a lower-emphasis fill just short of resting
- **`DEFAULT`** — resting fill, **no suffix**: `bg-primary` is the resting fill, not
  `bg-primary-DEFAULT`
- `firm` — most emphatic fill (pressed/active backgrounds)
- `strong` — default legible foreground (body text, outlined-control text/border)
- `bolder` — highest-emphasis foreground (headings, hover/active text)

Note the doc at `docs/migrations/v0.18/semantic-colors.md` lists the surface band as only
`subtle, muted, soft, DEFAULT, firm` in its "Understanding the New Levels" section, omitting
`mild` from that bullet list even though it references `bg-primary-mild` elsewhere in the same
document. The type definitions in `types.ts` are authoritative and include `mild` between `soft`
and `DEFAULT`. Treat the 8-level list above as correct.

Names describe emphasis **rank**, never brightness. A level can be dark in light mode and
light in dark mode.

## Surface overlay levels

`surface-overlay-{level}` is a translucent, non-chromatic veil (black in light mode, white in
dark mode) for hover/elevation states. Levels, verified against `SurfaceOverlay` in `types.ts`
and the literal alpha values in `semantic.ts`:

```
subtle | soft | mild | firm | strong
```

`strong` is the **modal/drawer backdrop** (75% black in light mode, 95% white in dark mode,
confirmed by the JSDoc on `SurfaceOverlay.strong` and the alpha values in `semantic.ts`).

There is also a mirror-image `surface-lift-{level}` family (same five level names) that
lightens in light mode and darkens in dark mode instead, for frosted panels and sticky headers
that should float above the page rather than press into it. Neither `surface-overlay-*` nor
`surface-lift-*` gets an `on-*` contrast color: `resolve.ts` explicitly excludes both prefixes
(`shouldGenerateOnColor` rejects anything starting with `surface-overlay` or `surface-lift`)
because contrast for a translucent veil depends on whatever shows through it.

## Contrast text: `on-{category}-{level}`

`on-{category}-{level}` (e.g. `text-on-primary-firm`) is auto-generated for WCAG contrast
(black or white) on that specific background level. The bare `text-on-primary` resolves via the
`DEFAULT` level, same as the background classes.

Auto-generation covers every category in the `SEMANTIC_COLOR_PREFIXES` list above (the seven
color categories plus `surface-input`, `surface-modal`, `surface-drawer`). A small number of
`soft`-level on-colors are hand-specified rather than computed. `semantic.ts` hardcodes
`on-{category}-soft` to black (light theme) / white (dark theme) for every category, with a
comment explaining the generator measures the raw RGBA value of a translucent color rather than
its composite over the page, and gets that one wrong. You don't need to do anything differently
as a consumer. This only matters if you're overriding on-colors yourself.

## Light/dark and `.theme-inverse`

Every token is a CSS custom property, `--color-{category}-{level}`, redefined per color scheme.
Classes built on them adapt to light/dark automatically. No dark: variant is needed for the
semantic categories themselves. `strong` inverts to the **lightest** shade in dark mode (it's a
rank, not a literal brightness).

`.theme-inverse` is a **scoping class**, not a color category. Add it to any element and every
semantic token inside that subtree re-resolves to the opposite color scheme: a dark panel
embedded in an otherwise light-mode page, or vice versa. Ordinary semantic classes (`bg-surface-canvas`,
`text-neutral-bolder`, …) keep working unchanged inside it; you don't reach for special
"inverse" class names.

```gts
<div class="theme-inverse bg-surface-canvas p-6">
  <h3 class="text-neutral-bolder">Reads as dark in light mode</h3>
</div>
```

Verified against `resolveThemes()` in `packages/theme/src/plugin/resolve.ts`: the light theme's
selector is generated as `.light, .dark .theme-inverse` and the dark theme's as
`.dark, .light .theme-inverse`, i.e. `.theme-inverse` re-targets which theme's variables apply
to that subtree, it does not introduce a new palette.

## Common mistakes

- **No numbered scale.** `bg-primary-500`, `text-danger-700`, `border-neutral-300` do not exist.
  Use a named level: `bg-primary-soft`, `text-danger-firm`, `border-neutral-soft`.
- **Don't hand-pick black/white for text on a colored background.** Use `on-{category}-{level}`
  instead of `text-white`/`text-black`. It's computed for WCAG contrast and adapts per theme,
  where a hardcoded color won't.
- **`DEFAULT` has no suffix in the class name.** There is no `bg-primary-DEFAULT`; it's just
  `bg-primary`.
- **Don't reach for `inverse` as a category** (`bg-inverse`, `text-on-inverse`, etc.). It
  doesn't exist. Use `.theme-inverse` on a wrapping element instead.
- **`faded`/`default`/`info` are pre-v0.18 vocabulary**, not color-system vocabulary. See
  `api-naming.md` in this same references directory for the component-argument renames; this
  file only covers the Tailwind color classes.
