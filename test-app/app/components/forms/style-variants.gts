import Component from '@glimmer/component';
import type { TOC } from '@ember/component/template-only';
import {
  Input,
  Checkbox,
  Radio,
  Textarea,
  NativeSelect,
  Select,
  RadioGroup,
  CheckboxGroup
} from 'frontile';

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

const selectedAnimals = ['elephant'];

interface StyleVariantsArgs {}

const Title: TOC<{ Blocks: { default: [] } }> = <template>
  <h1 class="mb-4 text-2xl font-bold inline-block border-b-4 border-primary">
    {{yield}}
  </h1>
</template>;

export default class StyleVariants extends Component<StyleVariantsArgs> {
  <template>
    <div class="pt-4 flex flex-1 flex-col gap-4">
      <Title>Input</Title>

      <Input @label="First Name" placeholder="Placeholder" />

      <Input @label="First Name" @value="Robert" />

      <Input @label="First Name" @description="Your first name" />

      <Input @label="First Name" @errors="First name can't be blank" />

      <Input @label="Disabled" disabled={{true}} />
    </div>

    <div class="pt-4 flex flex-1 flex-col gap-4">
      <Title>Select</Title>

      <Select @label="Animals" @items={{animals}} @placeholder="Placeholder" />

      <Select
        @label="Animals"
        @items={{animals}}
        @selectedKeys={{selectedAnimals}}
      />

      <Select
        @label="Animals"
        @items={{animals}}
        @description="a list of animals"
      />

      <Select @label="Animals" @items={{animals}} @errors="select an animal" />
      <Select @label="Animals" @items={{animals}} @isDisabled={{true}} />
    </div>

    <div class="mt-8 pt-4 flex flex-1 flex-col gap-4">
      <Title>Textarea</Title>

      <Textarea @label="Bio" placeholder="Placeholder" />

      <Textarea
        @label="Bio"
        @value="Lorem ipsum dolor sit amet, consetetur sadipscing elitr."
      />

      <Textarea @label="Bio" @description="Your biography" />

      <Textarea @label="Bio" @errors="Bio can't be blank" />

      <Textarea @label="Disabled" disabled={{true}} />
    </div>

    <div class="pt-4 flex flex-1 flex-col gap-4">
      <Title>NativeSelect</Title>

      <NativeSelect
        @label="Animals"
        @items={{animals}}
        @placeholder="Placeholder"
      />

      <NativeSelect
        @label="Animals"
        @items={{animals}}
        @selectedKeys={{selectedAnimals}}
      />

      <NativeSelect
        @label="Animals"
        @items={{animals}}
        @description="a list of animals"
      />

      <NativeSelect
        @label="Animals"
        @items={{animals}}
        @errors="select an animal"
      />
      <NativeSelect @label="Animals" @items={{animals}} disabled={{true}} />
    </div>

    <div class="mt-8 pt-4 flex flex-1 flex-col gap-4">
      <Title>
        Checkbox
      </Title>

      <Checkbox @checked={{false}} @label="Unchecked" />

      <Checkbox @label="Checked" @checked={{true}} />

      <Checkbox
        @checked={{false}}
        @label="Disabled unchecked"
        disabled={{true}}
      />

      <Checkbox @label="Disabled checked" @checked={{true}} disabled={{true}} />

      <Checkbox
        @checked={{false}}
        @label="Unchecked with description"
        @description="This is a description"
      />

      <Checkbox
        @label="Checked with description"
        @description="This is a description"
        @checked={{true}}
      />
    </div>

    <div class="mt-8 pt-4 flex flex-1 flex-col gap-4">
      <Title>
        CheckboxGroup
      </Title>

      <CheckboxGroup @label="Select multiple options" as |Checkbox|>
        <Checkbox @label="Options 1" />
        <Checkbox @checked={{true}} @label="Option 2" />
        <Checkbox @label="Option 3" />
      </CheckboxGroup>

      <CheckboxGroup
        @label="Select multiple options"
        @description="This is a description in CheckboxGroup"
        as |Checkbox|
      >
        <Checkbox @label="Options 1" />
        <Checkbox @checked={{true}} @label="Option 2" />
        <Checkbox @label="Option 3" />
      </CheckboxGroup>

      <CheckboxGroup
        @label="Select multiple options"
        @errors="Select at least one option"
        as |Checkbox|
      >
        <Checkbox @label="Options 1" />
        <Checkbox @label="Option 2" />
        <Checkbox @label="Option 3" />
      </CheckboxGroup>

      <CheckboxGroup
        @label="I'm a horizontal group"
        @orientation="horizontal"
        as |Checkbox|
      >
        <Checkbox @label="Options 1" />
        <Checkbox @checked={{true}} @label="Option 2" />
        <Checkbox @label="Option 3" />
      </CheckboxGroup>
    </div>

    <div class="mt-8 pt-4 flex flex-1 flex-col gap-4">
      <Title>
        Radio
      </Title>

      <Radio @value="false" @label="Unchecked" />

      <Radio @label="Checked" @value={{true}} @checkedValue={{true}} />

      <Radio @value="false" @label="Disabled unchecked" disabled={{true}} />

      <Radio
        @label="Disabled checked"
        @value="true"
        @checkedValue="true"
        disabled={{true}}
      />

      <Radio
        @value="false"
        @label="Unchecked with description"
        @description="This is a description"
      />

      <Radio
        @label="Checked with description"
        @description="This is a description"
        @value="true"
        @checkedValue="true"
      />
    </div>

    <div class="my-8 pt-4 flex flex-1 flex-col gap-4">
      <Title>
        RadioGroup
      </Title>

      <RadioGroup @value="2" @label="Select one option" as |Radio|>
        <Radio @value="1" @label="Options 1" />
        <Radio @value="2" @label="Option 2" />
        <Radio @value="3" @label="Option 3" />
      </RadioGroup>

      <RadioGroup
        @value="2"
        @label="Select one option"
        @description="This is a description in RadioGroup"
        as |Radio|
      >
        <Radio @value="1" @label="Options 1" />
        <Radio @value="2" @label="Option 2" />
        <Radio @value="3" @label="Option 3" />
      </RadioGroup>

      <RadioGroup
        @value="2"
        @label="Select one option"
        @errors="The selected option is not valid"
        as |Radio|
      >
        <Radio @value="1" @label="Options 1" />
        <Radio @value="2" @label="Option 2" />
        <Radio @value="3" @label="Option 3" />
      </RadioGroup>

      <RadioGroup
        @value="2"
        @label="I'm a horizontal group"
        @orientation="horizontal"
        as |Radio|
      >
        <Radio @value="1" @label="Options 1" />
        <Radio @value="2" @label="Option 2" />
        <Radio @value="3" @label="Option 3" />
      </RadioGroup>
    </div>
  </template>
}
