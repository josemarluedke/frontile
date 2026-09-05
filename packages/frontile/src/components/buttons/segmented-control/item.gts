import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { on } from '@ember/modifier';
import { modifier } from 'ember-modifier';
import type { SegmentedControlContext } from './segmented-control';

interface SegmentedControlItemArgs<T> {
  /**
   * The value this item represents. Selecting it calls the control's
   * `@onChange` with exactly this value.
   */
  value: T;

  /**
   * Disables this item alone: it cannot be clicked and keyboard navigation
   * skips over it. The whole control can be disabled with the control's own
   * `@isDisabled`.
   *
   * @defaultValue false
   */
  isDisabled?: boolean;

  /** Class names appended to this item's theme classes. */
  class?: string;

  /**
   * Supplied by SegmentedControl. Not part of the public API.
   *
   * @internal
   */
  context: SegmentedControlContext<T>;
}

interface SegmentedControlItemSignature<T> {
  Args: SegmentedControlItemArgs<T>;
  Blocks: {
    default: [{ isSelected: boolean }];
  };
  Element: HTMLButtonElement | HTMLLabelElement;
}

class SegmentedControlItem<T> extends Component<
  SegmentedControlItemSignature<T>
> {
  get isSelected(): boolean {
    return this.args.context.isSelected(this.args.value);
  }

  get isDisabled(): boolean {
    return this.args.isDisabled || this.args.context.isGroupDisabled;
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

  get stringValue(): string {
    return String(this.args.value);
  }

  handleChange = (): void => {
    if (this.isDisabled) {
      return;
    }
    this.args.context.select(this.args.value);

    // The browser has already moved checkedness in the DOM. Ask the control to
    // re-assert the whole group from `@value` once the consumer has had its
    // chance to respond, so a declined (or absent) `@onChange` cannot leave the
    // native state disagreeing with the rendered selection.
    this.args.context.requestFormSync();
  };

  <template>
    {{#if @context.name}}
      {{! Form mode. Native radios bring their own arrow-key and focus
          behaviour for a same-named group, so RovingFocus deliberately stands
          down here rather than fighting the browser for control. }}
      <label
        class="{{@context.itemClass}} {{@class}}"
        data-selected="{{this.isSelected}}"
        data-disabled="{{this.isDisabled}}"
        {{@context.indicator.setupTarget this.isSelected}}
        ...attributes
      >
        <input
          type="radio"
          name={{@context.name}}
          value={{this.stringValue}}
          checked={{this.isSelected}}
          disabled={{this.isDisabled}}
          class="sr-only"
          {{this.registerValue @value}}
          {{on "change" this.handleChange}}
        />
        {{yield (hash isSelected=this.isSelected)}}
      </label>
    {{else}}
      <button
        type="button"
        role="radio"
        aria-checked="{{this.isSelected}}"
        disabled={{this.isDisabled}}
        class="{{@context.itemClass}} {{@class}}"
        data-selected="{{this.isSelected}}"
        data-disabled="{{this.isDisabled}}"
        {{this.registerValue @value}}
        {{@context.indicator.setupTarget this.isSelected}}
        {{@context.roving.setupItem this.isSelected}}
        {{on "click" this.handleClick}}
        ...attributes
      >
        {{yield (hash isSelected=this.isSelected)}}
      </button>
    {{/if}}
  </template>
}

export {
  SegmentedControlItem,
  type SegmentedControlItemSignature,
  type SegmentedControlItemArgs
};
export default SegmentedControlItem;
