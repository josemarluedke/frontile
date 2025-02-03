import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { array } from '@ember/helper';
import { Select } from '@frontile/forms';
import { Divider } from '@frontile/utilities';

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

const animalsAsOject = [
  { key: 'cheetah', label: 'Cheetah' },
  { key: 'crocodile', label: 'Crocodile' },
  { key: 'elephant', label: 'Elephant' },
  { key: 'giraffe', label: 'Giraffe' },
  { key: 'kangaroo', label: 'Kangaroo' },
  { key: 'koala', label: 'Koala' },
  { key: 'lemming', label: 'Lemming' },
  { key: 'lemur', label: 'Lemur' },
  { key: 'lion', label: 'Lion' },
  { key: 'lobster', label: 'Lobster' },
  { key: 'panda', label: 'Panda' },
  { key: 'penguin', label: 'Penguin' },
  { key: 'tiger', label: 'Tiger' },
  { key: 'zebra', label: 'Zebra' }
];

export default class Example extends Component {
  @tracked selectedKeys: string[] = [];
  @tracked selectedKeys2: string[] = ['elephant'];
  @tracked selectedKeys3: string[] = [];

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

  @action
  onSelectionChange3(keys: string[]) {
    this.selectedKeys3 = keys;
  }

  <template>
    <Select
      @selectionMode="multiple"
      @items={{animals}}
      @onAction={{this.onAction}}
      @selectedKeys={{this.selectedKeys}}
      @onSelectionChange={{this.onSelectionChange}}
      @placeholder="Select your favorite animals"
    >
      <:item as |o|>
        <o.Item @key={{o.item}} @intent="default" @appearance="faded">
          {{o.item}}
        </o.Item>
      </:item>
    </Select>
    Values:
    {{this.selectedKeys}}
    <Divider @class="my-8" />
    <Select
      @isFilterable={{true}}
      @placeholder="Select an animal"
      @allowEmpty={{true}}
      @selectionMode="single"
      @items={{animalsAsOject}}
      @intent="primary"
      @selectedKeys={{this.selectedKeys2}}
      @onAction={{this.onAction}}
      @onSelectionChange={{this.onSelectionChange2}}
    />
    Values:
    {{this.selectedKeys2}}
    <Divider @class="my-8" />
    <Select
      @disableTransitions={{true}}
      @onAction={{this.onAction}}
      @disabledKeys={{(array "notifications")}}
      @selectedKeys={{this.selectedKeys3}}
      @onSelectionChange={{this.onSelectionChange3}}
      @isDisabled={{true}}
      as |l|
    >
      <l.Item @key="profile" @description="View my profile">
        My Profile
      </l.Item>
      <l.Item @key="settings" @shortcut="⌘⇧S">Settings</l.Item>
      <l.Item @key="notifications" @shortcut="⌘⇧N" @withDivider={{true}}>
        Notifications
      </l.Item>
      <l.Item @key="reset" @intent="danger" @class="text-danger">
        <:start>
          <div>Start</div>
        </:start>
        <:default>
          Reset Settings
        </:default>
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
    </Select>
    Values:
    {{this.selectedKeys3}}
  </template>
}
