import type {
  Form,
  Checkbox,
  FormDescription,
  FormFeedback,
  Input,
  Label,
  NativeSelect,
  Select,
  Textarea,
  FormControl,
  RadioGroup,
  CheckboxGroup
} from './index';

export default interface Registry {
  Form: typeof Form;
  Checkbox: typeof Checkbox;
  FormDescription: typeof FormDescription;
  FormFeedback: typeof FormFeedback;
  Input: typeof Input;
  Label: typeof Label;
  NativeSelect: typeof NativeSelect;
  Select: typeof Select;
  Textarea: typeof Textarea;
  FormControl: typeof FormControl;
  CheckboxGroup: typeof CheckboxGroup;
  RadioGroup: typeof RadioGroup;
}
