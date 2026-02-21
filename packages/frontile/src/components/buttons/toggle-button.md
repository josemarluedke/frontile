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
import { ToggleButton } from 'frontile';
```

## Usage

```gjs preview
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

```gjs preview
import { ToggleButton } from 'frontile';

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

<Signature @component="ToggleButton" />
