import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { modifier } from 'ember-modifier';
import { useStyles, type SlotsToClasses } from '@frontile/theme';
import { selectionIndicator } from '../../../utils/selection-indicator';
import TabNavItem from './item';
import type { TabsSlots, TabsVariants } from '@frontile/theme';
import type { WithBoundArgs } from '@glint/template';

interface TabNavArgs {
  /** Accessible name for the navigation landmark. */
  label?: string;

  /**
   * The visual style of the navigation bar.
   *
   * @defaultValue 'solid'
   */
  variant?: TabsVariants['variant'];

  /**
   * The colour intent applied to the indicator.
   *
   * @defaultValue 'default'
   */
  intent?: TabsVariants['intent'];

  /**
   * The size of the links, driving padding and text size.
   *
   * @defaultValue 'md'
   */
  size?: TabsVariants['size'];

  /**
   * Lays the links out in a row or a column.
   *
   * @defaultValue 'horizontal'
   */
  orientation?: TabsVariants['orientation'];

  /**
   * Stretches the bar to its container and gives every link equal width.
   *
   * @defaultValue false
   */
  isFullWidth?: boolean;

  /** Class names for each slot of the component, merged with the theme's. */
  classes?: SlotsToClasses<TabsSlots>;
}

interface TabNavSignature {
  Args: TabNavArgs;
  Blocks: {
    default: [
      {
        Item: WithBoundArgs<typeof TabNavItem, 'itemClass' | 'setupItem'>;
        itemClass: string;
        setupItem: TabNav['setupItem'];
      }
    ];
  };
  Element: HTMLElement;
}

/**
 * A navigation bar styled like `Tabs`, for links that change the page.
 *
 * It deliberately does **not** use `rovingFocus`: these are links, so every one
 * of them stays individually reachable by Tab and the arrow keys are left to
 * the browser. The ARIA tabs pattern covers in-page panel switching only, and
 * applying it to navigation would remove links from the tab order for no gain.
 */
class TabNav extends Component<TabNavSignature> {
  indicator = selectionIndicator();

  @cached
  get styles() {
    const { tabs } = useStyles();

    return tabs({
      variant: this.args.variant,
      intent: this.args.intent,
      size: this.args.size,
      orientation: this.args.orientation,
      isFullWidth: this.args.isFullWidth
    });
  }

  @cached
  get itemClass(): string {
    return this.styles.tab({ class: this.args.classes?.tab });
  }

  /**
   * Marks an element as the active link and hands its geometry to the
   * indicator. Yielded so a consumer can bring their own link component --
   * `ember-link`, a custom `<AppLink>`, a plain `<a>` -- and still get both the
   * animation and the correct ARIA. `TabNav.Item` applies this internally, so
   * there is exactly one definition of what "active" writes to the DOM.
   */
  setupItem = modifier((element: HTMLElement, [isActive]: [boolean]) => {
    element.setAttribute('data-selected', String(Boolean(isActive)));

    if (isActive) {
      // Ember's `LinkTo` has never set `aria-current` -- it publishes only a
      // CSS class -- so this is the component's own contribution, not a
      // duplicate of something the framework already does.
      element.setAttribute('aria-current', 'page');
      this.indicator.claim(element);
    } else {
      element.removeAttribute('aria-current');
    }

    return (): void => {
      this.indicator.release(element);
    };
  });

  <template>
    <nav
      data-component="tabs"
      data-part="list"
      aria-label={{@label}}
      class="group/tabs {{this.styles.list class=@classes.list}}"
      {{this.indicator.setupContainer}}
      ...attributes
    >
      <span
        data-part="indicator"
        aria-hidden="true"
        class={{this.styles.indicator class=@classes.indicator}}
      ></span>

      {{yield
        (hash
          Item=(component
            TabNavItem itemClass=this.itemClass setupItem=this.setupItem
          )
          itemClass=this.itemClass
          setupItem=this.setupItem
        )
      }}
    </nav>
  </template>
}

export { TabNav, type TabNavSignature, type TabNavArgs };
export default TabNav;
