---
imports:
  - import Signature from 'site/components/signature';
---

# ButtonGroup

A button group is used to group buttons whose actions are related.

## Import

```js
import { ButtonGroup } from 'frontile';
```

## Usage

```gts preview
import { ButtonGroup } from 'frontile';

<template>
  <ButtonGroup aria-label='Example actions' as |g|>
    <g.Button>First</g.Button>
    <g.Button>Second</g.Button>
    <g.Button>Third</g.Button>
  </ButtonGroup>
</template>
```

## Using with ToggleButton

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { ButtonGroup } from 'frontile';

export default class Example extends Component {
  @tracked
  isSelected = {
    first: false,
    second: false,
    third: false
  };

  @action
  onChange(ty: keyof typeof this.isSelected, value: boolean): void {
    this.isSelected[ty] = value;
    this.isSelected = { ...this.isSelected };
  }

  <template>
    <ButtonGroup
      @size='sm'
      @intent='primary'
      aria-label='Example toggles'
      as |g|
    >
      {{#each-in this.isSelected as |key val|}}
        <g.ToggleButton
          @isSelected={{val}}
          @onChange={{(fn this.onChange key)}}
        >
          {{key}}
        </g.ToggleButton>
      {{/each-in}}
    </ButtonGroup>
  </template>
}
```

## ButtonGroup use case

A common use case for `ButtonGroup` is to create a split button.

```gts preview
import { ButtonGroup } from 'frontile';
import { ChevronDownIcon } from 'site/components/icons';

<template>
  <ButtonGroup @size='sm' @intent='primary' aria-label='Merge options' as |g|>
    <g.Button>Create a merge commit</g.Button>
    <g.Button
      @class='border-l-primary-mild'
      aria-label='More merge options'
    ><ChevronDownIcon /></g.Button>
  </ButtonGroup>
</template>
```

## Arguments

Arguments passed to `ButtonGroup` are forwarded to every yielded component. Any
of them can be overridden on an individual button.

```gts preview
import { ButtonGroup } from 'frontile';

<template>
  <ButtonGroup @size='sm' @intent='primary' aria-label='Example actions' as |g|>
    <g.Button>First</g.Button>
    <g.Button>Second</g.Button>
    <g.Button @intent='danger'>Third</g.Button>
  </ButtonGroup>
</template>
```

## Accessibility

`ButtonGroup` renders `role="group"`, which tells assistive technology that the
buttons belong together — but a group with no name is announced as an unlabelled
container, so the relationship is stated without being explained. Name it with
`aria-label` (or `aria-labelledby` pointing at a visible heading); both pass
through to the element via `...attributes`.

```gts preview
import { ButtonGroup } from 'frontile';

<template>
  <div class='flex flex-col gap-6'>
    <ButtonGroup aria-label='Text alignment' as |g|>
      <g.Button>Left</g.Button>
      <g.Button>Center</g.Button>
      <g.Button>Right</g.Button>
    </ButtonGroup>

    <div>
      <h4 id='zoom-label' class='text-neutral-strong mb-2'>Zoom</h4>
      <ButtonGroup aria-labelledby='zoom-label' as |g|>
        <g.Button>Out</g.Button>
        <g.Button>Reset</g.Button>
        <g.Button>In</g.Button>
      </ButtonGroup>
    </div>
  </div>
</template>
```

Grouping does not change how the buttons themselves behave: each stays in the
tab order and is reached with `Tab`, not with arrow keys. If you want one
selection out of several with arrow-key navigation, that is a radio group rather
than a button group — see [RadioGroup](/docs/components/forms/radio-group).

Yielded `g.ToggleButton`s each carry their own `aria-pressed`, so a group of them
is announced as several independent toggles. That is right for a formatting
toolbar where bold and italic can both be on; it is misleading for a set where
only one value can be active at a time.

## API

<Signature @component="ButtonGroup" />
