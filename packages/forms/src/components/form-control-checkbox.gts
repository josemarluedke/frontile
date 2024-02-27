import Component from '@glimmer/component';
import { FormControl, type FormControlSignature } from './form-control';
import type { CheckboxSignature } from './checkbox';

interface FormControlCheckboxSignatureArgs
  extends Pick<
      FormControlSignature['Args'],
      | 'class'
      | 'isInvalid'
      | 'isRequired'
      | 'size'
      | 'errors'
      | 'label'
      | 'description'
    >,
    Pick<CheckboxSignature['Args'], 'checked' | 'name' | 'onChange'> {}

interface FormControlCheckboxSignature {
  Args: FormControlCheckboxSignatureArgs;
  Blocks: {
    default: [];
  };
  Element: HTMLInputElement;
}

class FormControlCheckbox extends Component<FormControlCheckboxSignature> {
  get classes() {
    // const { formControl } = useStyles();
    // const { base, label, description, feedback } = formControl({
    //   size: this.args.size
    // });
    // return {
    //   base: base({
    //     class: this.args.class
    //   }),
    //   label: label(),
    //   description: description(),
    //   feedback: feedback()
    // };
    return {
      base: '',
      label: '',
      description: '',
      feedback: ''
    };
  }

  <template>
    <FormControl
      @isInvalid={{@isInvalid}}
      @errors={{@errors}}
      @class={{@class}}
      @size={{@size}}
      @isRequired={{@isRequired}}
      as |c|
    >
      <div class={{this.classes.base}}>
        <c.Checkbox
          @name={{@name}}
          @checked={{@checked}}
          @onChange={{@onChange}}
          ...attributes
        />
        <div>
          {{#if @label}}
            <c.Label>{{@label}}</c.Label>
          {{/if}}
          {{#if @description}}
            <c.Description>{{@description}}</c.Description>
          {{/if}}
        </div>
      </div>
    </FormControl>
  </template>
}

export { FormControlCheckbox, type FormControlCheckboxSignature };
export default FormControlCheckbox;
