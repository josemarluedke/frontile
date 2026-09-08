import type { SelectionMode } from '../../../utils/listManager';
import type { ListboxItemSignature } from '../listbox/item';

/**
 * How a submenu was asked to open.
 *
 * It decides whether the submenu highlights its first item: a keyboard user
 * who pressed ArrowRight expects to be somewhere, while a pointer user
 * hovering a row does not expect a selection to move. The `Listbox` at each
 * level is constructed fresh on open, so the source is read once, at mount,
 * as `autoActivateMode`.
 */
type OpenSource = 'pointer' | 'keyboard';

/**
 * What a level needs in order to drive a submenu it does not itself render.
 *
 * A level's ArrowRight handler has to open the submenu belonging to whichever
 * item is currently active. The item knows nothing about the submenu, and the
 * `Sub` renders inside the level's own block -- so each `Sub` registers a
 * handle under its trigger's key, and the level looks it up.
 */
interface SubHandle {
  open: (source: OpenSource) => void;
  close: () => void;
}

interface MenuContext {
  /** 0 for the root menu, 1 for a submenu, and so on. */
  depth: number;

  /**
   * Close the whole chain. Choosing a leaf three levels down dismisses the
   * entire dropdown, not just the level the leaf sits in.
   */
  closeRoot: () => void;

  /**
   * Close just this level, leaving its parent open -- what ArrowLeft does.
   * On the root this is the same thing as `closeRoot`.
   */
  closeSelf: () => void;

  /** The submenus registered at this level, keyed by their trigger's key. */
  subs: Map<string, SubHandle>;
  registerSub: (key: string, handle: SubHandle) => void;
  unregisterSub: (key: string) => void;

  // Everything below is declared once, on the root `Menu`, and inherited by
  // every depth -- so `@onAction` and `@selectedKeys` on the root apply to a
  // leaf at any level, and the levels cannot drift out of visual step.
  selectionMode?: SelectionMode;
  selectedKeys?: string[];
  disabledKeys?: string[];
  allowEmpty?: boolean;
  onAction?: (key: string) => void;
  onSelectionChange?: (keys: string[]) => void;
  appearance?: ListboxItemSignature['Args']['appearance'];
  intent?: ListboxItemSignature['Args']['intent'];
  shortcutAppearance?: ListboxItemSignature['Args']['shortcutAppearance'];
  closeOnItemSelect?: boolean;
  disableTransitions?: boolean;
  transitionDuration?: number;
}

interface RootMenuContextArgs extends Omit<
  MenuContext,
  'depth' | 'closeRoot' | 'closeSelf' | 'registerSub' | 'unregisterSub'
> {
  /** The root popover's close, used for both `closeRoot` and `closeSelf`. */
  close: () => void;
}

/**
 * `subs` is passed in rather than created here, and deliberately so: the
 * caller is a Glimmer component whose getter rebuilds this object on every
 * render, and a map created here would drop every `Sub` that had already
 * registered. The component owns one stable map for the life of the level.
 */
function createRootMenuContext(args: RootMenuContextArgs): MenuContext {
  const { close, subs, ...shared } = args;

  return {
    ...shared,
    depth: 0,
    subs,
    closeRoot: close,
    closeSelf: close,
    registerSub: (key, handle) => subs.set(key, handle),
    unregisterSub: (key) => subs.delete(key)
  };
}

function createChildMenuContext(
  parent: MenuContext,
  options: { closeSelf: () => void; subs: Map<string, SubHandle> }
): MenuContext {
  const { closeSelf, subs } = options;

  return {
    ...parent,
    depth: parent.depth + 1,
    subs,
    closeSelf,
    registerSub: (key, handle) => subs.set(key, handle),
    unregisterSub: (key) => subs.delete(key)
  };
}

export {
  createRootMenuContext,
  createChildMenuContext,
  type MenuContext,
  type RootMenuContextArgs,
  type SubHandle,
  type OpenSource
};
