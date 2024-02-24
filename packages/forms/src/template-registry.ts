import type { Select, NativeSelect } from './index';

export default interface Registry {
  Select: typeof Select;
  NativeSelect: typeof NativeSelect;
}
