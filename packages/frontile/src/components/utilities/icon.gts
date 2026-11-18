import Component from '@glimmer/component';
import { useStyles, type IconVariants } from '@frontile/theme';

export interface IconSignature {
  Args: {
    /**
     * The size of the circle. The icon inside scales with it.
     *
     * @defaultValue 'md'
     */
    size?: IconVariants['size'];

    /**
     * The color role. A `plain` icon without a color takes the color of the
     * surrounding text; every other variant defaults to `neutral`.
     */
    color?: IconVariants['color'];

    /**
     * How the circle is drawn. `plain` has no circle, only the icon. `solid`,
     * `soft` and `subtle` fill it at decreasing strength, and `outline` draws
     * a ring. A plain icon's box is tighter than the circle of the other
     * variants at the same size.
     *
     * @defaultValue 'plain'
     */
    variant?: IconVariants['variant'];

    /**
     * Draws the icon, its fill and its ring in the opposite light or dark
     * scheme, for an icon on a surface of the other scheme. An inverse plain
     * icon with no `@color` is neutral.
     *
     * @defaultValue false
     */
    inverse?: boolean;

    /**
     * The accessible name. Without it the icon is decorative and hidden from
     * screen readers; set it when the icon carries meaning on its own.
     */
    label?: string;

    /**
     * Custom classes for the root element, merged over the defaults.
     */
    classes?: { base?: string };
  };
  Blocks: {
    /** The icon, for example an inline `<svg>` or a `FaIcon`. */
    default: [];
  };
  Element: HTMLSpanElement;
}

class Icon extends Component<IconSignature> {
  // A plain icon takes the surrounding text color, unless it is inverse: an
  // inherited color cannot be inverted, so it becomes neutral.
  defaultColor(variant: string): 'neutral' | undefined {
    return variant === 'plain' && !this.args.inverse ? undefined : 'neutral';
  }

  get classNames(): string {
    const { icon } = useStyles();
    const variant = this.args.variant ?? 'plain';

    return icon({
      size: this.args.size,
      variant,
      color: this.args.color ?? this.defaultColor(variant),
      inverse: this.args.inverse,
      class: this.args.classes?.base
    });
  }

  <template>
    <span
      class={{this.classNames}}
      role={{if @label "img"}}
      aria-label={{@label}}
      aria-hidden={{unless @label "true"}}
      ...attributes
    >{{yield}}</span>
  </template>
}

export { Icon };
export default Icon;
