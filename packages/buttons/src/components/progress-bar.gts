import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';
import { htmlSafe } from '@ember/template';
import type { SafeString } from '@ember/template';
import { guidFor } from '@ember/object/internals';

export interface ProgressBarArgs {
  /**
   * The intent of the progress bar
   */
  intent?: 'default' | 'primary' | 'success' | 'warning' | 'danger';

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
   * The display format of the value.
   * Values are formatted as a percentage by default.
   */
  formatOptions?: Intl.NumberFormatOptions;

  /**
   * The content to display as the hint.
   */
  hint?: string;

  /**
   * Custom class name, it will override the default ones using Tailwind Merge library.
   */
  class?: string;
}

export interface ProgressBarSignature {
  Args: ProgressBarArgs;
  Blocks: {
    default: [];
  };
  Element: HTMLDivElement;
}

export default class ProgressBar extends Component<ProgressBarSignature> {
  id = guidFor(this);

  get classNames() {
    const { progressBar } = useStyles();

    const { base, progress, label } = progressBar({
      intent: this.args.intent || 'default',
      size: this.args.size,
      radius: this.args.radius,
      isIndeterminate: this.args.isIndeterminate
    });

    return {
      base: base({ class: this.args.class }),
      progress: progress(),
      label: label()
    };
  }

  get minValue(): number {
    return this.args.minValue || 0;
  }

  get maxValue(): number {
    return this.args.maxValue || 100;
  }

  get progress(): number {
    return this.args.progress || this.minValue;
  }

  get percentage(): number {
    return ((this.progress - this.minValue) / (this.maxValue - this.minValue)) * 100;
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

      return new Intl.NumberFormat(
        navigator?.language || 'en-US',
        options
      ).format(this.progress);
    }

    return this.percentage.toFixed(0) + '%';
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
      <div class={{this.classNames.base}}>
        <div
          role="progressbar"
          aria-labelledby={{if @label this.id}}
          aria-valuenow={{this.progress}}
          aria-valuemin={{this.minValue}}
          aria-valuemax={{this.maxValue}}
          class={{this.classNames.progress}}
          style={{this.progressWidth}}
        ></div>
      </div>
    </div>
  </template>
}
