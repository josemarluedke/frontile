---
imports:
  - import Signature from 'site/components/signature';
---

# Portal & PortalTarget

`Portal` renders its content somewhere else in the DOM, and `PortalTarget` marks the places it can render to. Reach for them when content has to escape a parent's `overflow: hidden` or stacking context — modals, drawers, popovers, tooltips, toasts — or when it belongs in a specific region of the page for reading order or z-index reasons.

## Import

```js
import { Portal, PortalTarget } from 'frontile';
```

## Usage

With no arguments, `Portal` renders into the closest destination it can find, falling back to `document.body`.

```gts preview
import { Portal } from 'frontile';

<template>
  <Portal>
    <div class='p-4 border border-neutral-soft rounded shadow-md'>
      This content is rendered in a portal.
    </div>
  </Portal>
</template>
```

## PortalTarget

`PortalTarget` renders a `div` marked with `data-portal-target="true"` and, when `@for` is
given, `data-portal-for="<name>"`. It takes attributes and a block, so it can be positioned
and styled like any other element and can hold content of its own.

A target with no `@for` is **unnamed**: it is the default destination for any `Portal`
rendered below it that has no `@target` of its own. A target with `@for` is only used by
portals that ask for it by name, so it never captures unrelated content.

```gts preview
import { Portal, PortalTarget } from 'frontile';

<template>
  <div class='flex flex-col space-y-4'>
    <PortalTarget />
    <PortalTarget @for='target-1' />

    <Portal @target='target-1'>
      <div class='p-4 border border-neutral-soft rounded shadow-md'>
        Rendered to target-1
      </div>
    </Portal>
  </div>
</template>
```

### Named targets as slots

Because named targets are opt-in, several can coexist and each `Portal` picks one by name.
The target's own block content stays put; portal content is appended after it.

```gts preview
import { Button, Portal, PortalTarget } from 'frontile';

<template>
  <div class='flex gap-4'>
    <PortalTarget
      @for='toolbar'
      class='flex-1 flex items-center gap-2 p-3 border border-neutral-soft rounded'
    >
      <span class='text-neutral-strong'>Toolbar</span>
    </PortalTarget>

    <PortalTarget
      @for='footer'
      class='flex-1 flex items-center gap-2 p-3 border border-neutral-soft rounded'
    >
      <span class='text-neutral-strong'>Footer</span>
    </PortalTarget>

    <Portal @target='toolbar'>
      <Button @size='sm'>Save changes</Button>
    </Portal>

    <Portal @target='footer'>
      <Button @size='sm' @appearance='outlined'>Cancel</Button>
    </Portal>
  </div>
</template>
```

### An application-level target

Without a target, overlays land in `document.body`, outside the element your app styles and
outside its stacking context. Rendering one unnamed `PortalTarget` near the end of the
application template gives every overlay a predictable home you control — this documentation
site does exactly that:

```gts
import { PortalTarget } from 'frontile';

<template>
  {{outlet}}

  <PortalTarget class='relative z-20' />
</template>
```

### How a destination is chosen

`Portal` resolves its destination in this order:

1. `@renderInPlace={{true}}` — no portal at all, the content stays where it is written.
2. `@target` as an `Element` — that element.
3. `@target` as a string beginning with `#` — the element with that id. Any id HTML allows
   works, including ones that are not valid CSS identifiers (`#1foo`, `#my.target`).
4. `@target` as any other string — the nearest `PortalTarget` with a matching `@for`. The
   name is compared literally, so it too may contain characters a selector would choke on.
5. Otherwise, the nearest parent portal, unless `@appendToParentPortal={{false}}`.
6. Otherwise, the nearest **unnamed** `PortalTarget`.
7. Otherwise, `document.body`.

When the destination ends up being plain `document.body`, `Portal` wraps its content in a
`PortalTarget` for you, so portals nested inside it still have somewhere to go.

## Nesting Portals

Portals nest: an inner `Portal` renders into the destination of the outer one.

```gts preview
import { Portal, PortalTarget } from 'frontile';

<template>
  <div class='h-40 relative w-32'>
    <PortalTarget />
  </div>

  <Portal
    class='absolute w-content bg-neutral/50 left-0 p-4 border border-neutral-soft rounded'
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

## Rendering Inline

`@renderInPlace={{true}}` skips the portal entirely and renders the content where it is
written — useful for turning portalling off conditionally.

```gts preview
import { Portal } from 'frontile';

<template>
  <div class='p-4 border border-neutral-soft rounded'>
    <Portal @renderInPlace={{true}}>
      This content is rendered inline instead of a portal.
    </Portal>
  </div>
</template>
```

## Rendering Inside a Specific DOM Element

`@target` also accepts an element id prefixed with `#`, or an `Element` reference, for
destinations that are not `PortalTarget`s — a third-party container, for instance.

```gts preview
import { Portal } from 'frontile';

<template>
  <div id='target' class='border border-neutral-soft p-4'>
    Target Element
  </div>
  <Portal @target='#target'>
    <div class='p-4 border border-neutral-soft rounded shadow-md'>
      Rendered inside target element.
    </div>
  </Portal>
</template>
```

## Append to Parent Portal

By default a `Portal` appends to the parent portal when there is one. Set
`@appendToParentPortal={{false}}` to make it resolve a destination on its own instead, which
sends it to the nearest unnamed `PortalTarget`.

```gts preview
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

## Server-Side Rendering

Both components work under FastBoot. `Portal` resolves its destination from the owner's
document rather than the global `document`, so portalled content is present in the
server-rendered HTML.

## Accessibility

Neither component adds a role or any ARIA attribute — `PortalTarget` is a plain `div`, and
that is deliberate: the semantics belong to whatever you render inside it. What they do
change is DOM position, and that has consequences:

- **Reading and tab order follow the destination, not the source.** Content written next to a
  button but portalled to the end of the page is announced and reached there. Place your
  application-level `PortalTarget` after the main content so overlay content comes last.
- **Focus management is not handled here.** `Portal` does not move, trap, or restore focus.
  For dialogs use `Modal`, `Drawer`, or `Overlay`, which handle focus, focus trapping, and
  the Escape key on top of `Portal`.
- **Keep the relationship explicit.** When portalled content describes a control that stays
  behind — a popover, a tooltip, an error message — wire it up with `aria-controls`,
  `aria-describedby`, or `aria-labelledby`, since proximity in the DOM no longer implies it.
- **Give a named target only one owner.** Two portals targeting the same name append in render
  order; for a slot that should hold one thing at a time, render one `Portal` at a time.

These notes come from reading `portal.gts` and `portal-target.gts` and the integration tests
in `test-app/tests/integration/components/overlays/`; the tests cover destination resolution,
not assistive-technology behavior.

## API

<Signature @component="PortalTarget" />
<Signature @component="Portal" />
