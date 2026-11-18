import { Button, type ButtonArgs } from './button';
import { Glyph } from '../utilities/glyph';
import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';
import type { PressEvent } from '../../modifiers/press';

export interface IconButtonSignature {
  Args: {
    /**
     * The icon to draw, passed to Glyph as its `@name`: `trash` becomes
     * `icon-trash`, a class your icon font defines.
     */
    icon: string;

    /**
     * The accessible name. An icon-only button has no text, so this is
     * required; it becomes the button's `aria-label`.
     */
    label: string;

    /**
     * The size of the button. Same names as Button.
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
  Element: HTMLButtonElement;
}

class IconButton extends Component<IconButtonSignature> {
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
      aria-label={{@label}}
      data-component="icon-button"
      ...attributes
    >
      <:icon><Glyph @name={{@icon}} @size="inherit" /></:icon>
    </Button>
  </template>
}

export { IconButton };
export default IconButton;
