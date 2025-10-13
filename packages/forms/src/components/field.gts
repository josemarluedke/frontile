import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { action } from '@ember/object';
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
  'name' | 'errors' | 'selectedKey' | 'isDisabled'
>;

type BoundMultiSelect<S = unknown> = WithBoundArgsForSignature<
  SelectSignature<S>,
  'name' | 'errors' | 'selectedKeys' | 'isDisabled'
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
  };
  Blocks: {
    default: [
      {
        Checkbox: WithBoundArgs<
          typeof Checkbox,
          'name' | 'errors' | 'checked' | 'isDisabled'
        >;
        CheckboxGroup: WithBoundArgs<
          typeof CheckboxGroup,
          'name' | 'errors' | 'isDisabled'
        >;
        Input: WithBoundArgs<
          typeof Input,
          'name' | 'errors' | 'value' | 'isDisabled'
        >;
        Radio: WithBoundArgs<
          typeof Radio,
          'name' | 'errors' | 'value' | 'isDisabled'
        >;
        RadioGroup: WithBoundArgs<
          typeof RadioGroup,
          'name' | 'errors' | 'value' | 'isDisabled'
        >;
        SingleSelect: BoundSingleSelect;
        MultiSelect: BoundMultiSelect;
        Switch: WithBoundArgs<
          typeof Switch,
          'name' | 'errors' | 'isSelected' | 'isDisabled'
        >;
        Textarea: WithBoundArgs<
          typeof Textarea,
          'name' | 'errors' | 'value' | 'isDisabled'
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
   */
  get fieldErrors() {
    return this.args.errors?.[this.args.name];
  }

  /** Returns the current value for the field from formData. */
  get fieldValue() {
    return this.args.formData?.[this.args.name];
  }

  /**
   * No-op action to satisfy onChange/onSelectionChange signaling of being
   * in a controlled state.
   */
  @action
  noop() {}

  <template>
    {{! @glint-nocheck component generics (radio, radio-group, select) trigger:  type instantiation is excessively deep and possibly infinite }}
    {{yield
      (hash
        Checkbox=(component
          Checkbox
          name=@name
          errors=this.fieldErrors
          checked=this.fieldValue
          onChange=this.noop
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
          onChange=this.noop
          isDisabled=@disabled
        )
        Radio=(component
          Radio
          name=@name
          errors=this.fieldErrors
          value=this.fieldValue
          onChange=this.noop
          isDisabled=@disabled
        )
        RadioGroup=(component
          RadioGroup
          name=@name
          errors=this.fieldErrors
          value=this.fieldValue
          onChange=this.noop
          isDisabled=@disabled
        )
        SingleSelect=(component
          Select
          name=@name
          errors=this.fieldErrors
          selectedKey=this.fieldValue
          onSelectionChange=this.noop
          isDisabled=@disabled
        )
        MultiSelect=(component
          Select
          name=@name
          errors=this.fieldErrors
          selectedKeys=this.fieldValue
          onSelectionChange=this.noop
          isDisabled=@disabled
        )
        Switch=(component
          Switch
          name=@name
          errors=this.fieldErrors
          isSelected=this.fieldValue
          onChange=this.noop
          isDisabled=@disabled
        )
        Textarea=(component
          Textarea
          name=@name
          errors=this.fieldErrors
          value=this.fieldValue
          onChange=this.noop
          isDisabled=@disabled
        )
      )
      to="default"
    }}
  </template>
}

export { Field, type FieldSignature };
export default Field;
