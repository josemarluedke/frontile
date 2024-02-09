import type VisuallyHidden from './components/visually-hidden';
import type Collapsible from './components/collapsible';

export default interface Registry {
  VisuallyHidden: typeof VisuallyHidden;
  Collapsible: typeof Collapsible;
}
