---
label: New
---

# ToggleState

The `toggleState` utility is a lightweight helper for managing boolean state in your components. It encapsulates a tracked property (`current`) and a `toggle` method that can be used to update the state. This utility supports:

- **Simple Toggling:** Calling `toggle()` without arguments simply inverts the current state.
- **Explicit State Setting:** You can pass a boolean to `toggle(true)` or `toggle(false)` to explicitly set the state.
- **Event Handling:** If an event (such as from a checkbox input) is passed, it will update the state based on the input’s `checked` property.
- **Callback Notification:** An optional callback can be provided to receive notifications whenever the state changes.

## Import

```js
import { toggleState } from '@frontile/utilities';
```

## Usage

### Creating a Toggle State

You can create a toggle state using the helper function:

```ts
import { toggleState } from '@frontile/utilities';

let state = toggleState(false, (val) => {
  console.log('State changed to:', val);
});
```

### Toggling the State

- Without arguments:

```ts
state.toggle(); // Flips the current state.
```

- With an explicit boolean value:

```ts
state.toggle(true); // Sets the state to true.
```

- With an event (e.g., from a checkbox):

```gts
// If used as an event handler, it reads the `checked` value:
<template><input type='checkbox' {{on 'change' state.toggle}} /></template>
```

### Example Component

Below is an example of a component that uses toggleState:

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { toggleState } from '@frontile/utilities';
import { Button } from '@frontile/buttons';
import { on } from '@ember/modifier';

export default class MyTestComponent extends Component {
  // Create a toggle state with an initial value of false.
  showingState = toggleState(false);

  // An explicit method to set the state to true.
  show = () => {
    this.showingState.toggle(true);
  };

  <template>
    <Button
      data-test-id='button-toggle'
      {{on 'click' this.showingState.toggle}}
    >
      Toggle
    </Button>

    <Button data-test-id='button-direct' {{on 'click' this.show}}>
      Show (explicit value)
    </Button>

    <input
      data-test-id='input-toggle'
      type='checkbox'
      checked={{this.showingState.current}}
      {{on 'change' this.showingState.toggle}}
    />

    {{#if this.showingState.current}}
      <div data-test-content>
        Hello World
      </div>
    {{/if}}
  </template>
}
```

### Using as a Template Helper

You can also use toggleState directly within your templates:

```gts preview
import { toggleState } from '@frontile/utilities';
import { Button } from '@frontile/buttons';
import { on } from '@ember/modifier';

<template>
  {{#let (toggleState) as |state|}}
    <Button data-test-id='button-toggle' {{on 'click' state.toggle}}>
      Toggle
    </Button>

    {{#if state.current}}
      <div data-test-content>
        Hello World
      </div>
    {{/if}}
  {{/let}}
</template>
```

### ToggleState with onChange Callback

Below is an example that demonstrates how to use `toggleState` with an `onChange` callback. The callback is invoked whenever the toggle state changes, allowing you to perform side effects such as logging or updating external state.

```gts preview
import Component from '@glimmer/component';
import { toggleState } from '@frontile/utilities';
import { Button } from '@frontile/buttons';
import { on } from '@ember/modifier';

export default class CallbackToggleExample extends Component {
  // Create a toggle state with an initial value of false and an onChange callback.
  toggle = toggleState(false, (newValue: boolean) => {
    console.log('Toggle state changed to:', newValue);
  });

  <template>
    {{#if this.toggle.current}}
      <div data-test-content>
        The toggle is ON
      </div>
    {{else}}
      <div data-test-content>
        The toggle is OFF
      </div>
    {{/if}}

    <Button data-test-id='button-toggle' {{on 'click' this.toggle.toggle}}>
      Toggle State
    </Button>
  </template>
}
```
