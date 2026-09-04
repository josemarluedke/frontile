import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { registerDestructor } from '@ember/destroyable';
import type Owner from '@ember/owner';
import { useStyles, type SlotsToClasses } from '@frontile/theme';
import { SelectionIndicator } from '../../../utils/selection-indicator';
import { RovingFocus } from '../../../utils/roving-focus';
import SegmentedControlItem from './item';
import type {
  SegmentedControlSlots,
  SegmentedControlVariants
} from '@frontile/theme';
import type { WithBoundArgs } from '@glint/template';

interface SegmentedControlArgs<T> {
  /**
   * The currently selected value. Compared against each item's `@value` with
   * `===`, so object values must be referentially stable.
   */
  value?: T;

  /** Called with the newly selected value when an item is chosen. */
  onChange?: (value: T) => void;

  /**
   * When set, items render as `<label>` wrapping a native radio input under
   * this name, so the control submits with its form. Without it the control
   * renders buttons and reports only through `onChange`.
   */
  name?: string;

  /** @defaultValue 'default' */
  intent?: SegmentedControlVariants['intent'];

  /** @defaultValue 'solid' */
  variant?: SegmentedControlVariants['variant'];

  /** @defaultValue 'md' */
  size?: SegmentedControlVariants['size'];

  /** @defaultValue 'horizontal' */
  orientation?: SegmentedControlVariants['orientation'];

  /**
   * Stretches the control to its container and gives every item equal width.
   *
   * @defaultValue false
   */
  isFullWidth?: boolean;

  /**
   * Draws a hairline between neighbouring items, hidden around the selected
   * one so the indicator never crosses a visible line.
   *
   * @defaultValue false
   */
  hasSeparators?: boolean;

  /**
   * Disables every item. Individual items can be disabled with the item's own
   * `@isDisabled`.
   *
   * @defaultValue false
   */
  isDisabled?: boolean;

  class?: string;

  /** Class names for each slot of the component, merged with the theme's. */
  classes?: SlotsToClasses<SegmentedControlSlots>;
}

interface SegmentedControlContext<T> {
  indicator: SelectionIndicator;
  roving: RovingFocus;
  isSelected: (value: T) => boolean;
  select: (value: T) => void;
  registerValue: (element: HTMLElement, value: T) => void;
  unregisterValue: (element: HTMLElement) => void;
  isGroupDisabled: boolean;
  name?: string;
  itemClass: string;
}

interface SegmentedControlSignature<T> {
  Args: SegmentedControlArgs<T>;
  Blocks: {
    default: [
      {
        Item: WithBoundArgs<typeof SegmentedControlItem<T>, 'context'>;
      }
    ];
  };
  Element: HTMLDivElement;
}

class SegmentedControl<T> extends Component<SegmentedControlSignature<T>> {
  indicator = new SelectionIndicator();

  // Values are held against their elements rather than serialised into a
  // `data-` attribute, so a non-string `@value` survives the round trip from
  // keyboard activation back to `onChange`.
  #values = new WeakMap<HTMLElement, T>();

  roving = new RovingFocus(() => ({
    orientation: this.args.orientation ?? 'horizontal',
    activationMode: 'automatic' as const,
    onActivate: this.activateElement
  }));

  constructor(owner: Owner, args: SegmentedControlSignature<T>['Args']) {
    super(owner, args);
    registerDestructor(this, () => this.indicator.destroy());
  }

  get styles() {
    const { segmentedControl } = useStyles();

    return segmentedControl({
      mode: this.args.name ? 'form' : 'button',
      intent: this.args.intent,
      variant: this.args.variant,
      size: this.args.size,
      orientation: this.args.orientation,
      isFullWidth: this.args.isFullWidth,
      isDisabled: this.args.isDisabled
    });
  }

  get orientation(): 'horizontal' | 'vertical' {
    return this.args.orientation ?? 'horizontal';
  }

  isSelected = (value: T): boolean => {
    return this.args.value === value;
  };

  select = (value: T): void => {
    if (this.args.isDisabled) {
      return;
    }
    this.args.onChange?.(value);
  };

  activateElement = (element: HTMLElement): void => {
    const value = this.#values.get(element);
    if (value !== undefined) {
      this.select(value);
    }
  };

  registerValue = (element: HTMLElement, value: T): void => {
    this.#values.set(element, value);
  };

  unregisterValue = (element: HTMLElement): void => {
    this.#values.delete(element);
  };

  get context(): SegmentedControlContext<T> {
    return {
      indicator: this.indicator,
      roving: this.roving,
      isSelected: this.isSelected,
      select: this.select,
      registerValue: this.registerValue,
      unregisterValue: this.unregisterValue,
      isGroupDisabled: this.args.isDisabled ?? false,
      name: this.args.name,
      itemClass: this.styles.item({ class: this.args.classes?.item })
    };
  }

  <template>
    <div
      role="radiogroup"
      aria-orientation={{this.orientation}}
      aria-disabled={{if @isDisabled "true"}}
      class="group/segmented {{this.styles.base class=@classes.base}}"
      {{this.indicator.setupContainer}}
      ...attributes
    >
      <span
        aria-hidden="true"
        class={{this.styles.indicator class=@classes.indicator}}
      ></span>

      {{! @glint-nocheck: SegmentedControlItem has a type param, glint cannot handle that with WithBoundArgs }}
      {{yield
        (hash Item=(component SegmentedControlItem context=this.context))
      }}
    </div>
  </template>
}

export {
  SegmentedControl,
  type SegmentedControlSignature,
  type SegmentedControlArgs,
  type SegmentedControlContext
};
export default SegmentedControl;
