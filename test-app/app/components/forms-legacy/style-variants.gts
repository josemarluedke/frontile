import FormInput from '@frontile/forms-legacy/components/form-input';
import FormTextarea from '@frontile/forms-legacy/components/form-textarea';
import FormCheckbox from '@frontile/forms-legacy/components/form-checkbox';
import FormCheckboxGroup from '@frontile/forms-legacy/components/form-checkbox-group';
import FormRadio from '@frontile/forms-legacy/components/form-radio';
import FormRadioGroup from '@frontile/forms-legacy/components/form-radio-group';

import Component from '@glimmer/component';

interface StyleVariantsArgs {}

export default class StyleVariants extends Component<StyleVariantsArgs> {
  <template>
    {{! @glint-nocheck }}
    <div class="pt-4 border-t">
      <h1
        class="mb-6 text-2xl font-bold inline-block border-b-4 border-primary"
      >
        FormInput
      </h1>

      <FormInput @label="First Name" placeholder="Placeholder" />

      <FormInput @label="First Name" @value="Robert" @containerClass="mt-4" />

      <FormInput
        @label="First Name"
        @hint="Your first name"
        @containerClass="mt-4"
      />

      <FormInput
        @label="First Name"
        @containerClass="mt-4"
        @errors="First name can't be blank"
        @hasSubmitted={{true}}
      />

      <FormInput @label="Disabled" @containerClass="mt-4" disabled={{true}} />
    </div>

    <div class="mt-8 pt-4 border-t">
      <h1
        class="mb-6 text-2xl font-bold inline-block border-b-4 border-primary"
      >
        FormTextarea
      </h1>

      <FormTextarea @label="Bio" placeholder="Placeholder" />

      <FormTextarea
        @label="Bio"
        @value="Lorem ipsum dolor sit amet, consetetur sadipscing elitr."
        @containerClass="mt-4"
      />

      <FormTextarea
        @label="Bio"
        @hint="Your biography"
        @containerClass="mt-4"
      />

      <FormTextarea
        @label="Bio"
        @containerClass="mt-4"
        @errors="Bio can't be blank"
        @hasSubmitted={{true}}
      />

      <FormTextarea
        @label="Disabled"
        @containerClass="mt-4"
        disabled={{true}}
      />
    </div>

    <div class="mt-8 pt-4 border-t">
      <h1
        class="mb-6 text-2xl font-bold inline-block border-b-4 border-primary"
      >
        FormCheckbox
      </h1>

      <FormCheckbox @checked={{false}} @label="Unchecked" />

      <FormCheckbox @label="Checked" @checked={{true}} @containerClass="mt-4" />

      <FormCheckbox
        @checked={{false}}
        @label="Disabled unchecked"
        disabled={{true}}
        @containerClass="mt-4"
      />

      <FormCheckbox
        @label="Disabled checked"
        @checked={{true}}
        disabled={{true}}
        @containerClass="mt-4"
      />

      <FormCheckbox
        @checked={{false}}
        @label="Unchecked with Hint"
        @hint="This is a hint"
        @containerClass="mt-4"
      />

      <FormCheckbox
        @label="Checked with Hint"
        @hint="This is a hint"
        @checked={{true}}
        @containerClass="mt-4"
      />
    </div>

    <div class="mt-8 pt-4 border-t">
      <h1
        class="mb-6 text-2xl font-bold inline-block border-b-4 border-primary"
      >
        FormCheckboxGroup
      </h1>

      <FormCheckboxGroup @label="Select multiple options" as |Checkbox|>
        <Checkbox @label="Options 1" />
        <Checkbox @checked={{true}} @label="Option 2" />
        <Checkbox @label="Option 3" />
      </FormCheckboxGroup>

      <FormCheckboxGroup
        @value="2"
        @label="Select multiple options"
        @hint="This is a hint in FormCheckboxGroup"
        @containerClass="mt-4"
        as |Checkbox|
      >
        <Checkbox @label="Options 1" />
        <Checkbox @checked={{true}} @label="Option 2" />
        <Checkbox @label="Option 3" />
      </FormCheckboxGroup>

      <FormCheckboxGroup
        @label="Select multiple options"
        @errors="Select at least one option"
        @hasSubmitted={{true}}
        @containerClass="mt-4"
        as |Checkbox|
      >
        <Checkbox @label="Options 1" />
        <Checkbox @label="Option 2" />
        <Checkbox @label="Option 3" />
      </FormCheckboxGroup>

      <FormCheckboxGroup
        @label="I'm an inline group"
        @isInline={{true}}
        @containerClass="mt-4"
        as |Checkbox|
      >
        <Checkbox @label="Options 1" />
        <Checkbox @checked={{true}} @label="Option 2" />
        <Checkbox @label="Option 3" />
      </FormCheckboxGroup>
    </div>

    <div class="mt-8 pt-4 border-t">
      <h1
        class="mb-6 text-2xl font-bold inline-block border-b-4 border-primary"
      >
        FormRadio
      </h1>

      <FormRadio @value={{false}} @label="Unchecked" />

      <FormRadio
        @label="Checked"
        @value={{true}}
        @checked={{true}}
        @containerClass="mt-4"
      />

      <FormRadio
        @value={{false}}
        @label="Disabled unchecked"
        disabled={{true}}
        @containerClass="mt-4"
      />

      <FormRadio
        @label="Disabled checked"
        @value={{true}}
        @checked={{true}}
        disabled={{true}}
        @containerClass="mt-4"
      />

      <FormRadio
        @value={{false}}
        @label="Unchecked with Hint"
        @hint="This is a hint"
        @containerClass="mt-4"
      />

      <FormRadio
        @label="Checked with Hint"
        @hint="This is a hint"
        @value={{true}}
        @checked={{true}}
        @containerClass="mt-4"
      />
    </div>

    <div class="my-8 pt-4 border-t">
      <h1
        class="mb-6 text-2xl font-bold inline-block border-b-4 border-primary"
      >
        FormRadioGroup
      </h1>

      <FormRadioGroup @value="2" @label="Select one option" as |Radio|>
        <Radio @value="1" @label="Options 1" />
        <Radio @value="2" @label="Option 2" />
        <Radio @value="3" @label="Option 3" />
      </FormRadioGroup>

      <FormRadioGroup
        @value="2"
        @label="Select one option"
        @hint="This is a hint in FormRadioGroup"
        @containerClass="mt-4"
        as |Radio|
      >
        <Radio @value="1" @label="Options 1" />
        <Radio @value="2" @label="Option 2" />
        <Radio @value="3" @label="Option 3" />
      </FormRadioGroup>

      <FormRadioGroup
        @value="2"
        @label="Select one option"
        @errors="The selected option is not valid"
        @hasSubmitted={{true}}
        @containerClass="mt-4"
        as |Radio|
      >
        <Radio @value="1" @label="Options 1" />
        <Radio @value="2" @label="Option 2" />
        <Radio @value="3" @label="Option 3" />
      </FormRadioGroup>

      <FormRadioGroup
        @value="2"
        @label="I'm an inline group"
        @isInline={{true}}
        @containerClass="mt-4"
        as |Radio|
      >
        <Radio @value="1" @label="Options 1" />
        <Radio @value="2" @label="Option 2" />
        <Radio @value="3" @label="Option 3" />
      </FormRadioGroup>
    </div>
  </template>
}
