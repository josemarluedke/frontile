import Component from '@glimmer/component';
import { modifier } from 'ember-modifier';

export interface WorkbenchSectionSignature {
  Args: {
    /** The full anchor, e.g. `button-variants` (no `#`). */
    id: string;
    title: string;
    subtitle?: string;
    /**
     * Initial open state.
     *
     * @defaultValue true
     */
    open?: boolean;
  };
  Blocks: { default: [] };
  Element: HTMLDetailsElement;
}

/**
 * A collapsible block inside a workbench card. It opens and scrolls into view
 * when `location.hash` is `#{@id}`, on render and on every `hashchange`.
 */
export default class WorkbenchSection extends Component<WorkbenchSectionSignature> {
  get isOpen(): boolean {
    return this.args.open ?? true;
  }

  revealOnHash = modifier((details: HTMLDetailsElement, [id]: [string]) => {
    const reveal = (): void => {
      if (window.location.hash === `#${id}`) {
        details.open = true;
        details.scrollIntoView({ block: 'start' });
      }
    };
    reveal();
    window.addEventListener('hashchange', reveal);
    return () => window.removeEventListener('hashchange', reveal);
  });

  <template>
    <details
      id={{@id}}
      open={{this.isOpen}}
      data-workbench-section
      class="scroll-mt-4"
      {{this.revealOnHash @id}}
      ...attributes
    >
      <summary
        class="text-neutral-strong flex cursor-pointer items-baseline gap-3 py-1"
      >
        <h3 class="text-base font-semibold">{{@title}}</h3>
        {{#if @subtitle}}
          <p class="text-neutral-firm text-sm">{{@subtitle}}</p>
        {{/if}}
      </summary>
      <div class="flex flex-col gap-4 pt-3">
        {{yield}}
      </div>
    </details>
  </template>
}
