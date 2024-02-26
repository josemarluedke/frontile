import Component from '@glimmer/component';
import { guidFor } from '@ember/object/internals';
import { hash } from '@ember/helper';
import Checkbox from './checkbox';
import Feedback from './form-feedback';
import Description from './form-description';
import Input from './input';
import Label from './label';
import Radio from './radio';
import Select from './select';
import NativeSelect from './native-select';
import Textarea from './textarea';
import type { WithBoundArgs } from '@glint/template';

// TODO add isInvalid to inputs, aria-invalid
// TODO add aria-describedby to inputs
// TODO allowClear or isClearable
// TODO Add Name ?

interface FormControlSignature {
  Args: {
    size?: 'sm' | 'md' | 'lg';

    label?: string;
    description?: string;
    errors?: string[] | string;

    isInvalid?: boolean;
    class?: string;

    isRequired?: boolean;
  };
  Blocks: {
    default: [
      {
        id: string;
        Label: WithBoundArgs<typeof Label, 'for' | 'size' | 'isRequired'>;
        Description: WithBoundArgs<typeof Description, 'id' | 'size'>;
        Feedback: WithBoundArgs<typeof Feedback, 'id' | 'size' | 'messages'>;
        Input: WithBoundArgs<typeof Input, 'id' | 'size'>;
        Textarea: WithBoundArgs<typeof Textarea, 'id' | 'size'>;
        Checkbox: WithBoundArgs<typeof Checkbox, 'id' | 'size'>;
        Radio: WithBoundArgs<typeof Radio, 'id' | 'size'>;
        NativeSelect: typeof NativeSelect;
        Select: typeof Select;
      }
    ];
    label: [];
    description: [];
  };
  Element: HTMLDivElement;
}

function or(arg1: unknown, arg2: unknown): boolean {
  return !!(arg1 || arg2);
}

class FormControl extends Component<FormControlSignature> {
  id = guidFor(this);

  get descriptionId(): string {
    return this.id + '-description';
  }

  get feedbackId(): string {
    return this.id + '-feedback';
  }

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

  get isInvalid(): boolean {
    if (
      this.args.isInvalid ||
      (this.args.errors && this.args.errors.length > 0)
    ) {
      return true;
    } else {
      return false;
    }
  }

  <template>
    <div ...attributes>
      {{#if (or @label (has-block "label"))}}
        <Label
          @for={{this.id}}
          @class={{this.classes.label}}
          @isRequired={{this.args.isRequired}}
        >
          {{@label}}
          {{yield to="label"}}
        </Label>
      {{/if}}

      {{#if (or @description (has-block "Description"))}}
        <Description
          @id={{this.descriptionId}}
          @class={{this.classes.description}}
        >
          {{@description}}
          {{yield to="description"}}
        </Description>
      {{/if}}

      {{! @glint-nocheck: NativeSelect and Select have type arguments, that does not work with WithBoundArgs}}
      {{yield
        (hash
          id=this.id
          Label=(component
            Label
            for=this.id
            size=@size
            isRequired=@isRequired
            class=this.classes.label
          )
          Description=(component
            Description
            id=this.descriptionId
            size=@size
            class=this.classes.description
          )
          Feedback=(component
            Feedback
            id=this.feedbackId
            size=@size
            class=this.classes.feedback
            messages=@errors
          )
          Input=(component Input id=this.id size=@size)
          Textarea=(component Textarea id=this.id size=@size)
          Checkbox=(component Checkbox id=this.id size=@size)
          Radio=(component Radio id=this.id size=@size)
          NativeSelect=(component NativeSelect id=this.id size=@size)
          Select=(component Select id=this.id size=@size)
        )
        to="default"
      }}

      {{#if this.isInvalid}}
        <Feedback
          @class={{this.classes.feedback}}
          @messages={{@errors}}
          @intent="danger"
        />
      {{/if}}
    </div>
  </template>
}

export { FormControl, type FormControlSignature };
export default FormControl;
