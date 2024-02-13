---
label: New
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
import { Popover } from '@frontile/overlays';
```

## Usage

```gjs preview
import { Button } from '@frontile/buttons';
import { Popover } from '@frontile/overlays';

<template>
  <Popover as |p|>
    <Button {{p.trigger}} {{p.anchor}}>
      Toggle Popover
    </Button>

    <p.Content @class="p-2">
      This is some example content for the popover. It can contain anything.
    </p.Content>
  </Popover>
</template>
```

## Focus Trapping 

Prevents the user from tabbing outside of the popover content while it's open, 
ensuring better accessibility and usability. To enable this option, ensure a 
focusable element is rendered at all times within the popover content.

```gjs preview
import { Button } from '@frontile/buttons';
import { Popover } from '@frontile/overlays';
import { FormInput } from '@frontile/forms';

<template>
  <Popover as |p|>
    <Button {{p.trigger}} {{p.anchor}}>
      Toggle Popover
    </Button>

    <p.Content @disableFocusTrap={{false}} @class="p-4">
      <FormInput @label="First Name" class="mb-2" />
      <FormInput @label="Last Name" class="mb-2" />
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

```gjs preview
import { on } from '@ember/modifier';
import { Popover } from '@frontile/overlays';
import { Button } from '@frontile/buttons';

<template>
  <Popover as |pop|>
    <Button
      {{pop.trigger}}
      {{pop.anchor}}
      {{on "mouseenter" pop.open}}
      {{on "mouseleave" pop.close}}
    >
      Hover me
    </Button>

    <pop.Content @class="p-2">
      Hovered content
    </pop.Content>
  </Popover>
</template>
```

## Blocking Window Scroll

Prevent scrolling of the main window when the popover is open, focusing the 
user's attention on the popover content.

```gjs preview
import { Button } from '@frontile/buttons';
import { Popover } from '@frontile/overlays';
import { FormInput } from '@frontile/forms';

<template>
  <Popover as |p|>
    <Button {{p.trigger}} {{p.anchor}}>
      Toggle Popover
    </Button>

    <p.Content 
      @blockScroll={{true}}
      @disableFocusTrap={{false}} 
      @class="p-4"
    >
      <FormInput @label="First Name" class="mb-2" />
      <FormInput @label="Last Name" class="mb-2" />
      <Button>Save</Button>
    </p.Content>
  </Popover>
</template>
```

## Backdrop Options

Choose from various backdrop options such as none, faded, blur, or transparent.

```gjs preview
import { Button } from '@frontile/buttons';
import { Popover } from '@frontile/overlays';
import { FormInput } from '@frontile/forms';

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
        @class="p-4"
      >
        <FormInput @label="First Name" class="mb-2" />
        <FormInput @label="Last Name" class="mb-2" />
        <Button>Save</Button>
      </p.Content>
    </Popover>
  {{/each}}
</template>
```

## Placement

Easily specify the placement of the popover relative to its trigger element, 
ensuring optimal positioning in various UI layouts.

```gjs preview
import { Button } from '@frontile/buttons';
import { Popover } from '@frontile/overlays';

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
  <div class="flex flex-wrap md:inline-grid md:grid-cols-3 gap-4">
    {{#each placements as |placement|}}
      <Popover @placement={{placement}} as |p|>
        <Button {{p.trigger}} {{p.anchor}}>
          {{placement}}
        </Button>
        <p.Content @class="p-4">
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

```gjs preview
import { Button } from '@frontile/buttons';
import { Popover } from '@frontile/overlays';

const sizes = [
  'sm',
  'md',
  'lg',
  'xl'
];

<template>
  <div class="flex flex-wrap md:inline-grid md:grid-cols-4 gap-4">
    {{#each sizes as |size|}}
      <Popover as |p|>
        <Button {{p.trigger}} {{p.anchor}}>
          {{size}}
        </Button>
        <p.Content @size={{size}} @class="p-4">
          This is some example content for the popover. It can contain anything.
        </p.Content>
      </Popover>
    {{/each}}
  </div>
</template>
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

```gjs preview
import { Popover } from '@frontile/overlays';
import { Button } from '@frontile/buttons';

<template>
  <Popover as |pop|>
    <Button {{pop.trigger}} {{pop.anchor}}>
      Toggle Popover
    </Button>

    <pop.Content @class="p-4">
      This is some example content for the popover. Check the nested popover by
      clicking the button below.

      <Popover @placement="right" as |pop|>
        <Button {{pop.trigger}} {{pop.anchor}} @class="mt-2">
          Second Popover
        </Button>

        <pop.Content @class="p-4">
          <p>
            More content here, the nested overlay.
          </p>
          <p class="mt-2">
            Clicking outside or pressing Escape will close this Popover, and not
            the root Popover.
          </p>
        </pop.Content>
      </Popover>
    </pop.Content>
  </Popover>
</template>
```

## API

