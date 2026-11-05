import type { useStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';

/**
 * Stub `closeButton` theme: short class names with no sizing or padding, in
 * place of the shipped classes. A `Chip` renders a `CloseButton`, so anything
 * that measures chip geometry (see the Select tests) depends on it too.
 *
 * Like `chip-stub-styles.ts`: a file that relies on these must register them
 * itself for its own module and restore afterwards, since `registerCustomStyles`
 * is one slot shared by the whole run and `ember-exam` decides which files share
 * a run.
 */
export const closeButtonStubStyles: ReturnType<
  typeof useStyles
>['closeButton'] = tv({
  slots: {
    base: 'close-button',
    icon: 'close-button__icon'
  },

  variants: {
    size: {
      xs: 'close-button--xs',
      sm: 'close-button--sm',
      md: 'close-button--md',
      lg: 'close-button--lg',
      xl: 'close-button--xl'
    },
    variant: {
      ghost: 'close-button-ghost',
      soft: 'close-button-soft'
    }
  },
  defaultVariants: {
    size: 'md',
    variant: 'ghost'
  }
} as never);
