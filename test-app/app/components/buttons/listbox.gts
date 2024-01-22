import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { array } from '@ember/helper';
import { Listbox, Divider } from '@frontile/buttons';

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
  onChange(value: boolean): void {
    this.isSelected = value;
  }

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
    <div class="w-[260px] border px-1 py-2 rounded border-default-200 mt-4">
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
    <div class="w-[260px] border px-1 py-2 rounded border-default-200">
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
    <div class="w-[260px] border px-1 py-2 rounded border-default-200">
      <Listbox
        @isKeyboardEventsEnabled={{true}}
        @onAction={{this.onAction}}
        @disabledKeys={{(array "option-3" "option-4")}}
        as |l|
      >
        <l.Item
          @key="option-1"
          @shortcut="⌘⇧E"
          @description="this is a cool option"
          @intent="warning"
          @appearance="faded"
        >
          <:default>
            Items 1
          </:default>
        </l.Item>
        <l.Item @key="option-2" @shortcut="⌘⇧C">Items 2</l.Item>
        <l.Item @key="option-3">B something 1</l.Item>
        <l.Item @key="option-4" @withDivider={{true}}>C something 1</l.Item>
        <l.Item
          @key="option-5"
          @shortcut="⌘⇧B"
          @intent="danger"
          @appearance="faded"
          @class="text-danger"
        >A something 1</l.Item>
      </Listbox>
    </div>
  </template>
}
