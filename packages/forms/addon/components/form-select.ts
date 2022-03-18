import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { assert } from '@ember/debug';
import {
  PowerSelectArgs,
  Select
} from 'ember-power-select/addon/components/power-select';

interface FormSelectArgs extends PowerSelectArgs {
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
  size?: 'sm' | 'lg';

  // Same as onFocus from ember-power-select
  onFocusIn?: (select: Select, event: FocusEvent) => void;
  // Same as onBlur from ember-power-select
  onFocusOut?: (select: Select, event: FocusEvent) => void;
}

export default class FormSelect extends Component<FormSelectArgs> {
  @tracked shouldShowErrorFeedback = false;
  @tracked isOpen = false;

  constructor(owner: unknown, args: FormSelectArgs) {
    super(owner, args);
    assert(
      '<FormSelect> requires an `@onChange` function',
      this.args.onChange && typeof this.args.onChange === 'function'
    );
  }

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

  @action handleOpen(select: Select, event: Event): void {
    this.isOpen = true;
    this.shouldShowErrorFeedback = false;

    if (typeof this.args.onOpen === 'function') {
      this.args.onOpen(select, event);
    }
  }

  @action handleClose(select: Select, event: Event): void {
    this.isOpen = false;
    this.shouldShowErrorFeedback = true;

    if (typeof this.args.onClose === 'function') {
      this.args.onClose(select, event);
    }
  }

  @action handleFocusIn(select: Select, event: FocusEvent): void {
    this.shouldShowErrorFeedback = false;

    if (typeof this.args.onFocusIn === 'function') {
      this.args.onFocusIn(select, event);
    }

    // ember-power-select argument
    if (typeof this.args.onFocus === 'function') {
      this.args.onFocus(select, event);
    }
  }

  @action handleFocusOut(select: Select, event: FocusEvent): void {
    if (!this.isOpen) {
      this.shouldShowErrorFeedback = true;
    }

    if (typeof this.args.onFocusOut === 'function') {
      this.args.onFocusOut(select, event);
    }

    // ember-power-select argument
    if (typeof this.args.onBlur === 'function') {
      this.args.onBlur(select, event);
    }
  }

  @action handleChange(
    selection: unknown,
    select: Select,
    event?: Event
  ): void {
    this.shouldShowErrorFeedback = true;
    this.args.onChange(selection, select, event);
  }
}
