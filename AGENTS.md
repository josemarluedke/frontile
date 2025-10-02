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

```
frontile/
├── packages/              # Component library packages
│   ├── buttons/          # Button, ButtonGroup, Chip, CloseButton, ToggleButton
│   ├── collections/      # Table, Listbox, Dropdown
│   ├── forms/            # Input, Select, Checkbox, Radio, Switch, Textarea
│   ├── forms-legacy/     # Legacy form components
│   ├── overlays/         # Modal, Drawer, Popover, Overlay, Portal
│   ├── notifications/    # NotificationCard, NotificationsContainer
│   ├── status/           # ProgressBar
│   ├── utilities/        # Avatar, Collapsible, Divider, Spinner, VisuallyHidden
│   ├── theme/            # Styling system with Tailwind Variants
│   ├── changeset-form/   # Form components integrated with ember-changeset
│   └── frontile/         # Meta package that exports all packages
├── test-app/             # Test application for all packages
├── site/                 # Documentation site (frontile.dev)
└── docs/                 # Additional documentation

```

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

**Build specific package:**

```bash
pnpm --filter collections build
```

**Build all packages:**

```bash
pnpm build
```

**Important:** When working on a package, build it before running tests. If you modify styles in `@frontile/theme`, build that package too.

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

**Check types for specific package:**

```bash
pnpm --filter collections lint:types
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

### Package Dependencies

Common dependency order (build these in order if modifying multiple):

1. `@frontile/theme` - Base styling system
2. `@frontile/utilities` - Utility components
3. Other packages (buttons, forms, overlays, etc.)
4. `frontile` - Meta package

## Testing Guidelines

- Tests live in `test-app/tests/integration/components/`
- Use `@ember/test-helpers` for rendering and interactions
- Test accessibility features (ARIA attributes, keyboard navigation)
- Test component variants and states
- Run tests after building the package you modified

## Documentation

When adding features or making changes that impact usage:

1. Update relevant documentation in `site/` directory
2. Document new component props and arguments
3. Add usage examples
4. Update type signatures

## Common Tasks

### Adding a New Component

1. Create component file in appropriate package (e.g., `packages/buttons/src/components/new-component.gts`)
2. Add styles to `@frontile/theme` if needed
3. Export from package index
4. Add tests in `test-app/tests/integration/components/`
5. Build package: `pnpm --filter buttons build`
6. Run tests: `cd test-app && pnpm ember test --filter="new-component"`
7. Update documentation in `site/`

### Modifying Existing Component

1. Edit component in its package
2. If styles changed, build `@frontile/theme` first
3. Build the component's package
4. Run relevant tests
5. Update documentation if public API changed
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
