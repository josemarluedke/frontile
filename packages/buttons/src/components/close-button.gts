import Component from '@glimmer/component';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { VisuallyHidden } from '@frontile/utilities';
import { useStyles, type CloseButtonVariants } from '@frontile/theme';

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
     * The function to call when button is clicked
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

  @action handleClick(event: Event): void {
    if (typeof this.args.onClick === 'function') {
      this.args.onClick(event);
    }
  }

  <template>
    <button
      type="button"
      class={{this.classes.base}}
      ...attributes
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
