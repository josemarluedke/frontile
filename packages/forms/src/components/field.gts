import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import Checkbox from './checkbox';
import CheckboxGroup from './checkbox-group';
import Input from './input';
import Radio from './radio';
import RadioGroup from './radio-group';
import Select from './select';
import Switch from './switch';
import Textarea from './textarea';

import type { WithBoundArgs } from '@glint/template';
import type { FormErrors } from './form';

interface FieldSignature {
  Element: HTMLElement;
  Args: {
    /** The name of the form field. */
    name: string;
    /** The validation errors for the form, keyed by field name. */
    errors?: FormErrors;
  };
  Blocks: {
    default: [
      {
        Checkbox: WithBoundArgs<typeof Checkbox, 'name' | 'errors'>;
        CheckboxGroup: WithBoundArgs<typeof CheckboxGroup, 'name' | 'errors'>;
        Input: WithBoundArgs<typeof Input, 'name' | 'errors'>;
        Radio: WithBoundArgs<typeof Radio, 'name' | 'errors'>;
        RadioGroup: WithBoundArgs<typeof RadioGroup, 'name' | 'errors'>;
        Select: WithBoundArgs<typeof Select, 'name' | 'errors'>;
        Switch: WithBoundArgs<typeof Switch, 'name' | 'errors'>;
        Textarea: WithBoundArgs<typeof Textarea, 'name' | 'errors'>;
      }
    ];
  };
}

/**
 * Field is a component wrapper that provides conveniences for form fields.
 * It automatically binds the appropriate form errors by name to yielded
 * components.
 */
class Field extends Component<FieldSignature> {
  /**
   * Returns the validation errors for the field.
   */
  get fieldErrors() {
    return this.args.errors?.[this.args.name];
  }

  <template>
    {{! @glint-nocheck component generics (radio, radio-group, select) trigger:  type instantiation is excessively deep and possibly infinite }}
    {{yield
      (hash
        Checkbox=(component Checkbox name=@name errors=this.fieldErrors)
        CheckboxGroup=(component
          CheckboxGroup name=@name errors=this.fieldErrors
        )
        Input=(component Input name=@name errors=this.fieldErrors)
        Radio=(component Radio name=@name errors=this.fieldErrors)
        RadioGroup=(component RadioGroup name=@name errors=this.fieldErrors)
        Select=(component Select name=@name errors=this.fieldErrors)
        Switch=(component Switch name=@name errors=this.fieldErrors)
        Textarea=(component Textarea name=@name errors=this.fieldErrors)
      )
      to="default"
    }}
  </template>
}

export { Field, type FieldSignature };
export default Field;
