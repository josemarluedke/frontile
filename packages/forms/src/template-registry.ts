import type FormFieldCheckbox from './components/form-field/checkbox';
import type FormFieldFeedback from './components/form-field/feedback';
import type FormFieldHint from './components/form-field/hint';
import type FormFieldInput from './components/form-field/input';
import type FormFieldLabel from './components/form-field/label';
import type FormFieldRadio from './components/form-field/radio';
import type FormFieldTextarea from './components/form-field/textarea';
import type FormCheckboxGroup from './components/form-checkbox-group';
import type FormCheckbox from './components/form-checkbox';
import type FormField from './components/form-field';
import type FormInput from './components/form-input';
import type FormRadioGroup from './components/form-radio-group';
import type FormRadio from './components/form-radio';
import type FormSelect from './components/form-select';
import type FormTextarea from './components/form-textarea';

export default interface Registry {
  FormFieldCheckbox: typeof FormFieldCheckbox;
  FormFieldFeedback: typeof FormFieldFeedback;
  FormFieldHint: typeof FormFieldHint;
  FormFieldInput: typeof FormFieldInput;
  FormFieldLabel: typeof FormFieldLabel;
  FormFieldRadio: typeof FormFieldRadio;
  FormFieldTextarea: typeof FormFieldTextarea;
  FormCheckboxGroup: typeof FormCheckboxGroup;
  FormCheckbox: typeof FormCheckbox;
  FormField: typeof FormField;
  FormInput: typeof FormInput;
  FormRadioGroup: typeof FormRadioGroup;
  FormRadio: typeof FormRadio;
  FormSelect: typeof FormSelect;
  FormTextarea: typeof FormTextarea;
}
