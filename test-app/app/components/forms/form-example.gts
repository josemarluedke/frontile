import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Button } from '@frontile/buttons';
import {
  Form,
  FormControl,
  FormControlCheckbox,
  FormControlRadio
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
    <Form @onChange={{this.onChange}}>
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
        @name="favoriteAnimal"
        @label="My field 5"
        @description="description"
        @errors="error message here"
        as |c|
      >
        <c.NativeSelect
          @items={{animals}}
          @placeholder="Select your favorite animals"
        >
          <:item as |o|>
            <o.Item @key={{o.item}}>
              {{o.item}}
            </o.Item>
          </:item>
        </c.NativeSelect>
      </FormControl>

      <FormControlCheckbox
        @label="Do you agree with the terms?"
        @name="accept"
        @errors="you must accept"
      />

      <FormControlRadio
        @label="Yellow"
        @value="yellow"
        @errors="Yellow is cool"
      />

      <FormControl
        @label="Account Type"
        @errors="Please select an account"
        @name="accountType"
        as |c|
      >
        <c.RadioGroup @value="personal" as |r|>
          <r.ControlRadio @value="personal" @label="Personal" />
          <r.ControlRadio
            @value="business"
            @label="Business"
            @description="If this account is for business"
          />
          <r.ControlRadio @value="other" @label="Other" />
        </c.RadioGroup>
      </FormControl>

      <FormControl
        @label="Interests"
        @errors="Please select an intereset"
        as |c|
      >
        <c.CheckboxGroup as |g|>
          <g.ControlCheckbox
            @name="iot"
            @label="IoT"
            @description="Internet of things"
          />
          <g.ControlCheckbox @name="music" @label="Music" />
          <g.ControlCheckbox
            @checked={{true}}
            @name="enterntainment"
            @label="Entertainment"
            @description="Movies and TV series"
          />
        </c.CheckboxGroup>
      </FormControl>

      <Button @type="submit">Submit</Button>
    </Form>
    <pre>{{JSON.stringify this.data null 3}}</pre>
  </template>
}
