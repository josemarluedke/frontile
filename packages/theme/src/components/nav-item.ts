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
    // Hidden in the icon rail, except inside a folder's flyout: the flyout
    // sits inside the sidebar's DOM but lists items with their labels.
    navItemLabel:
      'truncate group-data-[collapsed=true]/sidebar:[&:not([data-part=nav-folder-flyout]_*)]:sr-only',
    navFolder: 'flex flex-col',
    navFolderTrigger: navItemRow,
    navFolderChevron: [
      'ms-auto size-4 shrink-0 transition-transform data-[open=true]:rotate-90 motion-reduce:transition-none',
      'group-data-[collapsed=true]/sidebar:hidden'
    ],
    navFolderPanel:
      'ms-4 flex flex-col gap-0.5 border-s border-neutral-muted ps-2',
    // A folder's items, floating beside the icon rail. Positioned `fixed`
    // by the component, so it escapes the sidebar body's scroll clipping.
    // `--sidebar-rail` is reset so the rows' rail-centering start padding
    // (see `navItemRow`) works out to the same 0.5rem as their end padding.
    navFolderFlyout: [
      'z-50 flex min-w-48 flex-col gap-0.5 p-1 [--sidebar-rail:3.25rem]',
      'rounded-xl border border-neutral-subtle bg-surface-input shadow-elevation-3'
    ],
    // The folder's name at the top of its flyout, where the rail trigger
    // shows only an icon. Text only: the group is named by the trigger.
    navFolderFlyoutLabel:
      'truncate px-2 pt-1 pb-0.5 text-xs font-medium text-neutral-firm'
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
