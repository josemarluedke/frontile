import { tv } from '../tw';
import { focusVisibleRing } from './shared';
import type { VariantProps } from '../tw';

// The icon's position never depends on the collapsed state, so the rail
// closes over it instead of the icon sliding as the width animates.
// Start padding puts it at the center of the rail's content box:
// (rail - body padding on both sides - icon 1.25rem) / 2. The body's
// side padding is `--sidebar-gutter` (0.5rem unless the variant sets it).
// `--sidebar-rail` is the content width, so the inset variant excludes its
// 0.75rem gap. Only the inline layout follows the rail.
const railStart =
  'ps-[calc((var(--sidebar-rail,4rem)_-_2*var(--sidebar-gutter,0.5rem)_-_1.25rem)/2)]';

// The end padding puts a trailing icon or badge 1rem from the sidebar's edge,
// whatever the variant's gutter: a `Toggle` at the header's end has its icon
// there too (its fill starts at the gutter, its icon sits 0.5rem inside).
const rowPe = 'pe-[calc(1rem_-_var(--sidebar-gutter,0.5rem))]';

const navRow = [
  ...focusVisibleRing,
  // 36px with a mouse; 44px where the pointer is coarse (touch).
  `flex min-h-9 w-full items-center gap-2 rounded-lg ps-2 ${rowPe} py-1.5 text-sm pointer-coarse:min-h-11`,
  'text-neutral-firm',
  'not-data-[disabled=true]:hover:bg-neutral-muted',
  'not-data-[disabled=true]:hover:text-neutral-strong',
  'data-[disabled=true]:cursor-not-allowed data-[disabled=true]:opacity-disabled'
];

// An item is filled while it is the current page. A folder is never the
// current page, so its trigger takes `navRow` alone.
const navItemRow = [
  ...navRow,
  'data-[active=true]:bg-neutral-soft data-[active=true]:font-medium',
  // Hovering the current page keeps its fill rather than lightening it.
  'not-data-[disabled=true]:data-[active=true]:hover:bg-neutral-soft',
  'data-[active=true]:text-neutral-strong'
];

/**
 * Shared navigation row styles: `NavLink`, `NavItem` and `NavFolder`.
 * Slot names equal the kebab-cased `data-part` each component renders.
 */
const navItem = tv({
  slots: {
    navItem: navItemRow,
    navItemIcon: 'relative inline-flex shrink-0 items-center justify-center',
    navItemLabel: 'truncate',
    // The short text shown under the icon in the stacked layout.
    navItemShortLabel: 'max-w-full truncate text-[11px] leading-tight',
    navItemBadge:
      'inline-flex h-4 min-w-4 items-center justify-center rounded-full bg-danger px-1 text-[11px] leading-none font-medium text-on-danger',
    // Screen-reader text appended to the label for a badge.
    navItemBadgeLabel: 'sr-only',
    navFolder: 'flex flex-col',
    // A button, which browsers do not give a pointer cursor on their own.
    navFolderTrigger: [...navRow, 'not-data-[disabled=true]:cursor-pointer'],
    navFolderChevron: [
      'ms-auto size-4 shrink-0 transition-transform data-[open=true]:rotate-90 motion-reduce:transition-none',
      // Mirrored right to left, so it points toward the inline end. CSS
      // applies `scale` before `rotate`, so the open state turns the other
      // way there to still point down.
      'rtl:-scale-x-100 rtl:data-[open=true]:-rotate-90',
      'group-data-[collapsed=true]/sidebar:hidden'
    ],
    // The first child's top margin spaces it from the trigger. It lives
    // inside the panel because the collapsed panel clips it; a gap or
    // padding on the folder would show 4px while closed.
    navFolderPanel:
      'ms-4 flex flex-col gap-1 border-s border-neutral-muted ps-2 *:first:mt-1'
  },
  variants: {
    layout: {
      inline: {
        navItem: railStart,
        navFolderTrigger: railStart,
        navItemIcon: 'size-5',
        // Hidden in the icon rail.
        navItemLabel: 'group-data-[collapsed=true]/sidebar:sr-only'
      },
      // Small icon over text. Ignores the sidebar's collapsed state.
      stacked: {
        navItem: [
          'group/nav-item mx-auto min-h-14 w-full max-w-[72px] flex-col justify-center gap-0.5 px-0.5 py-1 text-[11px]',
          // The active fill sits behind the icon, not the whole item.
          'data-[active=true]:bg-transparent not-data-[disabled=true]:hover:bg-transparent',
          'not-data-[disabled=true]:data-[active=true]:hover:bg-transparent'
        ],
        navItemIcon: [
          'h-8 w-11 rounded-lg [&>svg]:size-5',
          'group-data-[active=true]/nav-item:bg-neutral-soft',
          'group-not-data-[disabled=true]/nav-item:group-hover/nav-item:bg-neutral-muted',
          'group-not-data-[disabled=true]/nav-item:group-data-[active=true]/nav-item:group-hover/nav-item:bg-neutral-soft'
        ]
      },
      // Icon only; the label is screen-reader text and a tooltip.
      icon: {
        navItem: 'size-11 min-h-11 justify-center rounded-lg px-0 py-0',
        navItemIcon: 'size-5',
        navItemLabel: 'sr-only'
      },
      // A row of a rail folder's `Dropdown` menu: the menu item draws the
      // row, the item only its icon, label and badge.
      menu: {
        navItemIcon: 'size-5'
      }
    },
    // The current page, in a rail folder's menu.
    current: {
      true: { navItemLabel: 'font-medium text-neutral-strong' }
    },
    // The visible text is the short label, so the full label is for
    // screen readers only.
    shortLabel: {
      true: { navItemLabel: 'sr-only' }
    },
    badgePlacement: {
      // At the icon's top-end corner.
      icon: { navItemBadge: 'absolute -top-1 -end-1' },
      end: { navItemBadge: 'ms-auto' }
    },
    // A plain dot with no text (the More tab's "something inside has a
    // badge" marker).
    badgeDot: {
      true: { navItemBadge: 'size-2 min-w-2 p-0' }
    }
  },
  compoundVariants: [
    // The dot is smaller than the pill, so it sits closer to the corner.
    {
      badgeDot: true,
      badgePlacement: 'icon',
      class: { navItemBadge: '-top-0.5 -end-0.5' }
    }
  ],
  defaultVariants: {
    layout: 'inline'
  }
});

export { navItem };
export type NavItemSlots = keyof ReturnType<typeof navItem>;
export type NavItemVariants = VariantProps<typeof navItem>;
