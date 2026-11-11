import Component from '@glimmer/component';
import { modifier, type FunctionBasedModifier } from 'ember-modifier';
import { FROZEN_STATES_SUPPORTED } from 'test-app/utils/workbench/frozen-states';

/** Interaction states a matrix can show, in column order. */
export const WORKBENCH_STATES = [
  'rest',
  'hover',
  'pressed',
  'focus',
  'disabled'
] as const;

/**
 * Columns for form controls. Only `focus` and `invalid-focus` are forced; the
 * rest are real values or arguments the block binds from the cell's flags.
 */
export const FORM_STATES = [
  'default',
  'filled',
  'focus',
  'disabled',
  'readonly',
  'invalid',
  'invalid-focus'
] as const;

export type WorkbenchState =
  (typeof WORKBENCH_STATES)[number] | (typeof FORM_STATES)[number];

/** Header text, where it differs from the state id. */
const STATE_LABELS: Partial<Record<WorkbenchState, string>> = {
  'invalid-focus': 'invalid·focus'
};

/** The `tw.css` attribute that freezes each state, if any. */
export const FORCE_ATTRIBUTES: Record<WorkbenchState, string | null> = {
  rest: null,
  hover: 'data-force-hover',
  pressed: 'data-force-active',
  focus: 'data-focus-visible-added',
  disabled: null,
  default: null,
  filled: null,
  readonly: null,
  invalid: null,
  'invalid-focus': 'data-focus-visible-added'
};

const ALL_STATES = Object.keys(FORCE_ATTRIBUTES) as WorkbenchState[];

interface ForceSignature {
  Element: Element;
  Args: { Named: Record<string, never>; Positional: [] };
}

type ForceModifier = FunctionBasedModifier<ForceSignature>;

function forceModifier(attribute: string | null): ForceModifier {
  return modifier<ForceSignature>((element) => {
    if (!attribute) {
      return;
    }
    element.setAttribute(attribute, '');
    return () => element.removeAttribute(attribute);
  });
}

// One definition per state, built once: the cells yield these as-is.
const FORCE_MODIFIERS = Object.fromEntries(
  ALL_STATES.map((state) => [state, forceModifier(FORCE_ATTRIBUTES[state])])
) as Record<WorkbenchState, ForceModifier>;

/** What each cell yields alongside its row and state. */
export interface WorkbenchStateCell {
  state: WorkbenchState;
  /** The column header text: the state id, or e.g. `invalid·focus`. */
  label: string;
  /** The force attribute this cell sets, or `null` when nothing is forced. */
  attribute: string | null;
  /** True in the `disabled` column; bind it to the control's disabled API. */
  isDisabled: boolean;
  /** True in the `filled` column; give the control a value or check it. */
  isFilled: boolean;
  /** True in the `readonly` column; bind it to `readonly`. */
  isReadonly: boolean;
  /** True in `invalid` and `invalid-focus`; bind it to `@isInvalid`/`@errors`. */
  isInvalid: boolean;
  /**
   * Put this on the control itself (`<Button {{cell.force}}>`): it sets
   * `attribute` on that element. Modifiers on a component invocation land on
   * its `...attributes` element.
   */
  force: ForceModifier;
}

export interface WorkbenchStateMatrixSignature<T extends string> {
  Args: {
    /** One row per value; the row header shows the value itself. */
    rows: readonly T[];
    /** Columns, in order. Defaults to every state in `WORKBENCH_STATES`. */
    states?: readonly WorkbenchState[];
    /**
     * Whether forced states render. Defaults to `FROZEN_STATES_SUPPORTED`;
     * when false only the columns that force nothing remain.
     */
    frozen?: boolean;
    /** Accessible name for the row-header column. @defaultValue 'Variant' */
    rowLabel?: string;
  };
  Blocks: {
    default: [row: T, state: WorkbenchState, cell: WorkbenchStateCell];
  };
  Element: HTMLDivElement;
}

const CELLS = Object.fromEntries(
  ALL_STATES.map((state) => [
    state,
    {
      state,
      label: STATE_LABELS[state] ?? state,
      attribute: FORCE_ATTRIBUTES[state],
      isDisabled: state === 'disabled',
      isFilled: state === 'filled',
      isReadonly: state === 'readonly',
      isInvalid: state === 'invalid' || state === 'invalid-focus',
      force: FORCE_MODIFIERS[state]
    }
  ])
) as Record<WorkbenchState, WorkbenchStateCell>;

/**
 * Rows x interaction states, each cell holding one control frozen in that
 * state. The block renders the control and applies `cell.force` to it.
 */
export default class WorkbenchStateMatrix<T extends string> extends Component<
  WorkbenchStateMatrixSignature<T>
> {
  get cells(): WorkbenchStateCell[] {
    const states = this.args.states ?? WORKBENCH_STATES;
    const frozen = this.args.frozen ?? FROZEN_STATES_SUPPORTED;
    return states
      .filter((state) => frozen || FORCE_ATTRIBUTES[state] === null)
      .map((state) => CELLS[state]);
  }

  <template>
    {{! `relative` makes the scroller the containing block, so it clips
        non-portaled absolute descendants (visually hidden inputs) instead
        of letting them widen the page. }}
    <div
      data-workbench-state-matrix
      class="relative min-w-0 overflow-x-auto"
      ...attributes
    >
      <table class="border-separate border-spacing-x-3 border-spacing-y-2">
        <thead>
          <tr>
            <th scope="col" class="sr-only">{{if
                @rowLabel
                @rowLabel
                "Variant"
              }}</th>
            {{#each this.cells as |cell|}}
              <th
                scope="col"
                data-state={{cell.state}}
                class="text-neutral-firm text-left text-[11px] font-semibold tracking-wider"
              >{{cell.label}}</th>
            {{/each}}
          </tr>
        </thead>
        <tbody>
          {{#each @rows as |row|}}
            <tr data-row={{row}}>
              <th
                scope="row"
                class="text-neutral-firm pr-2 text-left font-mono text-[11px] font-normal"
              >{{row}}</th>
              {{#each this.cells as |cell|}}
                <td data-state={{cell.state}} class="align-middle">
                  {{yield row cell.state cell}}
                </td>
              {{/each}}
            </tr>
          {{/each}}
        </tbody>
      </table>
    </div>
  </template>
}
