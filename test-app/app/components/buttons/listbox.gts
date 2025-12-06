import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { array } from '@ember/helper';
import { Listbox } from 'frontile';
import { Divider } from 'frontile';

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

export default class Example extends Component {
  @tracked selectedKeys: string[] = [];
  @tracked selectedKeys2: string[] = [];

  @action
  onAction(key: string) {
    // eslint-disable-next-line
    console.log('Click on key', key);
  }

  @action
  onSelectionChange(keys: string[]) {
    this.selectedKeys = keys;
  }

  @action
  onSelectionChange2(keys: string[]) {
    this.selectedKeys2 = keys;
  }

  <template>
    <div class="w-[260px] border px-1 py-2 rounded border-neutral-subtle mt-4">
      <Listbox
        @allowEmpty={{true}}
        @selectionMode="multiple"
        @items={{animals}}
        @onAction={{this.onAction}}
        @selectedKeys={{this.selectedKeys}}
        @onSelectionChange={{this.onSelectionChange}}
      >
        <:item as |o|>
          <o.Item @key={{o.item}} @intent="default" @appearance="faded">
            {{o.item}}
          </o.Item>
        </:item>
      </Listbox>
    </div>
    <Divider @class="my-8" />
    <div class="w-[260px] border px-1 py-2 rounded border-neutral-subtle">
      <Listbox
        @allowEmpty={{true}}
        @selectionMode="single"
        @items={{animals}}
        @selectedKeys={{this.selectedKeys2}}
        @onAction={{this.onAction}}
        @onSelectionChange={{this.onSelectionChange2}}
      />
    </div>
    <Divider @class="my-8" />
    <div class="w-[260px] border px-1 py-2 rounded border-neutral-subtle">
      <Listbox
        @isKeyboardEventsEnabled={{true}}
        @onAction={{this.onAction}}
        @disabledKeys={{(array "notifications")}}
      >
        <:default as |l|>
          <l.Item @key="profile" @description="View my profile">
            My Profile
          </l.Item>
          <l.Item @key="settings" @shortcut="⌘⇧S">Settings</l.Item>
          <l.Item @key="notifications" @shortcut="⌘⇧N" @withDivider={{true}}>
            Notifications
          </l.Item>
          <l.Item @key="reset" @intent="danger" @class="text-danger">
            Reset Settings
          </l.Item>
          <l.Item
            @key="delete"
            @shortcut="⌘⇧D"
            @intent="danger"
            @appearance="faded"
            @class="text-danger"
          >
            Delete Account
          </l.Item>
        </:default>
      </Listbox>
    </div>
  </template>
}
