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

The root element's part is usually `base`, but not always — it carries
whichever slot it actually renders. `Table`'s root is its wrapper `<div>`, so
that element is `data-part="wrapper"`; `SimpleTable` used on its own roots on
the `<table>` element, so that one is `data-part="table"`. `ProgressBar`'s
outer `<div>` renders no slot at all, so it has `data-component="progress-bar"`
and no `data-part`. Check the component's page if you need the exact shape.

Both attributes can be overridden: a `data-component` or `data-part` you pass
to a component wins over the one it would render itself.

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

What you usually mean is "the parts whose nearest `[data-component]` ancestor
is `x`". CSS has no "nearest enclosing" combinator, so in a stylesheet you
narrow the selector yourself, using child combinators down the path you want:

```css
/* The alert's own icon. The close button's icon is nested one level
   deeper, inside the close button, so it doesn't match. */
[data-component="alert"] > [data-part="inner"] > [data-part="icon"] {
  /* ... */
}
```

In tests, use the `ownParts(root, part)` helper from `frontile/test-support`,
which returns only the parts belonging to `root` itself:

```ts
import { ownParts } from 'frontile/test-support';

// Only Alert's own `icon` part, not CloseButton's.
const icons = ownParts(alertRootElement, 'icon');
```

### Not `data-slot`

If you're coming from shadcn/ui, Nuxt UI, or HeroUI, this convention will look
familiar but the attribute name differs — those use `data-slot`, Frontile uses
`data-part`. In Ember, "slot" already means a named block (`{{yield to="title"}}`),
which is a different thing from a styleable piece of the DOM.

`@frontile/forms-legacy` predates this convention and does not carry these
attributes.

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
      header: 'text-2xl px-4 py-6 bg-black text-white dark:bg-white dark:text-black rounded-none',
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
        default: 'shadow-elevation-2'
      }
    },
    compoundVariants: [
      ...components.button.compoundVariants,
      {
        appearance: 'default',
        intent: 'default',
        class: 'bg-black text-white hover:bg-black/80 dark:bg-white dark:text-black dark:hover:bg-white/80'
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
