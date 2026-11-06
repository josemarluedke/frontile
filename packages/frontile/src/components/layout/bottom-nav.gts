import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { registerDestructor } from '@ember/destroyable';
import { useStyles } from '@frontile/theme';
import NavItem from './nav-item';
import BottomNavMore from './bottom-nav-more';
import type { AppLayoutContext } from './context';
import type Owner from '@ember/owner';
import type { WithBoundArgs } from '@glint/template';

interface BottomNavArgs {
  /**
   * The navigation landmark's accessible name.
   *
   * @defaultValue 'Main'
   */
  label?: string;

  /**
   * Supplied by `AppLayout`. Not part of the public API.
   *
   * @internal
   */
  layout?: AppLayoutContext;
}

interface BottomNavSignature {
  Args: BottomNavArgs;
  Blocks: {
    default: [
      {
        /** A tab: `NavItem` as an icon with its label as a tooltip. */
        Item: WithBoundArgs<typeof NavItem, 'layout' | 'tooltipPlacement'>;
        /**
         * The last tab: opens a bottom sheet with more items and folders.
         * It shows active, or a dot, when an item inside is active or badged.
         */
        More: typeof BottomNavMore;
      }
    ];
  };
  Element: HTMLElement;
}

/**
 * A bar of icon tabs along the bottom of the screen, for the primary
 * navigation on small viewports. Rendered as a `nav` landmark. Each tab is a
 * `NavItem` in its `icon` layout, so the label is its accessible name and
 * shows as a tooltip. `More` adds a last tab that opens a bottom sheet of
 * further navigation.
 *
 * On its own the bar is fixed to the bottom of the viewport and always
 * rendered. Yielded by `AppLayout`, it renders only with
 * `@mobileNav="bottom"` below the layout's breakpoint, as the grid's bottom
 * row (sticky in `scrollMode="page"`); otherwise it renders nothing, and an
 * open More sheet goes with it.
 */
class BottomNav extends Component<BottomNavSignature> {
  constructor(owner: Owner, args: BottomNavArgs) {
    super(owner, args);
    const unregister = args.layout?.registerBottomNav(this);
    if (unregister) {
      registerDestructor(this, unregister);
    }
  }

  get label(): string {
    return this.args.label ?? 'Main';
  }

  /** Standalone: always. In a layout: only where it replaces the sidebar. */
  get isShown(): boolean {
    const layout = this.args.layout;
    return layout ? layout.bottomNavMode : true;
  }

  @cached
  get classNames(): string {
    const layout = this.args.layout;
    return useStyles()
      .bottomNav()
      .bottomNav({
        class: layout?.styles.bottomNav({ class: layout.classes?.bottomNav })
      });
  }

  <template>
    {{#if this.isShown}}
      <nav
        data-component="bottom-nav"
        data-part="bottom-nav"
        aria-label={{this.label}}
        class={{this.classNames}}
        ...attributes
      >
        {{yield
          (hash
            Item=(component NavItem layout="icon" tooltipPlacement="top")
            More=BottomNavMore
          )
        }}
      </nav>
    {{/if}}
  </template>
}

export { BottomNav, type BottomNavSignature, type BottomNavArgs };
export default BottomNav;
