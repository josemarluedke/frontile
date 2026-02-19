---
imports:
  - import Signature from 'site/components/signature';
---

# Button

The Button component can be used to trigger an action, such as submitting a form, opening a modal, and more.

## Import

```js
import { Button } from 'frontile';
```

## Usage

```gjs preview
import { Button } from 'frontile';

<template>
  <Button>Button</Button>
</template>
```

## Button Appearances

```gjs preview
import { Button } from 'frontile';

<template>
  <div>
    <Button>Default</Button>
    <Button @appearance='outlined'>Outlined</Button>
    <Button @appearance='tonal'>Tonal</Button>
    <Button @appearance='minimal'>Minimal</Button>
    <Button @appearance='custom'>Custom</Button>
  </div>
</template>
```

The `custom` appearance is available for the cases where you might want to fully customize the appearance of the button.
The default styles are mainly structural. Intent colors are applied as `color`.

## Button Intents

```gjs preview
import { Button } from 'frontile';

<template>
  <div>
    <Button @intent='default'>Default</Button>
    <Button @intent='primary'>Primary</Button>
    <Button @intent='accent'>Accent</Button>
    <Button @intent='success'>Success</Button>
    <Button @intent='warning'>Warning</Button>
    <Button @intent='danger'>Danger</Button>
  </div>
  <div class='mt-4'>
    <Button @appearance='outlined' @intent='default'>Default</Button>
    <Button @appearance='outlined' @intent='primary'>Primary</Button>
    <Button @appearance='outlined' @intent='accent'>Accent</Button>
    <Button @appearance='outlined' @intent='success'>Success</Button>
    <Button @appearance='outlined' @intent='warning'>Warning</Button>
    <Button @appearance='outlined' @intent='danger'>Danger</Button>
  </div>
  <div class='mt-4'>
    <Button @appearance='minimal' @intent='default'>Default</Button>
    <Button @appearance='minimal' @intent='primary'>Primary</Button>
    <Button @appearance='minimal' @intent='accent'>Accent</Button>
    <Button @appearance='minimal' @intent='success'>Success</Button>
    <Button @appearance='minimal' @intent='warning'>Warning</Button>
    <Button @appearance='minimal' @intent='danger'>Danger</Button>
  </div>
  <div class='mt-4'>
    <Button @appearance='tonal' @intent='default'>Default</Button>
    <Button @appearance='tonal' @intent='primary'>Primary</Button>
    <Button @appearance='tonal' @intent='accent'>Accent</Button>
    <Button @appearance='tonal' @intent='success'>Success</Button>
    <Button @appearance='tonal' @intent='warning'>Warning</Button>
    <Button @appearance='tonal' @intent='danger'>Danger</Button>
  </div>
</template>
```

## Button Sizes

```gjs preview
import { Button } from 'frontile';

<template>
  <Button @size='xs'>Button</Button>
  <Button @size='sm'>Button</Button>
  <Button>Button</Button>
  <Button @size='lg'>Button</Button>
  <Button @size='xl'>Button</Button>
</template>
```

## Disabled

```gjs preview
import { Button } from 'frontile';

<template>
  <div>
    <Button @intent='default' disabled>Default</Button>
    <Button @intent='primary' disabled>Primary</Button>
    <Button @intent='accent' disabled>Accent</Button>
    <Button @intent='success' disabled>Success</Button>
    <Button @intent='warning' disabled>Warning</Button>
    <Button @intent='danger' disabled>Danger</Button>
  </div>
</template>
```

## Renderless Button

Sometimes a button element is not ideal for a given case, but the same styles are still desired.
Frontile provides the option to disable rendering the `button` element, but instead it yields back an object with
the class names it would use.

```gjs preview
import { Button } from 'frontile';

<template>
  <Button @isRenderless={{true}} as |btn|>
    <a href='javascript:void(0)' class={{btn.classNames}}>My Link</a>
  </Button>
</template>
```

## Composition

You can compose appearance with intents and more to create the button that best fits your needs.

```gjs preview
import { Button } from 'frontile';

<template>
  <Button @appearance='outlined' @intent='primary'>Button</Button>
  <Button @appearance='minimal' @intent='warning'>Button</Button>
  <Button @size='xs' @intent='danger'>Button</Button>
</template>
```

## Customization

You can use TailwindCSS classes to customize even further.

```gjs preview
import { Button } from 'frontile';

<template>
  <Button @appearance='outlined' @intent='primary' @class='px-20 py-2 italic'>
    Button
  </Button>
</template>
```

Here is another example using TailwindCSS classes with the `custom` appearance.

```gjs preview
import { Button } from 'frontile';

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
import { Button } from 'frontile';
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';

export default class ButtonPressExample extends Component {
  @tracked pressCount = 0;

  handlePress = () => {
    this.pressCount++;
  };

  <template>
    <div class='flex items-center space-x-4'>
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
button[data-pressed='true'] {
  transform: scale(0.95);
  transition: transform 0.1s ease;
}
```

### Keyboard Accessibility

The press interaction automatically handles keyboard accessibility, responding to both Enter and Space key presses, making your buttons fully accessible to keyboard and screen reader users.

## API

<Signature @package="buttons" @component="Button" />
