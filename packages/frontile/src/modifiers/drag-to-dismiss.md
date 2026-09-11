---
label: New
---

# dragToDismiss

A modifier that turns pointer drags into a dismiss gesture along a single
axis. It tracks a pointer from `pointerdown` through `pointermove` to
`pointerup`, translates the element with the drag in real time, rubber-bands
movement away from the dismiss direction, and calls `onDismiss` when the
gesture clears either a distance or a velocity threshold. It has no knowledge
of any particular component — it only needs an axis, a direction, and a
callback — so it can drive a drawer, a sheet, a toast, or any other
draggable-to-dismiss surface.

## Import

```js
import { dragToDismiss } from 'frontile';
```

## Usage

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { dragToDismiss, Button } from 'frontile';

export default class DragToDismissExample extends Component {
  @tracked isOpen = true;

  open = () => {
    this.isOpen = true;
  };

  close = () => {
    this.isOpen = false;
  };

  <template>
    <Button @intent='primary' @onPress={{this.open}}>Open panel</Button>

    {{#if this.isOpen}}
      <div
        data-test-id='panel'
        class='mt-4 w-64 rounded border border-neutral-subtle bg-surface-card p-4'
        {{dragToDismiss
          axis='y'
          direction=1
          isEnabled=true
          onDismiss=this.close
          handleSelector="[data-test-id='panel-handle']"
        }}
      >
        <div
          data-test-id='panel-handle'
          class='mx-auto mb-3 h-1.5 w-10 rounded-full bg-neutral-muted'
        ></div>
        <p class='mb-3'>Drag me down to dismiss.</p>
        <Button @size='sm' @onPress={{this.close}}>Close panel</Button>
      </div>
    {{/if}}
  </template>
}
```

## Usage Notes

- **Commit thresholds**: a drag dismisses when either the displacement
  exceeds **25%** of the element's size along `axis`, or the velocity over the
  trailing **100ms** exceeds **0.4 px/ms**. Either alone is enough.
- **Animation**: a drag that does not commit springs back over **200ms** with
  `cubic-bezier(0.37, 0, 0.63, 1)`. One that commits carries on from where it
  was released to fully off-screen, over the same duration and easing.
  `onDismiss` fires when that exit animation finishes, not when the pointer is
  released — so the element is still mounted for about 200ms after the
  gesture ends.
- **Rubber-banding**: movement away from the dismiss direction is damped by a
  factor of **0.2**.
- **Handles**: pass `handleSelector` to make a specific child always
  draggable. A press there starts the drag immediately. With neither
  `handleSelector` nor `scrollSelector` set, a press anywhere on the element
  starts a drag.
- **Dragging from a scroll container**: with `scrollSelector` set, a press
  outside the handle does not start a drag straight away. It starts once the
  pointer has travelled **10px**, and only if that travel was predominantly
  along `axis`, in the dismiss `direction`, and the nearest ancestor matching
  `scrollSelector` is already scrolled to the edge the drag pulls away from.
  Anything else scrolls natively. A drag is also refused for **150ms** after
  that container last scrolled, so a fling that comes to rest against the edge
  is not mistaken for a dismiss.
- **`touch-action`**: set it on the scroll container to the axis the browser
  should keep — `pan-y` for a vertical drawer. The default `auto` also arms
  gestures like pinch-zoom, which cancels pointer tracking more readily.
- **Reduced motion**: when the user prefers reduced motion the transitions are
  skipped and `onDismiss` fires immediately.

## Accessibility

`dragToDismiss` is a pointer enhancement; it adds no role, accessible name,
keyboard interaction, or focus management. Always provide a keyboard-operable
dismiss control that calls the same callback, as the demo does. When dismissal
removes the focused surface, move focus to the control that opened it or another
logical destination.

The drag handle is only a visual affordance unless you make it an interactive
control yourself. Do not rely on gesture instructions alone, and keep the
non-gesture dismissal available when `@isEnabled` is false. Reduced-motion
preferences skip the settle animation automatically.

## API

The `dragToDismiss` modifier accepts only named arguments:

| Name             | Type         | Description                                                                                                                                                |
| ---------------- | ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `axis`           | `'x' \| 'y'` | The axis the drag moves along.                                                                                                                             |
| `direction`      | `1 \| -1`    | Which way along the axis dismisses: `1` for down/right, `-1` for up/left.                                                                                  |
| `isEnabled`      | `boolean`    | Whether the modifier responds to pointer events at all.                                                                                                    |
| `onDismiss`      | `() => void` | Called once the gesture commits to a dismiss.                                                                                                              |
| `handleSelector` | `string`     | Optional CSS selector for an element that is always draggable (e.g. a drag handle).                                                                        |
| `scrollSelector` | `string`     | Optional CSS selector for a scrollable container inside the element that may start a drag once it's already scrolled to the edge the drag pulls away from. |
