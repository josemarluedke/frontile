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

interface MenuContext extends MenuSelectionContext {
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

  // Appearance and timing are the root's for the whole chain: a submenu that
  // styled itself would make one menu look like two, so these are declared
  // once on the root and never overridden below it.
  variant?: ListboxItemSignature['Args']['variant'];
  color?: ListboxItemSignature['Args']['color'];
  shortcutVariant?: ListboxItemSignature['Args']['shortcutVariant'];
  disableTransitions?: boolean;
  transitionDuration?: number;
}

/**
 * The parts of a context a level may declare for itself.
 *
 * Declared once on the root and inherited by every depth -- so `@onAction` and
 * `@selectedKeys` written at the top apply to a leaf at any level -- but a
 * submenu may override any of them for its own level and the levels below,
 * which is what lets a navigation menu hold a multi-select submenu.
 *
 * Split out from `MenuContext` so the overridable set is a type rather than a
 * list repeated in prose and in a literal: `OVERRIDABLE_KEYS` below is indexed
 * by this interface, so an eighth setting added here fails to compile until it
 * is spelled there too, instead of silently being non-overridable.
 */
interface MenuSelectionContext {
  selectionMode?: SelectionMode;
  selectedKeys?: string[];
  disabledKeys?: string[];
  allowEmpty?: boolean;
  onAction?: (key: string) => void;
  onSelectionChange?: (keys: string[]) => void;
  closeOnItemSelect?: boolean;
}

const OVERRIDABLE_KEYS: Record<keyof MenuSelectionContext, true> = {
  selectionMode: true,
  selectedKeys: true,
  disabledKeys: true,
  allowEmpty: true,
  onAction: true,
  onSelectionChange: true,
  closeOnItemSelect: true
};

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
function bindSubRegistry(
  subs: Map<string, SubHandle>
): Pick<MenuContext, 'registerSub' | 'unregisterSub'> {
  return {
    registerSub: (key, handle) => subs.set(key, handle),
    unregisterSub: (key) => subs.delete(key)
  };
}

function createRootMenuContext(args: RootMenuContextArgs): MenuContext {
  const { close, subs, ...shared } = args;

  return {
    ...shared,
    depth: 0,
    subs,
    closeRoot: close,
    closeSelf: close,
    ...bindSubRegistry(subs)
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
    ...bindSubRegistry(subs)
  };
}

/**
 * Layers a level's own declarations over the context it inherited.
 *
 * Only settings actually written on this level count: reading them
 * unconditionally would overwrite inherited values with `undefined` and
 * silently break inheritance, which is the default and by far the common case.
 * That case also allocates nothing and hands back the parent's own object, so
 * a level that declares nothing is indistinguishable downstream from one that
 * never had the chance to.
 */
function createOverriddenMenuContext(
  parent: MenuContext,
  own: MenuSelectionContext
): MenuContext {
  let overrides: Partial<MenuSelectionContext> | undefined;

  for (const key of Object.keys(
    OVERRIDABLE_KEYS
  ) as (keyof MenuSelectionContext)[]) {
    const value = own[key];

    if (value !== undefined) {
      overrides ??= {};
      // Correlating the key with its own value type is beyond what TS narrows
      // across an index like this; the `Record` above is what actually keeps
      // the key set honest.
      overrides[key] = value as never;
    }
  }

  return overrides ? { ...parent, ...overrides } : parent;
}

export {
  createRootMenuContext,
  createChildMenuContext,
  createOverriddenMenuContext,
  type MenuContext,
  type MenuSelectionContext,
  type RootMenuContextArgs,
  type SubHandle,
  type OpenSource
};
