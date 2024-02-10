import type { Overlay, Modal, Drawer, Popover } from './index';

export default interface Registry {
  Overlay: typeof Overlay;
  Drawer: typeof Drawer;
  Modal: typeof Modal;
  Popover: typeof Popover;
}
