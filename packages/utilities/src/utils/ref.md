---
label: New
---

# ref

The `ref` utility offers a straightforward method to create a reference to a DOM element in your components. This is useful when you need direct access to an element for tasks like measuring dimensions, setting focus, or integrating with external libraries.

- **Element Reference:**
  Returns an object with a `setup` modifier that attaches the element to a tracked property in your component.

- **Reactive Tracking:**
  Changes to the element (e.g., mounting or unmounting) automatically trigger updates in your component.

- **Cleanup:**
  Automatically resets the element reference when the element is removed from the DOM.

- **Callback Notification:**
  If a callback function is provided, it is invoked every time the element changes, allowing you to perform additional operations (e.g., measuring the element's dimensions).

## Import

```js
import { ref } from 'frontile';
```

## Usage

### Basic

```gts preview
import Component from '@glimmer/component';
import { ref, toggleState } from 'frontile';
import { Button } from 'frontile';

export default class MyTestComponent extends Component {
  toggle = toggleState(true);

  // Create a ref to capture a reference to the DIV element.
  myRef = ref<HTMLDivElement>();

  <template>
    <Button @onPress={{this.toggle.toggle}}>
      Toggle
    </Button>

    {{#if this.toggle.current}}
      <div {{this.myRef.setup}}>
        Hello World
      </div>
    {{/if}}

    <div>
      Element TagName:
      {{this.myRef.current.tagName}}
    </div>
  </template>
}
```

### Using onChange to Measure Element Dimensions

In this example, a callback is provided to `ref` so that whenever the element is attached or removed, its width is measured and stored in a tracked property.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { ref } from 'frontile';

export default class ElementMeasureComponent extends Component {
  @tracked elementWidth = 0;

  // Create a ref with an onChange callback that updates the element's width.
  myRef = ref<HTMLDivElement>((el) => {
    if (el) {
      this.elementWidth = el.getBoundingClientRect().width;
    } else {
      this.elementWidth = 0;
    }
  });

  <template>
    <div {{this.myRef.setup}} class='bg-brand text-brand-contrast-1 w-48'>
      Measured Element
    </div>
    <p>
      Element Width:
      {{this.elementWidth}}px
    </p>
  </template>
}
```

This example is to just ilustrate the use of the `onChange`, but getting the element width
could be achieved using a getter property on the component as well.

### Using as a Template Helper

You can also use `ref` directly within your templates:

```gts preview
import { ref, toggleState } from 'frontile';
import { Button } from 'frontile';

<template>
  {{#let (ref) as |myRef|}}
    {{#let (toggleState true) as |toggle|}}
      <Button @onPress={{toggle.toggle}}>
        Toggle Visibility
      </Button>

      {{#if toggle.current}}
        <div {{myRef.setup}}>
          Content is visible
        </div>
      {{/if}}

      <div>
        Element TagName:
        {{myRef.current.tagName}}
      </div>
    {{/let}}
  {{/let}}
</template>
```
