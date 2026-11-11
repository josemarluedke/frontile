import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { schedule } from '@ember/runloop';
import { isDestroying } from '@ember/destroyable';
import { modifier } from 'ember-modifier';
import { measureType } from 'test-app/utils/workbench/css';

export interface WorkbenchSpecimenSignature {
  Args: {
    label: string;
    /** Print the first child element's computed metrics under the block. */
    measure?: boolean;
  };
  Blocks: { default: [] };
  Element: HTMLDivElement;
}

export type WorkbenchMeasureKey =
  | 'fontSize'
  | 'lineHeight'
  | 'fontWeight'
  | 'letterSpacing'
  | 'padding'
  | 'gap'
  | 'borderRadius'
  | 'height';

interface Metric {
  key: WorkbenchMeasureKey;
  name: string;
  value: string;
}

/** Pill radii (Tailwind's `rounded-full` computes to ~1.7e7px) read as `full`. */
const FULL_RADIUS_PX = 9999;

function radius(value: string): string {
  return parseFloat(value) >= FULL_RADIUS_PX ? 'full' : value;
}

function measure(el: Element): Metric[] {
  const type = measureType(el);
  const style = getComputedStyle(el);
  return [
    { key: 'fontSize', name: 'font-size', value: type.fontSize },
    { key: 'lineHeight', name: 'line-height', value: type.lineHeight },
    { key: 'fontWeight', name: 'font-weight', value: type.fontWeight },
    { key: 'letterSpacing', name: 'letter-spacing', value: type.letterSpacing },
    { key: 'padding', name: 'padding', value: style.padding },
    { key: 'gap', name: 'gap', value: style.gap },
    { key: 'borderRadius', name: 'radius', value: radius(style.borderRadius) },
    { key: 'height', name: 'height', value: style.height }
  ];
}

/** A labelled example. With `@measure`, prints what the browser computed. */
export default class WorkbenchSpecimen extends Component<WorkbenchSpecimenSignature> {
  @tracked metrics: Metric[] = [];

  measureFirstChild = modifier((block: HTMLElement, [enabled]: [boolean]) => {
    if (!enabled) {
      return;
    }
    // Read after render; setting tracked state while rendering would
    // invalidate a value this render already consumed.
    schedule('afterRender', () => {
      if (isDestroying(this)) {
        return;
      }
      const target = block.firstElementChild;
      this.metrics = target ? measure(target) : [];
    });
  });

  <template>
    <div
      data-workbench-specimen
      class="flex min-w-0 flex-col gap-2"
      ...attributes
    >
      <p
        data-specimen-label
        class="text-neutral-firm text-[11px] font-semibold tracking-wider uppercase"
      >{{@label}}</p>
      <div {{this.measureFirstChild (if @measure true false)}}>
        {{yield}}
      </div>
      {{#if @measure}}
        <dl
          class="text-neutral-firm grid grid-cols-[auto_1fr] gap-x-3 font-mono text-[11px]"
        >
          {{#each this.metrics as |metric|}}
            <dt>{{metric.name}}</dt>
            <dd data-measure={{metric.key}}>{{metric.value}}</dd>
          {{/each}}
        </dl>
      {{/if}}
    </div>
  </template>
}
