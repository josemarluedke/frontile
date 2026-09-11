---
title: Component Styles
order: 20
category: theming
---

# Customizing Component Styles

Frontile provides flexibility for customizing the styles of its components, allowing developers to create a cohesive design that aligns with your application's requirements. This guide details how to customize component styles using Tailwind Variants and discusses global versus local style overrides.

## Overview

Frontile uses [Tailwind Variants](https://www.tailwind-variants.org/) to manage and customize component styles. Tailwind Variants provide a structured way to define different visual representations (or variants) for components while keeping your styles consistent and maintainable.

A **slot** represents a specific part of a component that can be styled or customized separately. Slots allow you to apply different styles to different parts of a complex component, providing more granular control.

When customizing styles in Frontile, you can either apply styles globally using `registerCustomStyles` or customize individual components using class arguments. You can override default component styles by passing your own class names to the `class` or `classes` argument, depending on whether the component has slots.

## DOM Anatomy: `data-component` and `data-part`

Every Frontile component renders a stable, documented DOM anatomy, independent
of its CSS classes. Two attributes carry it:

- **`data-component="<name>"`** — the kebab-cased `tv()` config name (e.g. the
  `notificationCard` config produces `notification-card`), written on the
  component's **outermost rendered element only**. This is the name the
  component is registered under, not its filename — `commandDialog` →
  `command-dialog`.
- **`data-part="<name>"`** — the kebab-cased `tv()` slot key, written on
  **every** element that renders a slot (`startContent` → `start-content`).
  Slot names are exactly the keys you already pass to `@classes`, so if you
  can style a part with `@classes={{hash startContent='...'}}`, you can also
  select it with `[data-part="start-content"]`.

By convention the root element's part is `base` — but only by convention, not
by rule. It carries whichever slot it actually renders. `SimpleTable`, used
standalone, renders its `<table>` element as the root, which renders the
`table` slot, so it carries `data-part="table"`, not `data-part="base"`.
(`Table`'s own root is different: it's the wrapper `<div>`, which carries
`data-part="wrapper"` — `Table` composes `SimpleTable` internally with
`@isRoot={{false}}`, so the inner `<table>` keeps `data-part="table"` but no
longer carries `data-component`.) `ProgressBar`'s outer `<div>` renders no
slot at all, so it carries `data-component="progress-bar"` with no
`data-part`.

Both attributes are written **before** `...attributes` in every component's
template, so a value you pass through `...attributes` always wins. This is
how, for example, `Tooltip` — which renders no element of its own, only
`Overlay`'s portaled `<div>` — sets `data-component="tooltip"` on markup that
`Overlay` itself already stamps with `data-component="overlay"`.

A nested component's root legitimately carries **both** its own
`data-component` and a `data-part` belonging to its parent. `CloseButton`
rendered inside `Alert`, for instance, is simultaneously
`data-component="close-button"` (its own root) and `data-part="close-button"`
(the part it fills in `Alert`'s anatomy).

Two components can also render the same `data-component` value: `TabNav` is a
second renderer of the `tabs` config, alongside `Tabs` itself.

### Selecting by anatomy

Scope a selector to one component's own parts with:

```css
[data-component="modal"] [data-part="header"] {
  /* ... */
}
```

### Known limitation: a nested component can share a part name

`[data-component="x"] [data-part="y"]` is a plain CSS descendant combinator —
it matches **any** descendant, not just `y` parts that belong directly to
`x`. That's ambiguous whenever a nested component happens to have a part
with the same name. `Alert` renders a `CloseButton`, and `CloseButton` has
its own `icon` part (its SVG); `Alert` also has its own `icon` part (the
alert's leading icon). `[data-component="alert"] [data-part="icon"]` matches
both — the alert's own icon *and* the close button's icon glyph, because the
close button is a descendant of the alert's root.

The precise meaning consumers usually want is "the nearest `[data-component]`
ancestor of this part is `x`" — ownership by the closest component boundary,
not by any ancestor. CSS has no "nearest enclosing" combinator, so this
cannot be expressed as a selector at all; a descendant combinator is the best
CSS can do, and it is not equivalent.

Frontile's own tests resolve this with the `ownParts(root, part)` helper
exported from `frontile/test-support`:

```ts
import { ownParts } from 'frontile/test-support';

// Only Alert's own `icon` part, not CloseButton's.
const icons = ownParts(alertRootElement, 'icon');
```

It walks up from each candidate element's **parent** (not the element
itself — `closest()` would match a nested component's own root against
itself before ever reaching `root`, wrongly excluding a part that legitimately
belongs to `root`) until it either reaches `root` (a true match) or hits
another `[data-component]` ancestor first (owned by that nested component
instead, so excluded). See `packages/frontile/src/test-support.ts` for the
full implementation and reasoning.

`Table`'s composition of `SimpleTable` has the same shape from the other
direction: `SimpleTable` accepts an internal `@isRoot` flag so that when
`Table` composes it, only `Table`'s own outer wrapper carries
`data-component="table"` — `SimpleTable`'s `<table>` renders `data-part="table"`
but no `data-component` of its own, avoiding two nested `data-component="table"`
elements for what is, from the outside, one `Table` instance.

### Not `data-slot`

If you're coming from shadcn/ui, Nuxt UI, or HeroUI, you'll recognize the
shape of this convention but not the attribute name — those use `data-slot`.
Frontile uses `data-part` deliberately: `::part()` is the web platform's own
word for a styleable piece of a component (see the CSS Shadow Parts spec),
and "slot" already means something different in Ember — a named block
(`{{yield to="title"}}`), not a DOM anatomy hook. Reusing "slot" for both
would collide two unrelated concepts in the same codebase.

### Enforcement

Two mechanisms keep the anatomy honest as components change:

- `pnpm lint:hbs` runs two `ember-template-lint` rules —
  `frontile/require-data-part` (every element rendering a slot carries the
  matching `data-part`) and `frontile/require-root-data-component` (every
  component's outermost element carries `data-component`).
- `pnpm lint:anatomy` runs `scripts/check-anatomy.mjs`, a cross-file check
  that every slot a `tv()` config declares is actually rendered as a
  `data-part` somewhere, and every `data-part` rendered actually names a
  real slot.

`@frontile/forms-legacy` is excluded from both — it is deprecated and not
part of this anatomy migration.

## Customizing Styles

### Setting Up Global Customization

To apply global styles to your Frontile components, it's recommended to create a separate file for your theme settings. You can create a file named `app/theme.js` to register your global custom styles, and then import it in `app/app.js` to ensure the styles are applied across your application.

#### Example: Setting Up Global Styles

1. **Create a Theme File**: Create a new file called `app/theme.js` and add your global customizations.

   ```javascript
   // app/theme.js
   import { useStyles, registerCustomStyles, tv } from '@frontile/theme';

   const components = useStyles();

   registerCustomStyles({
     // stuff ...
   });
   ```

2. **Import the Theme File**: Import the theme file in `app/app.js` to ensure the global styles are applied.

   ```javascript
   // app/app.js
   import Application from '@ember/application';
   // stuff...
   import './theme'; // Import your theme file here

   export default class App extends Application {
     // stuff...
   }

   loadInitializers(App, config.modulePrefix);
   ```

### Global Customization with `registerCustomStyles`

The `registerCustomStyles` function allows you to override the default styles of Frontile components globally. This means that every instance of a specific component throughout your application will inherit the styles defined in `registerCustomStyles`.

#### Example: Global Customization

To globally change the styles of the Drawer, Modal, and Button components:

```javascript
import { useStyles, registerCustomStyles, tv } from '@frontile/theme';

const components = useStyles();

registerCustomStyles({
  modal: tv({
    extend: components.modal,
    slots: {
      header: 'font-header text-2xl pt-12 pl-6 pb-6',
      body: 'pt-4 pb-4 pl-6 pr-12',
      footer: 'bg-transparent py-4 px-12 pb-8'
    },
    variants: {
      size: {
        lg: 'max-w-[48rem]',
        xl: 'max-w-[64rem]'
      }
    }
  }),
  drawer: tv({
    extend: components.drawer,
    slots: {
      header: 'text-2xl px-4 py-6 bg-black text-white rounded-none',
      footer: 'px-4 py-6'
    },
    variants: {
      size: {
        lg: 'max-w-[48rem]',
        xl: 'max-w-[64rem]'
      }
    }
  }),
  button: tv({
    ...components.button,
    base: ['font-header text-xl'],
    variants: {
      ...components.button.variants,
      appearance: {
        ...components.button.variants.appearance,
        default: 'shadow-depth-2'
      }
    },
    compoundVariants: [
      ...components.button.compoundVariants,
      {
        appearance: 'default',
        intent: 'default',
        class: 'bg-black text-white hover:bg-black/80'
      }
    ]
  })
});
```

In this example:

- The `modal` component is customized globally, including changes to the header, body, and footer slots, and additional size variants.
- The `drawer` component is updated with new styles for the header and footer slots, as well as size variants.
- The `button` component's base styles and compound variants are customized, adding new default appearances.

Use global customization when you want consistency across your entire application for a particular component.

### Local Customization with Component Arguments

If you only need to customize the styles of a specific component instance, it is recommended to use arguments like `class` or `classes`, depending on the component. Frontile leverages Tailwind Variants with `tw-merge` to allow the merging of Tailwind classes, meaning any class passed locally will effectively overwrite the default styles.

#### Example: Local Customization with Drawer Component

```hbs
<Drawer
  @isOpen={{true}}
  @classes={{hash
    header='bg-neutral-strong text-on-neutral-strong'
    body='bg-neutral-subtle'
    footer='bg-neutral-strong text-on-neutral-strong'
  }}
>
  <!-- Drawer content here -->
</Drawer>
```

In this example, the `Drawer` component is provided with specific styles for the `header`, `body`, and `footer` slots. The `header` and `footer` have a dark background (`bg-neutral-strong`) with automatically contrasting text (`text-on-neutral-strong`), while the `body` has a light background (`bg-neutral-subtle`). This approach allows for context-specific customizations without impacting other instances of the Drawer component.
