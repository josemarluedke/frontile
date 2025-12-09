import { helper } from '@ember/component/helper';
import { twMerge } from '@frontile/theme';

export default helper(function twMergeHelper([defaultClass, overrides]: [
  string,
  string,
]) {
  return twMerge(defaultClass, overrides);
});
