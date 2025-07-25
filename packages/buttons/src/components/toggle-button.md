---
label: New
imports:
  - import Signature from 'site/components/signature';
---
# ToggleButton

A toggle button allows to toggle a selection on or off, for example switching 
between two states or modes.


## Import 

```js
import { ToggleButton } from '@frontile/buttons';
```

## Usage

```gjs preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { ToggleButton } from '@frontile/buttons';

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
    >
      <Icon />
    </ToggleButton>
  </template>
}

const Icon = <template>
  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
    <path stroke-linecap="round" stroke-linejoin="round" d="M11.48 3.499a.562.562 0 0 1 1.04 0l2.125 5.111a.563.563 0 0 0 .475.345l5.518.442c.499.04.701.663.321.988l-4.204 3.602a.563.563 0 0 0-.182.557l1.285 5.385a.562.562 0 0 1-.84.61l-4.725-2.885a.562.562 0 0 0-.586 0L6.982 20.54a.562.562 0 0 1-.84-.61l1.285-5.386a.562.562 0 0 0-.182-.557l-4.204-3.602a.562.562 0 0 1 .321-.988l5.518-.442a.563.563 0 0 0 .475-.345L11.48 3.5Z" />
  </svg>
</template>
```

## Intents

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { ToggleButton } from '@frontile/buttons';

export default class Example extends Component {
  @tracked
  isSelected = {
    default: false,
    primary: false,
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

```gjs preview
import { ToggleButton } from '@frontile/buttons';

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

```gjs preview
import { ToggleButton } from '@frontile/buttons';

<template>
  <div>
    <ToggleButton @intent='default' disabled="true">ToggleButton</ToggleButton>
    <ToggleButton @intent='primary' disabled="true">Primary</ToggleButton>
    <ToggleButton @intent='success' disabled="true">Success</ToggleButton>
    <ToggleButton @intent='warning' disabled="true">Warning</ToggleButton>
    <ToggleButton @intent='danger' disabled="true">Danger</ToggleButton>
  </div>
</template>
```

## API

<Signature @package="buttons" @component="ToggleButton" />
