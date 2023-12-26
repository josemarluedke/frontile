import type ChangesetFormFieldsInput from './components/changeset-form/fields/input';
import type ChangesetFormFieldsTextarea from './components/changeset-form/fields/textarea';
import type ChangesetFormFieldsSelect from './components/changeset-form/fields/select';
import type ChangesetFormFieldsCheckbox from './components/changeset-form/fields/checkbox';
import type ChangesetFormFieldsCheckboxGroup from './components/changeset-form/fields/checkbox-group';
import type ChangesetFormFieldsRadio from './components/changeset-form/fields/radio';
import type ChangesetFormFieldsRadioGroup from './components/changeset-form/fields/radio-group';
import type ChangesetForm from './components/changeset-form';

export default interface Registry {
  ChangesetFormFieldsInput: typeof ChangesetFormFieldsInput;
  ChangesetFormFieldsTextarea: typeof ChangesetFormFieldsTextarea;
  ChangesetFormFieldsSelect: typeof ChangesetFormFieldsSelect;
  ChangesetFormFieldsCheckbox: typeof ChangesetFormFieldsCheckbox;
  ChangesetFormFieldsCheckboxGroup: typeof ChangesetFormFieldsCheckboxGroup;
  ChangesetFormFieldsRadio: typeof ChangesetFormFieldsRadio;
  ChangesetFormFieldsRadioGroup: typeof ChangesetFormFieldsRadioGroup;
  ChangesetForm: typeof ChangesetForm;
}
