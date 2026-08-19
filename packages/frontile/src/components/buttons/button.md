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
  <div class='flex flex-wrap items-center gap-3'>
    <Button>Default</Button>
    <Button @appearance='soft'>Soft</Button>
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

Every intent is available in every appearance. The label on each row is the
`@appearance` value; the button labels are the `@intent` values.

```gjs preview
import { Button } from 'frontile';
import { array } from '@ember/helper';

const intents = [
  'default',
  'primary',
  'secondary',
  'tertiary',
  'success',
  'warning',
  'danger'
];

<template>
  <div class='flex flex-col gap-6'>
    {{#each
      (array 'default' 'soft' 'outlined' 'tonal' 'minimal')
      as |appearance|
    }}
      <div>
        <p class='font-code text-code-sm text-neutral-strong mb-2'>
          @appearance='{{appearance}}'
        </p>
        <div class='flex flex-wrap items-center gap-3'>
          {{#each intents as |intent|}}
            <Button @appearance={{appearance}} @intent={{intent}}>
              {{intent}}
            </Button>
          {{/each}}
        </div>
      </div>
    {{/each}}
  </div>
</template>
```

## Button Sizes

```gjs preview
import { Button } from 'frontile';

<template>
  <div class='flex flex-wrap items-center gap-3'>
    <Button @size='xs'>Button xs</Button>
    <Button @size='sm'>Button sm</Button>
    <Button>Button md</Button>
    <Button @size='lg'>Button lg</Button>
    <Button @size='xl'>Button xl</Button>
    <Button @size='2xl'>Button 2xl</Button>
  </div>
</template>
```

## With Icons

```gjs preview
import { Button } from 'frontile';
import { DownloadIcon, ShareIcon, CheckIcon } from 'site/components/icons';

<template>
  <div class='flex flex-wrap items-center gap-3'>
    <Button @size='xs' @intent='primary'><DownloadIcon /> Download</Button>
    <Button @size='sm' @intent='primary'><DownloadIcon /> Download</Button>
    <Button @intent='primary'><DownloadIcon /> Download</Button>
    <Button @size='lg' @intent='primary'><DownloadIcon /> Download</Button>
    <Button @size='xl' @intent='primary'><DownloadIcon /> Download</Button>
  </div>
</template>
```

Icons can be placed before or after text. They inherit the button's text color via `currentColor`.

```gjs preview
import { Button } from 'frontile';
import { DownloadIcon, ShareIcon, CheckIcon } from 'site/components/icons';

<template>
  <div class='flex gap-4'>
    <Button @intent='primary'><DownloadIcon /> Download</Button>
    <Button @appearance='outlined' @intent='default'>Share
      <ShareIcon /></Button>
    <Button @appearance='tonal' @intent='success'><CheckIcon /> Confirm</Button>
  </div>
</template>
```

## Label with a Unit

A label can carry a smaller trailing unit — a price suffix like `/mo`, a count,
or an abbreviation. The label keeps the bold `strong` text role that the size
variant already applies; the unit uses the regular-weight `body` role, two steps
down the scale.

Wrap the pair so the unit sits tight against the label: the button's own `gap`
spaces the icon slots, while the wrapper's narrower gap spaces label from unit.

```gjs preview
import { Button } from 'frontile';
import { StarIcon } from 'site/components/icons';

<template>
  <div class='flex flex-wrap items-center gap-3'>
    <Button @intent='primary'>
      <span class='inline-flex items-center gap-1'>
        Upgrade
        <span class='font-body text-body-xs'>/mo</span>
      </span>
    </Button>

    <Button @appearance='outlined' @intent='default'>
      <StarIcon />
      <span class='inline-flex items-center gap-1'>
        Button
        <span class='font-body text-body-xs'>/mo</span>
      </span>
      <StarIcon />
    </Button>
  </div>
</template>
```

The unit token pairs with the label token the size variant sets, so it needs to
change with `@size`:

| `@size` | label (automatic) | unit              | wrapper gap |
| ------- | ----------------- | ----------------- | ----------- |
| `xs`    | `text-strong-sm`  | `text-body-micro` | `gap-0.5`   |
| `sm`    | `text-strong-md`  | `text-body-2xs`   | `gap-0.5`   |
| `md`    | `text-strong-lg`  | `text-body-xs`    | `gap-1`     |
| `lg`    | `text-strong-xl`  | `text-body-sm`    | `gap-1`     |
| `xl`    | `text-strong-2xl` | `text-body-md`    | `gap-1`     |
| `2xl`   | `text-strong-3xl` | `text-body-lg`    | `gap-1.5`   |

```gjs preview
import { Button } from 'frontile';

<template>
  <div class='flex flex-wrap items-center gap-3'>
    <Button @size='sm' @intent='primary'>
      <span class='inline-flex items-center gap-0.5'>
        $9
        <span class='font-body text-body-2xs'>/mo</span>
      </span>
    </Button>
    <Button @intent='primary'>
      <span class='inline-flex items-center gap-1'>
        $19
        <span class='font-body text-body-xs'>/mo</span>
      </span>
    </Button>
    <Button @size='lg' @intent='primary'>
      <span class='inline-flex items-center gap-1'>
        $29
        <span class='font-body text-body-sm'>/mo</span>
      </span>
    </Button>
    <Button @size='2xl' @intent='primary'>
      <span class='inline-flex items-center gap-1.5'>
        $99
        <span class='font-body text-body-lg'>/mo</span>
      </span>
    </Button>
  </div>
</template>
```

## Disabled

```gjs preview
import { Button } from 'frontile';

<template>
  <div class='flex flex-wrap items-center gap-3'>
    <Button @intent='default' disabled>Default</Button>
    <Button @intent='primary' disabled>Primary</Button>
    <Button @intent='secondary' disabled>Secondary</Button>
    <Button @intent='tertiary' disabled>Tertiary</Button>
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

<Signature @component="Button" />
