import Component from '@glimmer/component';
import { cached, tracked } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { on } from '@ember/modifier';
import { schedule } from '@ember/runloop';
import { guidFor } from '@ember/object/internals';
import { modifier } from 'ember-modifier';
import { useStyles } from '@frontile/theme';
import Drawer from '../overlays/drawer';
import { EllipsisHorizontalIcon } from '../../-private/icons';
import NavItem from './nav-item';
import NavFolder from './nav-folder';
import type { NavFolderContext, NavItemHandle } from './nav-context';
import type { ComponentLike, WithBoundArgs } from '@glint/template';

interface BottomNavMoreArgs {
  /**
   * The tab's label: its accessible name and tooltip.
   *
   * @defaultValue 'More'
   */
  label?: string;

  /**
   * The tab's icon component. Defaults to a horizontal ellipsis.
   */
  icon?: ComponentLike;

  /**
   * The sheet's accessible name, for both the dialog and the `nav` inside it.
   * Defaults to the label.
   */
  sheetLabel?: string;

  /**
   * Renders no tab. The tab is also not rendered when every item inside is
   * hidden.
   *
   * @defaultValue false
   */
  isHidden?: boolean;
}

interface BottomNavMoreSignature {
  Args: BottomNavMoreArgs;
  Blocks: {
    /**
     * The sheet's content. Yields `Item`, an inline `NavItem`, and `Folder`,
     * an inline `NavFolder`. Following an item closes the sheet.
     *
     * The block is rendered twice: once hidden, always, to track which item
     * is active or badged, and once in the open sheet. Avoid `id`s and side
     * effects (modifiers, analytics, data loading) inside it.
     */
    default: [
      {
        Item: WithBoundArgs<
          typeof NavItem,
          'rail' | 'tooltipPlacement' | 'onActivate' | 'folder'
        >;
        Folder: WithBoundArgs<
          typeof NavFolder,
          'rail' | 'inDrawer' | 'onActivate' | 'parent'
        >;
      }
    ];
  };
}

/** Takes registrations and ignores them; see `sheetRegistry`. */
const IGNORE_REGISTRATION: NavFolderContext = {
  registerItem: () => () => {}
};

/**
 * The last tab of a `BottomNav`: it opens a bottom sheet holding more
 * navigation, as inline items and folders. The tab is a button with
 * `aria-haspopup="dialog"`; the sheet is a bottom `Drawer` with a `nav`
 * inside. The tab shows active when an item inside is active and a dot
 * when an item inside has a badge, even while the sheet is closed. It is
 * never `aria-current`: the current page is the item, not the tab.
 *
 * The sheet takes exactly the content given; nothing overflows into it.
 */
class BottomNavMore extends Component<BottomNavMoreSignature> {
  @tracked isOpen = false;

  /**
   * The registered items and folders, from the hidden copy of the block.
   * Items register while they render, so the set is not tracked: reading it
   * during render and then changing it in the same render would trip
   * Glimmer's backtracking assertion. `registryVersion` is bumped after
   * render instead, which re-runs everything that reads it. Same approach as
   * `NavFolder`.
   */
  #items = new Set<NavItemHandle>();
  @tracked registryVersion = 0;

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

  /** What the hidden copy's items and folders register with. */
  @cached
  get registry(): NavFolderContext {
    return { registerItem: this.registerItem };
  }

  /**
   * The open sheet's copy does not register: the hidden copy is always
   * rendered and already reports the same items.
   */
  sheetRegistry = IGNORE_REGISTRATION;

  get items(): NavItemHandle[] {
    // Consumed so the getters below re-run when items come or go. Each
    // handle's own state is a live read.
    void this.registryVersion;
    return [...this.#items];
  }

  get visibleItems(): NavItemHandle[] {
    return this.items.filter((item) => !item.isHidden);
  }

  /** A hidden item never makes the tab active. */
  get hasActive(): boolean {
    return this.visibleItems.some((item) => item.isActive);
  }

  /** A hidden item never badges the tab. */
  get hasBadge(): boolean {
    return this.visibleItems.some((item) => item.hasBadge);
  }

  /**
   * Hidden by `@isHidden`, or once something has registered and none of it
   * is visible.
   */
  get isTabHidden(): boolean {
    return (
      Boolean(this.args.isHidden) ||
      (this.items.length > 0 && this.visibleItems.length === 0)
    );
  }

  /** A hidden tab has no sheet to show. */
  get sheetOpen(): boolean {
    return this.isOpen && !this.isTabHidden;
  }

  get label(): string {
    return this.args.label ?? 'More';
  }

  get sheetLabel(): string {
    return this.args.sheetLabel ?? this.label;
  }

  get icon(): ComponentLike {
    return this.args.icon ?? EllipsisHorizontalIcon;
  }

  get tabId(): string {
    return `${guidFor(this)}-tab`;
  }

  get sheetId(): string {
    return `${guidFor(this)}-sheet`;
  }

  /** Only while the sheet exists, so it never points at nothing. */
  get controlsId(): string | undefined {
    return this.sheetOpen ? this.sheetId : undefined;
  }

  toggle = (): void => {
    this.isOpen = !this.isOpen;
  };

  /** Handed to the sheet's items, so following one closes the sheet. */
  closeSheet = (): void => {
    this.isOpen = false;
  };

  /**
   * Closes the sheet when the tab goes away (every item hidden), so it does
   * not reopen on its own when an item reappears. Deferred to after render,
   * where changing state is safe.
   */
  closeWhenHidden = modifier((_element: HTMLElement, [hidden]: [boolean]) => {
    if (hidden && this.isOpen) {
      schedule('afterRender', () => {
        if (!this.isDestroying && !this.isDestroyed) {
          this.isOpen = false;
        }
      });
    }
  });

  /** Handed to the hidden copy's items, which are never clicked. */
  ignore = (): void => {};

  /**
   * Focus goes back to the More tab when the sheet closes, however it
   * closes. If the tab is gone, wherever focus was before.
   */
  get focusTrapOptions() {
    const tabId = this.tabId;
    return {
      setReturnFocus: (previous: HTMLElement | SVGElement) => {
        const tab = document.getElementById(tabId);
        return tab && tab.isConnected ? tab : previous;
      }
    };
  }

  @cached
  get classes() {
    const styles = useStyles().bottomNav();
    return {
      bottomNavMoreRegistry: styles.bottomNavMoreRegistry(),
      bottomNavMoreNav: styles.bottomNavMoreNav(),
      // Merged into the Drawer's own slots.
      sheet: {
        base: styles.bottomNavMoreSheet(),
        body: styles.bottomNavMoreBody()
      }
    };
  }

  <template>
    {{! The hidden copy: always rendered, so its items register and the tab
        knows about active and badged items while the sheet is closed. Out
        of sight, out of the tab order and out of the accessibility tree.
        Rendered before the tab, so its items have registered by the time
        the tab first reads them. }}
    <div
      hidden
      inert
      aria-hidden="true"
      data-part="bottom-nav-more-registry"
      class={{this.classes.bottomNavMoreRegistry}}
      {{this.closeWhenHidden this.isTabHidden}}
    >
      {{yield
        (hash
          Item=(component
            NavItem
            rail=false
            tooltipPlacement="top"
            onActivate=this.ignore
            folder=this.registry
          )
          Folder=(component
            NavFolder
            rail=false
            inDrawer=true
            onActivate=this.ignore
            parent=this.registry
          )
        )
      }}
    </div>
    {{#unless this.isTabHidden}}
      {{! aria-current="false" overrides the "page" NavLink sets for an
          active link: the tab only shows that the current page is inside.

          No tooltip, unlike the other tabs. Focus returns here when the
          sheet closes, which would open a tooltip over the tab that was
          just used. Portal no longer lets the sheet render into the
          unnamed target a tooltip's Portal made for itself (it is marked
          data-portal-owner), so that is no longer a hazard, but the
          tooltip is still unwanted there. The label is still the
          accessible name. }}
      <NavItem
        @layout="icon"
        @noTooltip={{true}}
        @icon={{this.icon}}
        @isActive={{this.hasActive}}
        @badgeDot={{this.hasBadge}}
        @badgeLabel="has updates"
        id={{this.tabId}}
        aria-haspopup="dialog"
        aria-expanded="{{this.sheetOpen}}"
        aria-controls={{this.controlsId}}
        aria-current="false"
        {{on "click" this.toggle}}
      >{{this.label}}</NavItem>
    {{/unless}}
    {{! No close button: the drag handle (a button), Escape and the backdrop
        close the sheet, and a corner button would sit over the first row. }}
    <Drawer
      @isOpen={{this.sheetOpen}}
      @onClose={{this.closeSheet}}
      @placement="bottom"
      @variant="flat"
      @size="sm"
      @allowCloseButton={{false}}
      @classes={{this.classes.sheet}}
      @focusTrapOptions={{this.focusTrapOptions}}
      id={{this.sheetId}}
      data-component="bottom-nav-more"
      data-part="bottom-nav-more-sheet"
      aria-label={{this.sheetLabel}}
      as |d|
    >
      <d.Body data-part="bottom-nav-more-body">
        <nav
          aria-label={{this.sheetLabel}}
          data-part="bottom-nav-more-nav"
          class={{this.classes.bottomNavMoreNav}}
        >
          {{yield
            (hash
              Item=(component
                NavItem
                rail=false
                tooltipPlacement="top"
                onActivate=this.closeSheet
                folder=this.sheetRegistry
              )
              Folder=(component
                NavFolder
                rail=false
                inDrawer=true
                onActivate=this.closeSheet
                parent=this.sheetRegistry
              )
            )
          }}
        </nav>
      </d.Body>
    </Drawer>
  </template>
}

export { BottomNavMore, type BottomNavMoreSignature, type BottomNavMoreArgs };
export default BottomNavMore;
