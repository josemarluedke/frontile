import type Overlay from './components/overlay';
import type Drawer from './components/drawer';
import type Modal from './components/modal';

export default interface Registry {
  Overlay: typeof Overlay;
  Drawer: typeof Drawer;
  Modal: typeof Modal;
}
