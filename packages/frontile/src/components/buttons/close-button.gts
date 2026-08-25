import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { deprecate } from '@ember/debug';
import { VisuallyHidden } from '../utilities/visually-hidden';
import { press, type PressEvent } from '../../modifiers/press';
import { useStyles, type CloseButtonVariants } from '@frontile/theme';
import type Owner from '@ember/owner';

interface CloseButtonSignature {
  Args: {
    /**
     * The title of the close button
     *
     * @defaultValue 'Close'
     */
    title?: string;

    /**
     * The icon size
     *
     * @defaultValue 'lg'
     */
    size?: CloseButtonVariants['size'];

    /**
     * @defaultValue 'transparent'
     */
    variant?: CloseButtonVariants['variant'];

    /**
     * The function to call when button is pressed
     */
    onPress?: (event: PressEvent) => void;

    /**
     * Deprecated: The function to call when button is clicked
     *
     * @deprecated Use onPress instead for better cross-platform support
     */
    onClick?: (event: Event) => void;

    /**
     * Additional class for close button element
     */
    class?: string;
  };
  Blocks: {
    default: [string | null];
  };
  Element: HTMLButtonElement;
}

class CloseButton extends Component<CloseButtonSignature> {
  @tracked isPressed = false;

  constructor(owner: Owner, args: CloseButtonSignature['Args']) {
    super(owner, args);

    if (args.onClick) {
      deprecate(
        'CloseButton: onClick is deprecated. Use onPress instead for better cross-platform support including touch, keyboard, and screen reader interactions.',
        false,
        {
          id: 'frontile.close-button.onClick',
          until: '0.18.0',
          for: 'frontile',
          since: { available: '0.17.0', enabled: '0.17.0' }
        }
      );
    }
  }

  get classes() {
    const { closeButton } = useStyles();

    let { base, icon } = closeButton({
      size: this.args.size || 'md',
      variant: this.args.variant || 'transparent'
    });

    return {
      base: base({ class: this.args.class }),
      icon: icon()
    };
  }

  handlePressChange = (isPressed: boolean): void => {
    this.isPressed = isPressed;
  };

  @action handlePress(event: PressEvent): void {
    if (typeof this.args.onPress === 'function') {
      this.args.onPress(event);
    }
  }

  @action handleClick(event: Event): void {
    if (typeof this.args.onClick === 'function') {
      this.args.onClick(event);
    }
  }

  <template>
    <button
      type="button"
      class={{this.classes.base}}
      data-pressed={{if this.isPressed "true"}}
      ...attributes
      {{press this.handlePress onPressChange=this.handlePressChange}}
      {{on "click" this.handleClick}}
    >

      {{#if (has-block)}}
        {{yield this.classes.icon}}
      {{else}}
        <svg
          class={{this.classes.icon}}
          aria-hidden="true"
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M6 18L18 6M6 6l12 12"
          ></path>
        </svg>
      {{/if}}

      <VisuallyHidden>
        {{if @title @title "Close"}}
      </VisuallyHidden>
    </button>
  </template>
}

export { CloseButton, type CloseButtonSignature };
export default CloseButton;
