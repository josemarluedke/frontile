---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Portal & PortalTarget

The `Portal` and `PortalTarget` components are designed to make it easy to render content into a different part of the DOM. This is useful for scenarios such as rendering modals, popovers, or other UI elements that should not be restricted by parent container overflow or need to be placed in a specific area of the page for accessibility or UX considerations.

## Import

```js
import { Portal, PortalTarget } from 'frontile';
```

## Server-Side Rendering Support

The `Portal` and `PortalTarget` components are fully compatible with server-side rendering (SSR). This ensures that your content is properly rendered and accessible, even when the application is being served from the server, making these components suitable for SEO and initial page load performance considerations.

## Usage

### Basic Example

The `Portal` component renders its content to a specified target or, by default, to the closest available target. You can use it to decouple your UI elements from their usual place in the DOM.

```gjs
import { Portal, PortalTarget } from 'frontile';

<template>
  <Portal>
    <div class='p-4 border rounded shadow-md'>
      This content is rendered in a portal.
    </div>
  </Portal>
</template>
```

### Nesting Portals

You can also nest `Portal` components within each other. The inner `Portal` elements can append to the parent portal if configured that way.

```gjs preview
import { Portal, PortalTarget } from 'frontile';

<template>
  <div class='h-40 relative w-32'>
    <PortalTarget />
  </div>

  <Portal
    class='absolute w-content bg-default/50 left-0 p-4 border border-default rounded'
  >
    First portal (Outer)
    <Portal
      class='absolute w-content bg-primary/50 border border-primary left-12 rounded'
    >
      Second portal (Inner)
      <Portal
        class='absolute w-content bg-danger/50 border border-danger left-16 rounded'
      >
        Last portal (Inner 2)
      </Portal>
    </Portal>
  </Portal>
</template>
```

In this example, the inner `Portal` renders its content inside the destination of the outer `Portal`.

### Using `PortalTarget`

The `PortalTarget` component is used to create named or unnamed locations where content can be rendered using the `Portal` component. This allows for more control over where a portal's content is displayed.

```gjs preview
import { Portal, PortalTarget } from 'frontile';

<template>
  <div class='flex flex-col space-y-4'>
    <PortalTarget />
    <PortalTarget @for='target-1' />

    <Portal @target='target-1'>
      <div class='p-4 border rounded shadow-md'>
        Rendered to target-1
      </div>
    </Portal>
  </div>
</template>
```

In this example, the portal content is directed to the named target, `target-1`, ensuring it is rendered in the appropriate place within the DOM.

## Controlling Where Content Renders

The `Portal` component has a `target` argument that allows you to specify where the content should be rendered. This can be:

- A DOM `Element` directly.
- An ID prefixed with `#` to target a specific element by its ID.
- A target name to match a `PortalTarget` with the `@for` argument.

### Rendering Inline

If you set the `@renderInPlace` argument to `true`, the content will be rendered inline without creating a new portal.

```gjs preview
import { Portal, PortalTarget } from 'frontile';

<template>
  <div class='p-4 border rounded'>
    <Portal @renderInPlace={{true}}>
      This content is rendered inline instead of a portal.
    </Portal>
  </div>
</template>
```

### Rendering Inside a Specific DOM Element

You can use a target element directly by passing its ID or a reference to the `@target` argument.

```gjs preview
import { Portal, PortalTarget } from 'frontile';

<template>
  <div id='target' class='border p-4'>
    Target Element
  </div>
  <Portal @target='#target'>
    <div class='p-4 border rounded shadow-md'>
      Rendered inside target element.
    </div>
  </Portal>
</template>
```

In this example, the portal content is rendered inside the element with the ID `target`.

## Append to Parent Portal

By default, `Portal` components append their content to the parent portal if one exists. This behavior can be disabled by setting the `@appendToParentPortal` argument to `false`.

```gjs preview
import { Portal, PortalTarget } from 'frontile';

<template>
  <PortalTarget />

  <Portal>
    Outer portal content
    <Portal @appendToParentPortal={{false}}>
      This content is rendered separately, not appended to the parent portal.
    </Portal>
  </Portal>
</template>
```

In this example, the inner `Portal` will not append its content to the parent portal, resulting in the content being rendered at a different level.

## Accessibility and Considerations

- Ensure that portal content, especially dynamic elements like modals and popovers, has a clear focus and can be accessed by keyboard navigation.
- Portals are useful when elements should escape any parent `overflow: hidden` constraints.

The `Portal` and `PortalTarget` components provide a robust way to manage dynamic content placement within your Ember.js applications, making them a powerful tool for managing modals, popovers, tooltips, and more.

## API

<Signature @package="overlays" @component="PortalTarget" />
<Signature @package="overlays" @component="Portal" />
