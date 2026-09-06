import Component from '@glimmer/component';
import { cached, tracked } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { guidFor } from '@ember/object/internals';
import { useStyles, type SlotsToClasses } from '@frontile/theme';
import {
  selectionIndicator,
  type SelectionIndicator
} from '../../../utils/selection-indicator';
import { rovingFocus, type RovingFocus } from '../../../utils/roving-focus';
import Tab from './tab';
import Panel from './panel';
import type { TabsSlots, TabsVariants } from '@frontile/theme';
import type Owner from '@ember/owner';
import type { WithBoundArgs } from '@glint/template';

interface TabsArgs<T> {
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

  /**
   * The currently selected value. Compared against each tab's `@value` with
   * `===`, so object values must be referentially stable.
   *
   * *Passing* this argument at all puts the component in controlled mode --
   * passing it as `undefined` included. Omit it entirely to let `Tabs` track
   * the selection itself, seeded by `@defaultValue`.
   */
  value?: T;

  /** Sets the initially selected value when uncontrolled. */
  defaultValue?: T;

  /** Called with the newly selected value when a tab is chosen. */
  onChange?: (value: T) => void;

  /**
   * `automatic` moves selection with focus, which the APG recommends when
   * panel content is already loaded. `manual` moves focus only and waits for
   * Enter or Space.
   *
   * @defaultValue 'automatic'
   */
  activationMode?: 'automatic' | 'manual';

  /** Class names for each slot of the component, merged with the theme's. */
  classes?: SlotsToClasses<TabsSlots>;
}

interface TabsContext<T> {
  indicator: SelectionIndicator;
  orientation: 'horizontal' | 'vertical';
  listClass: string;
  indicatorClass: string;
  tabClass: string;
  panelClass: string;
  isGroupDisabled: boolean;
  isSelected: (value: T) => boolean;
  select: (value: T) => void;
  registerValue: (element: HTMLElement, value: T) => void;
  unregisterValue: (element: HTMLElement) => void;
  idFor: (value: T, kind: 'tab' | 'panel') => string;
  roving: RovingFocus;
}

interface ListArgs<T> {
  /** Accessible name for the tab list. */
  label?: string;

  /**
   * Supplied by Tabs. Not part of the public API.
   *
   * @internal
   */
  context: TabsContext<T>;
}

interface ListSignature<T> {
  Args: ListArgs<T>;
  Blocks: { default: [] };
  Element: HTMLDivElement;
}

// A class rather than a template-only component: `TOC` values are not
// themselves generic, so `WithBoundArgs<typeof List<T>, 'context'>` below
// would not type-check against a `TOC`-typed constant. A plain class with no
// state, mirroring how `Tab` is generic, gives Glint something it can
// actually parameterize.
class List<T> extends Component<ListSignature<T>> {
  <template>
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
  </template>
}

interface TabsSignature<T> {
  Args: TabsArgs<T>;
  Blocks: {
    default: [
      {
        List: WithBoundArgs<typeof List<T>, 'context'>;
        Tab: WithBoundArgs<typeof Tab<T>, 'context'>;
        Panel: WithBoundArgs<typeof Panel<T>, 'context'>;
      }
    ];
  };
  Element: HTMLDivElement;
}

class Tabs<T> extends Component<TabsSignature<T>> {
  indicator = selectionIndicator();

  roving = rovingFocus(() => ({
    orientation: this.args.orientation ?? 'horizontal',
    activationMode: this.args.activationMode ?? 'automatic',
    onActivate: this.activateElement
  }));

  // Uncontrolled mode's own selection, seeded from `@defaultValue`. Written on
  // every `select` regardless of mode -- the getter ignores it when controlled
  // -- so both modes share one code path, exactly as `SegmentedControl` does.
  @tracked _value: T | undefined;

  #values = new Map<HTMLElement, T>();

  // Values are given an index on first sight and ids are derived from it,
  // rather than from the value's `String()` form: two distinct values that
  // stringify alike would otherwise collide into one id and silently break the
  // `aria-controls` round trip. Untracked, so populating it during render
  // raises no backtracking assertion.
  #indices = new Map<T, number>();

  constructor(owner: Owner, args: TabsSignature<T>['Args']) {
    super(owner, args);
    this._value = this.args.defaultValue;
  }

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

  /**
   * Whether `@value` was *passed* decides the mode -- not whether it holds a
   * value. `T` is generic, so `undefined` is a legitimate selection meaning
   * "nothing is selected". Glimmer's named-args object carries a key for every
   * argument written in the invoking template, so `in` distinguishes
   * `@value={{undefined}}` from an omitted `@value`.
   */
  get isControlled(): boolean {
    return 'value' in this.args;
  }

  get selectedValue(): T | undefined {
    return this.isControlled ? this.args.value : this._value;
  }

  isSelected = (value: T): boolean => this.selectedValue === value;

  select = (value: T): void => {
    if (this.args.isDisabled) {
      return;
    }
    this._value = value;
    this.args.onChange?.(value);
  };

  registerValue = (element: HTMLElement, value: T): void => {
    this.#values.set(element, value);
  };

  unregisterValue = (element: HTMLElement): void => {
    this.#values.delete(element);
  };

  activateElement = (element: HTMLElement): void => {
    // `has`, not a `!== undefined` check: `T` may itself be `undefined`, so
    // only membership distinguishes "not registered" from "registered against
    // an undefined value".
    if (!this.#values.has(element)) {
      return;
    }
    this.select(this.#values.get(element) as T);
  };

  idFor = (value: T, kind: 'tab' | 'panel'): string => {
    let index = this.#indices.get(value);
    if (index === undefined) {
      index = this.#indices.size;
      this.#indices.set(value, index);
    }
    return `${guidFor(this)}-${kind}-${index}`;
  };

  @cached
  get context(): TabsContext<T> {
    return {
      indicator: this.indicator,
      orientation: this.orientation,
      listClass: this.styles.list({ class: this.args.classes?.list }),
      indicatorClass: this.styles.indicator({
        class: this.args.classes?.indicator
      }),
      tabClass: this.styles.tab({ class: this.args.classes?.tab }),
      panelClass: this.styles.panel({ class: this.args.classes?.panel }),
      isGroupDisabled: this.args.isDisabled ?? false,
      isSelected: this.isSelected,
      select: this.select,
      registerValue: this.registerValue,
      unregisterValue: this.unregisterValue,
      idFor: this.idFor,
      roving: this.roving
    };
  }

  <template>
    <div class={{this.styles.base class=@classes.base}} ...attributes>
      {{#let
        (component List context=this.context)
        (component Tab context=this.context)
        (component Panel context=this.context)
        as |TabList TabItem TabPanel|
      }}
        {{! @glint-ignore: WithBoundArgs vs. a generic component }}
        {{yield (hash List=TabList Tab=TabItem Panel=TabPanel)}}
      {{/let}}
    </div>
  </template>
}

export { Tabs, List, type TabsSignature, type TabsArgs, type TabsContext };
export default Tabs;
