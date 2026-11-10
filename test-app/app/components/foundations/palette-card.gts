import type { TOC } from '@ember/component/template-only';
import { array, hash } from '@ember/helper';
import { htmlSafe, type SafeString } from '@ember/template';
import WorkbenchCard from 'test-app/components/workbench/card';
import WorkbenchSection from 'test-app/components/workbench/section';
import WorkbenchPanes from 'test-app/components/workbench/panes';

export interface PaletteStep {
  step: string;
  value: string;
}

export interface PaletteCardSignature {
  Args: {
    /** Ramp name, e.g. `gray`. Becomes the card id `palette-{name}`. */
    name: string;
    steps: PaletteStep[];
    description?: string;
  };
}

/** Values come from the theme's palette objects. */
function fill(value: string): SafeString {
  return htmlSafe(`background-color: ${value}`);
}

const DESCRIPTION =
  'Theme-independent ramp. It is not emitted as CSS variables and is read from the theme source, so these swatches are drawn from the JS values.';

const PaletteCard: TOC<PaletteCardSignature> = <template>
  <WorkbenchCard
    @id="palette-{{@name}}"
    @title={{@name}}
    @description={{if @description @description DESCRIPTION}}
    @sections={{array (hash id="steps" label="Steps")}}
  >
    <WorkbenchSection @id="palette-{{@name}}-steps" @title="Steps">
      <WorkbenchPanes as |scheme|>
        <div class="grid grid-cols-2 gap-2" data-scheme={{scheme}}>
          {{#each @steps as |s|}}
            <div
              data-palette-step={{s.step}}
              class="border-neutral-soft flex min-w-0 flex-col overflow-hidden rounded-md border text-xs"
            >
              {{! template-lint-disable no-inline-styles }}
              <div class="h-10" style={{fill s.value}}></div>
              <div class="flex items-center justify-between gap-2 px-2 py-1.5">
                <span class="font-medium">{{s.step}}</span>
                <span
                  data-step-value
                  class="text-neutral-firm font-mono"
                >{{s.value}}</span>
              </div>
            </div>
          {{/each}}
        </div>
      </WorkbenchPanes>
    </WorkbenchSection>
  </WorkbenchCard>
</template>;

export default PaletteCard;
