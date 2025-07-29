---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Switch

The `Switch` component is a customizable toggle control that can be used both as a controlled and uncontrolled component. It supports custom content blocks—`startContent`, `thumbContent`, and `endContent`—to render additional elements such as icons or labels. The component integrates with Frontile’s `FormControl` to provide labels, descriptions, and error feedback, ensuring a consistent and accessible experience.

## Import

```js
import { Switch } from '@frontile/forms';
```

## Usage

### Uncontrolled Switch

In uncontrolled mode, the switch manages its own state based on the initial `defaultSelected` value. If a `booolen` value is passed to the `isSelected` argument, the switch will be controlled independently of `defaultSelected`. The `onChange` callback is called with the new value when the switch is toggled.

```gts preview
import Component from '@glimmer/component';
import { Switch } from '@frontile/forms';

export default class UncontrolledSwitchExample extends Component {
  // The switch maintains its own state.
  onChange = (value: boolean, event: Event) => {
    console.log('Switch toggled to:', value);
  };

  <template>
    <Switch
      @label='Enable Notifications'
      @defaultSelected={{true}}
      @onChange={{this.onChange}}
    />
  </template>
}
```

### Controlled Switch

In controlled mode, you pass the current state via isSelected and update it through the onChange callback.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Switch } from '@frontile/forms';

export default class ControlledSwitchExample extends Component {
  @tracked isEnabled = false;

  onChange = (value: boolean, event: Event) => {
    this.isEnabled = value;
  };

  <template>
    <Switch
      @label='Dark Mode'
      @isSelected={{this.isEnabled}}
      @onChange={{this.onChange}}
    />
    <p>Dark Mode is {{if this.isEnabled 'enabled' 'disabled'}}</p>
  </template>
}
```

### With Icons

Customize the switch appearance by using content blocks:

- `startContent`: Renders before the switch thumb.
- `thumbContent`: Renders inside the switch thumb. It receives an object with `isSelected` to reflect the current state.
- `endContent`: Renders after the switch thumb.

```gts preview
import Component from '@glimmer/component';
import { Switch } from '@frontile/forms';

export default class CustomContentSwitchExample extends Component {
  <template>
    <Switch @label='Dark Mode'>
      <:startContent>
        <Sun />
      </:startContent>
      <:endContent>
        <Moon />
      </:endContent>
    </Switch>
  </template>
}

const Moon = <template>
  <svg
    xmlns='http://www.w3.org/2000/svg'
    viewBox='0 0 24 24'
    fill='currentColor'
    class='size-4'
  >
    <path
      fill-rule='evenodd'
      d='M9.528 1.718a.75.75 0 0 1 .162.819A8.97 8.97 0 0 0 9 6a9 9 0 0 0 9 9 8.97 8.97 0 0 0 3.463-.69.75.75 0 0 1 .981.98 10.503 10.503 0 0 1-9.694 6.46c-5.799 0-10.5-4.7-10.5-10.5 0-4.368 2.667-8.112 6.46-9.694a.75.75 0 0 1 .818.162Z'
      clip-rule='evenodd'
    />
  </svg>
</template>;

const Sun = <template>
  <svg
    xmlns='http://www.w3.org/2000/svg'
    viewBox='0 0 24 24'
    fill='currentColor'
    class='size-4'
  >
    <path
      d='M12 2.25a.75.75 0 0 1 .75.75v2.25a.75.75 0 0 1-1.5 0V3a.75.75 0 0 1 .75-.75ZM7.5 12a4.5 4.5 0 1 1 9 0 4.5 4.5 0 0 1-9 0ZM18.894 6.166a.75.75 0 0 0-1.06-1.06l-1.591 1.59a.75.75 0 1 0 1.06 1.061l1.591-1.59ZM21.75 12a.75.75 0 0 1-.75.75h-2.25a.75.75 0 0 1 0-1.5H21a.75.75 0 0 1 .75.75ZM17.834 18.894a.75.75 0 0 0 1.06-1.06l-1.59-1.591a.75.75 0 1 0-1.061 1.06l1.59 1.591ZM12 18a.75.75 0 0 1 .75.75V21a.75.75 0 0 1-1.5 0v-2.25A.75.75 0 0 1 12 18ZM7.758 17.303a.75.75 0 0 0-1.061-1.06l-1.591 1.59a.75.75 0 0 0 1.06 1.061l1.591-1.59ZM6 12a.75.75 0 0 1-.75.75H3a.75.75 0 0 1 0-1.5h2.25A.75.75 0 0 1 6 12ZM6.697 7.757a.75.75 0 0 0 1.06-1.06l-1.59-1.591a.75.75 0 0 0-1.061 1.06l1.59 1.591Z'
    />
  </svg>
</template>;
```

```gts preview
import Component from '@glimmer/component';
import { Switch } from '@frontile/forms';

export default class CustomContentSwitchExample extends Component {
  <template>
    <Switch @label='Dark Mode'>
      <:thumbContent as |o|>
        {{#if o.isSelected}}
          <Moon />
        {{else}}
          <Sun />
        {{/if}}
      </:thumbContent>
    </Switch>
  </template>
}
const Moon = <template>
  <svg
    xmlns='http://www.w3.org/2000/svg'
    viewBox='0 0 24 24'
    fill='currentColor'
    class='size-3'
  >
    <path
      fill-rule='evenodd'
      d='M9.528 1.718a.75.75 0 0 1 .162.819A8.97 8.97 0 0 0 9 6a9 9 0 0 0 9 9 8.97 8.97 0 0 0 3.463-.69.75.75 0 0 1 .981.98 10.503 10.503 0 0 1-9.694 6.46c-5.799 0-10.5-4.7-10.5-10.5 0-4.368 2.667-8.112 6.46-9.694a.75.75 0 0 1 .818.162Z'
      clip-rule='evenodd'
    />
  </svg>
</template>;

const Sun = <template>
  <svg
    xmlns='http://www.w3.org/2000/svg'
    viewBox='0 0 24 24'
    fill='currentColor'
    class='size-3'
  >
    <path
      d='M12 2.25a.75.75 0 0 1 .75.75v2.25a.75.75 0 0 1-1.5 0V3a.75.75 0 0 1 .75-.75ZM7.5 12a4.5 4.5 0 1 1 9 0 4.5 4.5 0 0 1-9 0ZM18.894 6.166a.75.75 0 0 0-1.06-1.06l-1.591 1.59a.75.75 0 1 0 1.06 1.061l1.591-1.59ZM21.75 12a.75.75 0 0 1-.75.75h-2.25a.75.75 0 0 1 0-1.5H21a.75.75 0 0 1 .75.75ZM17.834 18.894a.75.75 0 0 0 1.06-1.06l-1.59-1.591a.75.75 0 1 0-1.061 1.06l1.59 1.591ZM12 18a.75.75 0 0 1 .75.75V21a.75.75 0 0 1-1.5 0v-2.25A.75.75 0 0 1 12 18ZM7.758 17.303a.75.75 0 0 0-1.061-1.06l-1.591 1.59a.75.75 0 0 0 1.06 1.061l1.591-1.59ZM6 12a.75.75 0 0 1-.75.75H3a.75.75 0 0 1 0-1.5h2.25A.75.75 0 0 1 6 12ZM6.697 7.757a.75.75 0 0 0 1.06-1.06l-1.59-1.591a.75.75 0 0 0-1.061 1.06l1.59 1.591Z'
    />
  </svg>
</template>;
```

### Intent

```gts preview
import { Switch } from '@frontile/forms';

<template>
  <div class='flex gap-4'>
    <Switch @intent='default' @label='Default' @defaultSelected={{true}} />
    <Switch @intent='primary' @label='Primary' @defaultSelected={{true}} />
    <Switch @intent='success' @label='Success' @defaultSelected={{true}} />
    <Switch @intent='warning' @label='Warning' @defaultSelected={{true}} />
    <Switch @intent='danger' @label='Danger' @defaultSelected={{true}} />
  </div>
</template>
```

### Sizes

```gts preview
import { Switch } from '@frontile/forms';

<template>
  <div class='flex gap-4'>
    <Switch @size='sm' @label='Small' />
    <Switch @size='md' @label='Medium' />
    <Switch @size='lg' @label='large' />
  </div>
</template>
```

### Disabled

```gts preview
import Component from '@glimmer/component';
import { Switch } from '@frontile/forms';

export default class CustomContentSwitchExample extends Component {
  <template><Switch @label='Dark Mode' @isDisabled={{true}} /></template>
}
```

## API

<Signature @package="forms" @component="Switch" />
