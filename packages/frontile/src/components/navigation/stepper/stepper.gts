import Component from '@glimmer/component';
import { cached, tracked } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { guidFor } from '@ember/object/internals';
import { isDestroyed, isDestroying } from '@ember/destroyable';
import { schedule } from '@ember/runloop';
import { rovingFocus, type RovingFocus } from '../../../utils/roving-focus';
import { useStyles, type SlotsToClasses } from '@frontile/theme';
import StepperList from './list';
import StepperPanel from './panel';
import StepperStep from './step';
import type { StepperSlots, StepperVariants } from '@frontile/theme';
import type Owner from '@ember/owner';
import type { WithBoundArgs } from '@glint/template';

interface StepperArgs<T> {
  /**
   * The currently selected step's value. Compared against each step's
   * `@value` with `===`, so object values must be referentially stable.
   *
   * *Passing* this argument at all puts the component in controlled mode --
   * passing it as `undefined` included. Omit it entirely to let `Stepper`
   * track the selection itself, seeded by `@defaultValue`.
   */
  value?: T;

  /**
   * Sets the initially selected value when uncontrolled. Without it, the
   * first enabled step starts selected.
   */
  defaultValue?: T;

  /**
   * Called with the newly selected value when the user picks a step, and
   * when `next`, `prev` or `goTo` move the selection. In controlled mode the
   * selection only moves if this handler updates `@value`.
   */
  onChange?: (value: T) => void;

  /**
   * Lays the steps out in a row or a column, and switches the arrow keys that
   * move between them to match.
   *
   * @defaultValue 'horizontal'
   */
  orientation?: StepperVariants['orientation'];

  /**
   * The size of the step indicators and their text.
   *
   * @defaultValue 'md'
   */
  size?: StepperVariants['size'];

  /**
   * The accent used for complete and active steps and the filled connector.
   * Invalid steps are always danger-colored, whatever this is.
   *
   * @defaultValue 'primary'
   */
  color?: StepperVariants['color'];

  /**
   * Where a step's title sits relative to its indicator: beside it (`end`) or
   * centered underneath (`bottom`). Ignored when vertical.
   *
   * @defaultValue 'end'
   */
  labelPosition?: StepperVariants['labelPosition'];

  /**
   * Collapses titles to the active one at narrow container widths. Set to
   * `false` to always show every title.
   *
   * @defaultValue true
   */
  collapseLabels?: boolean;

  /**
   * Formats the "Step N of M" line shown when titles are collapsed. Use it to
   * localize the text.
   *
   * @defaultValue (position, total) => `Step ${position} of ${total}`
   */
  summaryLabel?: (position: number, total: number) => string;

  /** Class names for each slot of the component, merged with the theme's. */
  classes?: SlotsToClasses<StepperSlots>;
}

/**
 * What a step tells the root about itself. The getters read the step's live
 * arguments, so the root always sees the current title and disabled state.
 */
interface StepRecord<T> {
  readonly id: string;
  readonly element: HTMLElement;
  readonly value: T;
  readonly title: string | undefined;
  readonly isDisabled: boolean;
}

type StepState = 'complete' | 'active' | 'upcoming';

interface StepperSummary {
  /** The formatted "Step N of M" text. */
  label: string;
  title: string | undefined;
}

interface StepperContext<T> {
  orientation: 'horizontal' | 'vertical';
  listClass: string;
  itemClass: string;
  stepClass: string;
  indicatorClass: string;
  connectorClass: string;
  labelClass: string;
  titleClass: string;
  descriptionClass: string;
  summaryClass: string;
  panelClass: string;
  /**
   * The "Step N of M" line, present only for a horizontal Stepper with
   * collapsing labels and a matched selection.
   */
  readonly summary: StepperSummary | undefined;
  /** Registered steps in document order. */
  readonly steps: readonly StepRecord<T>[];
  isSelected: (value: T) => boolean;
  stateOf: (value: T) => StepState;
  select: (value: T) => void;
  register: (record: StepRecord<T>) => void;
  unregister: (record: StepRecord<T>) => void;
  stepIdFor: (value: T) => string | undefined;
  panelIdFor: (value: T) => string;
  roving: RovingFocus;
}

/**
 * What `Stepper` yields. Exported so a component that receives the yielded
 * object (`<BillingStep @stepper={{S}} />`) can type its argument.
 */
interface StepperApi<T> {
  List: WithBoundArgs<typeof StepperList<T>, 'context'>;
  Step: WithBoundArgs<typeof StepperStep<T>, 'context'>;
  Panel: WithBoundArgs<typeof StepperPanel<T>, 'context'>;

  /** Moves to the next step that is not disabled. A no-op on the last one. */
  next: () => void;

  /** Moves to the previous step that is not disabled. A no-op on the first. */
  prev: () => void;

  /**
   * Moves to a specific step. Unlike `next` and `prev`, it can reach a
   * disabled step: `isDisabled` governs the user, not your code.
   */
  goTo: (value: T) => void;

  /** Whether `next` has a step to move to. */
  hasNext: boolean;

  /** Whether `prev` has a step to move to. */
  hasPrev: boolean;
}

interface StepperSignature<T> {
  Args: StepperArgs<T>;
  Blocks: {
    default: [StepperApi<T>];
  };
  Element: HTMLDivElement;
}

class Stepper<T> extends Component<StepperSignature<T>> {
  // Selection is manual -- Enter or Space -- unlike `Tabs`' automatic default:
  // selecting a step can trigger validation or navigation, which arrowing
  // past one must not.
  roving = rovingFocus(() => ({
    orientation: this.orientation,
    activationMode: 'manual',
    onActivate: this.activateElement
  }));

  // Uncontrolled mode's own selection, seeded from `@defaultValue`. Written on
  // every `select` regardless of mode -- the getter ignores it when controlled
  // -- so both modes share one code path, as `Tabs` does.
  @tracked _value: T | undefined;
  @tracked _hasSelection = false;

  // Registered steps live in an untracked list, with a tracked version that
  // consumers read. A step registers from its modifier, which installs inside
  // the render transaction that already read `steps` (via `stateOf`): writing
  // tracked state there trips Ember's backtracking assertion. So the list is
  // mutated freely and only the version bump -- which is what makes `steps`
  // reactive -- is deferred to `afterRender`, outside the transaction.
  #records: StepRecord<T>[] = [];
  @tracked _version = 0;
  #bumpScheduled = false;

  // Panel ids are derived from the order values are first seen, not from the
  // value's `String()` form: two distinct values that stringify alike would
  // otherwise collide. Untracked, so populating it during render raises no
  // backtracking assertion.
  #panelIndices = new Map<T, number>();

  constructor(owner: Owner, args: StepperSignature<T>['Args']) {
    super(owner, args);
    if ('defaultValue' in this.args) {
      this._value = this.args.defaultValue;
      this._hasSelection = true;
    }
  }

  @cached
  get styles() {
    const { stepper } = useStyles();

    return stepper({
      color: this.args.color,
      size: this.args.size,
      orientation: this.args.orientation,
      labelPosition: this.args.labelPosition,
      collapseLabels: this.args.collapseLabels
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

  /** Registered steps in document order. */
  get steps(): readonly StepRecord<T>[] {
    // Consumed for its tag only: this is what re-runs dependents when the
    // registry changes.
    void this._version;

    return [...this.#records].sort((a, b) =>
      a.element.compareDocumentPosition(b.element) &
      Node.DOCUMENT_POSITION_FOLLOWING
        ? -1
        : 1
    );
  }

  get selectedValue(): T | undefined {
    if (this.isControlled) {
      return this.args.value;
    }

    // A Stepper always has a current step. Uncontrolled, a stored value that no
    // registered step matches -- its step was removed -- falls back to the
    // first enabled step. Before any step has registered there is nothing to
    // compare against, so the stored value stands.
    if (this._hasSelection) {
      const steps = this.steps;
      if (
        steps.length === 0 ||
        steps.some((step) => step.value === this._value)
      ) {
        return this._value;
      }
    }

    return this.steps.find((step) => !step.isDisabled)?.value;
  }

  /** Backs the narrow-width "Step N of M" line. */
  get summary(): StepperSummary | undefined {
    if (
      this.orientation !== 'horizontal' ||
      this.args.collapseLabels === false
    ) {
      return undefined;
    }
    const steps = this.steps;
    const selected = this.selectedValue;
    const index = steps.findIndex((step) => step.value === selected);
    if (index === -1) {
      return undefined;
    }
    const position = index + 1;
    const total = steps.length;
    return {
      label: this.args.summaryLabel
        ? this.args.summaryLabel(position, total)
        : `Step ${position} of ${total}`,
      title: steps[index]?.title
    };
  }

  isSelected = (value: T): boolean => this.selectedValue === value;

  stateOf = (value: T): StepState => {
    const selected = this.selectedValue;
    if (value === selected) {
      return 'active';
    }
    const values = this.steps.map((step) => step.value);
    const activeIndex = values.indexOf(selected as T);
    const index = values.indexOf(value);
    return activeIndex !== -1 && index !== -1 && index < activeIndex
      ? 'complete'
      : 'upcoming';
  };

  /**
   * The nearest step in `direction` that is not disabled. With no current
   * step (nothing selected, or the selected value matches no step) `next`
   * finds the first enabled step and `prev` finds none.
   */
  #neighbor(direction: 1 | -1): StepRecord<T> | undefined {
    const steps = this.steps;
    const selected = this.selectedValue;
    const current = steps.findIndex((step) => step.value === selected);

    for (
      let i = current + direction;
      i >= 0 && i < steps.length;
      i += direction
    ) {
      const step = steps[i];
      if (step && !step.isDisabled) {
        return step;
      }
    }
    return undefined;
  }

  get hasNext(): boolean {
    return this.#neighbor(1) !== undefined;
  }

  get hasPrev(): boolean {
    return this.#neighbor(-1) !== undefined;
  }

  next = (): void => {
    const target = this.#neighbor(1);
    if (target) {
      this.select(target.value);
    }
  };

  prev = (): void => {
    const target = this.#neighbor(-1);
    if (target) {
      this.select(target.value);
    }
  };

  goTo = (value: T): void => {
    this.select(value);
  };

  select = (value: T): void => {
    this._value = value;
    this._hasSelection = true;
    this.args.onChange?.(value);
  };

  register = (record: StepRecord<T>): void => {
    this.#records.push(record);
    this.#bump();
  };

  unregister = (record: StepRecord<T>): void => {
    this.#records = this.#records.filter((item) => item !== record);
    this.#bump();
  };

  #bump(): void {
    if (this.#bumpScheduled) {
      return;
    }
    this.#bumpScheduled = true;
    schedule('afterRender', () => {
      this.#bumpScheduled = false;
      if (isDestroying(this) || isDestroyed(this)) {
        return;
      }
      this._version++;
    });
  }

  activateElement = (element: HTMLElement): void => {
    const record = this.#records.find((item) => item.element === element);
    if (!record || record.isDisabled) {
      return;
    }
    this.select(record.value);
  };

  stepIdFor = (value: T): string | undefined =>
    this.steps.find((step) => step.value === value)?.id;

  panelIdFor = (value: T): string => {
    let index = this.#panelIndices.get(value);
    if (index === undefined) {
      index = this.#panelIndices.size;
      this.#panelIndices.set(value, index);
    }
    return `${guidFor(this)}-panel-${index}`;
  };

  @cached
  get context(): StepperContext<T> {
    // eslint-disable-next-line @typescript-eslint/no-this-alias
    const stepper = this;
    const classes = this.args.classes;

    return {
      orientation: this.orientation,
      listClass: this.styles.list({ class: classes?.list }),
      itemClass: this.styles.item({ class: classes?.item }),
      stepClass: this.styles.step({ class: classes?.step }),
      indicatorClass: this.styles.indicator({ class: classes?.indicator }),
      connectorClass: this.styles.connector({ class: classes?.connector }),
      labelClass: this.styles.label({ class: classes?.label }),
      titleClass: this.styles.title({ class: classes?.title }),
      descriptionClass: this.styles.description({
        class: classes?.description
      }),
      summaryClass: this.styles.summary({ class: classes?.summary }),
      panelClass: this.styles.panel({ class: classes?.panel }),
      get summary() {
        return stepper.summary;
      },
      get steps() {
        return stepper.steps;
      },
      isSelected: this.isSelected,
      stateOf: this.stateOf,
      select: this.select,
      register: this.register,
      unregister: this.unregister,
      stepIdFor: this.stepIdFor,
      panelIdFor: this.panelIdFor,
      roving: this.roving
    };
  }

  <template>
    <div
      data-component="stepper"
      data-part="base"
      data-orientation={{this.orientation}}
      class={{this.styles.base class=@classes.base}}
      ...attributes
    >
      {{#let
        (component StepperList context=this.context)
        (component StepperStep context=this.context)
        (component StepperPanel context=this.context)
        as |List Step Panel|
      }}
        {{! @glint-ignore: WithBoundArgs vs. a generic component }}
        {{yield
          (hash
            List=List
            Step=Step
            Panel=Panel
            next=this.next
            prev=this.prev
            goTo=this.goTo
            hasNext=this.hasNext
            hasPrev=this.hasPrev
          )
        }}
      {{/let}}
    </div>
  </template>
}

export {
  Stepper,
  type StepperSignature,
  type StepperApi,
  type StepperArgs,
  type StepperContext,
  type StepRecord,
  type StepState,
  type StepperSummary
};
export default Stepper;
