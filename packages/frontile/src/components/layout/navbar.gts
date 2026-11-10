import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { standaloneStyles, type AppLayoutContext } from './context';

interface NavbarArgs {
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
    const styles = this.args.layout?.styles ?? standaloneStyles();
    return styles.navbar({ class: this.args.layout?.classes?.navbar });
  }

  <template>
    <header data-part="navbar" class={{this.classNames}} ...attributes>
      {{yield}}
    </header>
  </template>
}

export { Navbar, type NavbarSignature, type NavbarArgs };
export default Navbar;
