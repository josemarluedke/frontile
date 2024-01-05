import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import { concat } from '@ember/helper';
import FormRadio from './form-radio';
import FormField from './form-field';
import { useStyles } from '@frontile/theme';
import type { WithBoundArgs } from '@glint/template';

export interface FormRadioGroupArgs {
  value: string | number | boolean | undefined;
  /** The group label */
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
  /** If the Checkbox should be in one line */
  isInline?: boolean;

  /** Default callback added to the yielded FormRadio component, called when onchange is triggered */
  onChange?: (value: unknown, event: Event) => void;
}

export interface FormRadioGroupSignature {
  Args: FormRadioGroupArgs;
  Blocks: {
    default: [
      radio: WithBoundArgs<typeof FormRadio, 'checked'> &
        WithBoundArgs<typeof FormRadio, 'privateContainerClass'> &
        WithBoundArgs<typeof FormRadio, '_parentOnChange'> &
        WithBoundArgs<typeof FormRadio, 'size'> &
        WithBoundArgs<typeof FormRadio, 'name'>
    ];
  };
  Element: HTMLDivElement;
}

export default class FormRadioGroup extends Component<FormRadioGroupSignature> {
  @tracked shouldShowErrorFeedback = false;

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

  @action handleChange(value: unknown, event: Event): void {
    this.shouldShowErrorFeedback = true;

    if (typeof this.args.onChange === 'function') {
      this.args.onChange(value, event);
    }
  }

  get classes() {
    const { formRadioGroup } = useStyles();
    const { base, label, formRadio, hint, feedback } = formRadioGroup({
      isInline: this.args.isInline
    });

    return {
      base: base({
        class: this.args.containerClass
      }),
      label: label(),
      hint: hint(),
      feedback: feedback(),
      formRadio: formRadio()
    };
  }

  <template>
    <FormField
      @size={{@size}}
      class={{this.classes.base}}
      role="radiogroup"
      ...attributes
      as |f|
    >
      {{#if @label}}
        <f.Label @class={{this.classes.label}}>
          {{@label}}
        </f.Label>
      {{/if}}

      {{#if @hint}}
        <f.Hint @class={{this.classes.hint}}>

          {{@hint}}
        </f.Hint>
      {{/if}}

      {{yield
        (component
          FormRadio
          checked=@value
          privateContainerClass=this.classes.formRadio
          _parentOnChange=this.handleChange
          size=@size
          name=(concat f.id "-radio-group")
        )
      }}

      {{#if this.showErrorFeedback}}
        <f.Feedback @class={{this.classes.feedback}} @errors={{@errors}} />
      {{/if}}
    </FormField>
  </template>
}
