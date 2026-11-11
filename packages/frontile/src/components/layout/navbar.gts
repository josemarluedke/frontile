import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { useStyles } from '@frontile/theme';
import {
  layoutVariants,
  standaloneStyles,
  type AppLayoutContext
} from './context';
import type { AppLayoutVariants } from '@frontile/theme';

interface NavbarArgs {
  /**
   * The navbar's color, one of the theme's semantic categories. Inside an
   * `AppLayout` it defaults to the layout's `@color`.
   *
   * @defaultValue 'neutral'
   */
  color?: AppLayoutVariants['color'];

  /**
   * How the navbar wears its color: `plain` keeps its ground; `solid` fills
   * it with the color, with text and toggles in its contrast color. Inside an
   * `AppLayout` it defaults to the layout's `@navbarSurface`.
   *
   * @defaultValue 'plain'
   */
  surface?: AppLayoutVariants['navbarSurface'];

  /**
   * Supplied by `AppLayout`. Not part of the public API.
   *
   * @internal
   */
  layout?: AppLayoutContext;
}

interface NavbarSignature {
  Args: NavbarArgs;
  Blocks: { default: [] };
  Element: HTMLElement;
}

/**
 * The top bar of the content column, rendered as a `header` landmark. It
 * always sits to the sidebar's side, never above it.
 */
class Navbar extends Component<NavbarSignature> {
  @cached
  get classNames(): string {
    return this.styles.navbar({ class: this.args.layout?.classes?.navbar });
  }

  /**
   * The layout's shared styles, unless the navbar carries its own color or
   * surface; then its own, built from the layout's config.
   */
  get styles() {
    const { color, surface } = this.args;
    const layout = this.args.layout;
    if (color === undefined && surface === undefined) {
      return layout?.styles ?? standaloneStyles();
    }
    const config = layout?.config;
    return useStyles().appLayout({
      ...layoutVariants(config),
      variant: config?.variant ?? 'attached',
      color: color ?? config?.color,
      ownColor: !layout || color !== undefined,
      navbarSurface: surface ?? config?.navbarSurface
    });
  }

  <template>
    <header data-part="navbar" class={{this.classNames}} ...attributes>
      {{yield}}
    </header>
  </template>
}

export { Navbar, type NavbarSignature, type NavbarArgs };
export default Navbar;
