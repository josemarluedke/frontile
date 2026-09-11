---
title: Focus management
order: 2
category: accessibility
---

# Focus management

Focus indicators (typically an outline around a focused element) are essential for accessibility. They help keyboard users navigate and identify which element currently has focus, allowing users to interact with elements by pressing `Enter` instead of using a mouse.

While focus indicators are critical for keyboard navigation, they can feel unnecessary when using a mouse. Frontile solves this with smart focus management.

## How it works

Frontile includes a [library](https://github.com/WICG/focus-visible) based on the proposed CSS `:focus-visible` pseudo-selector. It adds a `focus-visible` class to focused elements **only when keyboard navigation is detected** (`Tab`, `Shift + Tab`, or arrow keys).

When the mouse is used to focus an element, the class is not added—except for text inputs and textareas, where focus indicators are always helpful.

## Example

Try focusing these elements with both keyboard (`Tab` key) and mouse to see the difference:

```gts preview
import { Button, Input } from 'frontile';

<template>
  <div class='space-y-4'>
    <Input placeholder='Focus me with Tab or mouse' />

    <Button @intent='primary'>
      Focus me with Tab or mouse
    </Button>
  </div>
</template>
```

Notice how the keyboard focus is clearly visible with `Tab`, but clicking with the mouse doesn't show the focus ring on the button.

## Focus lifecycle in overlays

Modal, Drawer, Popover, and Dropdown are all built on the shared `Overlay` primitive, which
manages focus around opening and closing:

- **On open**, focus moves into the overlay's content. By default the focus trap is active,
  and moving focus into the content is handled by the focus-trap library itself as part of
  activating the trap. If `@disableFocusTrap={{true}}` is passed, the trap doesn't run at
  all — in that case Overlay focuses the content itself instead, unless
  `@preventAutoFocus={{true}}` is also passed. (`@preventAutoFocus` only has an effect when
  the trap is disabled; it does nothing when the trap is active.)
- **While open**, a focus trap keeps Tab and Shift+Tab cycling within the overlay's content,
  so keyboard users can't tab out to the page behind it. This is configurable via
  `@focusTrapOptions` and can be turned off entirely with `@disableFocusTrap={{true}}`.
- **On close**, focus returns to whatever element had focus before the overlay opened —
  typically the button that triggered it — unless `@preventFocusRestore={{true}}` is passed.
- On `Modal` and `Drawer`, `aria-modal="true"` tracks whether the trap is actually active, so
  assistive technology isn't told the page is modal when the trap has been disabled.

## Used by

- [Overlay](../../packages/frontile/src/components/overlays/overlay.md)
- [Modal](../../packages/frontile/src/components/overlays/modal.md)
- [Drawer](../../packages/frontile/src/components/overlays/drawer.md)
- [Popover](../../packages/frontile/src/components/overlays/popover.md)
- [Dropdown](../../packages/frontile/src/components/collections/dropdown.md)
