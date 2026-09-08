---
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
import { dragToDismiss } from 'frontile/modifiers/drag-to-dismiss';
```

## Example

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { dragToDismiss } from 'frontile/modifiers/drag-to-dismiss';

export default class DragToDismissExample extends Component {
  @tracked isOpen = true;

  open = () => {
    this.isOpen = true;
  };

  close = () => {
    this.isOpen = false;
  };

  <template>
    <button {{on "click" this.open}} class='text-on-primary bg-primary p-2 rounded' type='button'>
      Open panel
    </button>

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
        Drag me down to dismiss.
      </div>
    {{/if}}
  </template>
}
```

## API

The `dragToDismiss` modifier accepts only named arguments:

| Name             | Type          | Description                                                                                        |
| ---------------- | ------------- | --------------------------------------------------------------------------------------------------- |
| `axis`            | `'x' \| 'y'` | The axis the drag moves along.                                                                       |
| `direction`        | `1 \| -1`    | Which way along the axis dismisses: `1` for down/right, `-1` for up/left.                            |
| `isEnabled`        | `boolean`    | Whether the modifier responds to pointer events at all.                                              |
| `onDismiss`        | `() => void` | Called once the gesture commits to a dismiss.                                                        |
| `handleSelector`   | `string`     | Optional CSS selector for an element that is always draggable (e.g. a drag handle).                  |
| `scrollSelector`   | `string`     | Optional CSS selector for a scrollable container inside the element that may start a drag once it's already scrolled to the edge the drag pulls away from. |

## Usage Notes

- **Commit thresholds**: a drag commits to dismiss when either the
  displacement exceeds **25%** of the element's size along `axis`, or the
  velocity over the trailing **100ms** exceeds **0.4 px/ms**. Either
  condition alone is enough.
- **Settle animation**: whether the drag commits or springs back, the
  element's transform animates over **200ms** with
  `cubic-bezier(0.37, 0, 0.63, 1)` easing.
- **Rubber-banding**: movement away from the dismiss direction is damped by a
  factor of **0.2**, so the element still visibly responds to the gesture
  without appearing to detach or leave its container.
- **Handles vs. free-drag**: without `handleSelector` or `scrollSelector`, the
  whole element starts a drag on `pointerdown`. Pass `handleSelector` to
  restrict dragging to a specific child (e.g. a grab handle), and
  `scrollSelector` to let a drag also start from inside a scrollable region,
  but only once that region is already scrolled to the edge the gesture pulls
  away from — so a partially scrolled list still scrolls normally instead of
  dismissing.
- **Reduced motion**: when the user prefers reduced motion, the settle and
  commit transitions are skipped rather than animated.
