import Component from '@glimmer/component';
import { cached, tracked } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { on } from '@ember/modifier';
import { schedule } from '@ember/runloop';
import { registerDestructor } from '@ember/destroyable';
import { guidFor } from '@ember/object/internals';
import { modifier } from 'ember-modifier';
import { twMerge, useStyles } from '@frontile/theme';
import Collapsible from '../utilities/collapsible';
import Tooltip from '../overlays/tooltip';
import Dropdown from '../collections/dropdown/dropdown';
import { ChevronRightIcon } from '../../-private/icons';
import NavItem from './nav-item';
import NavLink from './nav-link';
import type { NavFolderContext, NavItemHandle } from './nav-context';
import type { TOC } from '@ember/component/template-only';
import type { ComponentLike, WithBoundArgs } from '@glint/template';

interface NavFolderArgs {
  /** The folder's label, shown in its trigger. */
  label: string;

  /**
   * An icon component, shown before the label. It is hidden from assistive
   * technology.
   */
  icon?: ComponentLike;

  /**
   * Makes the open state controlled. Clicks then only call `@onOpenChange`,
   * and so does an automatic open when a child becomes active.
   *
   * This is the inline open state. In the collapsed icon rail the folder
   * opens as a menu instead, whose state is its own: `@open` does not
   * control it and `@onOpenChange` is not called for it. The inline state
   * still follows an active child there, and shows on expanding.
   */
  open?: boolean;

  /**
   * The initial open state when `@open` is not given.
   *
   * @defaultValue false
   */
  defaultOpen?: boolean;

  /**
   * Called with the requested inline open state whenever it would change.
   * Not called when the menu of the collapsed icon rail opens or closes.
   */
  onOpenChange?: (open: boolean) => void;

  /**
   * Hides the folder. A folder is also hidden when none of its items is
   * visible.
   *
   * @defaultValue false
   */
  isHidden?: boolean;

  /**
   * Class names added to the folder's root element. Merged with Tailwind
   * Merge, so a class that conflicts with a theme class wins.
   */
  class?: string;

  /**
   * Supplied by `Sidebar`: whether the sidebar is drawn as the icon rail,
   * where the folder opens as a menu. Not part of the public API.
   *
   * @internal
   */
  rail?: boolean;

  /**
   * Supplied by `Sidebar`: the side rail tooltips, and so the menu, open
   * on. Not part of the public API.
   *
   * @defaultValue 'right'
   * @internal
   */
  tooltipPlacement?: 'left' | 'right';

  /**
   * Supplied by `Sidebar`: whether the sidebar renders in the mobile drawer,
   * where the folder is always inline (never a menu). Not part of the
   * public API.
   *
   * @internal
   */
  inDrawer?: boolean;

  /**
   * Supplied by `Sidebar` while it renders in the mobile drawer: handed to
   * each item so following one closes the drawer. Not part of the public API.
   *
   * @internal
   */
  onActivate?: () => void;

  /**
   * Supplied by `BottomNav.More`: the container this folder belongs to. The
   * folder registers a handle with it that reports its children: active when
   * a visible child is, hidden when the folder or every child is, badged
   * when a visible child is. Not part of the public API.
   *
   * @internal
   */
  parent?: NavFolderContext;
}

interface NavFolderSignature {
  Args: NavFolderArgs;
  Blocks: {
    /** Yields `Item`, a `NavItem` that belongs to this folder. */
    default: [
      {
        Item: WithBoundArgs<
          typeof NavItem,
          'rail' | 'tooltipPlacement' | 'onActivate' | 'folder'
        >;
      }
    ];
  };
  Element: HTMLDivElement;
}

interface FolderTriggerSignature {
  Args: {
    label: string;
    icon?: ComponentLike;
    isOpen: boolean;
    isActive: boolean;
    classes: {
      navFolderTrigger: string;
      navItemIcon: string;
      navItemLabel: string;
      navFolderChevron: string;
    };
  };
  Element: HTMLAnchorElement | HTMLButtonElement;
}

/**
 * The folder's trigger row, the same in the rail and inline; each caller
 * adds its own behaviour (a `Dropdown` trigger, or the disclosure toggle)
 * and ARIA through attributes and modifiers.
 *
 * No `@isActive` to `NavLink`: the folder is not the current page, so the
 * trigger must not get `aria-current`. `data-active` (overriding NavLink's)
 * is a hook only: the trigger has no active styling.
 */
const FolderTrigger: TOC<FolderTriggerSignature> = <template>
  <NavLink
    data-part="nav-folder-trigger"
    data-open="{{@isOpen}}"
    data-active="{{@isActive}}"
    class={{@classes.navFolderTrigger}}
    ...attributes
  >
    {{#if @icon}}
      <span
        data-part="nav-item-icon"
        class={{@classes.navItemIcon}}
        aria-hidden="true"
      ><@icon /></span>
    {{/if}}
    <span
      data-part="nav-item-label"
      data-sidebar-label
      class={{@classes.navItemLabel}}
    >{{@label}}</span>
    <ChevronRightIcon
      data-part="nav-folder-chevron"
      data-open="{{@isOpen}}"
      class={{@classes.navFolderChevron}}
    />
  </NavLink>
</template>;

/**
 * A collapsible group of navigation items, one level deep. The trigger is a
 * disclosure button (`aria-expanded`, `aria-controls`); the items sit in a
 * `role="group"` panel labelled by it. The folder opens when
 * one of its items is active, on load and whenever an item newly becomes
 * active, but never forces itself open otherwise. It is hidden when none of
 * its items is visible.
 *
 * In the collapsed icon rail (not in the mobile drawer) the trigger is a
 * `Dropdown` menu button instead, and the items are the menu's link items,
 * beside the rail. The menu brings the keyboard model (arrows, type-ahead,
 * Escape returning focus to the trigger); tabbing out of it or following an
 * item closes it.
 */
class NavFolder extends Component<NavFolderSignature> {
  /**
   * The registered items. Items register while they render, so the set is
   * not tracked: reading it during render and then changing it in the same
   * render would trip Glimmer's backtracking assertion. `registryVersion`
   * is bumped after render instead, which re-runs everything that reads it.
   */
  #items = new Set<NavItemHandle>();
  @tracked registryVersion = 0;

  @tracked internalOpen = this.args.defaultOpen ?? false;

  /**
   * The rail menu's open state, separate from the inline one so neither
   * disturbs the other. Only honored in the rail; see `isMenuOpen`.
   */
  @tracked menuOpen = false;

  /** Whether the rail trigger's tooltip would be open; see `isTooltipShown`. */
  @tracked tooltipOpen = false;

  /** Whether an active item has been seen; untracked, the modifier's memory. */
  #wasActive = false;

  constructor(owner: unknown, args: NavFolderSignature['Args']) {
    super(owner as never, args);

    const parent = args.parent;
    if (parent) {
      // Lazy getters over the folder's own derived state, so the parent sees
      // the children as they are when it reads them (after render; see
      // `registryVersion`).
      const folder = (): NavFolder => this;
      const unregister = parent.registerItem({
        get isActive() {
          return folder().hasActiveDescendant;
        },
        get isHidden() {
          return folder().isFolderHidden ?? false;
        },
        get hasBadge() {
          return folder().visibleItems.some((item) => item.hasBadge);
        }
      });
      registerDestructor(this, unregister);
    }
  }

  #bumpRegistry(): void {
    schedule('afterRender', () => {
      if (!this.isDestroying && !this.isDestroyed) {
        this.registryVersion++;
      }
    });
  }

  registerItem = (item: NavItemHandle): (() => void) => {
    this.#items.add(item);
    this.#bumpRegistry();
    return () => {
      this.#items.delete(item);
      this.#bumpRegistry();
    };
  };

  @cached
  get context(): NavFolderContext {
    return { registerItem: this.registerItem };
  }

  get items(): NavItemHandle[] {
    // Consumed so the getters below re-run when items come or go. Each
    // handle's own `isActive` / `isHidden` are live reads.
    void this.registryVersion;
    return [...this.#items];
  }

  get visibleItems(): NavItemHandle[] {
    return this.items.filter((item) => !item.isHidden);
  }

  /** A hidden item never makes the folder active. */
  get hasActiveDescendant(): boolean {
    return this.visibleItems.some((item) => item.isActive);
  }

  /** Hidden by `@isHidden`, or because no item is visible (or there is none). */
  get isFolderHidden(): true | undefined {
    return this.args.isHidden || this.visibleItems.length === 0
      ? true
      : undefined;
  }

  get isControlled(): boolean {
    return this.args.open !== undefined;
  }

  /** The inline open state, whatever the sidebar's shape. */
  get isOpen(): boolean {
    return this.isControlled ? Boolean(this.args.open) : this.internalOpen;
  }

  /**
   * In the icon rail the items sit in a menu; inside the mobile drawer
   * the sidebar is always expanded, so the folder is inline there.
   */
  get isMenuMode(): boolean {
    return Boolean(this.args.rail) && !this.args.inDrawer;
  }

  get isMenuOpen(): boolean {
    return this.isMenuMode && this.menuOpen;
  }

  /** What the folder reports as open: the menu in the rail, else the panel. */
  get isExpanded(): boolean {
    return this.isMenuMode ? this.isMenuOpen : this.isOpen;
  }

  /** A collapsed panel keeps its links out of the tab order. */
  get inert(): true | undefined {
    return this.isOpen ? undefined : true;
  }

  /**
   * The rail trigger is only an icon, so it shows its label as a tooltip,
   * with no delay like the rail items beside it, but never over its open
   * menu. Two guards, because the tooltip can open in the same event that
   * opens the menu (a click focuses the trigger first, and a keyboard focus
   * opens a no-delay tooltip at once): opening the menu closes the tooltip,
   * and while the menu is open the tooltip's own requests to open are
   * ignored. Its listeners stay installed, so a pointer leaving the trigger
   * meanwhile is still heard.
   */
  get isTooltipShown(): boolean {
    return this.tooltipOpen && !this.isMenuOpen;
  }

  setTooltipOpen = (open: boolean): void => {
    this.tooltipOpen = open && !this.isMenuOpen;
  };

  setMenuOpen = (open: boolean): void => {
    this.menuOpen = open;
    if (open) {
      this.tooltipOpen = false;
    }
  };

  /**
   * Tab (either way) in the open menu closes it; the menu hands focus back
   * to the trigger, so the next Tab moves on from there. Without this the
   * menu's focus trap would keep focus cycling inside it.
   */
  closeMenuOnTab = (event: KeyboardEvent): void => {
    if (event.key === 'Tab') {
      event.preventDefault();
      this.setMenuOpen(false);
    }
  };

  /**
   * The menu beside the rail: toward the content, top edges aligned. Flips
   * for an end sidebar, whose tooltips open on the left.
   */
  get menuPlacement(): 'left-start' | 'right-start' {
    return this.args.tooltipPlacement === 'left' ? 'left-start' : 'right-start';
  }

  setOpen(open: boolean): void {
    if (!this.isControlled) {
      this.internalOpen = open;
    }
    this.args.onOpenChange?.(open);
  }

  toggle = (): void => {
    this.setOpen(!this.isOpen);
  };

  /**
   * Leaving the rail (expanding the sidebar) removes the menu with the
   * `Dropdown` around it, so it also resets the rail state: the next
   * collapse starts closed. Deferred: this runs during render, which has
   * already read the state.
   */
  resetOutsideRail = modifier((_element: HTMLElement, [rail]: [boolean]) => {
    if (rail || (!this.menuOpen && !this.tooltipOpen)) {
      return;
    }
    schedule('afterRender', () => {
      if (!this.isDestroying && !this.isDestroyed) {
        this.menuOpen = false;
        this.tooltipOpen = false;
      }
    });
  });

  /**
   * Opens the folder when an item *newly* becomes active: on load (the first
   * time an active item is seen) and after a later transition into one.
   * Re-renders that leave it active do nothing, so a folder the user closed
   * stays closed. Deferred to after render, where changing state is safe.
   */
  followActive = modifier((_element: HTMLElement, [active]: [boolean]) => {
    const newlyActive = active && !this.#wasActive;
    this.#wasActive = active;
    if (newlyActive) {
      schedule('afterRender', () => {
        if (!this.isDestroying && !this.isDestroyed && !this.isOpen) {
          this.setOpen(true);
        }
      });
    }
  });

  get triggerId(): string {
    return `${guidFor(this)}-trigger`;
  }

  get panelId(): string {
    return `${guidFor(this)}-panel`;
  }

  @cached
  get classes() {
    const styles = useStyles().navItem();
    return {
      navFolder: styles.navFolder(),
      navFolderPanel: styles.navFolderPanel()
    };
  }

  /** The slots of the folder's trigger, with the icon and label of a row. */
  @cached
  get triggerClasses(): FolderTriggerSignature['Args']['classes'] {
    const styles = useStyles().navItem({ layout: 'inline' });
    return {
      navFolderTrigger: styles.navFolderTrigger(),
      navItemIcon: styles.navItemIcon(),
      navItemLabel: styles.navItemLabel(),
      navFolderChevron: styles.navFolderChevron()
    };
  }

  /** Merged, so a consumer class wins over a conflicting theme class. */
  get className(): string {
    return twMerge(this.classes.navFolder, this.args.class) ?? '';
  }

  <template>
    <div
      data-component="nav-folder"
      data-part="nav-folder"
      data-open="{{this.isExpanded}}"
      hidden={{this.isFolderHidden}}
      class={{this.className}}
      {{this.followActive this.hasActiveDescendant}}
      {{this.resetOutsideRail this.isMenuMode}}
      ...attributes
    >
      {{#if this.isMenuMode}}
        {{! A menu button: Dropdown sets aria-haspopup, aria-expanded and
            aria-controls on the trigger. The trigger stays a NavLink with
            no @href/@route, so it is a <button> and a click never follows
            a link. }}
        <Dropdown
          @placement={{this.menuPlacement}}
          @offsetOptions={{8}}
          @isOpen={{this.isMenuOpen}}
          @onOpenChange={{this.setMenuOpen}}
          as |d|
        >
          <Tooltip
            @openDelay={{0}}
            @isOpen={{this.isTooltipShown}}
            @onOpenChange={{this.setTooltipOpen}}
            @placement={{if @tooltipPlacement @tooltipPlacement "right"}}
            as |t|
          >
            <FolderTrigger
              @label={{@label}}
              @icon={{@icon}}
              @isOpen={{this.isMenuOpen}}
              @isActive={{this.hasActiveDescendant}}
              @classes={{this.triggerClasses}}
              id={{this.triggerId}}
              {{t.trigger}}
              {{d.triggerModifier}}
            />
            <t.Content>{{@label}}</t.Content>
          </Tooltip>
          {{! Named by the trigger, with no heading of its own: a menu is a
              flat list of items. No page-scroll lock, unlike a plain
              Dropdown: it is navigation beside the page. }}
          <d.Menu
            @blockScroll={{false}}
            aria-labelledby={{this.triggerId}}
            {{on "keydown" this.closeMenuOnTab}}
            as |MenuItem|
          >
            {{yield
              (hash
                Item=(component
                  NavItem
                  menuItem=MenuItem
                  rail=false
                  tooltipPlacement=@tooltipPlacement
                  onActivate=@onActivate
                  folder=undefined
                )
              )
            }}
          </d.Menu>
        </Dropdown>
        {{! The menu renders its items only while open, so the folder could
            not otherwise tell it holds the current page while closed. The
            block is rendered a second time here for that alone: its items
            register and render nothing, and the wrapper hides anything else
            the block holds, so there are no duplicate ids and nothing
            focusable. }}
        <div hidden inert>
          {{yield
            (hash
              Item=(component
                NavItem
                registerOnly=true
                rail=false
                tooltipPlacement=@tooltipPlacement
                onActivate=@onActivate
                folder=this.context
              )
            )
          }}
        </div>
      {{else}}
        <FolderTrigger
          @label={{@label}}
          @icon={{@icon}}
          @isOpen={{this.isOpen}}
          @isActive={{this.hasActiveDescendant}}
          @classes={{this.triggerClasses}}
          id={{this.triggerId}}
          aria-expanded="{{this.isOpen}}"
          aria-controls={{this.panelId}}
          {{on "click" this.toggle}}
        />
        {{! The mount-time auto-open lands in the same runloop as the first
            render, before any frame, so the panel starts open instead of
            sliding open on every load. Later opens animate. }}
        <Collapsible
          @isOpen={{this.isOpen}}
          @instantUntilPainted={{true}}
          id={{this.panelId}}
          data-part="nav-folder-panel"
          role="group"
          aria-labelledby={{this.triggerId}}
          inert={{this.inert}}
          class={{this.classes.navFolderPanel}}
        >
          {{yield
            (hash
              Item=(component
                NavItem
                rail=@rail
                tooltipPlacement=@tooltipPlacement
                onActivate=@onActivate
                folder=this.context
              )
            )
          }}
        </Collapsible>
      {{/if}}
    </div>
  </template>
}

export { NavFolder, type NavFolderSignature, type NavFolderArgs };
export default NavFolder;
