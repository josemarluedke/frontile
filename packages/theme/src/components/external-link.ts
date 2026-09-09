import { tv } from '../tw';
import { focusVisibleRing } from './shared';
import type { VariantProps } from 'tailwind-variants';

const externalLink = tv({
  slots: {
    // `inline`, not `inline-flex`. An external link's home is running text, and
    // `inline-flex` would make the whole anchor an atomic inline-block that
    // refuses to break across lines mid-phrase.
    //
    // No colour: `text-current` inherits from whatever the link sits in, so
    // there is no `intent` variant to keep in sync. `decoration-current/40`
    // gives the rule a lighter weight than the text without naming a palette.
    base: [
      'inline text-current',
      'decoration-current/40 underline-offset-2',
      'hover:decoration-current',
      'transition-colors duration-150',
      'rounded-sm',
      ...focusVisibleRing
    ],
    // A wrapper rather than the `<svg>` itself, so the `:icon` block gets the
    // same sizing and spacing as the built-in glyph. `size-[1em]` tracks the
    // inherited font size, which is why the component needs no size scale.
    // `align-[-0.125em]` seats it on the text baseline instead of hanging it
    // from the line box.
    icon: [
      'inline-flex items-center justify-center size-[1em] shrink-0',
      'align-[-0.125em]',
      '[&>svg]:size-full'
    ]
  },
  variants: {
    underline: {
      always: { base: 'underline' },
      hover: { base: 'no-underline hover:underline' },
      none: { base: 'no-underline hover:no-underline' }
    },
    iconPlacement: {
      start: { icon: 'mr-0.5' },
      end: { icon: 'ml-0.5' }
    }
  },
  defaultVariants: {
    underline: 'always',
    iconPlacement: 'end'
  }
});

export type ExternalLinkVariants = VariantProps<typeof externalLink>;
export type ExternalLinkSlots = keyof ReturnType<typeof externalLink>;

export { externalLink };
