---
label: New
imports:
  - import Signature from 'site/components/signature';
---
# ButtonGroup

A button group is used to group buttons whose actions are related.


## Import 

```js
import { ButtonGroup } from '@frontile/buttons';
```

## Using with Button

```gjs preview
import { ButtonGroup } from '@frontile/buttons';

<template>
  <ButtonGroup as |g|>
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
import { ButtonGroup } from '@frontile/buttons';

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
    <ButtonGroup @size="sm" @intent="primary" as |g|>
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


```gjs preview
import { ButtonGroup } from '@frontile/buttons';

<template>
  <ButtonGroup @size="sm" @intent="primary" as |g|>
    <g.Button>Create a merge commit</g.Button>
    <g.Button @class="border-l-primary-400"><Icon/></g.Button>
  </ButtonGroup>
</template>

const Icon = <template>
  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
    <path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5" />
  </svg>
</template>
```

## Arguments

You pass pass arguments to `ButtonGroup` and they will be passed in to each of the yielded component. 
You can overwrite at the specific component as well.

```gjs preview
import { ButtonGroup } from '@frontile/buttons';

<template>
  <ButtonGroup @size="sm" @intent="primary" as |g|>
    <g.Button>First</g.Button>
    <g.Button>Second</g.Button>
    <g.Button @intent="danger">Third</g.Button>
  </ButtonGroup>
</template>
```

## API

<Signature @package="buttons" @component="ButtonGroup" />
