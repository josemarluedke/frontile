# Chip

Chips are compact elements that represent an input, attribute, or action.

## Usage

```hbs preview-template
<Chip>Chip</Chip>
```

## Chip Appearances

```hbs preview-template
<div>
  <Chip @appearance='default'>Default</Chip>
  <Chip @appearance='outlined'>Outlined</Chip>
  <Chip @appearance='faded'>Faded</Chip>
</div>
```

## Chip Intents

```hbs preview-template
<div>
  <Chip @intent='default'>Chip</Chip>
  <Chip @intent='primary'>Primary</Chip>
  <Chip @intent='success'>Success</Chip>
  <Chip @intent='warning'>Warning</Chip>
  <Chip @intent='danger'>Danger</Chip>
</div>
<div class="mt-6">
  <Chip @appearance="outlined" @intent='default'>Chip</Chip>
  <Chip @appearance="outlined" @intent='primary'>Primary</Chip>
  <Chip @appearance="outlined" @intent='success'>Success</Chip>
  <Chip @appearance="outlined" @intent='warning'>Warning</Chip>
  <Chip @appearance="outlined" @intent='danger'>Danger</Chip>
</div>
<div class="mt-6">
  <Chip @appearance="faded" @intent='default'>Chip</Chip>
  <Chip @appearance="faded" @intent='primary'>Primary</Chip>
  <Chip @appearance="faded" @intent='success'>Success</Chip>
  <Chip @appearance="faded" @intent='warning'>Warning</Chip>
  <Chip @appearance="faded" @intent='danger'>Danger</Chip>
</div>
```
## Close Button

If you pass the `@onClose` argument, the close button will be visible.
  
```gts preview
import Component from '@glimmer/component';
import { action } from '@ember/object';
import Chip from '@frontile/buttons/components/chip';

export default class DemoComponent extends Component {
  @action onClose() {
    console.log('closed')
  }
  <template>
    <Chip @appearance="faded" @onClose={{this.onClose}}>My Chip</Chip>
    <Chip @appearance="faded" @intent="primary" @onClose={{this.onClose}}>My Chip</Chip>
    <Chip @appearance="faded" @intent="success" @onClose={{this.onClose}}>My Chip</Chip>
    <Chip @appearance="faded" @intent="warning" @onClose={{this.onClose}}>My Chip</Chip>
    <Chip @appearance="faded" @intent="danger" @onClose={{this.onClose}}>My Chip</Chip>
  </template>
}
```

## Chip Sizes

```hbs preview-template
<Chip @size='sm'>Chip</Chip>
<Chip @size='md'>Chip</Chip>
<Chip @size='lg'>Chip</Chip>
```
[[demo:close-button]]

## Disabled

You can pass the argument `@isDisabled` to represent a disabled chip.

```hbs preview-template
<div>
  <Chip @intent='default' @isDisabled={{true}}>Chip</Chip>
  <Chip @intent='primary' @isDisabled={{true}}>Primary</Chip>
  <Chip @intent='success' @isDisabled={{true}}>Success</Chip>
  <Chip @intent='warning' @isDisabled={{true}}>Warning</Chip>
  <Chip @intent='danger' @isDisabled={{true}}>Danger</Chip>
</div>
```

You can also use TailwindCSS classes to customize even further.

```hbs preview-template
<Chip @appearance='outlined' @intent='primary' @class='px-20 py-2 italic'>
  Chip
</Chip>
```

Note that here we used the HTML attribute `class`, instead of the argument `@class`.
Using the class attribute will just append the class names passed in, while the
argument `@class` will override and merge TailwindCSS class names.

## API

