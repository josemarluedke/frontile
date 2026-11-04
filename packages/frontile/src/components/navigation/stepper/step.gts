import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import { guidFor } from '@ember/object/internals';
import { modifier } from 'ember-modifier';
import type { StepperContext, StepRecord } from './stepper';

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

  /** Class names appended to this step's theme classes. */
  class?: string;

  /**
   * Supplied by Stepper. Not part of the public API.
   *
   * @internal
   */
  context: StepperContext<T>;
}

interface StepperStepSignature<T> {
  Args: StepperStepArgs<T>;
  Blocks: { default: [] };
  Element: HTMLButtonElement;
}

class StepperStep<T> extends Component<StepperStepSignature<T>> {
  id = guidFor(this);

  get isSelected(): boolean {
    return this.args.context.isSelected(this.args.value);
  }

  get state() {
    return this.args.context.stateOf(this.args.value);
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
        return undefined;
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

  handleClick = (): void => {
    if (this.isDisabled) {
      return;
    }
    this.args.context.select(this.args.value);
  };

  <template>
    <li
      data-part="item"
      data-state={{this.state}}
      data-disabled="{{this.isDisabled}}"
      class={{@context.itemClass}}
    >
      <button
        type="button"
        data-part="step"
        id={{this.id}}
        aria-current={{if this.isSelected "step"}}
        aria-disabled="{{this.isDisabled}}"
        class="{{@context.stepClass}} {{@class}}"
        {{this.registerStep}}
        {{on "click" this.handleClick}}
        ...attributes
      >
        {{yield}}
      </button>
      <span
        data-part="connector"
        aria-hidden="true"
        class={{@context.connectorClass}}
      ></span>
    </li>
  </template>
}

export { StepperStep, type StepperStepSignature, type StepperStepArgs };
export default StepperStep;
