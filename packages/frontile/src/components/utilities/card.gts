import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';

interface CardSignature {
  Args: {
    /**
     * The surface treatment. `outline` is a bordered card, `flat` has no
     * visible border, and `soft` swaps the fill for a faint tint with no
     * border.
     *
     * @defaultValue 'outline'
     */
    variant?: 'outline' | 'flat' | 'soft';

    /**
     * Colours the hover and selected border. The resting border is neutral
     * either way. The border is 1px in every state; hover and selected add a
     * second 1px inset layer in the same colour so they read as 2px without a
     * layout shift.
     *
     * @defaultValue 'neutral'
     */
    color?: 'neutral' | 'primary';

    /**
     * How much padding surrounds the contents.
     *
     * @defaultValue 'comfortable'
     */
    density?: 'compact' | 'comfortable' | 'spacious';

    /**
     * `raised` gives an `outline` card its shadow, and lifts it on hover when
     * the card is interactive. `none` removes both. `flat` and `soft` never
     * have a shadow, so this changes nothing for them.
     *
     * @defaultValue 'raised'
     */
    elevation?: 'raised' | 'none';

    /**
     * Shows the card as selected. This is appearance only: Card holds no
     * selection state, and does not set `role` or `aria-*` for you. Pair it
     * with whatever provides the selection behaviour and semantics. A selected
     * card also shows the `indicator` block, if one is passed.
     *
     * @defaultValue false
     */
    isSelected?: boolean;

    /**
     * Adds the hover, pressed, focus-visible and pointer styles for a card
     * that can be clicked. It does not make the card focusable or add an
     * event handler; use a `button`, a link, or `role` and `tabindex` through
     * `...attributes` for that.
     *
     * @defaultValue false
     */
    isInteractive?: boolean;

    /**
     * Dims the card and removes its hover and pressed styles. Disabled and
     * selected can be combined: the selected border and its inset layer stay
     * visible.
     *
     * @defaultValue false
     */
    isDisabled?: boolean;

    /**
     * Custom class name, it will override the default ones using Tailwind
     * Merge library.
     */
    class?: string;
  };
  Blocks: {
    /**
     * The card's contents. Card has no regions of its own; lay them out here.
     * When the `indicator` block is also used, the contents go in
     * `<:default>`, because named blocks cannot sit beside loose content.
     */
    default: [];

    /**
     * Opts in to a selection indicator: a small circle at the card's top-right
     * corner holding whatever you pass, usually a check icon from your own
     * icon library. It is shown only while the card is selected, is hidden
     * from assistive technology, and takes its fill from `@color`. Card never
     * supplies the icon, so it depends on no icon set.
     *
     * A parent with `overflow: hidden` clips the part that overhangs the
     * corner.
     */
    indicator?: [];
  };
  Element: HTMLDivElement;
}

class Card extends Component<CardSignature> {
  get classNames() {
    const { card } = useStyles();

    return card({
      variant: this.args.variant,
      color: this.args.color,
      density: this.args.density,
      elevation: this.args.elevation,
      isSelected: this.args.isSelected,
      isInteractive: this.args.isInteractive,
      isDisabled: this.args.isDisabled,
      class: this.args.class
    });
  }

  get indicatorClassNames() {
    const { cardIndicator } = useStyles();

    return cardIndicator({ color: this.args.color });
  }

  <template>
    <div
      class={{this.classNames}}
      data-component="card"
      data-part="base"
      data-selected={{@isSelected}}
      data-disabled={{@isDisabled}}
      ...attributes
    >
      {{yield}}
      {{#if @isSelected}}
        {{#if (has-block "indicator")}}
          <span
            class={{this.indicatorClassNames}}
            data-part="indicator"
            aria-hidden="true"
          >
            {{yield to="indicator"}}
          </span>
        {{/if}}
      {{/if}}
    </div>
  </template>
}

export { Card };
export default Card;
