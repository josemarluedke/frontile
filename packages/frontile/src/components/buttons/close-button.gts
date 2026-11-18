import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { assert } from '@ember/debug';
import { VisuallyHidden } from '../utilities/visually-hidden';
import { press, type PressEvent } from '../../modifiers/press';
import { useStyles, type CloseButtonVariants } from '@frontile/theme';
import { assertRemovedArg } from '../../-private/removed-args';
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
     * @defaultValue 'ghost'
     */
    variant?: 'ghost' | 'soft';

    /**
     * The function to call when button is pressed
     */
    onPress?: (event: PressEvent) => void;

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

    assertRemovedArg('CloseButton', args, 'onClick', 'onPress');

    // The type no longer admits these, but untyped consumers still can.
    const variant = args.variant as string | undefined;
    assert(
      'CloseButton: @variant="transparent" was removed in 0.19.0. Use @variant="ghost".',
      variant !== 'transparent'
    );
    assert(
      'CloseButton: @variant="subtle" was removed in 0.19.0. Use @variant="soft".',
      variant !== 'subtle'
    );
  }

  get classes() {
    const { closeButton } = useStyles();

    const { base, icon } = closeButton({
      size: this.args.size || 'md',
      variant: this.args.variant ?? 'ghost'
    });

    return {
      base: base({ class: this.args.class }),
      icon: icon()
    };
  }

  handlePressChange = (isPressed: boolean): void => {
    this.isPressed = isPressed;
  };

  handlePress = (event: PressEvent): void => {
    if (typeof this.args.onPress === 'function') {
      this.args.onPress(event);
    }
  };

  <template>
    <button
      type="button"
      class={{this.classes.base}}
      data-pressed={{if this.isPressed "true"}}
      data-component="close-button"
      data-part="base"
      ...attributes
      {{press this.handlePress onPressChange=this.handlePressChange}}
    >

      {{#if (has-block)}}
        {{yield this.classes.icon}}
      {{else}}
        <svg
          class={{this.classes.icon}}
          data-part="icon"
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
