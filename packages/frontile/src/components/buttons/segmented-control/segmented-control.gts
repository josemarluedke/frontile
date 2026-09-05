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

  /**
   * The colour intent applied to the selected item's indicator and label.
   *
   * @defaultValue 'default'
   */
  intent?: SegmentedControlVariants['intent'];

  /**
   * The visual style of the control's track and indicator.
   *
   * @defaultValue 'solid'
   */
  variant?: SegmentedControlVariants['variant'];

  /**
   * The size of the control, driving item padding and text size.
   *
   * @defaultValue 'md'
   */
  size?: SegmentedControlVariants['size'];

  /**
   * Lays the items out in a row or a column, and switches the arrow keys that
   * move between them to match.
   *
   * @defaultValue 'horizontal'
   */
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

      {{!
        Glint cannot compose WithBoundArgs with a generic component, so the
        curried Item does not type-check against the block signature even
        though that signature is correct. The let exists only to isolate the
        failure onto the yield, keeping the ignore below scoped to a single
        line; a nocheck directive would silence this whole template instead.
      }}
      {{#let (component SegmentedControlItem context=this.context) as |Item|}}
        {{! @glint-ignore: WithBoundArgs vs. a generic component }}
        {{yield (hash Item=Item)}}
      {{/let}}
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
