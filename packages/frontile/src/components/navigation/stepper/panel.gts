import Component from '@glimmer/component';
import type { StepperContext } from './stepper';

interface StepperPanelArgs<T> {
  /** The value this panel is paired with; must match a `Step`'s `@value`. */
  value: T;

  /**
   * Keeps the panel's content in the DOM, hidden, while its step is not the
   * selected one. Use it to preserve a form's local state across steps.
   * Without it only the selected step's panel renders.
   *
   * A kept-mounted panel keeps running its own effects while hidden, and
   * anything in it with an autofocus fires on mount whether or not the step
   * is selected.
   *
   * @defaultValue false
   */
  keepMounted?: boolean;

  /** Class names appended to this panel's theme classes. */
  class?: string;

  /**
   * Supplied by Stepper. Not part of the public API.
   *
   * @internal
   */
  context: StepperContext<T>;
}

interface StepperPanelSignature<T> {
  Args: StepperPanelArgs<T>;
  Blocks: { default: [] };
  Element: HTMLDivElement;
}

class StepperPanel<T> extends Component<StepperPanelSignature<T>> {
  get isSelected(): boolean {
    return this.args.context.isSelected(this.args.value);
  }

  get shouldRender(): boolean {
    return this.isSelected || (this.args.keepMounted ?? false);
  }

  get id(): string {
    return this.args.context.panelIdFor(this.args.value);
  }

  get stepId(): string | undefined {
    return this.args.context.stepIdFor(this.args.value);
  }

  <template>
    {{#if this.shouldRender}}
      <div
        role="region"
        data-part="panel"
        id={{this.id}}
        aria-labelledby={{this.stepId}}
        hidden={{if this.isSelected false true}}
        class="{{@context.panelClass}} {{@class}}"
        ...attributes
      >
        {{yield}}
      </div>
    {{/if}}
  </template>
}

export { StepperPanel, type StepperPanelSignature, type StepperPanelArgs };
export default StepperPanel;
