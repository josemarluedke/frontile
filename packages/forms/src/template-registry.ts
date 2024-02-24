import type {
  Checkbox,
  FormDescription,
  FormFeedback,
  Input,
  Label,
  NativeSelect,
  Select,
  Textarea
} from './index';

export default interface Registry {
  Checkbox: typeof Checkbox;
  FormDescription: typeof FormDescription;
  FormFeedback: typeof FormFeedback;
  Input: typeof Input;
  Label: typeof Label;
  NativeSelect: typeof NativeSelect;
  Select: typeof Select;
  Textarea: typeof Textarea;
}
