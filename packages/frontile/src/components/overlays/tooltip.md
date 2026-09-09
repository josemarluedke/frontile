---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Tooltip

A Tooltip shows a short, non-interactive hint next to whatever a user hovers or
keyboard-focuses. It is built on [Popover](./popover.md): reach for `Popover`
instead whenever the overlay needs to hold links, buttons, or anything else a
user must be able to interact with, because a tooltip's content is announced
through `aria-describedby` as a description of the trigger, not a region of its
own — interactive elements inside it are unreachable to assistive technology.

## Import

```js
import { Tooltip } from 'frontile';
```

## Usage

Pass `@content` for the common case of a plain-text tooltip, and put the
`trigger` modifier on the element the tooltip describes.

```gts preview
import { Tooltip } from 'frontile';
import { Button } from 'frontile';

<template>
  <Tooltip @content='Add to library' as |t|>
    <Button {{t.trigger}}>Add</Button>
  </Tooltip>
</template>
```

## Placement

```gts preview
import { Tooltip } from 'frontile';
import { Button } from 'frontile';

const placements = ['top', 'right', 'bottom', 'left'];

<template>
  <div class='flex flex-wrap gap-8 p-8'>
    {{#each placements as |placement|}}
      <Tooltip @content={{placement}} @placement={{placement}} as |t|>
        <Button {{t.trigger}}>{{placement}}</Button>
      </Tooltip>
    {{/each}}
  </div>
</template>
```

## Arrow

`@arrow={{true}}` renders an arrow pointing at the trigger.

```gts preview
import { Tooltip } from 'frontile';
import { Button } from 'frontile';

<template>
  <Tooltip @content='With an arrow' @arrow={{true}} as |t|>
    <Button {{t.trigger}}>Hover me</Button>
  </Tooltip>
</template>
```

## Rich content

Use the yielded `Content` block instead of `@content` when the tooltip needs
more than a single string. Passing both `@content` and a `Content` block
asserts in development — pick one.

```gts preview
import { Tooltip } from 'frontile';
import { Button } from 'frontile';

<template>
  <Tooltip as |t|>
    <Button {{t.trigger}}>Keyboard shortcuts</Button>
    <t.Content>
      <p class='font-semibold'>Save</p>
      <p>Cmd+S saves the current document.</p>
    </t.Content>
  </Tooltip>
</template>
```

## Intent

```gts preview
import { Tooltip } from 'frontile';
import { Button } from 'frontile';

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
  <div class='flex flex-wrap gap-8 p-8'>
    {{#each intents as |intent|}}
      <Tooltip @content={{intent}} @intent={{intent}} as |t|>
        <Button {{t.trigger}}>{{intent}}</Button>
      </Tooltip>
    {{/each}}
  </div>
</template>
```

## Size

```gts preview
import { Tooltip } from 'frontile';
import { Button } from 'frontile';

const sizes = ['sm', 'md', 'lg'];

<template>
  <div class='flex flex-wrap gap-8 p-8'>
    {{#each sizes as |size|}}
      <Tooltip @content={{size}} @size={{size}} as |t|>
        <Button {{t.trigger}}>{{size}}</Button>
      </Tooltip>
    {{/each}}
  </div>
</template>
```

## Delays

`@openDelay` (default `200`ms) and `@closeDelay` (default `150`ms) control how
long the tooltip waits before showing and hiding. `@closeDelay` is also the
window the pointer has to cross the gap between the trigger and the tooltip
content, so setting it very low makes the tooltip effectively non-interactive.

These defaults are deliberately longer than the underlying `Popover`'s hover
defaults (`100`ms/`100`ms): a tooltip fires on every incidental mouse pass over
its trigger, so it waits a little longer before appearing to avoid flashing at
a user who was only moving the cursor across.

```gts preview
import { Tooltip } from 'frontile';
import { Button } from 'frontile';

<template>
  <Tooltip
    @content='Opens slowly, closes fast'
    @openDelay={{600}}
    @closeDelay={{0}}
    as |t|
  >
    <Button {{t.trigger}}>Hover and wait</Button>
  </Tooltip>
</template>
```

## Interactive content

By default, moving the pointer or keyboard focus off the trigger and onto the
tooltip's own content keeps it open — useful when the content is long enough
that a reader's cursor has to cross a gap to reach it. `@disableInteractive`
closes the tooltip as soon as the pointer leaves the trigger instead, without
waiting to see whether it lands on the content.

```gts preview
import { Tooltip } from 'frontile';
import { Button } from 'frontile';

<template>
  <div class='flex flex-wrap gap-8 p-8'>
    <Tooltip @content='You can hover this tooltip' as |t|>
      <Button {{t.trigger}}>Interactive (default)</Button>
    </Tooltip>

    <Tooltip
      @content='This one closes immediately'
      @disableInteractive={{true}}
      as |t|
    >
      <Button {{t.trigger}}>Not interactive</Button>
    </Tooltip>
  </div>
</template>
```

## Controlled

Pair `@isOpen` with `@onOpenChange` to drive the tooltip from your own state.
`@isOpen` only takes effect together with `@onOpenChange` — passing `@isOpen`
alone falls back to uncontrolled behavior.

Open the tooltip in response to an interaction or after the component has
mounted, not on the very first render: the trigger installs its floating-ui
anchor through a modifier, which only runs once the element exists, so forcing
`@isOpen={{true}}` before that happens throws.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Tooltip } from 'frontile';
import { Button } from 'frontile';

export default class ControlledTooltipExample extends Component {
  @tracked isOpen = false;

  onOpenChange = (isOpen: boolean) => {
    this.isOpen = isOpen;
  };

  show = () => {
    this.isOpen = true;
  };

  <template>
    <Button @onPress={{this.show}} class='mr-4'>Show tooltip</Button>

    <Tooltip
      @content='Opened from outside'
      @isOpen={{this.isOpen}}
      @onOpenChange={{this.onOpenChange}}
      as |t|
    >
      <Button {{t.trigger}}>Trigger</Button>
    </Tooltip>
  </template>
}
```

## Imperative Controls

Besides `@isOpen`/`@onOpenChange`, the default block also yields `isOpen`, `open`, and
`close` directly, with no external state required. `open` and `close` drive the tooltip from
anywhere on the page — a button doesn't have to be the trigger itself — and `isOpen` reports
whether the tooltip is currently open.

```gts preview
import { Tooltip } from 'frontile';
import { Button } from 'frontile';

<template>
  <Tooltip @content='Hover me, then dismiss me from the button' as |t|>
    <Button {{t.trigger}} class='mr-4'>Trigger</Button>
    <Button @appearance='outlined' @onPress={{t.close}}>Close tooltip</Button>
    <p class='mt-2 text-sm'>{{if t.isOpen "Open" "Closed"}}</p>
  </Tooltip>
</template>
```

## Disabled

`@isDisabled={{true}}` still installs the trigger element, but skips wiring up the hover and
focus listeners that open the tooltip — so the tooltip never opens, and the trigger itself
renders exactly as you wrote it, whether or not it also carries a plain `disabled` attribute.
Toggling `@isDisabled` back to `false` at runtime re-installs the listeners immediately.

The common case is disabling the tooltip alongside a disabled trigger, so a hint about an
unavailable action doesn't pop up on hover.

```gts preview
import { Tooltip } from 'frontile';
import { Button } from 'frontile';

<template>
  <div class='flex flex-wrap gap-8 p-8'>
    <Tooltip @content='Save your changes' @isDisabled={{true}} as |t|>
      <Button {{t.trigger}} disabled>Save (disabled)</Button>
    </Tooltip>

    <Tooltip @content='Save your changes' as |t|>
      <Button {{t.trigger}}>Save (enabled)</Button>
    </Tooltip>
  </div>
</template>
```

## Accessibility

The `trigger` modifier marks up the element it's applied to as the tooltip's
description, and keeps it in sync as the tooltip opens and closes:

```
aria-describedby="<the content's id>"
```

The tooltip opens on mouse hover, and on keyboard `focus-visible` after
`@openDelay`. `Escape` closes it while it's open. The content itself carries
`role="tooltip"` and is never a tab stop (`tabindex="-1"`) — focus is never
moved into it, only the description relationship changes.

Touch has no equivalent: there is no long-press emulation, so anything said
only in a tooltip is invisible to a touch-only user. Make sure the same
information is available another way — in the trigger's own label, or
elsewhere on the page — rather than relying on the tooltip alone.

## API

<Signature @component="Tooltip" />
