---
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
import { Input } from 'frontile';

<template>
  <div class='space-y-4'>
    <Input @placeholder='Focus me with Tab or mouse' />

    <a
      class='inline-block px-4 py-2 bg-brand-soft text-white rounded hover:bg-brand-medium focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-soft focus-visible:ring-offset-2'
      href='javascript:void(0)'
    >
      Focus me with Tab or mouse
    </a>
  </div>
</template>
```

Notice how the keyboard focus is clearly visible with `Tab`, but clicking with the mouse doesn't show the focus ring on the button.
