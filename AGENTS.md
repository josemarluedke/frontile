# Frontile Development Guide for AI Agents

This guide helps AI agents understand the Frontile project structure and development workflow.

## Project Overview

Frontile is a modern, accessible component library for Ember.js built with:

- **Ember Octane** with Glimmer components
- **TypeScript** with Glint for type-safe templates
- **Tailwind CSS** with Tailwind Variants for styling
- **GTS/GJS** template tag format (prefer `.gts` over `.gjs`)
- **pnpm workspaces** for monorepo management

## Project Structure

**Important — source is consolidated.** All component source now lives in the single
`packages/frontile` package, grouped by category under `packages/frontile/src/components/`.
The old per-feature packages (`buttons`, `collections`, `forms`, `overlays`, `notifications`,
`status`, `utilities`) are now thin **deprecation/re-export wrappers** — their `src/` contains
only `index.ts` + `template-registry.ts` and re-exports from `frontile`. **Do not add or edit
component source in those wrapper packages**; work in `packages/frontile/src/`.

```
frontile/
├── packages/
│   ├── frontile/                    # PRIMARY package — all component source lives here
│   │   └── src/
│   │       ├── components/          # Source grouped by category:
│   │       │   ├── buttons/         #   Button, ButtonGroup, Chip, CloseButton, ToggleButton
│   │       │   ├── collections/     #   Table, Listbox, Dropdown
│   │       │   ├── forms/           #   Input, Select, Checkbox, Radio, Switch, Textarea
│   │       │   ├── overlays/        #   Modal, Drawer, Popover, Overlay, Portal
│   │       │   ├── notifications/   #   NotificationCard, NotificationsContainer
│   │       │   ├── status/          #   ProgressBar
│   │       │   └── utilities/       #   Avatar, Collapsible, Divider, Spinner, VisuallyHidden
│   │       ├── modifiers/  services/  utils/
│   │       └── buttons.ts, collections.ts, …  # category barrel entry points
│   ├── theme/                       # Styling system (Tailwind Variants + semantic colors)
│   ├── core/                        # Shared low-level primitives
│   ├── tailwindcss-plugin-helpers/  # Helpers for the Tailwind plugin
│   ├── changeset-form/              # Form components integrated with ember-changeset
│   ├── forms-legacy/                # Legacy form components (still maintained)
│   └── buttons/ collections/ forms/ overlays/ notifications/ status/ utilities/
│                                    # Deprecation wrappers re-exporting from `frontile`
├── test-app/             # Test application (integration/unit tests for all components)
├── site/                 # Documentation site (frontile.dev), built with Docfy
└── docs/                 # Markdown docs (theming, migrations) rendered by the site

```

**Component docs are co-located:** each component has a sibling `.md` file next to its `.gts`
(e.g. `packages/frontile/src/components/buttons/button.gts` + `button.md`). See the
Documentation section below — these `.md` files are rendered as **live demos** by Docfy.

## Development Workflow

### Running Tests

**All tests:**

```bash
cd test-app && pnpm ember test
```

**Filter specific tests:**

```bash
cd test-app && pnpm ember test --filter="table"
```

**From root (alternative):**

```bash
pnpm test
```

### Building Packages

**Build the main package (most component work):**

```bash
pnpm --filter frontile build
```

**Build the theme package (after any style/color change):**

```bash
pnpm --filter @frontile/theme build
```

**Build all packages:**

```bash
pnpm build
```

**Important:** When working on a component, build `frontile` before running tests. If you
modify styles or colors in `@frontile/theme`, build `@frontile/theme` too (the theme feeds
generated Tailwind classes/CSS variables consumed everywhere). The legacy per-feature
packages (`collections`, `buttons`, …) are wrappers — you rarely build them directly.

### Linting

**Check linting:**

```bash
pnpm lint:js
```

**Auto-fix linting:**

```bash
pnpm lint:js --fix
```

### Type Checking

**Check types for a specific package:**

```bash
pnpm --filter frontile lint:types
pnpm --filter @frontile/theme lint:types
```

**Check types for test-app:**

```bash
cd test-app && pnpm lint:types
```

**Always run type checking and linting before committing.**

### Running Development Server

```bash
pnpm start  # Starts test-app dev server
```

## Code Style Guidelines

### Component Format

- **Prefer `.gts` over `.gjs`** for all components
- For template-only components, use TypeScript and import `TOC` (Template Only Component)
- Use Glimmer components with `<template>` tags
- Follow TypeScript strict mode conventions

Example template-only component:

```typescript
import type { TOC } from '@ember/component/template-only';

export interface Signature {
  Args: {
    title: string;
  };
}

const MyComponent: TOC<Signature> = <template>
  <div>{{@title}}</div>
</template>;

export default MyComponent;
```

### Helpers and Utilities

**Important:** When working with template helpers in `.gts` files:

- Import helpers explicitly from `@ember/helper` (e.g., `hash`, `array`, `fn`)
- **`eq` is NOT available** from `@ember/helper` - use custom helper or inline comparison
- Common available helpers: `hash`, `array`, `fn`, `get`, `concat`
- Import `on` modifier from `@ember/modifier`;

Example:

```typescript
import { hash, fn } from '@ember/helper';
import { on } from '@ember/modifier';

<template>
  <MyComponent @options={{hash foo="bar" baz="qux"}} />
  <button {{on "click" (fn this.handleClick "arg")}}>Click</button>
</template>
```

### Styling

- Use Tailwind Variants via `@frontile/theme`
- Components accept `@classes` argument for customization
- Follow existing patterns in theme package

### Semantic Color System

Colors are **semantic categories with named levels** — not a numbered scale. Use these
generated Tailwind utilities; there is no `primary-500`-style numbered class.

- **Categories:** `neutral` (default UI), `primary` (brand/important actions), `accent`,
  `success`, `warning`, `danger`, plus `inverse` (for inverted surfaces) and `surface-*`.
- **Levels** (low → high emphasis): `subtle`, `muted`, `soft`, `medium` (= `DEFAULT`),
  `firm`, `strong`, `bolder`, `boldest`. Because `medium` is `DEFAULT`, the bare class works
  too — `bg-primary` == `bg-primary-medium`.
- **Contrast text:** `on-{category}-{level}` (e.g. `text-on-primary-medium`) is
  auto-generated (black/white) for WCAG contrast on that background. The bare `text-on-primary`
  also resolves via DEFAULT. Users may override these in their theme config.
- Light/dark adapt automatically via CSS variables (`--color-{category}-{level}`); `strong`
  inverts to the lightest shade in dark mode.

**Source of truth (edit these to change colors):**
- `packages/theme/src/colors/semantic.ts` — the values for each category/level (light + dark).
- `packages/theme/src/colors/types.ts` — the `ThemeColors` type (category keys + `on-*`).
- `packages/theme/src/plugin/resolve.ts` — `SEMANTIC_COLOR_PREFIXES` drives class + CSS-var
  generation, including the `on-*` contrast colors.

> Note: the category was briefly named `brand` during v0.18-alpha and reverted to `primary`.
> Use `primary`. The v0.18 migration guide (`docs/migrations/v0.18/`) documents the move from
> the old numbered scale to named levels.

### Package Dependencies

Common dependency/build order (build in this order if modifying multiple):

1. `@frontile/theme` - Base styling system (colors, Tailwind Variants)
2. `frontile` - The main package containing all component source
3. Legacy wrapper packages (`buttons`, `collections`, …) only if you specifically need them

In practice, most work is just: build `@frontile/theme` (if styles changed), then `frontile`.

## Testing Guidelines

- Tests live in `test-app/tests/integration/components/`
- Use `@ember/test-helpers` for rendering and interactions
- Test accessibility features (ARIA attributes, keyboard navigation)
- Test component variants and states
- Run tests after building the package you modified

## Documentation

Frontile docs come in two co-located/rendered forms — both matter:

1. **Component docs** — the `.md` file beside each component (e.g.
   `packages/frontile/src/components/buttons/button.md`). **Docfy renders the GJS/HTML code
   fences in these files as live, interactive demos.** A class in a code block is real output,
   not just sample text — so any class change (e.g. color tokens) must be applied there too,
   or the rendered demo breaks. Document new props/args and add usage examples here.
2. **Guide docs** — `docs/` (theming, migrations) and the `site/` app, also Docfy-rendered.

When changing public API or styling, update the affected `.md` files, type signatures, and
examples. After doc/style changes, it's worth running the site (`cd site && pnpm build` or
`pnpm start`) to confirm the rendered demos still look right.

## Common Tasks

### Adding a New Component

1. Create the component under the right category, e.g.
   `packages/frontile/src/components/buttons/new-component.gts`
2. Add styles to `@frontile/theme` if needed (build it after)
3. Export it from the category barrel (e.g. `packages/frontile/src/buttons.ts`) / `index.ts`
4. Add a co-located `new-component.md` with usage + demos
5. Add tests in `test-app/tests/integration/components/`
6. Build: `pnpm --filter frontile build`
7. Run tests: `cd test-app && pnpm ember test --filter="new-component"`

### Modifying Existing Component

1. Edit the component in `packages/frontile/src/components/<category>/`
2. If styles/colors changed, build `@frontile/theme` first
3. Build `frontile`
4. Run relevant tests
5. Update the co-located `.md` (and any guide docs) if public API or styling changed
6. Run type checking and linting

### Bug Fixes

1. Write a failing test first
2. Fix the bug
3. Build the package
4. Verify tests pass
5. Run linting and type checking

## Pre-Commit Checklist

Before committing, always run:

```bash
pnpm --filter <package-name> build      # Build modified package(s)
cd test-app && pnpm ember test          # Run tests
pnpm lint:hbs --fix                     # Fix template linting
pnpm lint:js --fix                      # Fix JS/TS linting
pnpm --filter <package-name> lint:types # Type check
```

## Important Notes

- This is a **monorepo** using pnpm workspaces
- Packages are published independently but versioned together
- Components should be **accessible** (follow ARIA guidelines)
- All components should support **dark mode**
- Use **Tailwind Variants** for styling, not plain CSS
- Template imports use `.gts` extension
- Type safety is enforced with Glint
