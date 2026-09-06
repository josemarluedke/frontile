import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { useStyles, type SlotsToClasses } from '@frontile/theme';
import {
  selectionIndicator,
  type SelectionIndicator
} from '../../../utils/selection-indicator';
import type { TabsSlots, TabsVariants } from '@frontile/theme';
import type { TOC } from '@ember/component/template-only';
import type { WithBoundArgs } from '@glint/template';

interface TabsArgs {
  /**
   * The visual style of the tab list.
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
   * The size of the tabs, driving padding and text size.
   *
   * @defaultValue 'md'
   */
  size?: TabsVariants['size'];

  /**
   * Lays the tabs out in a row or a column, and switches the arrow keys that
   * move between them to match.
   *
   * @defaultValue 'horizontal'
   */
  orientation?: TabsVariants['orientation'];

  /**
   * Stretches the tab list to its container and gives every tab equal width.
   *
   * @defaultValue false
   */
  isFullWidth?: boolean;

  /**
   * Disables every tab.
   *
   * @defaultValue false
   */
  isDisabled?: boolean;

  /** Class names for each slot of the component, merged with the theme's. */
  classes?: SlotsToClasses<TabsSlots>;
}

interface TabsContext {
  indicator: SelectionIndicator;
  orientation: 'horizontal' | 'vertical';
  listClass: string;
  indicatorClass: string;
}

interface ListArgs {
  /** Accessible name for the tab list. */
  label?: string;

  /**
   * Supplied by Tabs. Not part of the public API.
   *
   * @internal
   */
  context: TabsContext;
}

interface ListSignature {
  Args: ListArgs;
  Blocks: { default: [] };
  Element: HTMLDivElement;
}

const List: TOC<ListSignature> = <template>
  <div
    role="tablist"
    aria-orientation={{@context.orientation}}
    aria-label={{@label}}
    class="group/tabs {{@context.listClass}}"
    {{@context.indicator.setupContainer}}
    ...attributes
  >
    <span aria-hidden="true" class={{@context.indicatorClass}}></span>
    {{yield}}
  </div>
</template>;

interface TabsSignature {
  Args: TabsArgs;
  Blocks: {
    default: [{ List: WithBoundArgs<typeof List, 'context'> }];
  };
  Element: HTMLDivElement;
}

class Tabs extends Component<TabsSignature> {
  indicator = selectionIndicator();

  @cached
  get styles() {
    const { tabs } = useStyles();

    return tabs({
      variant: this.args.variant,
      intent: this.args.intent,
      size: this.args.size,
      orientation: this.args.orientation,
      isFullWidth: this.args.isFullWidth,
      isDisabled: this.args.isDisabled
    });
  }

  get orientation(): 'horizontal' | 'vertical' {
    return this.args.orientation ?? 'horizontal';
  }

  @cached
  get context(): TabsContext {
    return {
      indicator: this.indicator,
      orientation: this.orientation,
      listClass: this.styles.list({ class: this.args.classes?.list }),
      indicatorClass: this.styles.indicator({
        class: this.args.classes?.indicator
      })
    };
  }

  <template>
    <div class={{this.styles.base class=@classes.base}} ...attributes>
      {{yield (hash List=(component List context=this.context))}}
    </div>
  </template>
}

export { Tabs, List, type TabsSignature, type TabsArgs, type TabsContext };
export default Tabs;
