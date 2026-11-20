import Component from '@glimmer/component';
import type Owner from '@ember/owner';
import { assert } from '@ember/debug';
import { useStyles } from '@frontile/theme';
import { CloseButton } from './close-button';
import { assertRemovedArg } from '../../-private/removed-args';

interface ChipSignature {
  Args: {
    /**
     * The chip variant.
     *
     * @defaultValue 'solid'
     */
    variant?: 'solid' | 'outline' | 'soft';

    /**
     * The color of the chip.
     */
    color?:
      | 'neutral'
      | 'primary'
      | 'secondary'
      | 'tertiary'
      | 'success'
      | 'warning'
      | 'danger';

    /**
     * The size of the chip. Uses Button's size names and text size: the same
     * `@size` gives the same label text size on Chip, Badge and Button.
     *
     * @defaultValue 'xs'
     */
    size?: '2xs' | 'xs' | 'sm' | 'md' | 'lg' | 'xl' | '2xl';

    /**
     * Adds a dot before the content, colored by `@color`. On the `solid`
     * variant the dot takes the chip's text color, since the chip's
     * background is already the chip's color.
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
  constructor(owner: Owner, args: ChipSignature['Args']) {
    super(owner, args);
    assertRemovedArg('Chip', args, 'appearance', 'variant');
    assertRemovedArg('Chip', args, 'intent', 'color');
    assert(
      'Chip: @radius was removed in 0.19.0. Chip is always a pill; use Badge for a squared label.',
      (args as Record<string, unknown>)['radius'] === undefined
    );
  }

  get classNames() {
    const { chip } = useStyles();

    const { base, content, dot, closeButton } = chip({
      color: this.args.color || 'neutral',
      size: this.args.size,
      variant: this.args.variant || 'solid',
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
    <div
      class={{this.classNames.base}}
      data-component="chip"
      data-part="base"
      ...attributes
    >
      {{#if @withDot}}
        <span class={{this.classNames.dot}} data-part="dot"></span>
      {{/if}}
      <span class={{this.classNames.content}} data-part="content">
        {{yield}}
      </span>
      {{#if @onClose}}
        <CloseButton
          @class={{this.classNames.closeButton}}
          @title={{@closeButtonTitle}}
          @onPress={{@onClose}}
          tabindex={{@closeButtonTabIndex}}
          disabled={{@isDisabled}}
          data-part="close-button"
        />
      {{/if}}
    </div>
  </template>
}

export { Chip, type ChipSignature };
export default Chip;
