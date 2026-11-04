import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { guidFor } from '@ember/object/internals';
import { useStyles } from '@frontile/theme';
import Drawer from '../overlays/drawer';
import { AppLayoutState } from './app-layout-state';
import type { AppLayoutContext } from './context';
import type { AppLayoutVariants } from '@frontile/theme';

interface AsideArgs {
  /**
   * The accessible name of the `aside` landmark, also the name of the drawer
   * below `lg`.
   *
   * @defaultValue 'Details'
   */
  label?: string;

  /**
   * The layout variant, `inset` or `attached`. Only used when the aside is
   * rendered outside an `AppLayout`; inside one it follows the layout.
   *
   * @defaultValue 'attached'
   */
  variant?: AppLayoutVariants['variant'];

  /**
   * The state that drives it. Only used when the aside is rendered outside
   * an `AppLayout`; inside one it follows the layout's state.
   */
  state?: AppLayoutState;

  /**
   * Supplied by `AppLayout`. Not part of the public API.
   *
   * @internal
   */
  layout?: AppLayoutContext;
}

interface AsideSignature {
  Args: AsideArgs;
  Blocks: { default: [] };
  Element: HTMLElement;
}

/**
 * A panel beside `Main`, shown while `asideOpen` is true. From `lg` (64rem)
 * up it is an in-flow column that narrows `Main`; below `lg` the same block
 * renders in a right-side `Drawer`, whatever the layout's `@breakpoint` is.
 * Open it with `AsideToggle`. Outside an `AppLayout` it needs `@state` and
 * is always inline.
 */
class Aside extends Component<AsideSignature> {
  fallbackState = new AppLayoutState();

  get state(): AppLayoutState {
    return this.args.layout?.state ?? this.args.state ?? this.fallbackState;
  }

  /**
   * Below `lg` the content moves into the drawer. Only one of the two is
   * rendered, so the block (and any ids in it) exists once.
   */
  get inDrawer(): boolean {
    return this.args.layout?.belowAsideBreakpoint ?? false;
  }

  get label(): string {
    return this.args.label ?? 'Details';
  }

  get id(): string {
    return this.args.layout?.asideId ?? `${guidFor(this)}-aside`;
  }

  /** `Drawer` placements are physical: the aside's side is `right`, `left` in RTL. */
  get placement(): 'left' | 'right' {
    return this.args.layout?.isRtl() ? 'left' : 'right';
  }

  closeDrawer = (): void => {
    this.state.closeAside();
  };

  @cached
  get styles() {
    const layout = this.args.layout;
    return useStyles().appLayout({
      variant: layout?.config.variant ?? this.args.variant ?? 'attached',
      navbarPlacement: layout?.config.navbarPlacement,
      breakpoint: layout?.config.breakpoint,
      scrollMode: layout?.config.scrollMode,
      sidebarSide: layout?.config.sidebarSide,
      standalone: !layout
    });
  }

  @cached
  get classNames(): string {
    return this.styles.aside({ class: this.args.layout?.classes?.aside });
  }

  @cached
  get mobileClassNames(): string {
    return this.styles.mobileAside({
      class: this.args.layout?.classes?.mobileAside
    });
  }

  <template>
    {{#if this.inDrawer}}
      <Drawer
        @isOpen={{this.state.asideOpen}}
        @onClose={{this.closeDrawer}}
        @placement={{this.placement}}
        @size="xs"
        @variant="flat"
        id={{@layout.asideDrawerId}}
        aria-label={{this.label}}
      >
        <aside
          id={{this.id}}
          aria-label={{this.label}}
          data-part="mobile-aside"
          class={{this.mobileClassNames}}
          ...attributes
        >
          {{yield}}
        </aside>
      </Drawer>
    {{else if this.state.asideOpen}}
      <aside
        id={{this.id}}
        aria-label={{this.label}}
        data-part="aside"
        class={{this.classNames}}
        ...attributes
      >
        {{yield}}
      </aside>
    {{/if}}
  </template>
}

export { Aside, type AsideSignature, type AsideArgs };
export default Aside;
