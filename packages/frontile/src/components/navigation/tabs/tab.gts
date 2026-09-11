import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { on } from '@ember/modifier';
import { modifier } from 'ember-modifier';
import type { TabsContext } from './tabs';

interface TabsTabArgs<T> {
  /** The value this tab represents, paired with a `Panel` of the same value. */
  value: T;

  /**
   * Disables this tab alone: it cannot be activated and keyboard navigation
   * skips over it.
   *
   * @defaultValue false
   */
  isDisabled?: boolean;

  /** Class names appended to this tab's theme classes. */
  class?: string;

  /**
   * Supplied by Tabs. Not part of the public API.
   *
   * @internal
   */
  context: TabsContext<T>;
}

interface TabsTabSignature<T> {
  Args: TabsTabArgs<T>;
  Blocks: { default: [{ isSelected: boolean }] };
  Element: HTMLButtonElement;
}

class TabsTab<T> extends Component<TabsTabSignature<T>> {
  get isSelected(): boolean {
    return this.args.context.isSelected(this.args.value);
  }

  get isDisabled(): boolean {
    return this.args.isDisabled || this.args.context.isGroupDisabled;
  }

  get id(): string {
    return this.args.context.idFor(this.args.value, 'tab');
  }

  get panelId(): string {
    return this.args.context.idFor(this.args.value, 'panel');
  }

  registerValue = modifier((element: HTMLElement, [value]: [T]) => {
    this.args.context.registerValue(element, value);

    return (): void => {
      this.args.context.unregisterValue(element);
    };
  });

  handleClick = (): void => {
    if (this.isDisabled) {
      return;
    }
    this.args.context.select(this.args.value);
  };

  <template>
    <button
      type="button"
      role="tab"
      data-part="tab"
      id={{this.id}}
      aria-selected="{{this.isSelected}}"
      aria-controls={{this.panelId}}
      aria-disabled="{{this.isDisabled}}"
      data-selected="{{this.isSelected}}"
      data-disabled="{{this.isDisabled}}"
      class="{{@context.tabClass}} {{@class}}"
      {{this.registerValue @value}}
      {{@context.indicator.setupTarget this.isSelected}}
      {{@context.roving.setupItem}}
      {{on "click" this.handleClick}}
      ...attributes
    >
      {{yield (hash isSelected=this.isSelected)}}
    </button>
  </template>
}

export { TabsTab, type TabsTabSignature, type TabsTabArgs };
export default TabsTab;
