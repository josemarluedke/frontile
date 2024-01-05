import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import FormCheckbox from './form-checkbox';
import { useStyles } from '@frontile/theme';
import FormField from './form-field';
import { hash } from '@ember/helper';
import type { WithBoundArgs } from '@glint/template';

export interface FormCheckboxGroupArgs {
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
  /** Default callback added to the yielded FormCheckbox component, called when onchange is triggered */
  onChange?: (value: unknown, event: Event) => void;
}

export interface FormCheckboxGroupSignature {
  Args: FormCheckboxGroupArgs;
  Blocks: {
    default: [
      checkbox: WithBoundArgs<typeof FormCheckbox, 'privateContainerClass'> &
        WithBoundArgs<typeof FormCheckbox, '_parentOnChange'> &
        WithBoundArgs<typeof FormCheckbox, 'size'>,
      api: { onChange: (value: unknown, event: Event) => void }
    ];
  };
  Element: HTMLDivElement;
}

export default class FormCheckboxGroup extends Component<FormCheckboxGroupSignature> {
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
    const { formCheckboxGroup } = useStyles();
    const { base, label, formCheckbox, hint, feedback } = formCheckboxGroup({
      isInline: this.args.isInline
    });

    return {
      base: base({
        class: this.args.containerClass
      }),
      label: label(),
      hint: hint(),
      feedback: feedback(),
      formCheckbox: formCheckbox()
    };
  }

  <template>
    <FormField
      @size={{@size}}
      class={{this.classes.base}}
      role="group"
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
          FormCheckbox
          privateContainerClass=this.classes.formCheckbox
          _parentOnChange=this.handleChange
          size=@size
        )
        (hash onChange=this.handleChange)
      }}

      {{#if this.showErrorFeedback}}
        <f.Feedback @class={{this.classes.feedback}} @errors={{@errors}} />
      {{/if}}
    </FormField>
  </template>
}
