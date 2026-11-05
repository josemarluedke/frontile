import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import { guidFor } from '@ember/object/internals';
import { modifier } from 'ember-modifier';
import Spinner from '../../utilities/spinner';
import type { StepperContext, StepRecord, StepState } from './stepper';
import type { ComponentLike } from '@glint/template';

interface StepperStepArgs<T> {
  /**
   * The value this step represents. Steps are matched by value, never by
   * position, so they can be conditional, looped or wrapped in components.
   */
  value: T;

  /**
   * Prevents the user from selecting this step: clicks are ignored and arrow
   * keys skip over it.
   *
   * @defaultValue false
   */
  isDisabled?: boolean;

  /** The step's title. */
  title?: string;

  /** Supporting text shown beneath or beside the title. */
  description?: string;

  /**
   * An icon component shown in the indicator while the step is active or
   * upcoming. Complete, invalid and loading steps show their own marks.
   */
  icon?: ComponentLike<{ Element: SVGElement }>;

  /**
   * Shows a spinner in place of the indicator content and sets `aria-busy`.
   *
   * @defaultValue false
   */
  isLoading?: boolean;

  /**
   * Marks the step as having a problem: a danger-colored indicator with a
   * screen-reader-only "Invalid" announcement. Always danger, whatever the
   * Stepper's `@color`.
   *
   * @defaultValue false
   */
  isInvalid?: boolean;

  /**
   * The text announced to screen readers for an invalid step. Use it to
   * localize the announcement.
   *
   * @defaultValue 'Invalid'
   */
  invalidLabel?: string;

  /**
   * Overrides whether the step counts as complete. Omit it and a step is
   * complete when it comes before the selected step. Pass it when completion
   * is business logic rather than position.
   */
  isComplete?: boolean;

  /** Class names appended to this step's theme classes. */
  class?: string;

  /**
   * Supplied by Stepper. Not part of the public API.
   *
   * @internal
   */
  context: StepperContext<T>;
}

/** What the `indicator` and `label` blocks receive. */
interface StepperStepSlotState {
  state: StepState;
  isInvalid: boolean;
  isLoading: boolean;
}

interface StepperStepSignature<T> {
  Args: StepperStepArgs<T>;
  Blocks: {
    /** Replaces the content of the indicator circle. */
    indicator: [StepperStepSlotState];
    /** Replaces the default title and description. */
    label: [StepperStepSlotState];
  };
  Element: HTMLButtonElement;
}

// Long enough for the check's draw (60ms delay + 320ms) to finish.
const COMPLETION_ANIMATION_MS = 450;

class StepperStep<T> extends Component<StepperStepSignature<T>> {
  id = guidFor(this);

  get isSelected(): boolean {
    return this.args.context.isSelected(this.args.value);
  }

  get state(): StepState {
    const derived = this.args.context.stateOf(this.args.value);
    // The active step is always active; `@isComplete` only decides between
    // complete and upcoming for the rest.
    if (derived === 'active' || this.args.isComplete === undefined) {
      return derived;
    }
    return this.args.isComplete ? 'complete' : 'upcoming';
  }

  /** The state, once the step has registered; before that, `undefined`. */
  get settledState(): StepState | undefined {
    return this.number > 0 ? this.state : undefined;
  }

  /** What a screen reader announces for an invalid step. */
  get invalidText(): string {
    return this.args.invalidLabel ?? 'Invalid';
  }

  get isLoading(): boolean {
    return this.args.isLoading ?? false;
  }

  get isInvalid(): boolean {
    return this.args.isInvalid ?? false;
  }

  get isCompleteMark(): boolean {
    return this.state === 'complete';
  }

  get hasText(): boolean {
    return Boolean(this.args.title || this.args.description);
  }

  get slotState(): StepperStepSlotState {
    return {
      state: this.state,
      isInvalid: this.isInvalid,
      isLoading: this.isLoading
    };
  }

  /** One-based position, or 0 before the step has registered. */
  get number(): number {
    return this.args.context.steps.findIndex((step) => step.id === this.id) + 1;
  }

  get isDisabled(): boolean {
    return this.args.isDisabled ?? false;
  }

  registerStep = modifier((element: HTMLElement) => {
    // eslint-disable-next-line @typescript-eslint/no-this-alias
    const step = this;
    const record: StepRecord<T> = {
      id: this.id,
      element,
      get value() {
        return step.args.value;
      },
      get title() {
        return step.args.title;
      },
      get isDisabled() {
        return step.isDisabled;
      }
    };

    this.args.context.register(record);

    return (): void => {
      this.args.context.unregister(record);
    };
  });

  // The state this step was in the last time the modifier ran. Not tracked:
  // it is bookkeeping for the modifier, never read by a template.
  #previousState: StepState | undefined;

  /**
   * Flags the `<li>` with `data-just-completed` for the length of the check's
   * animation, but only when the step *becomes* complete -- not when it first
   * renders complete, which would replay the animation on every step of a
   * Stepper that opens partway through. The attribute is written straight to
   * the element: the animation is a one-shot visual, and routing it through
   * tracked state would re-render the step for nothing.
   */
  trackCompletion = modifier(
    (element: HTMLElement, [state]: [StepState | undefined]) => {
      // `undefined`: the step has not registered yet, so its state is still the
      // provisional one every step starts with. It is not a real transition.
      if (state === undefined) {
        return;
      }

      const previous = this.#previousState;
      this.#previousState = state;

      if (
        previous === undefined ||
        previous === 'complete' ||
        state !== 'complete'
      ) {
        return;
      }

      element.dataset['justCompleted'] = 'true';
      const timer = setTimeout(() => {
        delete element.dataset['justCompleted'];
      }, COMPLETION_ANIMATION_MS);

      return (): void => {
        clearTimeout(timer);
        delete element.dataset['justCompleted'];
      };
    }
  );

  handleClick = (): void => {
    if (this.isDisabled) {
      return;
    }
    this.args.context.pick(this.args.value);
  };

  <template>
    <li
      data-part="item"
      data-state={{this.state}}
      data-invalid="{{this.isInvalid}}"
      data-loading="{{this.isLoading}}"
      data-disabled="{{this.isDisabled}}"
      class={{@context.itemClass}}
      {{this.trackCompletion this.settledState}}
    >
      <button
        type="button"
        data-part="step"
        id={{this.id}}
        aria-current={{if this.isSelected "step"}}
        aria-disabled="{{this.isDisabled}}"
        aria-busy={{if this.isLoading "true"}}
        data-selected="{{this.isSelected}}"
        class="{{@context.stepClass}} {{@class}}"
        {{this.registerStep}}
        {{@context.roving.setupItem}}
        {{on "click" this.handleClick}}
        ...attributes
      >
        <span
          data-part="indicator"
          aria-hidden="true"
          class={{@context.indicatorClass}}
        >
          {{#if (has-block "indicator")}}
            {{yield this.slotState to="indicator"}}
          {{else if this.isLoading}}
            <Spinner @size="sm" class={{@context.spinnerClass}} />
          {{else if this.isInvalid}}
            <svg
              viewBox="0 0 16 16"
              class={{@context.markClass}}
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
            ><path d="M8 4v5M8 12h.01" /></svg>
          {{else if this.isCompleteMark}}
            <svg
              viewBox="0 0 16 16"
              class={{@context.checkClass}}
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
            ><path d="M3.5 8.5l3 3 6-6.5" pathLength="1" /></svg>
          {{else if @icon}}
            <@icon />
          {{else if this.number}}
            {{this.number}}
          {{/if}}
        </span>
        {{#if (has-block "label")}}
          <span data-part="label" class={{@context.labelClass}}>
            {{yield this.slotState to="label"}}
          </span>
        {{else if this.hasText}}
          <span data-part="label" class={{@context.labelClass}}>
            {{#if @title}}
              <span data-part="title" class={{@context.titleClass}}>
                {{@title}}
              </span>
            {{/if}}
            {{#if @description}}
              <span data-part="description" class={{@context.descriptionClass}}>
                {{@description}}
              </span>
            {{/if}}
          </span>
        {{/if}}
        {{#if this.isInvalid}}
          <span class={{@context.invalidTextClass}}>{{this.invalidText}}</span>
        {{/if}}
      </button>
      <span
        data-part="connector"
        aria-hidden="true"
        class={{@context.connectorClass}}
      ></span>
    </li>
  </template>
}

export {
  StepperStep,
  type StepperStepSignature,
  type StepperStepArgs,
  type StepperStepSlotState
};
export default StepperStep;
