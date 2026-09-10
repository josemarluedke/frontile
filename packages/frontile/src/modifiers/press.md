---
---

# press

A modifier that handles press interactions across mouse, touch, keyboard, and screen readers. It normalizes press events across browsers and platforms, and handles many nuances of dealing with pointer and keyboard events.

## Import

```js
import { press } from 'frontile';
```

## Features

- **Cross-platform** - Handles mouse, touch, and keyboard interactions
- **Keyboard accessible** - Responds to Enter and Space key presses
- **Customizable** - Supports press start, press end, and press up events
- **Optimized** - Only adds event listeners for callbacks you provide
- **Flexible** - Supports both positional and named arguments

`press` listens on `pointerdown`/`mousedown`, `pointerup`/`mouseup`, `pointercancel`,
`keydown`, and `keyup`. It registers no `click` listener, so a native `element.click()` never
triggers `onPress`.

> **Note:** In tests, an assertion that `onPress` did not fire after `element.click()` passes
> against a broken implementation just as well as a working one. To check that a disabled
> control suppresses `onPress`, use the `click` helper from `@ember/test-helpers`, which
> refuses a disabled form control the way a browser does — `await assert.rejects(click(el),
> /disabled/)` — and then assert the press count. Driving `pointerdown`/`pointerup` through
> `triggerEvent` reports the opposite: `dispatchEvent` reaches listeners whatever the
> element's `disabled` state, so a correct implementation still fires.

## Example

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { press, type PressEvent } from 'frontile';

export default class PressExample extends Component {
  @tracked events = [];
  @tracked isPressed = false;

  handlePressStart = (e: PressEvent) => {
    this.events = [...this.events, `press start with ${e.pointerType}`];
  };

  handlePressEnd = (e: PressEvent) => {
    this.events = [...this.events, `press end with ${e.pointerType}`];
  };

  handlePress = (e: PressEvent) => {
    this.events = [...this.events, `press with ${e.pointerType}`];
  };

  handlePressChange = (isPressed) => {
    this.isPressed = isPressed;
  };

  <template>
    <div class='flex items-center space-x-2'>

      <button
        {{press
          onPressStart=this.handlePressStart
          onPressEnd=this.handlePressEnd
          onPress=this.handlePress
          onPressChange=this.handlePressChange
        }}
        class={{if this.isPressed 'bg-success' 'bg-success/70'}}
        class='text-on-success p-4 rounded'
      >
        Press me! ({{if this.isPressed 'pressed' 'not pressed'}})
      </button>
      <div
        class='w-48 h-48 overflow-auto mt-4 space-y-1 border border-neutral-subtle rounded p-2'
      >
        Output:
        <ul>
          {{#each this.events as |event index|}}
            <li class='text-sm'>{{event}}</li>
          {{/each}}
        </ul>
      </div>
    </div>
  </template>
}
```

## API

The press modifier accepts an optional positional `onPress` function and the following named options:

| Name            | Type                           | Description                                                                                                         |
| --------------- | ------------------------------ | ------------------------------------------------------------------------------------------------------------------- |
| `onPress`       | `(e: PressEvent) => void`      | Handler called when press is released over the target.                                                              |
| `onPressStart`  | `(e: PressEvent) => void`      | Handler called when a press interaction starts.                                                                     |
| `onPressEnd`    | `(e: PressEvent) => void`      | Handler called when a press interaction ends, either over the target or when the pointer leaves the target.         |
| `onPressUp`     | `(e: PressEvent) => void`      | Handler called when a press is released over the target. Not called when the release happens outside of the target. |
| `onPressChange` | `(isPressed: boolean) => void` | Handler called when the press state changes.                                                                        |

### PressEvent

Press events are normalized across different input methods and provide consistent information:

| Property                | Type                                                     | Description                                                  |
| ----------------------- | -------------------------------------------------------- | ------------------------------------------------------------ |
| `type`                  | `'pressstart' \| 'pressend' \| 'pressup' \| 'press'`     | The type of press event.                                     |
| `pointerType`           | `'mouse' \| 'pen' \| 'touch' \| 'keyboard' \| 'virtual'` | The pointer type that triggered the event.                   |
| `target`                | `Element`                                                | The target element of the press event.                       |
| `shiftKey`              | `boolean`                                                | Whether the shift key was held during the event.             |
| `ctrlKey`               | `boolean`                                                | Whether the ctrl key was held during the event.              |
| `metaKey`               | `boolean`                                                | Whether the meta key was held during the event.              |
| `altKey`                | `boolean`                                                | Whether the alt key was held during the event.               |
| `x`                     | `number`                                                 | The x position relative to the target element.               |
| `y`                     | `number`                                                 | The y position relative to the target element.               |
| `continuePropagation()` | `() => void`                                             | Allows the event to continue propagating to parent elements. |

## Usage Notes

- **Positional argument**: Pass `onPress` as the first argument: `{{press this.handlePress}}`
- **Mixed arguments**: Combine positional `onPress` with named arguments for other callbacks
- **Conflict handling**: Cannot provide both positional and named `onPress` (assertion error)
- **Performance**: Only adds the event listeners your callbacks require - a
  single callback can need more than one (e.g. `onPressChange` also needs
  `pointercancel`)
- **Accessibility**: Automatically handles Enter and Space key interactions. On a
  `<button type="button">` press also calls `preventDefault()`, which suppresses the
  browser's native activation click, so the element fires a single press per keypress
- **Cross-platform**: Supports mouse, touch, and keyboard across all browsers
- **Propagation**: By default a press stops propagation of the underlying
  event to parent elements. Call `continuePropagation()` on the `PressEvent` in
  any handler to let it through. Only events on the pressed element itself are
  stopped - a release that happens outside of the element is left untouched, so
  other listeners on the page (including document-level ones) still receive it.

> **Note:** `preventDefault()` on the keyboard event does not stop it propagating. An
> ancestor `keydown` handler that also treats Enter or Space as activation will act on the
> same keypress a second time — a calendar grid handling Enter to select the focused day
> selects twice once its day cells use `press`. Container-level key handlers above a
> press-bearing element should check `event.defaultPrevented` before acting.
