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
    {{#if @context.collapsed}}
      {{! The current step, as a button. The native popover on the list does
      the toggling, Escape and click-away; this only has to point at it. }}
      <button
        type="button"
        data-part="trigger"
        class={{@context.triggerClass}}
        popovertarget={{@context.listId}}
        popovertargetaction="toggle"
        aria-controls={{@context.listId}}
        aria-expanded="{{@context.isMenuOpen}}"
        {{@context.registerTrigger}}
      >
        <span class={{@context.triggerLabelClass}}>
          <span class={{@context.summaryClass}}>{{if
              @context.summary
              @context.summary.label
              @label
            }}</span>
          {{#if @context.summary.title}}
            <span class={{@context.summaryTitleClass}}>
              {{@context.summary.title}}
            </span>
          {{/if}}
        </span>
        <svg
          viewBox="0 0 16 16"
          class={{@context.chevronClass}}
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
          aria-hidden="true"
        ><path d="M4 6l4 4 4-4" /></svg>
      </button>
    {{/if}}
    <ol
      id={{@context.listId}}
      data-part="list"
      aria-label={{@label}}
      class={{@context.listClass}}
      {{@context.menuList @context.collapsed}}
      ...attributes
    >
      {{yield}}
    </ol>
    {{#if @context.showSummaryLine}}
      {{! Decorative: the active step is already announced through
      aria-current, so this must not be read a second time. }}
      <p data-part="summary" aria-hidden="true" class={{@context.summaryClass}}>
        <span
          class={{@context.summaryTextClass}}
        >{{@context.summary.label}}</span>
        {{#if @context.summary.title}}
          <span class={{@context.summaryTitleClass}}>
            {{@context.summary.title}}
          </span>
        {{/if}}
      </p>
    {{/if}}
  </template>
}

export { StepperList, type StepperListSignature, type StepperListArgs };
export default StepperList;
