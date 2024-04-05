import Component from '@glimmer/component';
import { guidFor } from '@ember/object/internals';
import { hash } from '@ember/helper';
import Feedback from './form-feedback';
import Description from './form-description';
import Label from './label';
import type { WithBoundArgs } from '@glint/template';

interface FormControlSharedArgs {
  label?: string;
  isRequired?: boolean;
  description?: string;
  errors?: string[] | string;
  isInvalid?: boolean;
}

interface Args extends FormControlSharedArgs {
  id?: string;
  size?: 'sm' | 'md' | 'lg';
  preventErrorFeedback?: boolean;
  class?: string;
}

interface FormControlSignature {
  Args: Args;
  Blocks: {
    default: [
      {
        id: string;
        isInvalid: boolean;
        describedBy: (
          hasDescription?: string | boolean,
          hasFeedback?: string | boolean
        ) => string | undefined;
        Label: WithBoundArgs<typeof Label, 'for' | 'size' | 'isRequired'>;
        Description: WithBoundArgs<typeof Description, 'id' | 'size'>;
        Feedback: WithBoundArgs<
          typeof Feedback,
          'id' | 'size' | 'messages' | 'intent'
        >;
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

  describedBy = (
    hasDescription?: string | boolean,
    hasFeedback?: string | boolean
  ): string | undefined => {
    const ids = [];

    if (hasDescription) {
      ids.push(this.descriptionId);
    }

    if (hasFeedback) {
      ids.push(this.feedbackId);
    }

    if (ids.length > 0) {
      return ids.join(' ');
    }
  };

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

  get showErrorFeedback(): boolean {
    if (!(this.args.preventErrorFeedback === true) && this.isInvalid) {
      return true;
    }
    return false;
  }

  <template>
    <div class={{@class}} ...attributes>
      {{#if (or @label (has-block "label"))}}
        <Label @for={{this.id}} @isRequired={{@isRequired}} @size={{@size}}>
          {{@label}}
          {{yield to="label"}}
        </Label>
      {{/if}}

      {{#if (or @description (has-block "Description"))}}
        <Description @id={{this.descriptionId}} @size={{@size}}>
          {{@description}}
          {{yield to="description"}}
        </Description>
      {{/if}}

      {{yield
        (hash
          id=this.id
          isInvalid=this.isInvalid
          describedBy=this.describedBy
          Label=(component Label for=this.id size=@size isRequired=@isRequired)
          Description=(component Description id=this.descriptionId size=@size)
          Feedback=(component
            Feedback
            id=this.feedbackId
            size=@size
            messages=@errors
            intent="danger"
          )
        )
        to="default"
      }}

      {{#if this.showErrorFeedback}}
        <Feedback
          @id={{this.feedbackId}}
          @size={{@size}}
          @messages={{@errors}}
          @intent="danger"
        />
      {{/if}}
    </div>
  </template>
}

export { FormControl, type FormControlSignature, type FormControlSharedArgs };
export default FormControl;
