import type { VisuallyHidden, Collapsible, Spinner, Divider } from './index';

export default interface Registry {
  VisuallyHidden: typeof VisuallyHidden;
  Collapsible: typeof Collapsible;
  Spinner: typeof Spinner;
  Divider: typeof Divider;
}
