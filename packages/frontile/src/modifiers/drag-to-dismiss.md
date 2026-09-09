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
    <button
      {{on 'click' this.open}}
      class='text-on-primary bg-primary p-2 rounded'
      type='button'
    >
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

| Name             | Type         | Description                                                                                                                                                |
| ---------------- | ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `axis`           | `'x' \| 'y'` | The axis the drag moves along.                                                                                                                             |
| `direction`      | `1 \| -1`    | Which way along the axis dismisses: `1` for down/right, `-1` for up/left.                                                                                  |
| `isEnabled`      | `boolean`    | Whether the modifier responds to pointer events at all.                                                                                                    |
| `onDismiss`      | `() => void` | Called once the gesture commits to a dismiss.                                                                                                              |
| `handleSelector` | `string`     | Optional CSS selector for an element that is always draggable (e.g. a drag handle).                                                                        |
| `scrollSelector` | `string`     | Optional CSS selector for a scrollable container inside the element that may start a drag once it's already scrolled to the edge the drag pulls away from. |

## Usage Notes

- **Commit thresholds**: a drag commits to dismiss when either the
  displacement exceeds **25%** of the element's size along `axis`, or the
  velocity over the trailing **100ms** exceeds **0.4 px/ms**. Either
  condition alone is enough.
- **Settle animation**: when a drag springs back (does not commit), the
  element's transform animates back to rest over **200ms** with
  `cubic-bezier(0.37, 0, 0.63, 1)` easing. When a drag commits, the element
  instead animates the rest of the way off-screen along the same axis (its
  own size in the dismiss direction), continuing from wherever the gesture
  was released, using the same duration and easing. `onDismiss` is
  deliberately deferred until that exit animation finishes — via
  `transitionend`, with a timeout fallback in case it never fires — rather
  than firing immediately. Because the element stays open (and mounted) for
  the whole animation, nothing re-renders or tears it down mid-flight, so the
  motion is continuous from wherever the user let go instead of visibly
  snapping back to rest before a separate close animation takes over.
- **Rubber-banding**: movement away from the dismiss direction is damped by a
  factor of **0.2**, so the element still visibly responds to the gesture
  without appearing to detach or leave its container.
- **Handles vs. free-drag**: without `handleSelector` or `scrollSelector`, the
  whole element starts a drag on `pointerdown`. Pass `handleSelector` to
  restrict dragging to a specific child (e.g. a grab handle) — a press there
  claims the drag immediately, since a handle is an explicit affordance with
  nothing else it could mean.
- **`scrollSelector` and native scrolling**: a press elsewhere does _not_
  claim the gesture on `pointerdown` when `scrollSelector` is configured —
  claiming immediately, and calling `preventDefault` on every subsequent
  move, is what used to break native scrolling: a scroll container whose
  content is no taller than itself (`scrollHeight === clientHeight`, the
  common "content fits" case) is _always_ at its scroll edge, so every touch
  on it would hijack the gesture and the user could never scroll. Instead the
  modifier waits, undecided, until the pointer has travelled past a small
  threshold (10px), then decides once and never re-evaluates: it claims the
  drag only if that travel was predominantly along `axis`, in the dismiss
  `direction`, _and_ the nearest ancestor matching `scrollSelector` (if any)
  is already scrolled to the edge the drag pulls away from. Otherwise it
  abandons the gesture permanently — no `preventDefault`, ever, for the rest
  of that pointer's gesture — and native scrolling proceeds untouched. A
  press outside any `scrollSelector` element entirely (e.g. a header) has no
  native scroll to protect, so it only needs the direction/threshold check.
  `pointercancel` on a gesture still in this undecided state (e.g. the
  browser taking over to scroll) resets cleanly without dismissing. A
  consumer whose scroll container scrolls along the same axis as the drag
  should also set `touch-action` on it (e.g. `pan-y` for a vertical drawer)
  so the browser is free to pan it natively once handed off, instead of the
  default `auto`, which can additionally recognize gestures like pinch-zoom
  and fire `pointercancel` more eagerly.
- **Reduced motion**: when the user prefers reduced motion, the settle and
  commit transitions are skipped rather than animated.
