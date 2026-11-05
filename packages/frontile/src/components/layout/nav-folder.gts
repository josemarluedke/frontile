import Component from '@glimmer/component';
import { cached, tracked } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { on } from '@ember/modifier';
import { schedule } from '@ember/runloop';
import { guidFor } from '@ember/object/internals';
import { modifier } from 'ember-modifier';
import { useStyles } from '@frontile/theme';
import Collapsible from '../utilities/collapsible';
import { ChevronRightIcon } from '../../-private/icons';
import NavItem from './nav-item';
import NavLink from './nav-link';
import type { NavItemClasses } from './nav-item';
import type { NavFolderContext, NavItemHandle } from './nav-context';
import type { ComponentLike, WithBoundArgs } from '@glint/template';

/** Class names `Sidebar` hands each folder, one per theme slot. */
export interface NavFolderClasses {
  navFolder: string;
  navFolderTrigger: string;
  navFolderChevron: string;
  navFolderPanel: string;
}

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
   */
  open?: boolean;

  /**
   * The initial open state when `@open` is not given.
   *
   * @defaultValue false
   */
  defaultOpen?: boolean;

  /** Called with the requested open state whenever it would change. */
  onOpenChange?: (open: boolean) => void;

  /**
   * Hides the folder. A folder is also hidden when none of its items is
   * visible.
   *
   * @defaultValue false
   */
  isHidden?: boolean;

  /** Class names appended to the folder's root element. */
  class?: string;

  /**
   * Supplied by `Sidebar`. Not part of the public API. Without it (a folder
   * rendered on its own) the theme's classes are used.
   *
   * @internal
   */
  classes?: NavFolderClasses;

  /**
   * Supplied by `Sidebar`: the classes for the folder's items, and for the
   * icon and label in its trigger. Not part of the public API.
   *
   * @internal
   */
  itemClasses?: NavItemClasses;

  /**
   * Supplied by `Sidebar`: whether the sidebar is drawn as the icon rail.
   * Not part of the public API.
   *
   * @internal
   */
  rail?: boolean;

  /**
   * Supplied by `Sidebar`: the side rail tooltips open on. Not part of the
   * public API.
   *
   * @internal
   */
  tooltipPlacement?: 'left' | 'right';

  /**
   * Supplied by `Sidebar`: whether the sidebar renders in the mobile drawer.
   * Not part of the public API.
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
}

interface NavFolderSignature {
  Args: NavFolderArgs;
  Blocks: {
    /** Yields `Item`, a `NavItem` that belongs to this folder. */
    default: [
      {
        Item: WithBoundArgs<
          typeof NavItem,
          'classes' | 'rail' | 'tooltipPlacement' | 'onActivate' | 'folder'
        >;
      }
    ];
  };
  Element: HTMLDivElement;
}

/**
 * A collapsible group of navigation items, one level deep. The trigger is a
 * disclosure button (`aria-expanded`, `aria-controls`); the items sit in a
 * `role="group"` panel labelled by it. The folder shows active and opens when
 * one of its items is active, on load and whenever an item newly becomes
 * active, but never forces itself open otherwise. It is hidden when none of
 * its items is visible.
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

  /** Whether an active item has been seen; untracked, the modifier's memory. */
  #wasActive = false;

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

  get isOpen(): boolean {
    return this.isControlled ? Boolean(this.args.open) : this.internalOpen;
  }

  /** A collapsed panel keeps its links out of the tab order. */
  get inert(): true | undefined {
    return this.isOpen ? undefined : true;
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
  get classes(): NavFolderClasses {
    if (this.args.classes) {
      return this.args.classes;
    }
    const styles = useStyles().navItem();
    return {
      navFolder: styles.navFolder(),
      navFolderTrigger: styles.navFolderTrigger(),
      navFolderChevron: styles.navFolderChevron(),
      navFolderPanel: styles.navFolderPanel()
    };
  }

  @cached
  get itemClasses(): NavItemClasses {
    if (this.args.itemClasses) {
      return this.args.itemClasses;
    }
    const styles = useStyles().navItem();
    return {
      navItem: styles.navItem(),
      navItemIcon: styles.navItemIcon(),
      navItemLabel: styles.navItemLabel()
    };
  }

  get className(): string {
    return this.args.class
      ? `${this.classes.navFolder} ${this.args.class}`
      : this.classes.navFolder;
  }

  <template>
    <div
      data-component="nav-folder"
      data-part="nav-folder"
      data-open="{{this.isOpen}}"
      hidden={{this.isFolderHidden}}
      class={{this.className}}
      {{this.followActive this.hasActiveDescendant}}
      ...attributes
    >
      {{! Not passing @isActive: the folder is not the current page, so the
          trigger must not get aria-current. data-active (overriding NavLink's)
          shows an active item for styling only. }}
      <NavLink
        id={{this.triggerId}}
        data-part="nav-folder-trigger"
        aria-expanded="{{this.isOpen}}"
        aria-controls={{this.panelId}}
        data-open="{{this.isOpen}}"
        data-active="{{this.hasActiveDescendant}}"
        class={{this.classes.navFolderTrigger}}
        {{on "click" this.toggle}}
      >
        {{#if @icon}}
          <span
            data-part="nav-item-icon"
            class={{this.itemClasses.navItemIcon}}
            aria-hidden="true"
          ><@icon /></span>
        {{/if}}
        <span
          data-part="nav-item-label"
          data-sidebar-label
          class={{this.itemClasses.navItemLabel}}
        >{{@label}}</span>
        <ChevronRightIcon
          data-part="nav-folder-chevron"
          data-open="{{this.isOpen}}"
          class={{this.classes.navFolderChevron}}
        />
      </NavLink>
      <Collapsible
        @isOpen={{this.isOpen}}
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
              classes=this.itemClasses
              rail=@rail
              tooltipPlacement=@tooltipPlacement
              onActivate=@onActivate
              folder=this.context
            )
          )
        }}
      </Collapsible>
    </div>
  </template>
}

export { NavFolder, type NavFolderSignature, type NavFolderArgs };
export default NavFolder;
