import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { FormControl } from '@frontile/forms';
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

interface FormExampleArgs {}

export default class FormExample extends Component<FormExampleArgs> {
  <template>
    <FormControl
      @label="My field"
      @description="Cool field"
      @errors="it should be cool"
      as |c|
    >
      <c.Input />
    </FormControl>

    <FormControl
      @label="My field 2"
      @description="Nice nice nice"
      @errors="it should be cool, really cool"
      as |c|
    >
      <c.Radio @value="a" />
    </FormControl>

    <FormControl
      @label="My field 3"
      @description="description"
      @errors="error message here"
      as |c|
    >
      <c.Checkbox @checked={{true}} />
    </FormControl>

    <FormControl
      @label="My field 4"
      @description="description"
      @errors="error message here"
      as |c|
    >
      <c.Textarea />
    </FormControl>

    <FormControl
      @label="My field 5"
      @description="description"
      @errors="error message here"
      as |c|
    >
      <c.Select
        @selectionMode="multiple"
        @items={{animals}}
        @selectedKeys={{this.selectedKeys}}
        @onSelectionChange={{this.onSelectionChange}}
        @placeholder="Select your favorite animals"
      >
        <:item as |o|>
          <o.Item @key={{o.item}} @intent="default" @appearance="faded">
            {{o.item}}
          </o.Item>
        </:item>
      </c.Select>
    </FormControl>

    <FormControl
      @label="My field 5"
      @description="description"
      @errors="error message here"
      as |c|
    >
      <c.NativeSelect
        @items={{animals}}
        @selectedKeys={{this.selectedKeys}}
        @onSelectionChange={{this.onSelectionChange}}
        @placeholder="Select your favorite animals"
      >
        <:item as |o|>
          <o.Item @key={{o.item}}>
            {{o.item}}
          </o.Item>
        </:item>
      </c.NativeSelect>
    </FormControl>
  </template>
}
