import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { useStyles } from '@frontile/theme';
import FormField from './form-field';

export interface FormSelectArgs {
  /** The input field label */
  label?: string;
  /** A help text to be displayed */
  hint?: string;
  /** If the form has been submitted, used to force displaying errors */
  hasSubmitted?: boolean;
  /** If has errors */
  hasError?: boolean;
  /** Force displaying errors */
  showError?: boolean;
  /** A list of errors or a single text describing the error */
  errors?: string[] | string;
  /** CSS classes to be added in the container element */
  containerClass?: string;
  /** The size */
  size?: 'sm' | 'md' | 'lg';

  /** If is multiple select instead of single */
  isMultiple?: boolean;
}

export interface FormSelectSignature {
  Args: FormSelectArgs;
  Blocks: {
    default: [];
  };
  Element: HTMLDivElement;
}

export default class FormSelect extends Component<FormSelectSignature> {
  @tracked shouldShowErrorFeedback = false;
  @tracked isOpen = false;

  get showErrorFeedback(): boolean {
    if (this.args.hasError === false) {
      return false;
    }

    if (
      (this.args.showError ||
        this.args.hasSubmitted ||
        this.shouldShowErrorFeedback) &&
      this.args.errors &&
      this.args.errors.length > 0
    ) {
      return true;
    } else {
      return false;
    }
  }

  get classes() {
    const { formSelect } = useStyles();

    const { base, label, select, hint, feedback } = formSelect({
      size: this.args.size
    });

    return {
      base: base({
        class: this.args.containerClass
      }),
      label: label(),
      select: select(),
      hint: hint(),
      feedback: feedback()
    };
  }

  <template>
    <FormField @size={{@size}} class={{this.classes.base}} as |f|>

      {{#if @label}}
        <f.Label @for="" id={{f.id}} @class={{this.classes.label}}>
          {{@label}}
        </f.Label>
      {{/if}}

      {{#if @hint}}
        <f.Hint @class={{this.classes.hint}}>
          {{@hint}}
        </f.Hint>
      {{/if}}

      Select Goes Here

      {{#if this.showErrorFeedback}}
        <f.Feedback @class={{this.classes.feedback}} @errors={{@errors}} />
      {{/if}}
    </FormField>
  </template>
}
