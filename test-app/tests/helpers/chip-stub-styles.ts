import type { useStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';

/**
 * Stub `chip` theme: short, padding-free class names that tests can assert
 * against, in place of the shipped compound-variant classes.
 *
 * `registerCustomStyles` writes to one slot shared by the whole test run, so a
 * file that asserts against these stubs must register them itself (for its own
 * module, restoring afterwards) rather than rely on `chip-test.gts` having been
 * loaded in the same run. `ember-exam` splits the suite across jobs, so which
 * files share a run is not something a test can assume.
 */
export const chipStubStyles: ReturnType<typeof useStyles>['chip'] = tv({
  slots: {
    base: ['chip'],
    content: ['chip-content'],
    dot: ['chip-dot'],
    closeButton: ['chip-close-button']
  },
  variants: {
    variant: {
      solid: 'chip-solid',
      outline: 'chip-outline',
      soft: 'chip-soft'
    },
    color: {
      neutral: 'chip-neutral',
      primary: 'chip-primary',
      secondary: 'chip-secondary',
      tertiary: 'chip-tertiary',
      success: 'chip-success',
      warning: 'chip-warning',
      danger: 'chip-danger'
    },
    size: {
      xs: 'chip-xs',
      sm: 'chip-sm',
      md: 'chip-md',
      lg: 'chip-lg'
    },
    radius: {
      none: 'radius-none',
      sm: 'radius-sm',
      lg: 'radius-lg',
      full: 'radius-full'
    }
  },
  defaultVariants: {
    size: 'md',
    color: 'primary'
  }
}) as never;
