import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import NavItem from './nav-item';
import type { AppLayoutContext } from './context';
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
      }
    ];
  };
  Element: HTMLElement;
}

/**
 * A bar of icon tabs along the bottom of the screen, for the primary
 * navigation on small viewports. Rendered as a `nav` landmark. Each tab is a
 * `NavItem` in its `icon` layout, so the label is its accessible name and
 * shows as a tooltip.
 */
class BottomNav extends Component<BottomNavSignature> {
  get label(): string {
    return this.args.label ?? 'Main';
  }

  @cached
  get classNames(): string {
    return useStyles().bottomNav().bottomNav();
  }

  <template>
    <nav
      data-component="bottom-nav"
      data-part="bottom-nav"
      aria-label={{this.label}}
      class={{this.classNames}}
      ...attributes
    >
      {{yield
        (hash Item=(component NavItem layout="icon" tooltipPlacement="top"))
      }}
    </nav>
  </template>
}

export { BottomNav, type BottomNavSignature, type BottomNavArgs };
export default BottomNav;
