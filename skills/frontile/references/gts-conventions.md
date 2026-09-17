# Frontile GTS Conventions

Rules for writing `.gts` in an app that consumes the `frontile` package. Verified against
`packages/frontile/src/**` in the Frontile repo itself (source of truth for a version-matched
install), not inferred from memory of Ember conventions in general.

## Imports

Everything ships from the single `frontile` package:

```ts
import { Button, Input, Modal } from 'frontile';
```

Category subpaths are also official entry points, declared in `frontile`'s `exports` map, and
both styles appear in real apps:

```ts
import { Button, Chip } from 'frontile/buttons';
import { Input, Select } from 'frontile/forms';
```

Available subpaths: `buttons`, `forms`, `overlays`, `collections`, `notifications`, `status`,
`utilities`, `navigation`, `disclosure`.

**Do not confuse `frontile/buttons` with `@frontile/buttons`.** The first is a current entry
point of the `frontile` package. The second is a separate, deprecated package. They differ only
by the `@` and the slash, and rewriting the former into the barrel import because it looks
deprecated is a pointless diff. Match whichever style the file already uses.

The old scoped packages (`@frontile/buttons`, `@frontile/collections`, `@frontile/forms`,
`@frontile/overlays`, `@frontile/notifications`, `@frontile/status`, `@frontile/utilities`) are
deprecated re-export shims and are **removed in 0.19.0**. `@frontile/changeset-form` and
`@frontile/forms-legacy` are likewise deprecated, so migrate to `frontile`'s own form components.
`@frontile/theme` is a separate, still-current package: it supplies styling (Tailwind Variants,
color tokens, the Tailwind plugin), not components. Never import a component from it.

Tree-shaking works with explicit named imports in `.gts`/`.gjs`: import only what you use.

## `.gts` over `.gjs`

Prefer `.gts`. For a template-only component (no backing class), type it with `TOC` from
`@ember/component/template-only`:

```ts
import type { TOC } from '@ember/component/template-only';

export interface Signature {
  Args: { title: string };
}

const MyComponent: TOC<Signature> = <template>
  <div>{{@title}}</div>
</template>;

export default MyComponent;
```

## Template helpers and modifiers

Import explicitly inside a `<template>`:

- From `@ember/helper`: `hash`, `array`, `fn`, `get`, `concat`.
- From `@ember/modifier`: `on`.

### `eq` is not available from `@ember/helper`

Ember's helper module does not export `eq`, `and`, `or`, `not`. Do not write `{{eq @foo "bar"}}`
and assume it resolves.

**Check `package.json` first.** These come from `ember-truth-helpers`, which most Ember apps
already depend on, and if it is there the normal answer is simply to import from it:

```ts
import { eq } from 'ember-truth-helpers';
```

It is not a Frontile dependency, so it may be absent. Frontile's own source never uses it, and
the two patterns below are what the library does instead. Reach for them when the app does not
have `ember-truth-helpers` and you do not want to add it:

1. **Push the comparison into a getter on the backing class**, then branch on the getter in the
   template. E.g. `packages/frontile/src/components/buttons/segmented-control/item.gts` has
   `get isSelected(): boolean { return this.args.context.isSelected(this.args.value); }` and the
   template uses `{{this.isSelected}}` / `data-selected="{{this.isSelected}}"` directly, with no
   inline comparison helper at all.
2. **A plain module-scope function used as a helper**, when the comparison genuinely has to
   happen in the template (e.g. to compute a dynamic tag name). From
   `packages/frontile/src/components/disclosure/accordion/item.gts`:

   ```ts
   /**
    * `eq` is not available from `@ember/helper`, and a dynamic tag needs a string.
    * A plain module-scope function works as a helper, as in `divider.gts`.
    */
   function headingTag(level: HeadingLevel): string {
     return `h${level}`;
   }
   ```

   A plain function imported into a `<template>` and invoked there (`{{(headingTag @level)}}` /
   `{{element (headingTag @level)}}`) behaves as a helper without needing `ember-truth-helpers`
   or a custom Helper class.

## Installation and Tailwind setup (silent-failure trap)

Per `docs/get-started/installation.md`:

```sh
pnpm install frontile @frontile/theme
```

In `app/styles/app.css` (path relative to that file; one level shallower under Vite, where the
entry stylesheet is usually `app/app.css`):

```css
@import 'tailwindcss' source('../../');
@plugin "@frontile/theme/plugin/default";
@import '@frontile/theme';

@source '../../node_modules/frontile';
@source '../../node_modules/@frontile';
```

**Why the `@source` lines matter:** Tailwind v4 skips `node_modules` when scanning for classes
used in templates. Frontile's components carry their utility classes in `node_modules/frontile`
(and, while consumers are mid-migration, `node_modules/@frontile/*`). Without these `@source`
directives, Tailwind purges those classes as unused and Frontile's components render **completely
unstyled**: no build error, no console warning, just plain HTML. This is the single most common
silent-failure mode for a fresh integration. If a consumer reports "the components render but
look unstyled," check for these lines first.

To customize the theme, create `frontile.js` at the project root:

```js
const { frontile } = require('@frontile/theme/plugin');
module.exports = frontile({/* your config */});
```

and swap the `@plugin` line to `@plugin "./../../frontile.js";`.

## `@classes` vs `@class` — per-slot styling

Verified on two real components with opposite shapes:

- **Single-slot components** (one root element, e.g. `Button`) take a plain `@class` string arg
  (`class?: string;` in `buttons/button.gts`), merged with the component's own theme classes.
- **Multi-slot components** (several themed parts, e.g. `Modal`) take `@classes` as a
  `SlotsToClasses<TheirSlots>` object, with one key per slot, merged per-slot with the theme:

  ```ts
  // overlays/modal.gts
  classes?: SlotsToClasses<ModalSlots>;
  ```

  ```gts
  <Modal @classes={{hash base="max-w-2xl" closeButton="top-2 right-2"}}>
    ...
  </Modal>
  ```

  Internally each slot renders as `{{this.classes.<slot> class=@classes.<slot>}}`, so an
  unset key falls back to the theme default for that slot and only the keys you pass are
  overridden.

Check a component's own `.d.ts`/`.md` to see which shape it uses. Do not assume `@classes` is
universal; components with a single root element use `@class` instead.

### Finding the slot names

`SlotsToClasses<ModalSlots>` does not tell you what the keys are. `ModalSlots` is derived as
`keyof ReturnType<typeof modal>`, so the names appear nowhere in the component's own
declaration. They are in the theme package's declarations, which ship for the same reason
`frontile`'s do:

```
node_modules/@frontile/theme/declarations/components/<name>.d.ts
```

One file per component (`button.d.ts`, `listbox.d.ts`, …), with overlays grouped in
`overlays.d.ts` and form controls under `components/forms/`. The `tv()` return type lists the
variant names and then the slots. For `modal`, as a consuming app sees it:

```ts
declare const modal: import('tailwind-variants').TVReturnType<
  {
    size: {
      xs: string;
      sm: string;
      md: string;
      lg: string;
      xl: string;
      full: string;
    };
    isCentered: { true: string };
  },
  {
    base: string;
    closeButton: string;
    header: string;
    body: string;
    footer: string;
  } /* … */
>;
```

The second type argument is the slot map, so Modal's `@classes` keys are `base`,
`closeButton`, `header`, `body`, and `footer`. This is version-exact the same way the
component declarations are, so prefer it over any list written down elsewhere.

## Finding exact arguments for any component

The published `frontile` package includes a `declarations/` directory (confirmed via
`packages/frontile/package.json`'s `"files"` field: `["addon-main.js", "declarations", "dist"]`,
and the directory exists at `packages/frontile/declarations/` in this repo's own build output).
In a consumer's `node_modules/frontile/declarations/**/*.d.ts` you get:

- The exact argument shape for the installed version (not whatever a training cutoff implies).
- Full JSDoc comments per argument, including default values.
- `@deprecated` tags on any argument/export being phased out.

When unsure of a component's exact args, defaults, or deprecations, read the `.d.ts` for that
component rather than guessing from a `.md` demo (demos show common cases, not the full surface).
