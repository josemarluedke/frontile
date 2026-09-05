import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { registerDestructor } from '@ember/destroyable';
import { buildWaiter } from '@ember/test-waiters';
import type Owner from '@ember/owner';
import { useStyles, type SlotsToClasses } from '@frontile/theme';
import {
  selectionIndicator,
  type SelectionIndicator
} from '../../../utils/selection-indicator';
import { rovingFocus, type RovingFocus } from '../../../utils/roving-focus';
import SegmentedControlItem from './item';
import type {
  SegmentedControlSlots,
  SegmentedControlVariants
} from '@frontile/theme';
import type { WithBoundArgs } from '@glint/template';

const formSyncWaiter = buildWaiter(
  '@frontile/buttons:segmented-control-form-sync'
);

interface SegmentedControlArgs<T> {
  /**
   * The currently selected value. Compared against each item's `@value` with
   * `===`, so object values must be referentially stable.
   *
   * *Passing* this argument at all puts the component in controlled mode --
   * passing it as `undefined` included, which is how a controlled control says
   * "nothing is selected". The selection then only ever reflects what you
   * pass, so pair it with `@onChange` and update your own state; setting it
   * back to `undefined` clears the selection. Omit the argument entirely to
   * let the control track the selection itself, seeded by `@defaultValue`.
   */
  value?: T;

  /**
   * Sets the initially selected value when the control is used uncontrolled
   * (that is, when `@value` is not provided). Ignored in controlled mode.
   *
   * @defaultValue undefined
   */
  defaultValue?: T;

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
  requestFormSync: () => void;
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
  indicator = selectionIndicator();

  // Uncontrolled mode's own selection, seeded from `@defaultValue`. Written on
  // every `select` regardless of mode -- see `select` -- so the two modes stay
  // on one code path, exactly as `Switch` does it.
  @tracked _value: T | undefined;

  // Values are held against their elements rather than serialised into a
  // `data-` attribute, so a non-string `@value` survives the round trip from
  // keyboard activation back to `onChange`. A `Map` rather than a `WeakMap`
  // because form mode has to walk every registered element to re-assert
  // checkedness; entries are removed by the registering modifier's teardown,
  // so nothing outlives the elements themselves.
  #values = new Map<HTMLElement, T>();

  #formSyncFrame?: number;
  #formSyncToken?: unknown;

  roving = rovingFocus(() => ({
    orientation: this.args.orientation ?? 'horizontal',
    activationMode: 'automatic' as const,
    onActivate: this.activateElement
  }));

  constructor(owner: Owner, args: SegmentedControlSignature<T>['Args']) {
    super(owner, args);
    this._value = this.args.defaultValue;
    // The indicator and the roving-focus manager clean themselves up through
    // their own modifiers' destructors. This frame is the component's own, so
    // it is the only thing here that needs registering.
    registerDestructor(this, () => {
      this.#cancelFormSync();
    });
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
      isDisabled: this.args.isDisabled,
      hasSeparators: this.args.hasSeparators
    });
  }

  get orientation(): 'horizontal' | 'vertical' {
    return this.args.orientation ?? 'horizontal';
  }

  /**
   * Whether `@value` was *passed* decides the mode -- not whether it holds a
   * value. `@value` is generic, so `undefined` is a legitimate selection
   * meaning "nothing is selected"; testing `!== undefined` (as `Switch` can,
   * because its `@isSelected` is a boolean and `undefined` there really does
   * mean "not passed") would run a controlled control uncontrolled until its
   * first pick, and would make clearing the selection impossible.
   *
   * Glimmer's named-args object carries a key for every argument written in
   * the invoking template, so `in` distinguishes `@value={{undefined}}` from
   * an omitted `@value` -- which `undefined` alone cannot.
   */
  get isControlled(): boolean {
    return 'value' in this.args;
  }

  /**
   * The selection everything else reads: the argument when controlled, the
   * internal field otherwise. `requestFormSync` re-asserts the native radios
   * from this (via `isSelected`) rather than from `@value`, so an uncontrolled
   * form-mode control does not snap the user's click back.
   */
  get selectedValue(): T | undefined {
    return this.isControlled ? this.args.value : this._value;
  }

  isSelected = (value: T): boolean => {
    return this.selectedValue === value;
  };

  select = (value: T): void => {
    if (this.args.isDisabled) {
      return;
    }
    // Written unconditionally, as in `Switch`: in controlled mode the getter
    // above ignores it, so one assignment serves both modes.
    this._value = value;
    this.args.onChange?.(value);
  };

  activateElement = (element: HTMLElement): void => {
    // `has`, not a `!== undefined` check on the result: `T` may itself be
    // `undefined`, so only membership distinguishes "this element is not
    // registered" from "it is registered against an undefined value".
    if (!this.#values.has(element)) {
      return;
    }
    this.select(this.#values.get(element) as T);
  };

  registerValue = (element: HTMLElement, value: T): void => {
    this.#values.set(element, value);
  };

  unregisterValue = (element: HTMLElement): void => {
    this.#values.delete(element);
  };

  /**
   * Form mode only. A native radio flips its own `checked` property the moment
   * it is clicked, and Glimmer will not undo that: `checked={{isSelected}}`
   * only writes when `isSelected` itself changes. So an uncontrolled control --
   * no `@onChange`, or a consumer that declines the change -- would keep the
   * user's pick in the DOM while `@value` and the indicator still say
   * otherwise, leaving the accessibility tree contradicting the visuals.
   *
   * Re-asserting synchronously inside the change handler would read the stale
   * `@value` and stomp a legitimate update, so this waits a frame: by then the
   * consumer has had its chance to respond and Glimmer has re-rendered, and
   * writing `isSelected` back is either a no-op (the update was accepted) or
   * the correction (it was not). The whole group is walked, because unchecking
   * the clicked radio does not restore its previously-checked sibling.
   *
   * Wrapped in a test waiter so `settled()` covers it, and cancelled on
   * teardown so it can never fire against a destroyed component.
   */
  requestFormSync = (): void => {
    if (this.#formSyncToken) {
      return;
    }

    const token = formSyncWaiter.beginAsync();
    this.#formSyncToken = token;

    this.#formSyncFrame = requestAnimationFrame(() => {
      this.#formSyncFrame = undefined;
      this.#formSyncToken = undefined;
      formSyncWaiter.endAsync(token);

      if (this.isDestroying || this.isDestroyed) {
        return;
      }

      for (const [element, value] of this.#values) {
        if (!(element instanceof HTMLInputElement)) {
          continue;
        }
        const shouldBeChecked = this.isSelected(value);
        if (element.checked !== shouldBeChecked) {
          element.checked = shouldBeChecked;
        }
      }
    });
  };

  #cancelFormSync(): void {
    if (this.#formSyncFrame !== undefined) {
      cancelAnimationFrame(this.#formSyncFrame);
      this.#formSyncFrame = undefined;
    }
    if (this.#formSyncToken) {
      formSyncWaiter.endAsync(this.#formSyncToken);
      this.#formSyncToken = undefined;
    }
  }

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
      requestFormSync: this.requestFormSync,
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
