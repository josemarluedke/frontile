---
order: 5
category: theme
---

# Customizing Component Styles

Frontile provides flexibility for customizing the styles of its components, allowing developers to create a cohesive design that aligns with your application's requirements. This guide details how to customize component styles using Tailwind Variants and discusses global versus local style overrides.

## Overview

Frontile uses [Tailwind Variants](https://www.tailwind-variants.org/) to manage and customize component styles. Tailwind Variants provide a structured way to define different visual representations (or variants) for components while keeping your styles consistent and maintainable.

A **slot** represents a specific part of a component that can be styled or customized separately. Slots allow you to apply different styles to different parts of a complex component, providing more granular control.

When customizing styles in Frontile, you can either apply styles globally using `registerCustomStyles` or customize individual components using class arguments. You can override default component styles by passing your own class names to the `class` or `classes` argument, depending on whether the component has slots.

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
    header='bg-neutral-strong text-neutral-subtle'
    body='bg-neutral-subtle'
    footer='bg-neutral-strong text-neutral-subtle'
  }}
>
  <!-- Drawer content here -->
</Drawer>
```

In this example, the `Drawer` component is provided with specific styles for the `header`, `body`, and `footer` slots. The `header` and `footer` have a dark background (`bg-neutral-strong`) and light text (`text-neutral-subtle`), while the `body` has a light background (`bg-neutral-subtle`). This approach allows for context-specific customizations without impacting other instances of the Drawer component.
