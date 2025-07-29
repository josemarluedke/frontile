---
label: New
imports:
  - import Signature from 'site/components/signature';
---
# Listbox

A listbox presents a collection of items, offering the user the option to select 
or not, one or multiple items from the list. This component serves as the foundation 
for Select, Dropdowns, and other similar components.

## Import 

```js
import { Listbox } from '@frontile/collections';
```

## Usage

In the example below, the listbox is configured in a multi-select mode, featuring 
a dynamic item list, and it permits an empty selection (no items chosen).

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Listbox } from '@frontile/collections';

export default class DemoComponent extends Component {
  @tracked selectedKeys: string[] = [];

  @action
  onAction(key: string) {
    console.log('Click on key', key);
  }

  @action
  onSelectionChange(keys: string[]) {
    this.selectedKeys = keys;
  }

  <template>
    <div class="w-[260px] border px-1 py-2 rounded border-default-200 text-foreground not-prose">
      <Listbox
        @isKeyboardEventsEnabled={{true}}
        @allowEmpty={{true}}
        @selectionMode="multiple"
        @items={{animals}}
        @selectedKeys={{this.selectedKeys}}
        @onSelectionChange={{this.onSelectionChange}}
        @onAction={{this.onAction}}
        @intent="primary"
      />
    </div>
    <div class="py-2 px-1">
      Selected Keys: "{{this.selectedKeys}}"
    </div>
  </template>
}

const animals = [
  'cheetah',
  'crocodile',
  'elephant',
  'giraffe',
  'kangaroo',
  'koala',
  'lemming',
  'lemur',
  'lion',
  'lobster',
  'panda',
  'penguin',
  'tiger',
  'zebra'
];
```

## Static items


In this example, static items are showcased, incorporating various features such as 
shortcuts and distinct intents, all within a no-selection mode.

```gts preview
import Component from '@glimmer/component';
import { action } from '@ember/object';
import { Listbox } from '@frontile/collections';

const disabledKeys = ['reset']

export default class DemoComponent extends Component {

  @action
  onAction(key: string) {
    console.log('Click on key', key);
  }

  <template>
    <div class="w-[260px] border px-1 py-2 rounded border-default-200 text-foreground not-prose">
      <Listbox
        @isKeyboardEventsEnabled={{true}}
        @onAction={{this.onAction}}
        @appearance="faded"
        @disabledKeys={{disabledKeys}}
        as |l|
      >
        <l.Item @key="profile" @description="View my profile">
          My Profile
        </l.Item>
        <l.Item @key="settings" @shortcut="⌘⇧S">Settings</l.Item>
        <l.Item @key="notifications" @shortcut="⌘⇧N" @withDivider={{true}}>
          Notifications
        </l.Item>
        <l.Item
          @key="reset"
          @intent="danger"
          @class="text-danger"
        >
          Reset Settings 
        </l.Item>
        <l.Item
          @key="delete"
          @shortcut="⌘⇧D"
          @intent="danger"
          @class="text-danger"
        >
          Delete Account
        </l.Item>
      </Listbox>
    </div>
  </template>
}
```

Kindly be aware that the implementation of shortcut event handling is your responsibility.

## API

<Signature @component="Listbox" />
<Signature @component="ListboxItem" />
