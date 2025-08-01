---
imports:
  - import Signature from 'site/components/signature';
---
# Button

The Button component can be used to trigger an action, such as submitting a form, opening a modal, and more.

## Import 

```js
import { Button } from '@frontile/buttons';
```

## Usage

```gjs preview
import { Button } from '@frontile/buttons';

<template>
  <Button>Button</Button>
</template>
```

## Button Appearances

```gjs preview
import { Button } from '@frontile/buttons';

<template>
  <div>
    <Button>Default</Button>
    <Button @appearance='outlined'>Outlined</Button>
    <Button @appearance='minimal'>Minimal</Button>
    <Button @appearance='custom'>Custom</Button>
  </div>
  <div class='mt-4'>
    <Button disabled>Default</Button>
    <Button @appearance='outlined' disabled>Outlined</Button>
    <Button @appearance='minimal' disabled>Minimal</Button>
    <Button @appearance='custom' disabled>Custom</Button>
  </div>
</template>
```

The `custom` appearance is available for the cases where you might want to fully customize the appearance of the button.
The default styles are mainly structural. Intent colors are applied as `color`.

## Button Intents

```gjs preview
import { Button } from '@frontile/buttons';

<template>
  <div>
    <Button @intent='primary'>Button</Button>
    <Button @intent='success'>Button</Button>
    <Button @intent='warning'>Button</Button>
    <Button @intent='danger'>Button</Button>
  </div>
  <div class='mt-4'>
    <Button @intent='primary' disabled>Button</Button>
    <Button @intent='success' disabled>Button</Button>
    <Button @intent='warning' disabled>Button</Button>
    <Button @intent='danger' disabled>Button</Button>
  </div>
</template>
```

## Button Sizes

```gjs preview
import { Button } from '@frontile/buttons';

<template>
  <Button @size='xs'>Button</Button>
  <Button @size='sm'>Button</Button>
  <Button>Button</Button>
  <Button @size='lg'>Button</Button>
  <Button @size='xl'>Button</Button>
</template>
```

## Renderless Button

Sometimes a button element is not ideal for a given case, but the same styles are still desired.
Frontile provides the option to disable rendering the `button` element, but instead it yields back an object with
the class names it would use.

```gjs preview
import { Button } from '@frontile/buttons';

<template>
  <Button @isRenderless={{true}} as |btn|>
    <a href='javascript:void(0)' class={{btn.classNames}}>My Link</a>
  </Button>
</template>
```

## Composition

You can compose appearance with intents and more to create the button that best fits your needs.

```gjs preview
import { Button } from '@frontile/buttons';

<template>
  <Button @appearance='outlined' @intent='primary'>Button</Button>
  <Button @appearance='minimal' @intent='warning'>Button</Button>
  <Button @size='xs' @intent='danger'>Button</Button>
</template>
```

You can also use TailwindCSS classes to customize even further.

```gjs preview
import { Button } from '@frontile/buttons';

<template>
  <Button @appearance='outlined' @intent='primary' @class='px-20 py-2 italic'>
    Button
  </Button>
</template>
```

Here is another example using TailwindCSS classes with the `custom` appearance.

```gjs preview
import { Button } from '@frontile/buttons';

<template>
  <Button
    @appearance='custom'
    class='bg-teal-100 hover:bg-teal-200 hover:text-teal-600 border-teal-600 rounded-none border-dashed'
  >
    Button
  </Button>
</template>
```

Note that here we used the HTML attribute `class`, instead of the argument `@class`.
Using the class attribute will just append the class names passed in, while the
argument `@class` will override and merge TailwindCSS class names.

## Press Interactions

The Button component supports press interactions through the `@onPress` callback, which provides cross-platform support for mouse, touch, and keyboard events.

```gjs preview
import { Button } from '@frontile/buttons';
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';

export default class ButtonPressExample extends Component {
  @tracked pressCount = 0;

  handlePress = () => {
    this.pressCount++;
  };

  <template>
    <div class="flex items-center space-x-4">
      <Button @onPress={{this.handlePress}}>
        Press me! ({{this.pressCount}})
      </Button>
      <p>Button has been pressed {{this.pressCount}} times</p>
    </div>
  </template>
}
```

### Press State

Buttons automatically track their pressed state and add a `data-pressed` attribute when being pressed, which can be used for styling:

```css
button[data-pressed="true"] {
  transform: scale(0.95);
  transition: transform 0.1s ease;
}
```

### Keyboard Accessibility

The press interaction automatically handles keyboard accessibility, responding to both Enter and Space key presses, making your buttons fully accessible to keyboard and screen reader users.

## API

<Signature @package="buttons" @component="Button" />
