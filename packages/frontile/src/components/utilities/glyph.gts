import Component from '@glimmer/component';
import { useStyles, type GlyphVariants } from '@frontile/theme';

export interface GlyphSignature {
  Args: {
    /**
     * The icon to draw. Becomes the `icon-<name>` class, so it must match a
     * class your icon font defines (`chevron-down` → `.icon-chevron-down`).
     */
    name: string;

    /**
     * The size of the icon. Each step matches the text size of the same name
     * on Button, Badge and Chip. `inherit` takes the size of the surrounding
     * text instead.
     *
     * @defaultValue 'md'
     */
    size?: GlyphVariants['size'];

    /**
     * An accessible name. Without it the glyph is decorative and hidden from
     * assistive tech; with it the glyph is exposed as an image with this name.
     * Give one only when the glyph carries meaning that no nearby text does.
     */
    label?: string;

    /**
     * Custom class name, it will override the default ones using Tailwind Merge
     * library.
     */
    class?: string;
  };
  Element: HTMLElement;
}

/**
 * Draws one icon from an icon font you supply. Frontile ships no font files:
 * define `.icon-<name>` in your own `@font-face` or icon kit.
 */
class Glyph extends Component<GlyphSignature> {
  get classNames(): string {
    const { glyph } = useStyles();

    return glyph({
      size: this.args.size,
      class: [`icon-${this.args.name}`, this.args.class]
    });
  }

  <template>
    {{! Decorative unless given a label: a font icon has no text of its own,
        so an unlabelled one would be announced as nothing or as the private-use
        character the font maps it to. }}
    <i
      class={{this.classNames}}
      role={{if @label "img"}}
      aria-label={{@label}}
      aria-hidden={{unless @label "true"}}
      data-component="glyph"
      ...attributes
    ></i>
  </template>
}

export { Glyph };
export default Glyph;
