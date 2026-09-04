---
imports:
  - import Signature from 'site/components/signature';
---

# Popover

A Popover component is a UI element that presents supplementary information or
actions related to a specific trigger element, typically appearing in a small overlay.
It offers a convenient way to display contextual content such as tooltips, forms,
or menus without cluttering the main interface, enhancing user experience and interaction.
Popovers can be triggered by various user actions like hovering, clicking, or focusing on an
element, providing flexibility in design and functionality.

The Popover component is built upon the [Overlay](./overlay.md) component,
inheriting its functionality and extending it to cater specifically to popover
behavior. This means that all options available in the Overlay component are also accessible as arguments in the
`Content` yielded component. Thus, users can leverage the full range of
customization options provided by the Overlay component seamlessly within the
context of popovers, ensuring consistency and flexibility in UI design and behavior.

## Import

```js
import { Popover } from 'frontile';
```

## Usage

```gts preview
import { Button } from 'frontile';
import { Popover } from 'frontile';

<template>
  <Popover as |p|>
    <Button {{p.trigger}} {{p.anchor}}>
      Toggle Popover
    </Button>

    <p.Content @class='p-2'>
      This is some example content for the popover. It can contain anything.
    </p.Content>
  </Popover>
</template>
```

## Focus Trapping

Prevents the user from tabbing outside of the popover content while it's open,
ensuring better accessibility and usability. To enable this option, ensure a
focusable element is rendered at all times within the popover content.

```gts preview
import { Button } from 'frontile';
import { Popover } from 'frontile';
import { Input } from 'frontile';

<template>
  <Popover as |p|>
    <Button {{p.trigger}} {{p.anchor}}>
      Toggle Popover
    </Button>

    <p.Content @disableFocusTrap={{false}} @class='p-4'>
      <Input @label='First Name' class='mb-2' />
      <Input @label='Last Name' class='mb-2' />
      <Button>Save</Button>
    </p.Content>
  </Popover>
</template>
```

## The Trigger

Besides triggering the popover through a click event, alternative methods are
available for managing the visibility of the content. The Popover component yields functions
such as `open`, `close`, or `toggle`, offering convenient control over the popover's behavior.

In the example below, the popover is showned when the user hovers the trigger button.

```gts preview
import { on } from '@ember/modifier';
import { Popover } from 'frontile';
import { Button } from 'frontile';

<template>
  <Popover as |pop|>
    <Button
      {{pop.trigger}}
      {{pop.anchor}}
      {{on 'mouseenter' pop.open}}
      {{on 'mouseleave' pop.close}}
    >
      Hover me
    </Button>

    <pop.Content @class='p-2'>
      Hovered content
    </pop.Content>
  </Popover>
</template>
```

## Blocking Window Scroll

Prevent scrolling of the main window when the popover is open, focusing the
user's attention on the popover content.

```gts preview
import { Button } from 'frontile';
import { Popover } from 'frontile';
import { Input } from 'frontile';

<template>
  <Popover as |p|>
    <Button {{p.trigger}} {{p.anchor}}>
      Toggle Popover
    </Button>

    <p.Content @blockScroll={{true}} @disableFocusTrap={{false}} @class='p-4'>
      <Input @label='First Name' class='mb-2' />
      <Input @label='Last Name' class='mb-2' />
      <Button>Save</Button>
    </p.Content>
  </Popover>
</template>
```

## Backdrop Options

Choose from various backdrop options such as none, faded, blur, or transparent.

```gts preview
import { Button } from 'frontile';
import { Popover } from 'frontile';
import { Input } from 'frontile';

const backdrops = ['none', 'faded', 'blur', 'transparent'];

<template>
  {{#each backdrops as |backdrop|}}
    <Popover as |p|>
      <Button {{p.trigger}} {{p.anchor}}>
        {{backdrop}}
      </Button>

      <p.Content
        @backdrop={{backdrop}}
        @blockScroll={{true}}
        @disableFocusTrap={{false}}
        @class='p-4'
      >
        <Input @label='First Name' class='mb-2' />
        <Input @label='Last Name' class='mb-2' />
        <Button>Save</Button>
      </p.Content>
    </Popover>
  {{/each}}
</template>
```

## Placement

Easily specify the placement of the popover relative to its trigger element,
ensuring optimal positioning in various UI layouts.

```gts preview
import { Button } from 'frontile';
import { Popover } from 'frontile';

const placements = [
  'top',
  'top-start',
  'top-end',
  'right',
  'right-start',
  'right-end',
  'bottom',
  'bottom-start',
  'bottom-end',
  'left',
  'left-start',
  'left-end'
];

<template>
  <div class='flex flex-wrap md:inline-grid md:grid-cols-3 gap-4'>
    {{#each placements as |placement|}}
      <Popover @placement={{placement}} as |p|>
        <Button {{p.trigger}} {{p.anchor}}>
          {{placement}}
        </Button>
        <p.Content @class='p-4'>
          This is some example content for the popover. It can contain anything.
        </p.Content>
      </Popover>
    {{/each}}
  </div>
</template>
```

## Size

The size of the content. It can be overwritten by passing width Tailwind classes
to the `Content` yielded component.

```gts preview
import { Button } from 'frontile';
import { Popover } from 'frontile';

const sizes = ['sm', 'md', 'lg', 'xl'];

<template>
  <div class='flex flex-wrap md:inline-grid md:grid-cols-4 gap-4'>
    {{#each sizes as |size|}}
      <Popover as |p|>
        <Button {{p.trigger}} {{p.anchor}}>
          {{size}}
        </Button>
        <p.Content @size={{size}} @class='p-4'>
          This is some example content for the popover. It can contain anything.
        </p.Content>
      </Popover>
    {{/each}}
  </div>
</template>
```

### Matching a different element's width

`@size='trigger'` sizes the content from `--trigger-width`, which is the width of
whatever element carries the `trigger` modifier. That is what you want while the
toggle and the box the content should line up with are the same element. When
they are not — a field where the toggle is one of several things sitting inside
it, and the content should match the whole field — put the `measureWidth`
modifier on the element to match. It takes precedence over the `trigger`
element's own width for as long as it is installed, so the two never race, and
you do not need it at all in the usual case.

## Controlled

You can use the `isOpen` and `onOpenChange` arguments to control whether the
popover is open or closed.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Popover } from 'frontile';
import { Divider } from 'frontile';
import { Button } from 'frontile';

export default class Example extends Component {
  @tracked isOpen = false;

  onOpenChange = (isOpen: boolean) => {
    this.isOpen = isOpen;
  };

  open = () => {
    this.isOpen = true;
  };

  close = () => {
    this.isOpen = false;
  };

  <template>
    <Button @onPress={{this.open}}>Open</Button>
    <Divider class='my-4' />

    <Popover
      @isOpen={{this.isOpen}}
      @onOpenChange={{this.onOpenChange}}
      as |pop|
    >
      <Button {{pop.trigger}} {{pop.anchor}}>
        Toggle Popover
      </Button>

      <pop.Content @class='p-4'>
        This is some example content for the popover. Check the nested popover
        by clicking the button below.

        <Button @onPress={{this.close}}>Close Popover</Button>
      </pop.Content>
    </Popover>
  </template>
}
```

## Stacking Popovers

When stacking Popovers, the behavior is designed to accommodate multiple layers
of interaction seamlessly. Each Popover instance maintains its own context,
allowing for a stacked arrangement of overlays. This means that users can trigger
a new Popover from within an existing one, creating a stacked structure. When
the "escape" key is pressed, the system intelligently identifies the most recently
added overlay and closes it, ensuring a natural and intuitive user experience.
Similarly, clicking outside of the overlays prioritizes the most recent addition,
closing it before proceeding to the underlying layers.

```gts preview
import { Popover } from 'frontile';
import { Button } from 'frontile';

<template>
  <Popover as |pop|>
    <Button {{pop.trigger}} {{pop.anchor}}>
      Toggle Popover
    </Button>

    <pop.Content @class='p-4'>
      This is some example content for the popover. Check the nested popover by
      clicking the button below.

      <Popover @placement='right' as |pop|>
        <Button {{pop.trigger}} {{pop.anchor}} @class='mt-2'>
          Second Popover
        </Button>

        <pop.Content @class='p-4'>
          <p>
            More content here, the nested overlay.
          </p>
          <p class='mt-2'>
            Clicking outside or pressing Escape will close this Popover, and not
            the root Popover.
          </p>
        </pop.Content>
      </Popover>
    </pop.Content>
  </Popover>
</template>
```

## Accessibility

The `trigger` modifier sets three attributes on whatever element you attach it to, and keeps
the last one in sync as the popover opens and closes:

```
aria-haspopup="true"
aria-controls="<the content's id>"
aria-expanded="true" | "false"
```

Because those go on your element, the trigger should be something natively focusable — a
`<button>`. Attaching `trigger` to a `<div>` gives you the ARIA without the keyboard.

With the default `click` trigger type, the trigger handles:

| Key                     | Behavior                                                       |
| ----------------------- | -------------------------------------------------------------- |
| `Enter` / `Space`       | Toggles, via the element's native click                        |
| `ArrowDown` / `ArrowUp` | Opens when closed                                              |
| any letter key          | Opens when closed, for type-ahead into the content             |
| `Escape`                | Closes when open                                               |
| `Tab`                   | Closes and moves on, without pulling focus back to the trigger |

A letter pressed with <kbd>Cmd</kbd>, <kbd>Ctrl</kbd> or <kbd>Alt</kbd> held is left alone —
those combinations belong to the browser or the OS, so <kbd>Cmd</kbd>+<kbd>R</kbd> reloads
without the popover opening over the page. <kbd>Shift</kbd>+letter still opens, since a
capital letter is legitimate type-ahead.

Focus moves into the content when it opens and returns to the trigger when it closes.

`@didClose` fires once the content has finished leaving, exit transition included — not at
the moment the popover is asked to close. That makes it the right place to unmount or reset
whatever the content was showing, and it will not fire at all for a `close()` on a popover
that was not open.

**`{{p.trigger "hover"}}` is mouse-only.** The hover branch attaches `mouseenter` and
`mouseleave` and no key handling at all, so none of the keys above work and focus is not
restored on close. A hover popover is fine for supplementary content that is also reachable
another way; don't put anything a keyboard or screen-reader user needs behind one.

## API

<Signature @component="Popover" />

<Signature @module="popover" @component="Content" />
