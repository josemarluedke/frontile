import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';

interface BadgeSignature {
  Args: {
    /**
     * The badge variant. There is no `solid`: a saturated block reads as a
     * Chip or Button.
     *
     * @defaultValue 'soft'
     */
    variant?: 'soft' | 'outline';

    /**
     * The color of the badge.
     *
     * @defaultValue 'neutral'
     */
    color?:
      'neutral' | 'primary' | 'secondary' | 'tertiary' | 'success' | 'danger';

    /**
     * The size of the badge
     *
     * @defaultValue 'md'
     */
    size?: 'xs' | 'sm' | 'md' | 'lg';

    /**
     * Custom class name, it will override the default ones using Tailwind Merge library.
     */
    class?: string;
  };
  Blocks: {
    default: [];
  };
  Element: HTMLSpanElement;
}

class Badge extends Component<BadgeSignature> {
  get classNames() {
    const { badge } = useStyles();

    const { base } = badge({
      color: this.args.color,
      size: this.args.size,
      variant: this.args.variant
    });

    return {
      base: base({ class: this.args.class })
    };
  }

  <template>
    <span
      class={{this.classNames.base}}
      data-component="badge"
      data-part="base"
      ...attributes
    >
      {{yield}}
    </span>
  </template>
}

export { Badge, type BadgeSignature };
export default Badge;
