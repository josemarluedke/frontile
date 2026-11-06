import Component from '@glimmer/component';
import { cached, tracked } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { on } from '@ember/modifier';
import { schedule } from '@ember/runloop';
import { guidFor } from '@ember/object/internals';
import { modifier } from 'ember-modifier';
import { waitForPromise } from '@ember/test-waiters';
import {
  autoUpdate,
  computePosition,
  flip,
  offset,
  shift,
  type Placement
} from '@floating-ui/dom';
import { twMerge, useStyles } from '@frontile/theme';
import Collapsible from '../utilities/collapsible';
import Tooltip from '../overlays/tooltip';
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
  navFolderFlyout: string;
  navFolderFlyoutLabel: string;
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
   *
   * This is the inline open state. In the collapsed icon rail the folder
   * opens as a flyout instead, whose state is its own: `@open` does not
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
   * Not called when the flyout of the collapsed icon rail opens or closes.
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
   * Supplied by `Sidebar`: whether the sidebar is drawn as the icon rail,
   * where the folder opens as a flyout. Not part of the public API.
   *
   * @internal
   */
  rail?: boolean;

  /**
   * Supplied by `Sidebar`: the side rail tooltips, and so the flyout, open
   * on. Not part of the public API.
   *
   * @defaultValue 'right'
   * @internal
   */
  tooltipPlacement?: 'left' | 'right';

  /**
   * Supplied by `Sidebar`: whether the sidebar renders in the mobile drawer,
   * where the folder is always inline (never a flyout). Not part of the
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
 * `role="group"` panel labelled by it. The folder opens when
 * one of its items is active, on load and whenever an item newly becomes
 * active, but never forces itself open otherwise. It is hidden when none of
 * its items is visible.
 *
 * In the collapsed icon rail (not in the mobile drawer) the items move into
 * a flyout beside the rail instead, opened only by the trigger. The flyout
 * is still a disclosure: it follows the trigger in the DOM, so Tab walks
 * from the trigger into it. Escape closes it and returns focus to the
 * trigger; following an item, clicking outside or tabbing out closes it.
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
   * The flyout's own open state, separate from the inline one so neither
   * disturbs the other. Only honored in the rail; see `isFlyoutOpen`.
   */
  @tracked flyoutOpen = false;

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

  /** The inline open state, whatever the sidebar's shape. */
  get isOpen(): boolean {
    return this.isControlled ? Boolean(this.args.open) : this.internalOpen;
  }

  /**
   * In the icon rail the items sit in a flyout; inside the mobile drawer
   * the sidebar is always expanded, so the folder is inline there.
   */
  get isFlyoutMode(): boolean {
    return Boolean(this.args.rail) && !this.args.inDrawer;
  }

  get isFlyoutOpen(): boolean {
    return this.isFlyoutMode && this.flyoutOpen;
  }

  /** What the trigger reports: the flyout in the rail, else the panel. */
  get isExpanded(): boolean {
    return this.isFlyoutMode ? this.isFlyoutOpen : this.isOpen;
  }

  /** A collapsed panel keeps its links out of the tab order. */
  get inert(): true | undefined {
    return this.isOpen ? undefined : true;
  }

  /** `hidden` on a closed flyout: its items stay rendered (and registered). */
  get flyoutHidden(): true | undefined {
    return this.isFlyoutOpen ? undefined : true;
  }

  /**
   * The rail trigger is only an icon, so it shows its label as a tooltip,
   * like the rail items beside it; not over its own open flyout, which
   * shows the label itself.
   */
  get tooltipDisabled(): boolean {
    return !this.isFlyoutMode || this.isFlyoutOpen;
  }

  get flyoutPlacement(): Placement {
    return this.args.tooltipPlacement === 'left' ? 'left-start' : 'right-start';
  }

  setOpen(open: boolean): void {
    if (!this.isControlled) {
      this.internalOpen = open;
    }
    this.args.onOpenChange?.(open);
  }

  toggle = (): void => {
    if (this.isFlyoutMode) {
      this.flyoutOpen = !this.flyoutOpen;
      this.#focusInFlyout = false;
    } else {
      this.setOpen(!this.isOpen);
    }
  };

  #flyoutElement?: HTMLElement;
  #triggerElement?: HTMLElement;

  /**
   * Whether focus is inside the open flyout. Kept from focus events because
   * expanding the sidebar removes the flyout in the same render that would
   * have to look: by then focus has already fallen to `<body>`.
   */
  #focusInFlyout = false;

  /**
   * Closes the flyout. Focus inside it would be left on a hidden element,
   * so it goes back to the trigger.
   */
  closeFlyout = (): void => {
    if (!this.flyoutOpen) {
      return;
    }
    this.flyoutOpen = false;
    this.#focusInFlyout = false;
    const active = document.activeElement;
    if (active && this.#flyoutElement?.contains(active)) {
      this.#triggerElement?.focus();
    }
  };

  registerFlyout = modifier((element: HTMLElement) => {
    this.#flyoutElement = element;
    const onFocusin = (): void => {
      this.#focusInFlyout = true;
    };
    // A focusout with no destination (the window losing focus, or the
    // flyout being removed) is not focus leaving for somewhere else.
    const onFocusout = (event: FocusEvent): void => {
      const next = event.relatedTarget;
      if (next instanceof Node) {
        this.#focusInFlyout = element.contains(next);
      }
    };
    element.addEventListener('focusin', onFocusin);
    element.addEventListener('focusout', onFocusout);
    return () => {
      element.removeEventListener('focusin', onFocusin);
      element.removeEventListener('focusout', onFocusout);
      if (this.#flyoutElement === element) {
        this.#flyoutElement = undefined;
      }
    };
  });

  registerTrigger = modifier((element: HTMLElement) => {
    this.#triggerElement = element;
  });

  /**
   * Places the open flyout beside the trigger, and keeps it there while it
   * is open. `fixed`, so the sidebar body's scrolling does not clip it.
   * Re-run (and torn down) whenever the placement or the open state
   * changes, so a stale placement never keeps updating.
   */
  positionFlyout = modifier(
    (flyout: HTMLElement, [placement, open]: [Placement, boolean]) => {
      const trigger = this.#triggerElement;
      if (!open || !trigger) {
        return;
      }
      Object.assign(flyout.style, { position: 'fixed', top: '0', left: '0' });
      const update = (): void => {
        void waitForPromise(
          computePosition(trigger, flyout, {
            placement,
            strategy: 'fixed',
            middleware: [offset(8), flip(), shift({ padding: 8 })]
          }).then(({ x, y }) => {
            Object.assign(flyout.style, { left: `${x}px`, top: `${y}px` });
          })
        );
      };
      return autoUpdate(trigger, flyout, update);
    }
  );

  /**
   * While the flyout is open: Escape closes it and focuses the trigger, and
   * a click or focus landing outside the folder (trigger and flyout) closes
   * it. A focus leaving for nowhere (the window losing focus) does not.
   *
   * Outside the rail it resets the flyout, so expanding the sidebar closes
   * it and the next collapse starts closed. Deferred: this runs during
   * render, which has already read the state. The flyout is gone by then,
   * so focus that was inside it has fallen to `<body>`; it goes to the
   * trigger, which is still there. Focus anywhere else is left alone.
   */
  dismissFlyout = modifier(
    (root: HTMLElement, [mode, open]: [boolean, boolean]) => {
      if (!mode) {
        if (this.flyoutOpen) {
          const refocus = this.#focusInFlyout;
          this.#focusInFlyout = false;
          schedule('afterRender', () => {
            if (this.isDestroying || this.isDestroyed) {
              return;
            }
            this.flyoutOpen = false;
            const active = document.activeElement;
            if (refocus && (!active || active === document.body)) {
              this.#triggerElement?.focus();
            }
          });
        }
        return;
      }
      if (!open) {
        return;
      }

      const onKeydown = (event: KeyboardEvent): void => {
        if (event.key === 'Escape') {
          this.closeFlyout();
          this.#triggerElement?.focus();
        }
      };
      const onFocusout = (event: FocusEvent): void => {
        const next = event.relatedTarget;
        if (next instanceof Node && !root.contains(next)) {
          this.closeFlyout();
        }
      };
      const onDocumentClick = (event: MouseEvent): void => {
        if (event.target instanceof Node && !root.contains(event.target)) {
          this.closeFlyout();
        }
      };

      root.addEventListener('keydown', onKeydown);
      root.addEventListener('focusout', onFocusout);
      document.addEventListener('click', onDocumentClick, true);
      return () => {
        root.removeEventListener('keydown', onKeydown);
        root.removeEventListener('focusout', onFocusout);
        document.removeEventListener('click', onDocumentClick, true);
      };
    }
  );

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

  get flyoutId(): string {
    return `${guidFor(this)}-flyout`;
  }

  /** The element that holds the items: the flyout in the rail. */
  get controlsId(): string {
    return this.isFlyoutMode ? this.flyoutId : this.panelId;
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
      navFolderPanel: styles.navFolderPanel(),
      navFolderFlyout: styles.navFolderFlyout(),
      navFolderFlyoutLabel: styles.navFolderFlyoutLabel()
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
      {{this.dismissFlyout this.isFlyoutMode this.isFlyoutOpen}}
      ...attributes
    >
      {{! Not passing @isActive: the folder is not the current page, so the
          trigger must not get aria-current. data-active (overriding
          NavLink's) is a hook only: the trigger has no active styling. No
          aria-haspopup in the rail either: the flyout is a disclosed group
          of links, not a menu or a dialog. }}
      <Tooltip
        @isDisabled={{this.tooltipDisabled}}
        @placement={{if @tooltipPlacement @tooltipPlacement "right"}}
        as |t|
      >
        <NavLink
          id={{this.triggerId}}
          data-part="nav-folder-trigger"
          aria-expanded="{{this.isExpanded}}"
          aria-controls={{this.controlsId}}
          data-open="{{this.isExpanded}}"
          data-active="{{this.hasActiveDescendant}}"
          class="{{this.classes.navFolderTrigger}}"
          {{this.registerTrigger}}
          {{t.trigger}}
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
            data-open="{{this.isExpanded}}"
            class={{this.classes.navFolderChevron}}
          />
        </NavLink>
        <t.Content>{{@label}}</t.Content>
      </Tooltip>
      {{#if this.isFlyoutMode}}
        {{! Rendered (and its items registered) while closed, so the folder
            still shows active in the rail; `hidden` keeps it out of
            sight, the tab order and the accessibility tree. Items get
            rail=false: they show their labels, without tooltips. }}
        <div
          id={{this.flyoutId}}
          data-part="nav-folder-flyout"
          role="group"
          aria-labelledby={{this.triggerId}}
          hidden={{this.flyoutHidden}}
          class={{this.classes.navFolderFlyout}}
          {{this.registerFlyout}}
          {{this.positionFlyout this.flyoutPlacement this.isFlyoutOpen}}
        >
          {{! The trigger shows only its icon here, so the folder's name
              heads the flyout. Hidden from assistive technology: the
              group is already named by the trigger. }}
          <div
            data-part="nav-folder-flyout-label"
            aria-hidden="true"
            class={{this.classes.navFolderFlyoutLabel}}
          >{{@label}}</div>
          {{yield
            (hash
              Item=(component
                NavItem
                classes=this.itemClasses
                rail=false
                tooltipPlacement=@tooltipPlacement
                onActivate=this.closeFlyout
                folder=this.context
              )
            )
          }}
        </div>
      {{else}}
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
                classes=this.itemClasses
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
