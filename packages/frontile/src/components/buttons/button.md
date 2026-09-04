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

```gts preview
import { Button } from 'frontile';

<template>
  <Button>Button</Button>
</template>
```

## Button Appearances

```gts preview
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

```gts preview
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

```gts preview
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

```gts preview
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

```gts preview
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

```gts preview
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
| `xs`    | `text-strong-sm`  | `text-body-3xs`   | `gap-0.5`   |
| `sm`    | `text-strong-md`  | `text-body-2xs`   | `gap-0.5`   |
| `md`    | `text-strong-lg`  | `text-body-xs`    | `gap-1`     |
| `lg`    | `text-strong-xl`  | `text-body-sm`    | `gap-1`     |
| `xl`    | `text-strong-2xl` | `text-body-md`    | `gap-1`     |
| `2xl`   | `text-strong-3xl` | `text-body-lg`    | `gap-1.5`   |

```gts preview
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

```gts preview
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

```gts preview
import { Button } from 'frontile';

<template>
  <Button @isRenderless={{true}} as |btn|>
    <a href='javascript:void(0)' class={{btn.classNames}}>My Link</a>
  </Button>
</template>
```

## Composition

You can compose appearance with intents and more to create the button that best fits your needs.

```gts preview
import { Button } from 'frontile';

<template>
  <Button @appearance='outlined' @intent='primary'>Button</Button>
  <Button @appearance='minimal' @intent='warning'>Button</Button>
  <Button @size='xs' @intent='danger'>Button</Button>
</template>
```

## Customization

You can use TailwindCSS classes to customize even further.

```gts preview
import { Button } from 'frontile';

<template>
  <Button @appearance='outlined' @intent='primary' @class='px-20 py-2 italic'>
    Button
  </Button>
</template>
```

Here is another example using TailwindCSS classes with the `custom` appearance.

```gts preview
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

```gts preview
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

## Accessibility

`Button` renders a native `<button type="button">`, so focus order, the disabled
state, and Enter/Space activation come from the platform. What follows is what
you still have to get right.

| Key     | Behaviour                                                |
| ------- | -------------------------------------------------------- |
| `Tab`   | Moves focus to the button. Disabled buttons are skipped. |
| `Enter` | Activates the button, firing `@onPress`.                 |
| `Space` | Activates the button, firing `@onPress`.                 |

### Use `@onPress`, not a `click` listener

The `press` modifier calls `preventDefault()` on Enter and Space so the two keys
behave identically across elements. A side effect is that the browser never
synthesises the `click` event it would normally follow with — so a
`{{on "click"}}` handler on a default `@type='button'` fires for the mouse but
**not** for the keyboard:

```gts preview
import { Button } from 'frontile';
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';

export default class KeyboardParityExample extends Component {
  @tracked pressCount = 0;
  @tracked clickCount = 0;

  handlePress = () => {
    this.pressCount++;
  };

  handleClick = () => {
    this.clickCount++;
  };

  <template>
    <div class='flex flex-wrap items-center gap-4'>
      <Button @intent='primary' @onPress={{this.handlePress}}>
        @onPress ({{this.pressCount}})
      </Button>
      <Button @appearance='outlined' {{on 'click' this.handleClick}}>
        click listener ({{this.clickCount}})
      </Button>
      <p class='text-neutral'>
        Activate each with the mouse, then again with
        <kbd>Tab</kbd>
        +
        <kbd>Enter</kbd>. Only the first counter moves the second time.
      </p>
    </div>
  </template>
}
```

`@type='submit'` and `@type='reset'` are deliberately exempt: the default is
preserved there so a button inside a form still submits or resets it from the
keyboard.

### Buttons with no text

An icon on its own leaves the button unnamed. Give it an `aria-label` — it
passes through to the element via `...attributes`:

```gts preview
import { Button } from 'frontile';
import { ShareIcon } from 'site/components/icons';

<template>
  <Button @intent='primary' aria-label='Share this page'>
    <ShareIcon />
  </Button>
</template>
```

### Disabling

There is no `@isDisabled` argument. Pass the plain HTML `disabled` attribute, as
the [Disabled](#disabled) demo above does; it removes the button from the tab
order and is what assistive technology reports.

### Renderless buttons

`@isRenderless` hands back only class names, so every semantic the `<button>`
provided becomes yours. An `<a href>` is already focusable and activates on
Enter; anything else — a `<div>`, a `<span>` — needs `role='button'`,
`tabindex='0'`, and its own key handling. Prefer a real `<button>` or `<a>` over
recreating that.

## API

<Signature @component="Button" />
