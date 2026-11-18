import type { useStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';

/**
 * Stub `badge` theme: short, padding-free class names that tests can assert
 * against, in place of the shipped compound-variant classes.
 *
 * `registerCustomStyles` writes to one slot shared by the whole test run, so a
 * file that asserts against these stubs must register them itself rather than
 * rely on another file having been loaded in the same run.
 */
export const badgeStubStyles: ReturnType<typeof useStyles>['badge'] = tv({
  slots: {
    base: ['badge'],
    value: ['badge-value'],
    unit: ['badge-unit'],
    dot: ['badge-dot'],
    icon: ['badge-icon']
  },
  variants: {
    variant: {
      soft: 'badge-soft',
      outline: 'badge-outline'
    },
    color: {
      neutral: 'badge-neutral',
      primary: 'badge-primary',
      secondary: 'badge-secondary',
      tertiary: 'badge-tertiary',
      success: 'badge-success',
      danger: 'badge-danger'
    },
    size: {
      '2xs': 'badge-2xs',
      xs: 'badge-xs',
      sm: 'badge-sm',
      md: 'badge-md',
      lg: 'badge-lg',
      xl: 'badge-xl',
      '2xl': 'badge-2xl'
    }
  },
  defaultVariants: {
    size: 'xs',
    color: 'neutral',
    variant: 'soft'
  }
}) as never;
