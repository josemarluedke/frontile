import { tv } from '../tw';
import { focusVisibleRing } from './shared';
import type { VariantProps } from '../tw';

const navItemRow = [
  ...focusVisibleRing,
  'flex min-h-9 w-full items-center gap-2 rounded-md px-2 py-1.5 text-sm',
  // The icon's position never depends on the collapsed state, so the rail
  // closes over it instead of the icon sliding as the width animates.
  // Start padding puts it at the center of the rail's content box:
  // (rail - body padding 1rem - icon 1.25rem) / 2. `--sidebar-rail` is
  // the content width, so the inset variant excludes its 0.75rem gap.
  'ps-[calc((var(--sidebar-rail,4rem)_-_2.25rem)/2)]',
  'text-neutral-firm',
  'not-data-[disabled=true]:hover:bg-neutral-subtle',
  'not-data-[disabled=true]:hover:text-neutral-strong',
  'data-[active=true]:bg-neutral-soft data-[active=true]:font-medium',
  'data-[active=true]:text-neutral-strong',
  'data-[disabled=true]:cursor-not-allowed data-[disabled=true]:opacity-disabled'
];

/**
 * Shared navigation row styles: `NavLink`, `NavItem` and `NavFolder`.
 * Slot names equal the kebab-cased `data-part` each component renders.
 */
const navItem = tv({
  slots: {
    navItem: navItemRow,
    navItemIcon: 'inline-flex size-5 shrink-0 items-center justify-center',
    navItemLabel: 'truncate group-data-[collapsed=true]/sidebar:sr-only',
    navFolder: 'flex flex-col',
    navFolderTrigger: [...navItemRow, 'justify-between'],
    navFolderChevron: [
      'size-4 transition-transform data-[open=true]:rotate-90 motion-reduce:transition-none',
      'group-data-[collapsed=true]/sidebar:hidden'
    ],
    navFolderPanel:
      'ms-4 flex flex-col gap-0.5 border-s border-neutral-muted ps-2',
    navFolderFlyout: 'min-w-48 flex flex-col gap-0.5 p-1'
  },
  variants: {
    layout: {
      inline: {}
    }
  },
  defaultVariants: {
    layout: 'inline'
  }
});

export { navItem };
export type NavItemSlots = keyof ReturnType<typeof navItem>;
export type NavItemVariants = VariantProps<typeof navItem>;
