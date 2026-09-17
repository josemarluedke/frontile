import { tv } from '../tw';
import { focusVisibleRing } from './shared';
import type { VariantProps } from 'tailwind-variants';

/**
 * The separator is rendered *inside* each `<li>` and hidden on the last one
 * with `group-last/item:hidden` (the `<li>` carries `group/item`), so neither
 * authoring form has to know which crumb is last.
 */
const breadcrumbs = tv({
  slots: {
    // Layout only. The nav landmark carries no ink of its own; every colour
    // decision belongs to `link` so the two stay in one place.
    base: '',

    // `flex-wrap`, so a long trail wraps onto a second line rather than
    // overflowing its container. Breadcrumbs have no horizontal-scroll
    // affordance, so overflow would simply hide the current page.
    list: 'flex flex-wrap items-center',

    item: 'group/item inline-flex items-center',

    link: [
      ...focusVisibleRing,
      'inline-flex items-center gap-1 rounded-sm',
      // `firm`, not `DEFAULT`: as ink on the light surface `neutral` is 3.13:1,
      // under WCAG AA. `pagination.ts` uses `firm` for the same job.
      'text-neutral-firm',
      'transition-colors duration-200',
      'motion-reduce:transition-none',
      // The current crumb is the only weight change in the trail: colour alone
      // is not a sufficient distinction, and it is the one crumb a reader
      // scans for.
      'data-[current=true]:font-medium',
      'aria-disabled:cursor-not-allowed aria-disabled:opacity-disabled aria-disabled:pointer-events-none'
    ],

    // The crumb's own ink, deliberately: receding a separator with colour costs
    // more contrast than it buys -- `neutral` lands at 2.95:1 on a gray-50
    // canvas. A thin chevron already reads lighter than a word beside it.
    separator: 'shrink-0 text-neutral-firm group-last/item:hidden',

    // The crumbs' weight, since it stands in for crumbs, but no focus ring and
    // no hover: it is a gap marker, and an affordance would promise a
    // destination it does not have.
    ellipsis:
      'inline-flex shrink-0 items-center justify-center select-none text-neutral-firm'
  },

  variants: {
    // Written as whole literal class strings rather than composed from parts --
    // Tailwind generates nothing from an interpolated class, so the scanner has
    // to see each one intact.
    size: {
      sm: {
        list: 'gap-1 text-body-xs',
        item: 'gap-1',
        separator: '[&_svg]:size-3.5',
        ellipsis: 'text-body-xs'
      },
      md: {
        list: 'gap-1.5 text-body-sm',
        item: 'gap-1.5',
        separator: '[&_svg]:size-4',
        ellipsis: 'text-body-sm'
      },
      lg: {
        list: 'gap-2 text-body-md',
        item: 'gap-2',
        separator: '[&_svg]:size-5',
        ellipsis: 'text-body-md'
      }
    },

    // Hover and current share one ink, so the row reads as a single control.
    //
    // Three categories, not the usual seven: the other four are fill colours,
    // meant to carry `text-on-*` on top of them the way `pagination.ts` uses
    // them. As ink they fail at every level -- `success` tops out at 2.30:1.
    color: {
      neutral: {
        link: 'hover:text-neutral-strong data-[current=true]:text-neutral-strong'
      },
      primary: {
        link: 'hover:text-primary-firm data-[current=true]:text-primary-firm'
      },
      danger: {
        link: 'hover:text-danger-firm data-[current=true]:text-danger-firm'
      }
    },

    // The current crumb is never underlined in any mode: it is the page you
    // are on, and underlining it would advertise a navigation that does
    // nothing.
    underline: {
      always: {
        link: 'underline underline-offset-2 data-[current=true]:no-underline'
      },
      hover: {
        link: 'no-underline underline-offset-2 hover:underline data-[current=true]:hover:no-underline'
      },
      none: { link: 'no-underline hover:no-underline' }
    }
  },

  defaultVariants: {
    size: 'md',
    color: 'neutral',
    // Not `ExternalLink`'s `always`: breadcrumbs sit in their own nav row where
    // the layout already marks them as links, whereas an external link lives in
    // running text and has to announce itself.
    underline: 'hover'
  }
});

export type BreadcrumbsVariants = VariantProps<typeof breadcrumbs>;
export type BreadcrumbsSlots = keyof ReturnType<typeof breadcrumbs>;

export { breadcrumbs };
