import type { TOC } from '@ember/component/template-only';

export type WorkbenchScheme = 'light' | 'dark' | 'inverse';

export interface WorkbenchPanesSignature {
  Args: {
    /** Adds a third pane: `.theme-inverse` inside a `.light` pane. */
    inverse?: boolean;
    /**
     * Stack the panes at every width. For content too wide for a third of
     * the page, such as a state matrix.
     */
    stacked?: boolean;
  };
  Blocks: { default: [scheme: WorkbenchScheme] };
  Element: HTMLDivElement;
}

/**
 * Renders its block once per color scheme. Each pane is its own themed
 * ancestor, so the panes hold their scheme whatever the page's root scheme.
 * Side by side at `lg`, stacked below it (or always, with `@stacked`).
 */
const WorkbenchPanes: TOC<WorkbenchPanesSignature> = <template>
  <div
    data-workbench-panes
    class="grid gap-4
      {{unless @stacked (if @inverse 'lg:grid-cols-3' 'lg:grid-cols-2')}}"
    ...attributes
  >
    <div
      data-workbench-pane="light"
      class="light bg-surface-app text-neutral-strong border-neutral-soft flex min-w-0 flex-col gap-3 rounded-lg border p-4"
    >
      <p
        data-pane-caption
        class="text-neutral-firm text-[11px] font-semibold tracking-wider"
      >LIGHT</p>
      {{yield "light"}}
    </div>
    <div
      data-workbench-pane="dark"
      class="dark bg-surface-app text-neutral-strong border-neutral-soft flex min-w-0 flex-col gap-3 rounded-lg border p-4"
    >
      <p
        data-pane-caption
        class="text-neutral-firm text-[11px] font-semibold tracking-wider"
      >DARK</p>
      {{yield "dark"}}
    </div>
    {{#if @inverse}}
      <div data-workbench-pane="inverse" class="light flex min-w-0 flex-col">
        <div
          class="theme-inverse bg-surface-app text-neutral-strong border-neutral-soft flex grow flex-col gap-3 rounded-lg border p-4"
        >
          <p
            data-pane-caption
            class="text-neutral-firm text-[11px] font-semibold tracking-wider"
          >INVERSE</p>
          {{yield "inverse"}}
        </div>
      </div>
    {{/if}}
  </div>
</template>;

export default WorkbenchPanes;
