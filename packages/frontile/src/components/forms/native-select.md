---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# NativeSelect

A select built on the browser's own `<select>` element, styled to match the rest of the form components. Reach for it when you want the platform's picker — the native dropdown on mobile, the OS list box on desktop — instead of the custom listbox that [Select](./select) renders.

## Import

```js
import { NativeSelect } from 'frontile';
```

## Usage

Pass a collection to `@items` and read the selection back from `@onSelectionChange`. Strings and numbers are used as both the key and the label.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { NativeSelect } from 'frontile';

const animals = ['Cheetah', 'Crocodile', 'Elephant'];

export default class NativeSelectUsage extends Component {
  @tracked selectedKey: string | null = 'Cheetah';

  onSelectionChange = (key: string | null) => {
    this.selectedKey = key;
  };

  <template>
    <NativeSelect
      @label='Favorite animal'
      @items={{animals}}
      @selectedKey={{this.selectedKey}}
      @onSelectionChange={{this.onSelectionChange}}
    />
    <p class='mt-4 text-sm text-neutral'>Selected: {{this.selectedKey}}</p>
  </template>
}
```

The component is controlled. `@selectedKey` is what the user sees selected, so it has to be updated from `@onSelectionChange` — without that, the browser's change is reverted on the next render.

## Items

Objects work too. The key comes from `key` or `id`, and the label from `label`, `value`, `name` or `title`. Anything else needs the `:item` block, which yields the raw item along with an `Item` component to render it with.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { NativeSelect } from 'frontile';

const countries = [
  { code: 'br', country: 'Brazil' },
  { code: 'ca', country: 'Canada' },
  { code: 'jp', country: 'Japan' }
];

export default class NativeSelectItemBlock extends Component {
  @tracked selectedKey: string | null = null;

  onSelectionChange = (key: string | null) => {
    this.selectedKey = key;
  };

  <template>
    <NativeSelect
      @label='Country'
      @items={{countries}}
      @selectedKey={{this.selectedKey}}
      @onSelectionChange={{this.onSelectionChange}}
    >
      <:item as |o|>
        <o.Item @key={{o.item.code}}>{{o.item.country}}</o.Item>
      </:item>
    </NativeSelect>
    <p class='mt-4 text-sm text-neutral'>Selected: {{this.selectedKey}}</p>
  </template>
}
```

When the options are a fixed, hand-written list, drop `@items` entirely and use the default block, which yields the same `Item` component.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { array } from '@ember/helper';
import { NativeSelect } from 'frontile';

export default class NativeSelectStaticItems extends Component {
  @tracked selectedKey: string | null = 'standard';

  onSelectionChange = (key: string | null) => {
    this.selectedKey = key;
  };

  <template>
    <NativeSelect
      @label='Shipping'
      @selectedKey={{this.selectedKey}}
      @disabledKeys={{(array 'overnight')}}
      @onSelectionChange={{this.onSelectionChange}}
      as |l|
    >
      <l.Item @key='standard'>Standard — 5 business days</l.Item>
      <l.Item @key='express'>Express — 2 business days</l.Item>
      <l.Item @key='overnight'>Overnight — unavailable</l.Item>
    </NativeSelect>
  </template>
}
```

`@disabledKeys` renders those options as disabled: still listed, still announced, not selectable.

## Empty Option

A native `<select>` always has something selected, so an initial "nothing chosen" state has to be a real option. `@allowEmpty` adds one, labeled with `@placeholder`, and picking it reports `null`.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { NativeSelect } from 'frontile';

const roles = ['Owner', 'Editor', 'Viewer'];

export default class NativeSelectAllowEmpty extends Component {
  @tracked selectedKey: string | null = null;

  onSelectionChange = (key: string | null) => {
    this.selectedKey = key;
  };

  <template>
    <NativeSelect
      @label='Role'
      @items={{roles}}
      @allowEmpty={{true}}
      @placeholder='Select a role'
      @selectedKey={{this.selectedKey}}
      @onSelectionChange={{this.onSelectionChange}}
    />
    <p class='mt-4 text-sm text-neutral'>Selected:
      {{if this.selectedKey this.selectedKey 'none'}}</p>
  </template>
}
```

## Multiple Selection

`@selectionMode='multiple'` renders the native multi-select list box. The state arguments change with it: use `@selectedKeys` instead of `@selectedKey`, and `@onSelectionChange` receives an array. Mixing them logs a warning.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { NativeSelect } from 'frontile';

const languages = ['Elixir', 'Go', 'Rust', 'TypeScript'];

export default class NativeSelectMultiple extends Component {
  @tracked selectedKeys: string[] = ['Rust'];

  onSelectionChange = (keys: string[]) => {
    this.selectedKeys = keys;
  };

  <template>
    <NativeSelect
      @label='Languages'
      @description='Hold Cmd or Ctrl to select more than one.'
      @selectionMode='multiple'
      @items={{languages}}
      @selectedKeys={{this.selectedKeys}}
      @onSelectionChange={{this.onSelectionChange}}
    />
  </template>
}
```

## Sizes

`@size` accepts `sm`, `md` (the default) and `lg`, matching the other form controls.

```gts preview
import { array, concat } from '@ember/helper';
import { NativeSelect } from 'frontile';

const plans = ['Basic', 'Pro'];

<template>
  <div class='flex flex-col gap-4'>
    {{#each (array 'sm' 'md' 'lg') as |size|}}
      <NativeSelect
        @label={{concat 'Plan (' size ')'}}
        @size={{size}}
        @items={{plans}}
      />
    {{/each}}
  </div>
</template>
```

## Description and Validation

NativeSelect is built on the same `FormControl` as the other form components, so `@label`, `@description`, `@isRequired`, `@errors` and `@isInvalid` behave identically. Errors are wired to the control through `aria-describedby` and set `aria-invalid`.

```gts preview
import { array } from '@ember/helper';
import { NativeSelect } from 'frontile';

const environments = ['Development', 'Staging', 'Production'];

<template>
  <div class='flex flex-col gap-4'>
    <NativeSelect
      @label='Environment'
      @description='Where the build will be deployed.'
      @isRequired={{true}}
      @items={{environments}}
    />

    <NativeSelect
      @label='Environment'
      @errors={{(array 'Select an environment to continue.')}}
      @allowEmpty={{true}}
      @placeholder='Select an environment'
      @items={{environments}}
    />
  </div>
</template>
```

## Start and End Content

The `:startContent` and `:endContent` named blocks place content inside the control. The chevron the component draws stays at the end, after whatever `:endContent` yields.

By default pointer events pass through end content to the select and are captured by start content; `@startContentPointerEvents` and `@endContentPointerEvents` flip that when the content itself needs to be clickable.

```gts preview
import { NativeSelect } from 'frontile';
import { SearchIcon } from 'site/components/icons';

const teams = ['Design', 'Engineering', 'Support'];

<template>
  <NativeSelect @label='Team' @items={{teams}}>
    <:startContent>
      <SearchIcon class='size-icon-md text-neutral' />
    </:startContent>
  </NativeSelect>
</template>
```

## Accessibility

NativeSelect renders a real `<select>`, so keyboard behavior, type-ahead and the mobile picker are the browser's own and match whatever the user's platform does elsewhere. That is the main reason to choose it over `Select`.

| Key                                                                                    | Behavior                                          |
| -------------------------------------------------------------------------------------- | ------------------------------------------------- |
| <kbd>Space</kbd> / <kbd>Alt</kbd> + <kbd>↓</kbd>                                       | Open the picker (browser dependent)               |
| <kbd>↑</kbd> / <kbd>↓</kbd>                                                            | Move through options                              |
| <kbd>Home</kbd> / <kbd>End</kbd>                                                       | First / last option                               |
| Printable characters                                                                   | Jump to the option starting with those characters |
| <kbd>Enter</kbd> / <kbd>Esc</kbd>                                                      | Commit / dismiss the open picker                  |
| <kbd>Cmd</kbd> / <kbd>Ctrl</kbd> + click, <kbd>Shift</kbd> + <kbd>↑</kbd>/<kbd>↓</kbd> | Extend the selection in `multiple` mode           |

The component's own responsibilities:

- `@label` renders a `<label>` bound to the select by `id`. Always provide it — there is no visual affordance that substitutes for it, and an unlabeled select is announced only by its current value.
- `@description` and `@errors` are referenced through `aria-describedby`, and an invalid control gets `aria-invalid="true"`.
- `@disabledKeys` sets the `disabled` attribute on the corresponding `<option>`, which screen readers announce as unavailable.
- The chevron is decorative and is not exposed to assistive technology.

For multiple selection, say so in `@description` as the demo above does: nothing in the native list box announces that Cmd or Ctrl extends the selection, and it is the most commonly missed interaction in the component.

## API

<Signature @component="NativeSelect" />
<Signature @component="NativeSelectItem" />
