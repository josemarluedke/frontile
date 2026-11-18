import type { useStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';

/**
 * Stub `listboxItem` theme: one class per `variant` and `color`, so a test can
 * tell which values reached an item without resolving the shipped compound
 * variants. Register it with `useCustomStyles` (see `scoped-styles.ts`).
 */
export const listboxItemStubStyles: ReturnType<
  typeof useStyles
>['listboxItem'] = tv({
  slots: {
    base: ['listboxItem'],
    descriptionWrapper: 'descriptionWrapper',
    label: 'label',
    description: ['description'],
    selectedIcon: ['selectedIcon'],
    shortcut: ['shortcut'],
    submenuIndicator: ['submenu-indicator']
  },
  variants: {
    variant: {
      solid: { base: 'item-variant-solid' },
      outline: { base: 'item-variant-outline' },
      subtle: { base: 'item-variant-subtle' }
    },
    color: {
      neutral: { base: 'item-neutral' },
      primary: { base: 'item-primary' },
      secondary: { base: 'item-secondary' },
      tertiary: { base: 'item-tertiary' },
      success: { base: 'item-success' },
      warning: { base: 'item-warning' },
      danger: { base: 'item-danger' }
    },
    isActive: { true: { base: ['is-active'] } },
    withDivider: { true: { base: ['with-divider'] } },
    isDisabled: { true: { base: 'is-disabled' } },
    isSelected: { true: { base: 'is-selected' } }
  },
  defaultVariants: {
    variant: 'solid',
    color: 'neutral'
  }
}) as never;
