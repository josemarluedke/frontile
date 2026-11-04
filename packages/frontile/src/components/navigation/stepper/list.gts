import Component from '@glimmer/component';
import type { StepperContext } from './stepper';

interface StepperListArgs<T> {
  /** Accessible name for the list of steps. */
  label?: string;

  /**
   * Supplied by Stepper. Not part of the public API.
   *
   * @internal
   */
  context: StepperContext<T>;
}

interface StepperListSignature<T> {
  Args: StepperListArgs<T>;
  Blocks: { default: [] };
  Element: HTMLOListElement;
}

// A class rather than a template-only component, so that
// `WithBoundArgs<typeof StepperList<T>, 'context'>` can be parameterized, as
// `TabsList` is.
class StepperList<T> extends Component<StepperListSignature<T>> {
  <template>
    <ol
      data-part="list"
      aria-label={{@label}}
      class={{@context.listClass}}
      ...attributes
    >
      {{yield}}
    </ol>
  </template>
}

export { StepperList, type StepperListSignature, type StepperListArgs };
export default StepperList;
