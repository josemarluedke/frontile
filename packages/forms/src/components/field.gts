import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { action, get } from '@ember/object';
import Checkbox from './checkbox';
import CheckboxGroup from './checkbox-group';
import Input from './input';
import Radio from './radio';
import RadioGroup from './radio-group';
import Select from './select';
import Switch from './switch';
import Textarea from './textarea';

import type { WithBoundArgs } from '@glint/template';
import type { FormDataCompiled, FormErrors } from './form';
import type { SelectSignature } from './select';
import type { WithBoundArgsForSignature } from './field-types';

type BoundSingleSelect<S = unknown> = WithBoundArgsForSignature<
  SelectSignature<S>,
  'name' | 'errors' | 'selectedKey' | 'onSelectionChange' | 'isDisabled'
>;

type BoundMultiSelect<S = unknown> = WithBoundArgsForSignature<
  SelectSignature<S>,
  'name' | 'errors' | 'selectedKeys' | 'onSelectionChange' | 'isDisabled'
>;

interface FieldSignature<T extends Record<string, unknown> = FormDataCompiled> {
  Element: HTMLElement;
  Args: {
    /** The name of the form field. */
    name: string;
    /** The validation errors for the form, keyed by field name. */
    errors?: FormErrors;
    /** The form data as key/value pairs. */
    formData?: T;
    /** Whether the field should be disabled. */
    disabled?: boolean;
    /** When to run validation. */
    validateOn?: ('change' | 'input')[];
    /** Function to validate a single field by name. */
    validateField?: (data: T, name: string) => Promise<FormErrors | undefined>;
  };
  Blocks: {
    default: [
      {
        Checkbox: WithBoundArgs<
          typeof Checkbox,
          'name' | 'errors' | 'checked' | 'onChange' | 'isDisabled'
        >;
        CheckboxGroup: WithBoundArgs<
          typeof CheckboxGroup,
          'name' | 'errors' | 'isDisabled'
        >;
        Input: WithBoundArgs<
          typeof Input,
          'name' | 'errors' | 'value' | 'onChange' | 'onInput' | 'isDisabled'
        >;
        Radio: WithBoundArgs<
          typeof Radio,
          'name' | 'errors' | 'value' | 'onChange' | 'isDisabled'
        >;
        RadioGroup: WithBoundArgs<
          typeof RadioGroup,
          'name' | 'errors' | 'value' | 'onChange' | 'isDisabled'
        >;
        SingleSelect: BoundSingleSelect;
        MultiSelect: BoundMultiSelect;
        Switch: WithBoundArgs<
          typeof Switch,
          'name' | 'errors' | 'isSelected' | 'onChange' | 'isDisabled'
        >;
        Textarea: WithBoundArgs<
          typeof Textarea,
          'name' | 'errors' | 'value' | 'onChange' | 'onInput' | 'isDisabled'
        >;
      }
    ];
  };
}

/**
 * Field is a component wrapper that provides conveniences for form fields.
 * It automatically binds the appropriate form errors by name to yielded
 * components.
 */
class Field<
  T extends Record<string, unknown> = FormDataCompiled
> extends Component<FieldSignature<T>> {
  /**
   * Returns the validation errors for the field.
   * Supports dotted field names (e.g., 'profile.email').
   */
  get fieldErrors() {
    return this.args.errors?.[this.args.name];
  }

  /** The events on which validation should run. Defaults to ['change']. */
  get validateOn(): ('change' | 'input')[] {
    return this.args.validateOn ?? ['change'];
  }

  /** Whether validation should run on field change. */
  get validateOnChange(): boolean {
    return this.validateOn.includes('change');
  }

  /** Whether validation should run on field input. */
  get validateOnInput(): boolean {
    return this.validateOn.includes('input');
  }

  /**
   * Returns the current value for the field from formData.
   * Supports both flat and dotted field names (e.g., 'email' or 'profile.email').
   * Uses Ember's get() which handles both flat keys and dotted paths.
   */
  get fieldValue() {
    if (!this.args.formData) return undefined;

    // Ember's get() handles both flat keys and dotted paths correctly
    return get(this.args.formData, this.args.name);
  }

  /**
   * No-op action to satisfy onChange/onSelectionChange signaling of being
   * in a controlled state.
   */
  @action
  handleChange() {
    if (this.validateOnChange) {
      this.args.validateField?.(this.args.formData as T, this.args.name);
    }
  }

  /**
   * Validates the field on input if input validation is enabled.
   * Uses a microtask to ensure form data has been updated before validation runs.
   */
  @action
  handleInput() {
    if (this.validateOnInput) {
      // Use a microtask to ensure the form's handleInput has completed and form data is updated
      Promise.resolve().then(() => {
        this.args.validateField?.(this.args.formData as T, this.args.name);
      });
    }
  }

  <template>
    {{! @glint-nocheck component generics (radio, radio-group, select) trigger:  type instantiation is excessively deep and possibly infinite }}
    {{yield
      (hash
        Checkbox=(component
          Checkbox
          name=@name
          errors=this.fieldErrors
          checked=this.fieldValue
          onChange=this.handleChange
          isDisabled=@disabled
        )
        CheckboxGroup=(component
          CheckboxGroup name=@name errors=this.fieldErrors isDisabled=@disabled
        )
        Input=(component
          Input
          name=@name
          errors=this.fieldErrors
          value=this.fieldValue
          onChange=this.handleChange
          onInput=this.handleInput
          isDisabled=@disabled
        )
        Radio=(component
          Radio
          name=@name
          errors=this.fieldErrors
          value=this.fieldValue
          onChange=this.handleChange
          isDisabled=@disabled
        )
        RadioGroup=(component
          RadioGroup
          name=@name
          errors=this.fieldErrors
          value=this.fieldValue
          onChange=this.handleChange
          isDisabled=@disabled
        )
        SingleSelect=(component
          Select
          name=@name
          errors=this.fieldErrors
          selectedKey=this.fieldValue
          onSelectionChange=this.handleChange
          isDisabled=@disabled
        )
        MultiSelect=(component
          Select
          name=@name
          errors=this.fieldErrors
          selectedKeys=this.fieldValue
          onSelectionChange=this.handleChange
          isDisabled=@disabled
        )
        Switch=(component
          Switch
          name=@name
          errors=this.fieldErrors
          isSelected=this.fieldValue
          onChange=this.handleChange
          isDisabled=@disabled
        )
        Textarea=(component
          Textarea
          name=@name
          errors=this.fieldErrors
          value=this.fieldValue
          onChange=this.handleChange
          onInput=this.handleInput
          isDisabled=@disabled
        )
      )
      to="default"
    }}
  </template>
}

export { Field, type FieldSignature };
export default Field;
