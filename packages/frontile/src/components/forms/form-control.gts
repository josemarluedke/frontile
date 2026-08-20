import Component from '@glimmer/component';
import { guidFor } from '@ember/object/internals';
import { hash } from '@ember/helper';
import Feedback, { type FormFeedbackSignature } from './form-feedback';
import Description, { type FormDescriptionSignature } from './form-description';
import Label, { type LabelSignature } from './label';
import type { ComponentLike, WithBoundArgs } from '@glint/template';

interface FormControlSharedArgs {
  /**
   * The label text rendered above the control and associated with it via `for`.
   * Use the `:label` block instead when the label needs markup.
   */
  label?: string;

  /**
   * Whether the field is required. Adds an asterisk to the label; it does not
   * set the `required` attribute on the control itself.
   *
   * @defaultValue false
   */
  isRequired?: boolean;

  /**
   * Help text rendered between the label and the control, and referenced by the
   * ids `describedBy` returns.
   */
  description?: string;

  /**
   * Validation messages for the field. A non-empty value also marks the control
   * invalid, and an array is joined with `; ` when displayed.
   */
  errors?: string[] | string;

  /**
   * Marks the control invalid without supplying messages, for validation that is
   * reported elsewhere.
   *
   * @defaultValue false
   */
  isInvalid?: boolean;

  /**
   * Whether the field is disabled. FormControl passes this through for styling;
   * the control it wraps is responsible for the `disabled` attribute.
   *
   * @defaultValue false
   */
  isDisabled?: boolean;
}

interface Args extends FormControlSharedArgs {
  /**
   * The id given to the control, and the base for the description and feedback
   * ids. Generated when omitted, so pass one only when something outside the
   * block has to reference it.
   */
  id?: string;

  /**
   * The size of the label, description and feedback text.
   *
   * @defaultValue 'md'
   */
  size?: 'sm' | 'md' | 'lg';

  /**
   * Suppresses the automatic error feedback, for when the block renders the
   * yielded `Feedback` itself or places messages elsewhere.
   *
   * @defaultValue false
   */
  preventErrorFeedback?: boolean;

  /**
   * Class names for the wrapping element.
   */
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
        Label: WithBoundArgs<
          ComponentLike<LabelSignature>,
          'for' | 'size' | 'isRequired'
        >;
        Description: WithBoundArgs<
          ComponentLike<FormDescriptionSignature>,
          'id' | 'size'
        >;
        Feedback: WithBoundArgs<
          ComponentLike<FormFeedbackSignature>,
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
