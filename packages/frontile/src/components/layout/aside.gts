import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { guidFor } from '@ember/object/internals';
import { service } from '@ember/service';
import { registerDestructor } from '@ember/destroyable';
import { modifier } from 'ember-modifier';
import { useStyles } from '@frontile/theme';
import Drawer from '../overlays/drawer';
import { AppLayoutState } from './app-layout-state';
import type { AppLayoutContext } from './context';
import type { AppLayoutVariants } from '@frontile/theme';
import type AppLayoutService from '../../services/app-layout';
import type Owner from '@ember/owner';

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
   * PROTOTYPE. Fill the aside from route templates (`LayoutAside`) instead
   * of this block. While the region is empty the aside and `AsideToggle`
   * render nothing, and emptying it closes the aside. Read once.
   */
  region?: string;

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
 * renders in a `Drawer` from the same side, whatever the layout's
 * `@breakpoint` is.
 * Open it with `AsideToggle`. Outside an `AppLayout` it needs `@state` and
 * is always inline.
 */
class Aside extends Component<AsideSignature> {
  @service('app-layout') declare appLayout: AppLayoutService;

  fallbackState = new AppLayoutState();

  constructor(owner: Owner, args: AsideArgs) {
    super(owner, args);
    const unregister = args.layout?.registerAside(this);
    if (unregister) {
      registerDestructor(this, unregister);
    }
    const region = args.region;
    if (region !== undefined) {
      const unsubscribe = this.appLayout.onEmpty(region, () =>
        this.state.closeAside()
      );
      registerDestructor(this, unsubscribe);
    }
  }

  /** Always true for a block aside; a route-driven one needs a source. */
  get hasContent(): boolean {
    const region = this.args.region;
    return region === undefined || this.appLayout.hasContent(region);
  }

  /** PROTOTYPE. Read by the layout's `hasAside` (`RegisteredAside`). */
  get available(): boolean {
    return this.hasContent;
  }

  registerTarget = modifier((element: HTMLElement, [region]: [string]) =>
    this.appLayout.registerTarget(region, element)
  );

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

  /**
   * The aside sits opposite the sidebar: at the end, or at the start with
   * `sidebarSide="end"`. `Drawer` placements are physical, so that side is
   * resolved against the layout's direction.
   */
  get placement(): 'left' | 'right' {
    const layout = this.args.layout;
    const atStart = layout?.config.sidebarSide === 'end';
    const rtl = layout?.isRtl() ?? false;
    return atStart !== rtl ? 'left' : 'right';
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
    {{#if this.hasContent}}
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
          {{#if @region}}
            <aside
              id={{this.id}}
              aria-label={{this.label}}
              data-part="mobile-aside"
              class={{this.mobileClassNames}}
              {{this.registerTarget @region}}
              ...attributes
            ></aside>
          {{else}}
            <aside
              id={{this.id}}
              aria-label={{this.label}}
              data-part="mobile-aside"
              class={{this.mobileClassNames}}
              ...attributes
            >
              {{yield}}
            </aside>
          {{/if}}
        </Drawer>
      {{else if this.state.asideOpen}}
        {{#if @region}}
          <aside
            id={{this.id}}
            aria-label={{this.label}}
            data-part="aside"
            class={{this.classNames}}
            {{this.registerTarget @region}}
            ...attributes
          ></aside>
        {{else}}
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
      {{/if}}
    {{/if}}
  </template>
}

export { Aside, type AsideSignature, type AsideArgs };
export default Aside;
