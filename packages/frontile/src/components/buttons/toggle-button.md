---
imports:
  - import Signature from 'site/components/signature';
---

# ToggleButton

A toggle button allows to toggle a selection on or off, for example switching
between two states or modes.

Unselected, it reads as an outlined button — ink and border only. Selected, it
fills with its intent color and switches to the matching contrast ink; hovering
and pressing deepen that fill one step at a time, the same ramp a filled
`Button` uses, so the label stays readable in every state.

## Import

```js
import { ToggleButton } from 'frontile';
```

## Usage

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { ToggleButton } from 'frontile';
import { StarIcon } from 'site/components/icons';

export default class Example extends Component {
  @tracked
  isSelected = false;

  @action
  onChange(value: boolean): void {
    this.isSelected = value;
  }

  <template>
    <ToggleButton
      @isSelected={{this.isSelected}}
      @onChange={{this.onChange}}
      aria-label='Favourite'
    >
      <StarIcon />
    </ToggleButton>
  </template>
}
```

## Intents

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { ToggleButton } from 'frontile';

export default class Example extends Component {
  @tracked
  isSelected = {
    default: false,
    primary: false,
    secondary: false,
    tertiary: false,
    success: false,
    warning: false,
    danger: false
  };

  @action
  onChange(ty: keyof typeof this.isSelected, value: boolean): void {
    this.isSelected[ty] = value;
    this.isSelected = { ...this.isSelected };
  }

  <template>
    {{#each-in this.isSelected as |key val|}}
      <ToggleButton
        @isSelected={{val}}
        @onChange={{(fn this.onChange key)}}
        @intent={{key}}
      >
        Toggle
      </ToggleButton>
    {{/each-in}}
  </template>
}
```

## ToggleButton Sizes

```gts preview
import { ToggleButton } from 'frontile';

<template>
  <ToggleButton @size='xs'>ToggleButton</ToggleButton>
  <ToggleButton @size='sm'>ToggleButton</ToggleButton>
  <ToggleButton @size='md'>ToggleButton</ToggleButton>
  <ToggleButton @size='lg'>ToggleButton</ToggleButton>
  <ToggleButton @size='xl'>ToggleButton</ToggleButton>
</template>
```

## Disabled

You can pass the attribute `disabled` to disable a toggle button.

```gts preview
import { ToggleButton } from 'frontile';

<template>
  <div>
    <ToggleButton @intent='default' disabled>ToggleButton</ToggleButton>
    <ToggleButton @intent='primary' disabled>Primary</ToggleButton>
    <ToggleButton @intent='secondary' disabled>Secondary</ToggleButton>
    <ToggleButton @intent='tertiary' disabled>Tertiary</ToggleButton>
    <ToggleButton @intent='success' disabled>Success</ToggleButton>
    <ToggleButton @intent='warning' disabled>Warning</ToggleButton>
    <ToggleButton @intent='danger' disabled>Danger</ToggleButton>
  </div>
</template>
```

## Accessibility

`ToggleButton` renders a native `<button>` carrying `aria-pressed`, which is what
turns it from a button into a toggle: assistive technology announces the label
followed by its state, and announces the change when it flips.

| Key     | Behaviour                                                |
| ------- | -------------------------------------------------------- |
| `Tab`   | Moves focus to the toggle. Disabled toggles are skipped. |
| `Enter` | Toggles it, firing `@onChange` with the new value.       |
| `Space` | Toggles it, firing `@onChange` with the new value.       |

`aria-pressed` tracks `@isSelected`, which the component does not own. Without an
`@onChange` that writes the new value back, the toggle looks pressed to the eye
for as long as the pointer is down but never reports a state change — the demos
under [Sizes](#togglebutton-sizes) and [Disabled](#disabled) are deliberately
inert for that reason, and are not the pattern to copy.

An icon with no text leaves the toggle unnamed, so the state is announced with
nothing to attach it to. Pass `aria-label`, as the [Usage](#usage) demo does.

The label should name the control, not the action — "Bold", not "Make bold" —
because `aria-pressed` already conveys whether it is on. A label that changes
with the state ("Mute" / "Unmute") duplicates that and contradicts it half the
time; if you want changing labels, use a plain `Button` and no `aria-pressed`.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { fn } from '@ember/helper';
import { ToggleButton } from 'frontile';

export default class Example extends Component {
  @tracked format: Record<string, boolean> = {
    Bold: false,
    Italic: false,
    Underline: false
  };

  onChange = (key: string, value: boolean): void => {
    this.format = { ...this.format, [key]: value };
  };

  <template>
    <div class='flex items-center gap-2'>
      {{#each-in this.format as |key selected|}}
        <ToggleButton
          @isSelected={{selected}}
          @onChange={{fn this.onChange key}}
          @intent='primary'
        >
          {{key}}
        </ToggleButton>
      {{/each-in}}
    </div>
  </template>
}
```

Use the plain HTML `disabled` attribute to disable a toggle; there is no
`@isDisabled` argument.

## API

<Signature @component="ToggleButton" />
