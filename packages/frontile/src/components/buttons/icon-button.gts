import { Button, type ButtonArgs } from './button';
import { assert } from '@ember/debug';
import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';
import type { PressEvent } from '../../modifiers/press';

export interface IconButtonSignature {
  Args: {
    /**
     * The accessible name. An icon-only button has no text, so this is
     * required and must not be empty; it becomes the button's `aria-label`.
     */
    label: string;

    /**
     * The size of the button. Same names as Button. Diameters run from 24px
     * (`xs`) to 80px (`2xl`).
     *
     * @defaultValue 'md'
     */
    size?: ButtonArgs['size'];

    /** The color of the button. Same values as Button. */
    color?: ButtonArgs['color'];

    /** The button variant. Same values as Button. */
    variant?: ButtonArgs['variant'];

    /**
     * Renders a spinner in place of the icon and disables the button.
     *
     * @defaultValue false
     */
    isLoading?: boolean;

    /** The HTML type of the button. */
    type?: ButtonArgs['type'];

    /** Callback for when the button is pressed. */
    onPress?: (event: PressEvent) => void;

    /**
     * Custom class name, it will override the default ones using Tailwind
     * Merge library.
     */
    class?: string;
  };
  Blocks: {
    /** The icon, for example an inline `<svg>`. Sized to the button's text. */
    default: [];
  };
  Element: HTMLButtonElement;
}

class IconButton extends Component<IconButtonSignature> {
  get label(): string {
    assert(
      'IconButton: @label is required, an icon-only button has no other accessible name.',
      typeof this.args.label === 'string' && this.args.label.trim() !== ''
    );

    return this.args.label;
  }

  get classNames(): string {
    const { iconButton } = useStyles();

    return iconButton({ size: this.args.size, class: this.args.class });
  }

  <template>
    <Button
      @size={{@size}}
      @color={{@color}}
      @variant={{@variant}}
      @isLoading={{@isLoading}}
      @type={{@type}}
      @onPress={{@onPress}}
      @class={{this.classNames}}
      aria-label={{this.label}}
      data-component="icon-button"
      ...attributes
    >
      <:icon>{{yield}}</:icon>
    </Button>
  </template>
}

export { IconButton };
export default IconButton;
