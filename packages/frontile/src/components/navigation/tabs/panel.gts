import Component from '@glimmer/component';
import type { TabsContext } from './tabs';

interface TabsPanelArgs<T> {
  /** The value this panel is paired with; must match a `Tab`'s `@value`. */
  value: T;

  /** Class names appended to this panel's theme classes. */
  class?: string;

  /**
   * Supplied by Tabs. Not part of the public API.
   *
   * @internal
   */
  context: TabsContext<T>;
}

interface TabsPanelSignature<T> {
  Args: TabsPanelArgs<T>;
  Blocks: { default: [] };
  Element: HTMLDivElement;
}

class TabsPanel<T> extends Component<TabsPanelSignature<T>> {
  get isSelected(): boolean {
    return this.args.context.isSelected(this.args.value);
  }

  get id(): string {
    return this.args.context.idFor(this.args.value, 'panel');
  }

  get tabId(): string {
    return this.args.context.idFor(this.args.value, 'tab');
  }

  <template>
    {{#if this.isSelected}}
      <div
        role="tabpanel"
        data-part="panel"
        id={{this.id}}
        aria-labelledby={{this.tabId}}
        tabindex="0"
        class="{{@context.panelClass}} {{@class}}"
        ...attributes
      >
        {{yield}}
      </div>
    {{/if}}
  </template>
}

export { TabsPanel, type TabsPanelSignature, type TabsPanelArgs };
export default TabsPanel;
