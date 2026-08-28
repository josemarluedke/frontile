import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';
import { htmlSafe } from '@ember/template';
import type { SafeString } from '@ember/template';
import { guidFor } from '@ember/object/internals';

interface ProgressBarSignature {
  Args: {
    /**
     * The intent of the progress bar
     */
    intent?:
      | 'default'
      | 'primary'
      | 'secondary'
      | 'tertiary'
      | 'success'
      | 'warning'
      | 'danger';

    /**
     * The size of the progress bar
     */
    size?: 'xs' | 'sm' | 'md' | 'lg';

    /**
     * The radius the progress bar
     */
    radius?: 'none' | 'sm' | 'lg' | 'full';

    /**
     * The current progress value
     */
    progress?: number;

    /**
     *
     * The smallest value allowed for the input
     *
     * @defaultValue 0
     */
    minValue?: number;

    /**
     *
     * The largest value allowed for the input
     *
     *@defaultValue 100
     */
    maxValue?: number;

    /**
     * Whether presentation is indeterminate when progress isn't known.
     *
     * @defaultValue false
     */
    isIndeterminate?: boolean;

    /**
     * The content to display as the label.
     */
    label?: string;

    /**
     * The content to display as the value's label (e.g. 1 of 4).
     */
    valueLabel?: string;

    /**
     * Whether the value's label is displayed.
     * True by default if there's a label, false by default if not.
     */
    showValueLabel?: boolean;

    /**
     * The display format of the value, passed to `Intl.NumberFormat`.
     *
     * A `percent` style formats the position on the min/max scale as a
     * fraction; every other style formats the raw `progress` value. With no
     * format options, the value is displayed as a whole percentage.
     */
    formatOptions?: Intl.NumberFormatOptions;

    /**
     * The content to display as the description.
     */
    description?: string;

    /**
     * Custom class name, it will override the default ones using Tailwind Merge library.
     */
    class?: string;
  };
  Blocks: {
    default: [];
  };
  Element: HTMLDivElement;
}

class ProgressBar extends Component<ProgressBarSignature> {
  id = guidFor(this);

  get classNames() {
    const { progressBar } = useStyles();

    const { base, progress, label, description } = progressBar({
      intent: this.args.intent || 'default',
      size: this.args.size,
      radius: this.args.radius,
      isIndeterminate: this.args.isIndeterminate
    });

    return {
      base: base({ class: this.args.class }),
      progress: progress(),
      label: label(),
      description: description()
    };
  }

  get minValue(): number {
    return this.args.minValue ?? 0;
  }

  get maxValue(): number {
    return this.args.maxValue ?? 100;
  }

  /**
   * `@progress={{0}}` is a legitimate value, so this falls back to `minValue`
   * only when nothing was passed — a truthiness check would report the bar as
   * already at the bottom of the scale instead of at zero.
   */
  get progress(): number {
    return this.args.progress ?? this.minValue;
  }

  /**
   * The position on the scale as 0–100. Clamped, because the result drives an
   * inline `width` — an out-of-range or `NaN` percentage is dropped by the CSS
   * parser, which renders as a silently empty bar rather than as an error.
   * A non-positive range has no meaningful position, so it reports 0.
   */
  get percentage(): number {
    const range = this.maxValue - this.minValue;
    if (range <= 0) {
      return 0;
    }

    const percentage = ((this.progress - this.minValue) / range) * 100;

    return Math.min(100, Math.max(0, percentage));
  }

  get showValueLabel(): boolean {
    if (typeof this.args.showValueLabel !== 'undefined') {
      return this.args.showValueLabel;
    }

    return !!this.args.label;
  }

  get formattedValueLabel(): string {
    // check if the value label should not be shown
    if (!this.showValueLabel || this.args.isIndeterminate) {
      return '';
    }

    // if @labelValue is provided use it
    if (this.args.valueLabel) {
      return this.args.valueLabel;
    }

    // if format options are provided
    if (this.args.formatOptions) {
      const options: Intl.NumberFormatOptions = {
        ...(this.args.formatOptions || {})
      };

      // `Intl` scales a `percent` style by 100 itself, so it has to be handed
      // the fraction of the min–max range — passing the already-scaled
      // percentage announces `@progress={{50}}` as "5,000%". Every other style
      // (`decimal`, `currency`, `unit`) formats the raw value on its own scale.
      const value =
        options.style === 'percent' ? this.percentage / 100 : this.progress;

      // `navigator` is a browser global with no counterpart in Node, so a bare
      // `navigator?.language` is a hard `ReferenceError` rather than
      // `undefined` when a ProgressBar is server-rendered.
      const locale =
        typeof navigator !== 'undefined' ? navigator.language : undefined;

      return new Intl.NumberFormat(locale || 'en-US', options).format(value);
    }

    return this.percentage.toFixed(0) + '%';
  }

  /**
   * ARIA requires aria-valuenow to be absent when the value is unknown —
   * reporting a number would announce "0%" rather than "amount unknown".
   *
   * Otherwise it is clamped to the scale, because assistive technology
   * announces a percentage computed from valuenow/valuemin/valuemax. Reporting
   * a raw 150 on a 0–100 scale would say "150%" to a screen-reader user while
   * the bar sits pinned at 100% for everyone else — the people who cannot see
   * the bar would be the only ones given the wrong number.
   */
  get ariaValueNow(): number | undefined {
    if (this.args.isIndeterminate) {
      return undefined;
    }

    return Math.min(this.maxValue, Math.max(this.minValue, this.progress));
  }

  get progressWidth(): SafeString {
    let percentage = this.percentage;
    if (this.args.isIndeterminate) {
      percentage = 50;
    }
    return htmlSafe(`width: ${percentage}%`);
  }

  <template>
    <div ...attributes>
      {{#if @label}}
        <div class={{this.classNames.label}}>
          <label id={{this.id}}>
            {{@label}}
          </label>
          {{#if this.showValueLabel}}
            <div>
              {{this.formattedValueLabel}}
            </div>
          {{/if}}
        </div>
      {{/if}}
      {{#if @description}}
        <div class={{this.classNames.description}}>
          {{@description}}
        </div>
      {{/if}}
      <div class={{this.classNames.base}}>
        <div
          role="progressbar"
          aria-labelledby={{if @label this.id}}
          aria-valuenow={{this.ariaValueNow}}
          aria-valuemin={{this.minValue}}
          aria-valuemax={{this.maxValue}}
          class={{this.classNames.progress}}
          style={{this.progressWidth}}
        ></div>
      </div>
    </div>
  </template>
}

export { ProgressBar, type ProgressBarSignature };
export default ProgressBar;
