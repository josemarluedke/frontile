import Component from '@glimmer/component';
import { cached, tracked } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { guidFor } from '@ember/object/internals';
import { isDestroyed, isDestroying } from '@ember/destroyable';
import { schedule } from '@ember/runloop';
import { modifier } from 'ember-modifier';
import { rovingFocus, type RovingFocus } from '../../../utils/roving-focus';
import { useStyles, type SlotsToClasses } from '@frontile/theme';
import { CollapseMenu } from './collapse-menu';
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
   * What a horizontal Stepper does when its container is too narrow for the
   * full row:
   *
   * - `'menu'` swaps the row for a button showing the current step. It opens
   *   the steps as a floating list.
   * - `'summary'` hides the titles and shows a "Step N of M" line instead.
   * - `false` leaves the layout alone at every width.
   *
   * Vertical Steppers never collapse.
   *
   * @defaultValue 'menu'
   */
  collapse?: 'menu' | 'summary' | false;

  /**
   * Formats the "Step N of M" text shown in the menu trigger or the summary
   * line. Use it to localize the text.
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
  listClass: string;
  itemClass: string;
  stepClass: string;
  indicatorClass: string;
  checkClass: string;
  connectorClass: string;
  labelClass: string;
  titleClass: string;
  descriptionClass: string;
  summaryClass: string;
  panelClass: string;
  /**
   * The current step's "Step N of M" text and title, present for a horizontal
   * Stepper that collapses and has a matched selection.
   */
  readonly summary: StepperSummary | undefined;
  /** Whether the standalone summary line (`@collapse='summary'`) shows. */
  readonly showSummaryLine: boolean;
  /** Whether the menu is active: `@collapse='menu'` and too narrow to fit. */
  readonly collapsed: boolean;
  readonly isMenuOpen: boolean;
  /** Id of the list, which the menu trigger points at. */
  readonly listId: string;
  triggerClass: string;
  triggerLabelClass: string;
  chevronClass: string;
  summaryTextClass: string;
  summaryTitleClass: string;
  markClass: string;
  spinnerClass: string;
  invalidTextClass: string;
  /** Installed on the menu trigger. */
  registerTrigger: CollapseMenu['registerTrigger'];
  /** Installed on the list; turns it into the floating panel when collapsed. */
  menuList: CollapseMenu['list'];
  /** A step chosen by the user: selects it and closes the menu. */
  pick: (value: T) => void;
  /** Registered steps in document order. */
  readonly steps: readonly StepRecord<T>[];
  isSelected: (value: T) => boolean;
  stateOf: (value: T) => StepState;
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
    // The collapsed menu lists the steps vertically, so the arrow keys follow.
    orientation: this.layout.orientation,
    activationMode: 'manual',
    onActivate: this.activateElement
  }));

  // Uncontrolled mode's own selection, seeded from `@defaultValue`. Written on
  // every `select` regardless of mode -- the getter ignores it when controlled
  // -- so both modes share one code path, as `Tabs` does.
  @tracked _value: T | undefined;
  @tracked _hasSelection = false;

  // Whether the root is narrower than the full row needs. Measured, not
  // derived: the answer lives in a container query, which JS can only read
  // back from the rendered page.
  @tracked _isNarrow = false;

  readonly listId = `${guidFor(this)}-list`;
  readonly menu = new CollapseMenu();

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
    this.context = this.#buildContext();
  }

  get collapseMode(): 'menu' | 'summary' | 'none' {
    return this.args.collapse === false
      ? 'none'
      : (this.args.collapse ?? 'menu');
  }

  /** Whether a menu is configured and applicable (horizontal only). */
  get usesMenu(): boolean {
    return this.collapseMode === 'menu' && this.orientation === 'horizontal';
  }

  /**
   * The layout the steps are drawn in. Collapsed into the menu, the list uses
   * the vertical layout inside the panel, whatever was configured; everything
   * that depends on the layout (styles and arrow keys)
   * reads it from here.
   */
  get layout(): {
    orientation: 'horizontal' | 'vertical';
    labelPosition: 'end' | 'bottom';
  } {
    return this.collapsed
      ? { orientation: 'vertical', labelPosition: 'end' }
      : {
          orientation: this.orientation,
          labelPosition: this.args.labelPosition ?? 'end'
        };
  }

  /** Whether the menu is active right now. */
  get collapsed(): boolean {
    return this.usesMenu && this._isNarrow;
  }

  /**
   * Styles for the root and the probe, which keep the *configured* layout:
   * the probe's threshold depends on `labelPosition`, and it must not change
   * when the list switches to its vertical, in-menu layout.
   */
  @cached
  get rootStyles() {
    const { stepper } = useStyles();

    return stepper({
      color: this.args.color,
      size: this.args.size,
      orientation: this.args.orientation,
      labelPosition: this.args.labelPosition,
      collapse: this.collapseMode
    });
  }

  get probeClass(): string {
    return this.rootStyles.probe();
  }

  // Everything below the root. Collapsed, the list lays out vertically, like
  // `@orientation='vertical'`, inside the floating panel.
  @cached
  get styles() {
    const { stepper } = useStyles();

    return stepper({
      color: this.args.color,
      size: this.args.size,
      orientation: this.layout.orientation,
      labelPosition: this.layout.labelPosition,
      collapse: this.collapseMode,
      collapsed: this.collapsed
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

  /** Backs the menu trigger and the narrow-width "Step N of M" line. */
  get summary(): StepperSummary | undefined {
    if (this.orientation !== 'horizontal' || this.collapseMode === 'none') {
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

  select = (value: T): void => {
    this._value = value;
    this._hasSelection = true;
    this.args.onChange?.(value);
  };

  // A step chosen by the user, as opposed to `next`/`prev`/`goTo`. Picking one
  // from the menu also closes it.
  pick = (value: T): void => {
    this.select(value);
    this.menu.close();
  };

  #setNarrow(narrow: boolean): void {
    if (narrow === this._isNarrow) {
      return;
    }
    // From a modifier or a ResizeObserver: the first runs inside the render
    // transaction that already read `collapsed`, so the write waits for
    // `afterRender`, like the step registry's version bump.
    schedule('afterRender', () => {
      if (isDestroying(this) || isDestroyed(this)) {
        return;
      }
      this._isNarrow = narrow;
    });
  }

  /**
   * Reads which side of the threshold the root is on from the probe element,
   * whose `display` the container query flips. Re-reads when the root
   * resizes.
   */
  observeWidth = modifier((root: HTMLElement, [enabled]: [boolean]) => {
    const probe = root.querySelector<HTMLElement>('[data-part="probe"]');
    if (!enabled || !probe) {
      this.#setNarrow(false);
      return;
    }

    const measure = (): void => {
      this.#setNarrow(getComputedStyle(probe).display === 'none');
    };
    measure();

    const observer = new ResizeObserver(measure);
    observer.observe(root);

    return (): void => {
      observer.disconnect();
    };
  });

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
    this.pick(record.value);
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

  // One object for the life of the component, with the class strings as
  // getters. A context rebuilt whenever the styles change (they do when the
  // menu collapses) is a new `@context` for every step, which re-runs each
  // `{{@context.…}}` modifier -- tearing down and reinstalling the roving
  // focus listeners on every step mid-update.
  readonly context: StepperContext<T>;

  #buildContext(): StepperContext<T> {
    // eslint-disable-next-line @typescript-eslint/no-this-alias
    const stepper = this;

    return {
      get listClass() {
        return stepper.styles.list({ class: stepper.args.classes?.list });
      },
      get itemClass() {
        return stepper.styles.item({ class: stepper.args.classes?.item });
      },
      get stepClass() {
        return stepper.styles.step({ class: stepper.args.classes?.step });
      },
      get indicatorClass() {
        return stepper.styles.indicator({
          class: stepper.args.classes?.indicator
        });
      },
      get checkClass() {
        return stepper.styles.check({ class: stepper.args.classes?.check });
      },
      get connectorClass() {
        return stepper.styles.connector({
          class: stepper.args.classes?.connector
        });
      },
      get labelClass() {
        return stepper.styles.label({ class: stepper.args.classes?.label });
      },
      get titleClass() {
        return stepper.styles.title({ class: stepper.args.classes?.title });
      },
      get descriptionClass() {
        return stepper.styles.description({
          class: stepper.args.classes?.description
        });
      },
      get summaryClass() {
        return stepper.styles.summary({ class: stepper.args.classes?.summary });
      },
      get triggerLabelClass() {
        return stepper.styles.triggerLabel({
          class: stepper.args.classes?.triggerLabel
        });
      },
      get chevronClass() {
        return stepper.styles.chevron({ class: stepper.args.classes?.chevron });
      },
      get summaryTextClass() {
        return stepper.styles.summaryText({
          class: stepper.args.classes?.summaryText
        });
      },
      get summaryTitleClass() {
        return stepper.styles.summaryTitle({
          class: stepper.args.classes?.summaryTitle
        });
      },
      get markClass() {
        return stepper.styles.mark({ class: stepper.args.classes?.mark });
      },
      get spinnerClass() {
        return stepper.styles.spinner({ class: stepper.args.classes?.spinner });
      },
      get invalidTextClass() {
        return stepper.styles.invalidText({
          class: stepper.args.classes?.invalidText
        });
      },
      get triggerClass() {
        return stepper.styles.trigger({ class: stepper.args.classes?.trigger });
      },
      get panelClass() {
        return stepper.styles.panel({ class: stepper.args.classes?.panel });
      },
      get summary() {
        return stepper.summary;
      },
      get showSummaryLine() {
        return stepper.collapseMode === 'summary' && !!stepper.summary;
      },
      get collapsed() {
        return stepper.collapsed;
      },
      get isMenuOpen() {
        return stepper.menu.isOpen;
      },
      get steps() {
        return stepper.steps;
      },
      listId: this.listId,
      registerTrigger: this.menu.registerTrigger,
      menuList: this.menu.list,
      pick: this.pick,
      isSelected: this.isSelected,
      stateOf: this.stateOf,
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
      data-collapsed="{{this.collapsed}}"
      class={{this.rootStyles.base class=@classes.base}}
      {{this.observeWidth this.usesMenu}}
      ...attributes
    >
      {{#if this.usesMenu}}
        <span
          data-part="probe"
          aria-hidden="true"
          class={{this.probeClass}}
        ></span>
      {{/if}}
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
            goTo=this.select
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
