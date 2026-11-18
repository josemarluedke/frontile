import { tv, type VariantProps } from '../tw';

/**
 * A single icon drawn from an icon font the consumer supplies. The recipe
 * knows nothing about which font: `.icon` and `.icon-<name>` are the contract,
 * and Frontile ships no `@font-face`.
 */
const glyph = tv({
  base: ['icon', 'inline-block', 'shrink-0', 'leading-none'],
  variants: {
    // The ten steps are the names of the label ramp Button, Badge and Chip
    // share, so an icon at a step is the same size as text at that step. Each
    // class reads the ramp's font-size token instead of copying a number, so
    // the icons follow the ramp if it is retuned. Only the size is taken:
    // `text-strong-*` would also pull in weight, tracking and line height,
    // which mean nothing to a glyph. Written out in full so Tailwind sees each
    // class.
    size: {
      '4xs': 'text-(length:--text-strong-4xs)',
      '3xs': 'text-(length:--text-strong-3xs)',
      '2xs': 'text-(length:--text-strong-2xs)',
      xs: 'text-(length:--text-strong-xs)',
      sm: 'text-(length:--text-strong-sm)',
      md: 'text-(length:--text-strong-md)',
      lg: 'text-(length:--text-strong-lg)',
      xl: 'text-(length:--text-strong-xl)',
      '2xl': 'text-(length:--text-strong-2xl)',
      '3xl': 'text-(length:--text-strong-3xl)'
    }
  },
  defaultVariants: {
    size: 'md'
  }
});

export type GlyphVariants = VariantProps<typeof glyph>;
export { glyph };
