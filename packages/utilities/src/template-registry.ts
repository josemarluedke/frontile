import type VisuallyHidden from './components/visually-hidden';
import type Collapsible from './components/collapsible';
import type Spinner from './components/spinner';

export default interface Registry {
  VisuallyHidden: typeof VisuallyHidden;
  Collapsible: typeof Collapsible;
  Spinner: typeof Spinner;
}
