---
imports:
  - import Signature from 'site/components/signature';
---

# Popover

A Popover shows supplementary content — a form, a menu, extra detail — next to a
trigger element, in a small overlay. It can be triggered by click, hover, or
focus.

Popover is built on [Overlay](./overlay.md), and all of Overlay's arguments are
also accepted by the `Content` yielded component.

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

Prevents the user from tabbing outside of the popover content while it's open.
To enable this option, ensure a focusable element is rendered at all times
within the popover content.

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

Besides a click on the trigger, Popover yields `open`, `close`, and `toggle`
functions for controlling visibility directly.

In the example below, the popover shows when the user hovers the trigger button.

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

## Hover Trigger

`{{p.trigger "hover"}}` installs a trigger that opens on pointer hover or keyboard
`focus-visible`, rather than on click. It opens after `@openDelay` (default `100`ms) and
closes after `@closeDelay` (default `100`ms) once the pointer or focus has left both the
trigger and the content. `@closeDelay` is also the window the pointer has to cross the gap
between the trigger and the content, so a very small value makes the content practically
unreachable by pointer — moving onto the content otherwise keeps the popover open. Pass
`@disableInteractive={{true}}` to `Content` to close as soon as the pointer leaves the
trigger instead.

```gts preview
import { Button } from 'frontile';
import { Popover } from 'frontile';

<template>
  <Popover @openDelay={{100}} @closeDelay={{300}} as |p|>
    <Button {{p.trigger 'hover'}} {{p.anchor}}>
      Hover me
    </Button>

    <p.Content @class='p-2'>
      You can move the pointer onto this content without it closing.
    </p.Content>
  </Popover>
</template>
```

The `aria=` option passed alongside `"hover"` (or `"click"`) controls which ARIA
relationship the trigger element carries — see [Accessibility](#accessibility).

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

Specify the placement of the popover relative to its trigger element.

```gts preview collapsible
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

## Arrow

`@arrow={{true}}` on `Content` renders an arrow pointing at the trigger. `Content` also
carries a `data-placement` attribute with the side floating-ui actually resolved for the
current position (after any flip), which the yielded `data` exposes too, for styling or
logic that needs to know which side the popover ended up on.

```gts preview
import { Button } from 'frontile';
import { Popover } from 'frontile';

<template>
  <Popover @placement='top' as |p|>
    <Button {{p.trigger}} {{p.anchor}}>
      Toggle Popover
    </Button>

    <p.Content @arrow={{true}} @class='p-2'>
      Resolved placement: {{p.data.placement}}
    </p.Content>
  </Popover>
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

```gts preview collapsible
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

Each Popover instance maintains its own context, so a Popover can be triggered
from within another, creating a stacked arrangement. Pressing Escape closes
the most recently opened overlay first; clicking outside behaves the same way,
closing the topmost layer before the ones beneath it.

```gts preview collapsible
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

**`{{p.trigger "hover"}}`** opens on pointer hover, and also on keyboard `focus-visible` —
so it is reachable without a mouse. `Escape` closes it while it's open. The pointer, and
keyboard focus, may both move off the trigger and onto the content without the popover
closing (see [Hover Trigger](#hover-trigger)). Unlike the click trigger, a hover popover
never moves focus into its content — focus stays wherever it already was, avoiding the page
jump that comes from a portaled overlay being scrolled into view. Consequently there is
nothing to restore on close either.

The `aria=` option, passed alongside the trigger type, chooses which relationship the
trigger element carries:

| Value | Effect |
| --- | --- |
| `'menu'` (default) | Sets `aria-haspopup`, `aria-controls`, and `aria-expanded`, as described above |
| `'describedby'` | Sets `aria-describedby` instead, present only while open — appropriate when the content describes the trigger rather than acting as a menu or panel |
| `'none'` | Sets none of the above, for a fully custom ARIA setup |

```gts preview
import { Button } from 'frontile';
import { Popover } from 'frontile';

<template>
  <Popover as |p|>
    <Button {{p.trigger 'hover' aria='describedby'}} {{p.anchor}}>
      Hover me
    </Button>

    <p.Content @class='p-2'>
      Announced as this button's description.
    </p.Content>
  </Popover>
</template>
```

## API

<Signature @component="Popover" />

<Signature @module="popover" @component="Content" />
