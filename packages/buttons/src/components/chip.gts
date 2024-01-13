import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';
import CloseButton from '@frontile/core/components/close-button';

export interface ChipArgs {
  /**
   * The chip appearance
   *
   * @defaultValue 'default'
   */
  appearance?: 'default' | 'outlined' | 'faded';

  /**
   * The intent of the chip
   */
  intent?: 'default' | 'primary' | 'success' | 'warning' | 'danger';

  /**
   * The size of the chip
   */
  size?: 'sm' | 'md' | 'lg';

  /**
   * The radius the chip
   */
  radius?: 'none' | 'sm' | 'lg' | 'full';

  /**
   * Option to add dot to the chip
   */
  withDot?: boolean;

  /**
   * Function to be called when clicking on the close button.
   * If you pass this argument, the close button will be visible.
   */
  onClose?: () => void;

  /**
   * Disables the clip and disables the close button if any.
   */
  isDisabled?: boolean;

  /**
   * Custom class name, it will override the default ones using Tailwind Merge library.
   */
  class?: string;
}

export interface ChipSignature {
  Args: ChipArgs;
  Blocks: {
    default: [];
  };
  Element: HTMLDivElement;
}

export default class Chip extends Component<ChipSignature> {
  get classNames() {
    const { chip } = useStyles();

    const { base, content, dot, closeButton } = chip({
      intent: this.args.intent || 'default',
      size: this.args.size,
      appearance: this.args.appearance || 'default',
      radius: this.args.radius,
      isDisabled: this.args.isDisabled
    });

    return {
      base: base({ class: this.args.class }),
      content: content(),
      dot: dot(),
      closeButton: closeButton()
    };
  }

  <template>
    <div class={{this.classNames.base}} ...attributes>
      {{#if @withDot}}
        <span class={{this.classNames.dot}}></span>
      {{/if}}
      <span class={{this.classNames.content}}>
        {{yield}}
      </span>
      {{#if @onClose}}
        <CloseButton
          @class={{this.classNames.closeButton}}
          @onClick={{@onClose}}
          disabled={{@isDisabled}}
        />
      {{/if}}
    </div>
  </template>
}
