import type VisuallyHidden from './components/visually-hidden';
import type CloseButton from './components/close-button';
import type Collapsible from './components/collapsible';

export default interface Registry {
  VisuallyHidden: typeof VisuallyHidden;
  CloseButton: typeof CloseButton;
  Collapsible: typeof Collapsible;
}
