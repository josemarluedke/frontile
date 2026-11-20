import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';

interface BadgeSignature {
  Args: {
    /**
     * The badge variant. `solid` fills with the color's default level, `soft`
     * is a tinted surface, and `outline` draws the color as a border.
     *
     * @defaultValue 'solid'
     */
    variant?: 'solid' | 'soft' | 'outline';

    /**
     * The color of the badge.
     *
     * @defaultValue 'neutral'
     */
    color?:
      'neutral' | 'primary' | 'secondary' | 'tertiary' | 'success' | 'danger';

    /**
     * The size of the badge. Uses Button's size names and text size: the same
     * `@size` gives the same label text size on Badge, Chip and Button.
     *
     * @defaultValue 'xs'
     */
    size?: '2xs' | 'xs' | 'sm' | 'md' | 'lg' | 'xl' | '2xl';

    /**
     * Adds a dot before the content, colored by `@color`.
     *
     * @defaultValue false
     */
    withDot?: boolean;

    /**
     * Custom class name, it will override the default ones using Tailwind Merge library.
     */
    class?: string;

    /**
     * A figure shown after the label, such as a price or a count. A number is
     * accepted, and `0` still renders; only `undefined` or `null` leaves the
     * value out. Rendered in its own part so the theme can give it a
     * tabular, heavier treatment.
     */
    value?: string | number;

    /**
     * A unit shown after the value, such as `/mo`. Rendered only when set.
     */
    unit?: string;
  };
  Blocks: {
    /**
     * The badge label.
     */
    default: [];

    /**
     * An icon shown before the label. Using this block means the label must
     * go in the `<:default>` block.
     */
    startIcon?: [];

    /**
     * An icon shown after the value and unit. Using this block means the label
     * must go in the `<:default>` block.
     */
    endIcon?: [];
  };
  Element: HTMLSpanElement;
}

/**
 * A non-interactive label for status or metadata. Renders, in order: dot, start
 * icon, label, value, unit, end icon.
 *
 * When you pass a named block (`<:startIcon>` or `<:endIcon>`), Glimmer no
 * longer treats loose content as the default block, so put the label in
 * `<:default>`.
 *
 * Facet 2.0 content parts map one-to-one onto this API, so there are no extra
 * slots: `leading` is the default block, `price` is `@value`, `unit` is
 * `@unit`, `startGlyph` is `<:startIcon>` and `endGlyph` is `<:endIcon>`.
 */
class Badge extends Component<BadgeSignature> {
  // `!= null` rather than truthiness, so a count of `0` is shown.
  get hasValue(): boolean {
    return this.args.value != null;
  }

  get classNames() {
    const { badge } = useStyles();

    const { base, value, unit, icon, dot } = badge({
      color: this.args.color,
      size: this.args.size,
      variant: this.args.variant
    });

    return {
      base: base({ class: this.args.class }),
      value: value(),
      unit: unit(),
      icon: icon(),
      dot: dot()
    };
  }

  <template>
    <span
      class={{this.classNames.base}}
      data-component="badge"
      data-part="base"
      ...attributes
    >
      {{#if @withDot}}
        <span class={{this.classNames.dot}} data-part="dot"></span>
      {{/if}}
      {{#if (has-block "startIcon")}}
        <span
          class={{this.classNames.icon}}
          data-part="icon"
          data-position="start"
        >
          {{yield to="startIcon"}}
        </span>
      {{/if}}
      {{yield}}
      {{#if this.hasValue}}
        <span
          class={{this.classNames.value}}
          data-part="value"
        >{{@value}}</span>
      {{/if}}
      {{#if @unit}}
        <span class={{this.classNames.unit}} data-part="unit">{{@unit}}</span>
      {{/if}}
      {{#if (has-block "endIcon")}}
        <span
          class={{this.classNames.icon}}
          data-part="icon"
          data-position="end"
        >
          {{yield to="endIcon"}}
        </span>
      {{/if}}
    </span>
  </template>
}

export { Badge, type BadgeSignature };
export default Badge;
