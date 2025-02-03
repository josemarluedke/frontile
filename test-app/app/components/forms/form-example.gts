import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Button } from '@frontile/buttons';
import { hash } from '@ember/helper';
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
import { Spinner } from '@frontile/utilities';

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

const stringify = JSON.stringify;

const MyCustomLabel = <template>
  This is a custom label. <span class="text-danger">Cool right?</span>
</template> as never;

interface FormExampleArgs {}
export default class FormExample extends Component<FormExampleArgs> {
  @tracked data = {};

  onChange = (data: Record<string, string | File>) => {
    this.data = data;
  };

  <template>
    <Form @onChange={{this.onChange}} class="flex flex-1 flex-col gap-4">
      <Input
        @name="field-0"
        @label="field 0"
        @endContentPointerEvents="none"
        @startContentPointerEvents="none"
      >
        <:startContent>
          @
        </:startContent>
        <:endContent>
          <Spinner @size="sm" />
        </:endContent>
      </Input>

      <Input
        @name="field-1"
        @label={{MyCustomLabel}}
        @description="Cool field"
        @isRequired={{true}}
        @isClearable={{true}}
      />

      <Radio
        @value="field-2"
        @label="My field 2"
        @description="Nice nice nice"
        @errors="it should be cool, really cool"
        @classes={{hash label="text-primary"}}
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
        @inputSize="sm"
        @selectionMode="multiple"
        @items={{animals}}
        @placeholder="Select your favorite animals"
        @label="My field 5"
        @description="description"
        @errors="error message here"
        @isClearable={{true}}
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
        @orientation="horizontal"
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
        @orientation="horizontal"
        as |Checkbox|
      >
        <Checkbox @name="music" @label="Music" />
        <Checkbox @name="iot" @label="IoT" @description="Internet of things" />
        <Checkbox
          @checked={{true}}
          @name="enterntainment"
          @label="Entertainment"
          @description="Movies and TV series"
        />
      </CheckboxGroup>

      <div>
        <Button @type="submit">Submit</Button>
      </div>
    </Form>
    <pre>{{stringify this.data null 3}}</pre>
  </template>
}
