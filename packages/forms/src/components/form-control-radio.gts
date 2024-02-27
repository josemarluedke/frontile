import Component from '@glimmer/component';
import { FormControl, type FormControlSignature } from './form-control';
import type { RadioSignature } from './radio';

interface FormControlRadioSignatureArgs
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
    Pick<RadioSignature['Args'], 'checked' | 'value' | 'name' | 'onChange'> {}

interface FormControlRadioSignature {
  Args: FormControlRadioSignatureArgs;
  Blocks: {
    default: [];
  };
  Element: HTMLInputElement;
}

class FormControlRadio extends Component<FormControlRadioSignature> {
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
        <c.Radio
          @name={{@name}}
          @value={{@value}}
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

export { FormControlRadio, type FormControlRadioSignature };
export default FormControlRadio;
