// Color for the app shell's navigation surfaces: the `AppLayout` frame, a
// `Sidebar` and a `Navbar`. Two layers of custom properties:
//
// 1. The layout color, set from `@color`. It names one semantic category, so
//    the parts below read one set of properties whatever the color is:
//
//      --app-layout-color         the color: a solid fill, the tints' base
//      --app-layout-color-strong  the current row's label on a tinted part
//      --app-layout-on-color      text on a solid fill
//
//    They are declared once, on the layout's root, and inherited by the parts
//    in it. Three places declare them again: the phone drawer (portalled out
//    of the layout, so it inherits nothing), a part with its own `@color`, and
//    a part rendered outside a layout. So an app sets a color outside the
//    theme on the root (`@classes` `base`), plus `mobileSidebar` for the
//    drawer.
//
// 2. The roles a navigation row, a sidebar group label and the layout's
//    toggles read (`--nav-item-*`, `--nav-folder-border`,
//    `--sidebar-group-label-fg`). Unset, each falls back to the neutral color
//    where it is read, so a neutral, plain shell sets nothing. A part's
//    surface sets them on the part from the layout color. They are computed
//    there: a layout color changed on an element inside the part does not
//    reach them.
//
// Every class below is a literal, written out per color: Tailwind only
// generates classes it finds as whole strings in the source.

const layoutColor = {
  // Neutral's fill is its darkest level, as for a solid neutral `Button`: a
  // mid-grey bar would read as disabled.
  neutral:
    '[--app-layout-color:var(--color-neutral-bolder)] [--app-layout-color-strong:var(--color-neutral-strong)] [--app-layout-on-color:var(--color-on-neutral-bolder)]',
  primary:
    '[--app-layout-color:var(--color-primary)] [--app-layout-color-strong:var(--color-primary-strong)] [--app-layout-on-color:var(--color-on-primary)]',
  secondary:
    '[--app-layout-color:var(--color-secondary)] [--app-layout-color-strong:var(--color-secondary-strong)] [--app-layout-on-color:var(--color-on-secondary)]',
  tertiary:
    '[--app-layout-color:var(--color-tertiary)] [--app-layout-color-strong:var(--color-tertiary-strong)] [--app-layout-on-color:var(--color-on-tertiary)]',
  success:
    '[--app-layout-color:var(--color-success)] [--app-layout-color-strong:var(--color-success-strong)] [--app-layout-on-color:var(--color-on-success)]',
  warning:
    '[--app-layout-color:var(--color-warning)] [--app-layout-color-strong:var(--color-warning-strong)] [--app-layout-on-color:var(--color-on-warning)]',
  danger:
    '[--app-layout-color:var(--color-danger)] [--app-layout-color-strong:var(--color-danger-strong)] [--app-layout-on-color:var(--color-on-danger)]'
} as const;

// The non-neutral colors, for compound variants: neutral's plain surface is
// the fallbacks, so it sets no roles.
const tintedColors = [
  'primary',
  'secondary',
  'tertiary',
  'success',
  'warning',
  'danger'
] satisfies (keyof typeof layoutColor)[];

// `plain`: the part keeps its own ground (the frame, or the attached
// sidebar's surface) and its rows take the color. The fills are fixed
// fractions of the color rather than its `soft`/`muted` levels, whose alpha
// differs from one category to the next, so every color steps the same way
// from hover to current. Resting text stays neutral.
const navTint = [
  '[--nav-item-hover-bg:color-mix(in_oklab,var(--app-layout-color)_10%,transparent)]',
  '[--nav-item-active-bg:color-mix(in_oklab,var(--app-layout-color)_18%,transparent)]',
  '[--nav-item-active-fg:var(--app-layout-color-strong)]',
  '[--nav-folder-border:color-mix(in_oklab,var(--app-layout-color)_25%,transparent)]'
];

// `solid`: the part is filled with the color. Text is the full contrast
// color, which is chosen for contrast at full strength only, so a light color
// (a yellow `warning`) gets dark rows and a dark one light rows. The fills are
// fractions of it. The `dark:` background is repeated because the attached
// variant's own `dark:` background would otherwise win.
const navSolid = [
  'bg-(--app-layout-color) dark:bg-(--app-layout-color) text-(--app-layout-on-color)',
  '[--nav-item-fg:var(--app-layout-on-color)]',
  '[--nav-item-hover-fg:var(--app-layout-on-color)]',
  '[--nav-item-active-fg:var(--app-layout-on-color)]',
  '[--nav-item-hover-bg:color-mix(in_oklab,var(--app-layout-on-color)_12%,transparent)]',
  '[--nav-item-active-bg:color-mix(in_oklab,var(--app-layout-on-color)_20%,transparent)]',
  '[--nav-folder-border:color-mix(in_oklab,var(--app-layout-on-color)_25%,transparent)]',
  '[--sidebar-group-label-fg:var(--app-layout-on-color)]'
];

// The frame's gradient stops, from the layout color.
const frameGradientStops = [
  '[--app-frame-gradient-from:color-mix(in_oklab,var(--app-layout-color)_16%,transparent)]',
  '[--app-frame-gradient-to:color-mix(in_oklab,var(--color-neutral-subtle)_16%,transparent)]'
];

export { layoutColor, tintedColors, navTint, navSolid, frameGradientStops };
