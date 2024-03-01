import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Button } from '@frontile/buttons';
import {
  Form,
  Input,
  Checkbox,
  Radio,
  Textarea,
  NativeSelect,
  Select,
  RadioGroup,
  CheckboxGroup
} from '@frontile/forms';
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
  @tracked data = {};

  onChange = (data: Record<string, string | File>) => {
    this.data = data;
  };

  <template>
    <Form @onChange={{this.onChange}} enctype="multipart/form-data">
      <Input
        @name="field-1"
        @label="My field"
        @description="Cool field"
        @isRequired={{true}}
      />

      <Radio
        @value="field-2"
        @label="My field 2"
        @description="Nice nice nice"
        @errors="it should be cool, really cool"
      />

      <Checkbox
        @name="field-3"
        @label="My field 3"
        @description="description"
        @errors="error message here"
        @checked={{true}}
      />

      <Textarea
        @name="field-4"
        @label="My field 4"
        @description="description"
        @errors="error message here"
      />

      <Select
        @name="all-fav-animals"
        @selectionMode="multiple"
        @items={{animals}}
        @placeholder="Select your favorite animals"
        @label="My field 5"
        @description="description"
        @errors="error message here"
      >
        <:item as |o|>
          <o.Item @key={{o.item}} @intent="default" @appearance="faded">
            {{o.item}}
          </o.Item>
        </:item>
      </Select>

      <NativeSelect
        @items={{animals}}
        @placeholder="Select your favorite animals"
        @name="favoriteAnimal"
        @label="My field 5"
        @description="description"
        @errors="error message here"
      >
        <:item as |o|>
          <o.Item @key={{o.item}}>
            {{o.item}}
          </o.Item>
        </:item>
      </NativeSelect>
      <RadioGroup
        @label="Account Type"
        @errors="Please select an account"
        @name="accountType"
        @value="personal"
        as |Radio|
      >
        <Radio @value="personal" @label="Personal" />
        <Radio
          @value="business"
          @label="Business"
          @description="If this account is for business"
        />
        <Radio @value="other" @label="Other" />
      </RadioGroup>

      <CheckboxGroup
        @label="Interests"
        @errors="Please select an intereset"
        as |Checkbox|
      >
        <Checkbox @name="iot" @label="IoT" @description="Internet of things" />
        <Checkbox @name="music" @label="Music" />
        <Checkbox
          @checked={{true}}
          @name="enterntainment"
          @label="Entertainment"
          @description="Movies and TV series"
        />
      </CheckboxGroup>

      <Button @type="submit">Submit</Button>
    </Form>
    <pre>{{JSON.stringify this.data null 3}}</pre>
  </template>
}
