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
│   │       │   ├── collections/     #   Table, SimpleTable, Listbox, Dropdown, Calendar, Command
│   │       │   ├── disclosure/      #   Accordion
│   │       │   ├── forms/           #   Input, Select, Checkbox, Radio, Switch, Textarea,
│   │       │   │                    #   SegmentedControl, …
│   │       │   ├── navigation/      #   Tabs, TabNav, Pagination, ExternalLink
│   │       │   ├── overlays/        #   Modal, Drawer, Popover, Overlay, Portal
│   │       │   ├── notifications/   #   NotificationCard, NotificationsContainer
│   │       │   ├── status/          #   Alert, ProgressBar
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

**Site tests** (the docs app — `<Signature>`, the Docfy components):

```bash
pnpm build && cd site && pnpm test
```

Two things differ from the test-app suite:

- It needs the **full** `pnpm build`, not just theme + `frontile` — see Building Packages.
- Each run leaves an orphaned browser holding testem's port 7357, so a second run fails
  with `listen EADDRINUSE :::7357`. Testem reports that as a single `not ok 1 - Error`
  with `# tests 1`, which looks like a catastrophic suite failure but is only a port
  clash. Either free the port (`lsof -tnP -i :7357 | xargs kill -9`) or run on another
  one: `pnpm vite build --mode development && pnpm testem ci --port 7412`.

### Building Packages

**Build the main package (most component work):**

```bash
pnpm --filter "frontile..." build
```

**Build the theme package (after any style/color change):**

```bash
pnpm --filter @frontile/theme build
```

**Build all packages:**

```bash
pnpm build
```

**Important:** note the trailing `...` in `--filter "frontile..."` — it tells pnpm to build
the package's workspace dependencies first. `frontile` compiles against `@frontile/theme`'s
generated `declarations/`, so building it alone against missing or out-of-date theme
declarations fails at the declaration step, with errors that point at `frontile`'s own source
rather than at the real cause (`Module '@frontile/theme' has no exported member
'AvatarSlots'` when they are missing; a narrower `datePicker is not a function` when they are
merely stale). Nothing is wrong with the source in that case — the dependency had simply not
been built. This bites hardest in a fresh clone or worktree, where nothing has been built yet.

Build `frontile` before running tests when you are working on a component. The legacy
per-feature packages (`collections`, `buttons`, …) are wrappers — you rarely build them
directly.

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
- **Use `@color` and `@variant`, not `@intent` and `@appearance`.** v0.18 renamed them and
  their values: `intent="default"` → `color="neutral"`, `appearance="default"` → `variant="solid"`,
  `outlined` → `outline`, `minimal` → `plain`. The old names still resolve and remain all over
  the repo, so copying a nearby call site will give you the deprecated form. Feedback
  surfaces (Alert, form feedback) take `@status` rather than `@color`.

### Semantic Color System

Colors are **semantic categories with named levels** — not a numbered scale. Use these
generated Tailwind utilities; there is no `primary-500`-style numbered class.

- **Categories:** `neutral` (default UI), `primary` (brand/important actions),
  `secondary`, `tertiary`, `success`, `warning`, `danger`, and `surface-*`. There is no
  `inverse` category — the allowlist that generates these lives in
  `packages/theme/src/plugin/resolve.ts` (`SEMANTIC_COLOR_PREFIXES`).
- **Inverting a subtree:** every token is emitted under `.light, .dark .theme-inverse` and
  `.dark, .light .theme-inverse`, so adding `.theme-inverse` to an element re-resolves the
  whole palette to the opposite scheme for that subtree. This is a scoping class, not a
  color category.
- **Levels** (low → high emphasis): `subtle`, `muted`, `soft`, `mild`, `DEFAULT`, `firm`,
  `strong`, `bolder`. The `DEFAULT` level has no suffix — `bg-primary` is the resting fill.
- **Surface overlay levels:** `subtle`, `soft`, `mild`, `firm`, `strong` (`strong` is the
  modal/drawer backdrop).
- **Contrast text:** `on-{category}-{level}` (e.g. `text-on-primary-firm`) is
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

**Except for the site test suite, which needs a full `pnpm build`.** The docs render live
demos from every package, including `forms-legacy` and `changeset-form`, so a theme +
`frontile` build is not enough. A partial build fails during `site`'s Vite build with

```
Rolldown failed to resolve import "@embroider/virtual/components/form-checkbox"
  from ".../forms-legacy/form-checkbox_gen/docfy-demo-src-components-form-checkbox-usage.hbs"
```

which names a demo template rather than the missing build, so it reads as a broken site
rather than an incomplete one.

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

### Two skill directories, two audiences

Both are real skills and `npx skills add josemarluedke/frontile` discovers both, so the
distinction has to stay legible in their `description` fields:

- **`skills/frontile/`** ships to *consumers*. It is what an agent working in someone
  else's Ember app installs. It deliberately carries no argument lists — it routes to
  `node_modules/frontile/declarations/**/*.d.ts` (version-exact for whoever installed it)
  and to the `.md` mirrors on frontile.dev. Adding an argument table here would go stale
  on the next release and would be wrong for anyone not on latest.
- **`.claude/skills/frontile-contributor-docs/`** is for work *inside this repo* — writing
  the co-located component `.md` files. It never leaves the repo in practice.

When Frontile's public API changes, `skills/frontile/references/api-naming.md` is the file
to check: it is the one place in the consumer skill that names arguments, and it does so
only to map removed names onto their replacements.

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
pnpm lint:hbs                           # Template linting — NEVER with --fix
pnpm lint:js --fix                      # Fix JS/TS linting
pnpm --filter <package-name> lint:types # Type check
```

**Never run `pnpm lint:hbs --fix`.** Several of `ember-template-lint`'s autofixers
*delete* the attribute they object to rather than flagging it, and they do it silently —
the diff is a deletion with no message. It has already removed ARIA attributes from a
component on this repo, which was only noticed during review. Run `pnpm lint:hbs` without
`--fix` and apply what it reports by hand. `pnpm lint:js --fix` is safe.

## Important Notes

- This is a **monorepo** using pnpm workspaces
- Packages are published independently but versioned together
- Components should be **accessible** (follow ARIA guidelines)
- All components should support **dark mode**
- Use **Tailwind Variants** for styling, not plain CSS
- Template imports use `.gts` extension
- Type safety is enforced with Glint
