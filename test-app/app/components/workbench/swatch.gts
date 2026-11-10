import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { htmlSafe, type SafeString } from '@ember/template';
import { schedule } from '@ember/runloop';
import { isDestroying } from '@ember/destroyable';
import { modifier } from 'ember-modifier';
import {
  compositeOver,
  contrastRatio,
  parseColor,
  toHex
} from 'test-app/utils/workbench/color';
import { backdropColor } from 'test-app/utils/workbench/css';

export interface WorkbenchSwatchSignature {
  Args: {
    /** A color token without the `--color-` prefix, e.g. `primary-mild`. */
    token: string;
    /**
     * The token for the "Aa" sample.
     *
     * @defaultValue `on-${token}`
     */
    onToken?: string;
  };
  Element: HTMLDivElement;
}

const LEVELS = [
  'subtle',
  'muted',
  'soft',
  'mild',
  'firm',
  'strong',
  'bolder'
] as const;

/** Below this, `data-low-contrast` is set (WCAG AA for body text). */
export const LOW_CONTRAST_THRESHOLD = 4.5;

/**
 * A token's fill with an "Aa" sample in its contrast color. Reports the fill
 * composited over whatever is behind it, and the WCAG contrast of the sample
 * against that composite. Re-reads when the root's class changes.
 */
export default class WorkbenchSwatch extends Component<WorkbenchSwatchSignature> {
  @tracked hex = '';
  @tracked ratio: number | null = null;

  get onToken(): string {
    return this.args.onToken ?? `on-${this.args.token}`;
  }

  get fillStyle(): SafeString {
    return htmlSafe(`background-color: var(--color-${this.args.token});`);
  }

  get sampleStyle(): SafeString {
    return htmlSafe(`color: var(--color-${this.onToken});`);
  }

  /** `primary-mild` → `mild`; `primary` → `DEFAULT`; `surface-card` → `card`. */
  get level(): string {
    const parts = this.args.token.split('-');
    const last = parts[parts.length - 1] ?? '';
    if ((LEVELS as readonly string[]).includes(last)) {
      return last;
    }
    return parts.length === 1 ? 'DEFAULT' : last;
  }

  get ratioLabel(): string {
    return this.ratio === null ? '' : `${this.ratio.toFixed(1)}:1`;
  }

  get isLowContrast(): boolean {
    return this.ratio !== null && this.ratio < LOW_CONTRAST_THRESHOLD;
  }

  read(root: HTMLElement): void {
    if (isDestroying(this)) {
      return;
    }
    const fill = root.querySelector('[data-swatch-fill]');
    const sample = root.querySelector('[data-swatch-sample]');
    if (!fill || !sample) {
      return;
    }
    const behind = fill.parentElement
      ? backdropColor(fill.parentElement)
      : { r: 255, g: 255, b: 255, a: 1 };
    const bg = compositeOver(
      parseColor(getComputedStyle(fill).backgroundColor),
      behind
    );
    const fg = compositeOver(parseColor(getComputedStyle(sample).color), bg);
    this.hex = toHex(bg);
    this.ratio = contrastRatio(fg, bg);
  }

  measure = modifier(
    (root: HTMLElement, [token, onToken]: [string, string]) => {
      // Positional args only re-run this when the tokens change.
      void token;
      void onToken;
      const run = (): void => {
        // Read after render; setting tracked state while rendering would
        // invalidate a value this render already consumed.
        schedule('afterRender', this, this.read, root);
      };
      run();
      const observer = new MutationObserver(run);
      observer.observe(document.documentElement, {
        attributes: true,
        attributeFilter: ['class']
      });
      return () => observer.disconnect();
    }
  );

  <template>
    <div
      data-workbench-swatch
      data-token={{@token}}
      data-swatch-hex={{this.hex}}
      data-low-contrast={{if this.isLowContrast "true"}}
      title="--color-{{@token}} / --color-{{this.onToken}}"
      class="border-neutral-soft flex min-w-0 flex-col overflow-hidden rounded-md border text-xs"
      {{this.measure @token this.onToken}}
      ...attributes
    >
      <div
        data-swatch-fill
        style={{this.fillStyle}}
        class="flex h-14 items-center justify-center"
      >
        <span
          data-swatch-sample
          style={{this.sampleStyle}}
          class="text-lg font-semibold"
        >Aa</span>
      </div>
      <div class="flex items-center justify-between gap-2 px-2 py-1.5">
        <span data-swatch-level class="font-medium">{{this.level}}</span>
        <span
          data-swatch-hex
          class="text-neutral-firm font-mono"
        >{{this.hex}}</span>
        <span
          data-swatch-ratio
          class="font-mono
            {{if this.isLowContrast 'text-danger' 'text-neutral-firm'}}"
        >{{this.ratioLabel}}</span>
      </div>
    </div>
  </template>
}
