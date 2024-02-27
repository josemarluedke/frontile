import Component from '@glimmer/component';
import { guidFor } from '@ember/object/internals';
import { hash } from '@ember/helper';
import Feedback from './form-feedback';
import Description from './form-description';
import Label from './label';
import type { WithBoundArgs } from '@glint/template';

// TODO add isInvalid to inputs, aria-invalid
// TODO add aria-describedby to inputs
// TODO allowClear or isClearable
// TODO Add Name ?

interface FormControlSignature {
  Args: {
    id?: string;
    size?: 'sm' | 'md' | 'lg';
    label?: string;
    isRequired?: boolean;
    description?: string;
    errors?: string[] | string;
    isInvalid?: boolean;
    class?: string;
  };
  Blocks: {
    default: [
      {
        id: string;
        isInvalid: boolean;
        Label: WithBoundArgs<typeof Label, 'for' | 'size' | 'isRequired'>;
        Description: WithBoundArgs<typeof Description, 'id' | 'size'>;
        Feedback: WithBoundArgs<typeof Feedback, 'id' | 'size' | 'messages'>;
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
  id = this.args.id || guidFor(this);

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

      {{yield
        (hash
          id=this.id
          isInvalid=this.isInvalid
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
