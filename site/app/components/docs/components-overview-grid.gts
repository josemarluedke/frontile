import type { TOC } from '@ember/component/template-only';
import { DocfyLink } from '@docfy/ember';
import { inventory, componentCount } from '../component-inventory';

export interface Signature {
  Element: HTMLDivElement;
}

/**
 * The full component catalog for /docs/components/overview, grouped by
 * category. Reads from the same component-inventory.ts the homepage's "Full
 * inventory" section uses, so the two lists can never drift apart.
 */
const ComponentsOverviewGrid: TOC<Signature> = <template>
  <div class="not-prose" ...attributes>
    <p class="font-caption text-caption-sm text-neutral-firm mb-10">
      {{componentCount}}
      components across
      {{inventory.length}}
      categories — every name below links to its docs.
    </p>

    {{#each inventory as |category|}}
      <div class="mb-12 last:mb-0">
        <h2 class="font-header text-header-lg text-neutral-bolder mb-1">
          {{category.name}}
        </h2>
        <p class="font-body text-body-sm text-neutral-firm mb-5">
          {{category.summary}}
        </p>

        <div class="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
          {{#each category.items as |item|}}
            <DocfyLink
              @to={{item.path}}
              class="block rounded-lg border border-neutral-soft bg-surface-overlay-soft px-4 py-3 transition-[border-color,translate] duration-180 ease-settle hover:border-primary-mild hover:-translate-y-px focus-visible:outline-2 focus-visible:outline-primary focus-visible:outline-offset-1 motion-reduce:transition-none motion-reduce:hover:translate-y-0"
            >
              <span
                class="block font-header text-header-sm text-neutral-strong"
              >{{item.name}}</span>
              <span
                class="mt-1 block font-body text-body-xs text-neutral-firm"
              >{{item.description}}</span>
            </DocfyLink>
          {{/each}}
        </div>
      </div>
    {{/each}}
  </div>
</template>;

export default ComponentsOverviewGrid;
