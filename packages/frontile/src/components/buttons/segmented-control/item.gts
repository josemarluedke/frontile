import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { on } from '@ember/modifier';
import { modifier } from 'ember-modifier';
import type { SegmentedControlContext } from './segmented-control';

interface SegmentedControlItemArgs<T> {
  /** The value this item represents. */
  value: T;

  /** @defaultValue false */
  isDisabled?: boolean;

  class?: string;

  /** Supplied by SegmentedControl. Not part of the public API. */
  context: SegmentedControlContext<T>;
}

interface SegmentedControlItemSignature<T> {
  Args: SegmentedControlItemArgs<T>;
  Blocks: {
    default: [{ isSelected: boolean }];
  };
  Element: HTMLButtonElement;
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

  <template>
    <button
      type="button"
      role="radio"
      aria-checked="{{this.isSelected}}"
      disabled={{this.isDisabled}}
      class="{{@context.itemClass}} {{@class}}"
      {{this.registerValue @value}}
      {{@context.indicator.setupTarget this.isSelected}}
      {{@context.roving.setupItem this.isSelected this.isDisabled}}
      {{on "click" this.handleClick}}
      ...attributes
    >
      {{yield (hash isSelected=this.isSelected)}}
    </button>
  </template>
}

export {
  SegmentedControlItem,
  type SegmentedControlItemSignature,
  type SegmentedControlItemArgs
};
export default SegmentedControlItem;
