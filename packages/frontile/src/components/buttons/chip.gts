import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';
import { CloseButton } from './close-button';

interface ChipSignature {
  Args: {
    /**
     * The chip appearance
     *
     * @defaultValue 'default'
     */
    appearance?: 'default' | 'outlined' | 'faded';

    /**
     * The intent of the chip, which drives its color
     *
     * @defaultValue 'default'
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
     * The size of the chip
     *
     * @defaultValue 'md'
     */
    size?: 'sm' | 'md' | 'lg';

    /**
     * The border radius of the chip
     *
     * @defaultValue 'full'
     */
    radius?: 'none' | 'sm' | 'lg' | 'full';

    /**
     * Adds a dot before the content, colored by `@intent`. On the `default`
     * appearance the dot takes the chip's text color, since the chip's
     * background is already the intent color.
     *
     * @defaultValue false
     */
    withDot?: boolean;

    /**
     * Function to be called when clicking on the close button.
     * If you pass this argument, the close button will be visible.
     */
    onClose?: () => void;

    /**
     * The accessible name of the close button. Every close button would
     * otherwise be announced as just "Close", which does not say *what* is
     * being removed — worth setting when several chips sit together.
     *
     * @defaultValue 'Close'
     */
    closeButtonTitle?: string;

    /**
     * `tabindex` for the close button.
     *
     * Set to `-1` when chips sit inside another control (a multi-select field,
     * say) and the close button should stay a pointer affordance: every chip
     * would otherwise cost a Tab stop before the control itself is reached.
     * Whoever does this owes keyboard users another way to remove a chip.
     *
     * @defaultValue undefined (the close button is a normal tab stop)
     */
    closeButtonTabIndex?: number | string;

    /**
     * Dims the chip and disables its close button, if any.
     *
     * @defaultValue false
     */
    isDisabled?: boolean;

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

class Chip extends Component<ChipSignature> {
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
          @title={{@closeButtonTitle}}
          @onPress={{@onClose}}
          tabindex={{@closeButtonTabIndex}}
          disabled={{@isDisabled}}
        />
      {{/if}}
    </div>
  </template>
}

export { Chip, type ChipSignature };
export default Chip;
