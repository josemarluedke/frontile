---
label: New
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
        class='text-success-foreground p-4 rounded'
      >
        Press me! ({{if this.isPressed 'pressed' 'not pressed'}})
      </button>
      <div
        class='w-48 h-48 overflow-auto mt-4 space-y-1 border border-default-200 rounded p-2'
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

| Name            | Type                           | Description                                                                                                     |
| --------------- | ------------------------------ | --------------------------------------------------------------------------------------------------------------- |
| `onPress`       | `(e: PressEvent) => void`      | Handler called when press is released over the target.                                                          |
| `onPressStart`  | `(e: PressEvent) => void`      | Handler called when a press interaction starts.                                                                 |
| `onPressEnd`    | `(e: PressEvent) => void`      | Handler called when a press interaction ends, either over the target or when the pointer leaves the target.     |
| `onPressUp`     | `(e: PressEvent) => void`      | Handler called when a press is released over the target, regardless of whether it started on the target or not. |
| `onPressChange` | `(isPressed: boolean) => void` | Handler called when the press state changes.                                                                    |

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
- **Performance**: Only adds event listeners for callbacks you provide
- **Accessibility**: Automatically handles Enter and Space key interactions
- **Cross-platform**: Supports mouse, touch, and keyboard across all browsers
