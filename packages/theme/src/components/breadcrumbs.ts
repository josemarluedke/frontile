import { tv } from '../tw';
import { focusVisibleRing } from './shared';
import type { VariantProps } from 'tailwind-variants';

/**
 * The separator is rendered *inside* each `<li>`, after the crumb, and hidden
 * on the last one with `group-last/item:hidden` (the `<li>` carries
 * `group/item`). That is why neither authoring form has to know which crumb is
 * last -- the same instinct as `pagination.ts`'s `:has()` layout: let the
 * rendered structure drive the CSS rather than computing a variant and
 * threading it through.
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
      // `neutral-firm`, not `neutral`: as text on the light surface `neutral` is
      // only 3.13:1, under the 4.5:1 WCAG AA needs for normal text. `firm` is
      // 8.06:1 light / 12.57:1 dark, and is what `pagination.ts` already uses
      // for the same job on the same kind of row.
      'text-neutral-firm',
      'transition-colors duration-200',
      'motion-reduce:transition-none',
      // The current crumb is the only weight change in the trail: colour alone
      // is not a sufficient distinction, and it is the one crumb a reader
      // scans for.
      'data-[current=true]:font-medium',
      'aria-disabled:cursor-not-allowed aria-disabled:opacity-disabled aria-disabled:pointer-events-none'
    ],

    // Same ink as the crumbs, not a step below them. The obvious instinct is to
    // recede the separator with colour, and this started at `neutral-muted` --
    // gray-100 in light mode, a *background* value, 1.18:1 as ink, invisible.
    // `button.ts` and `notification-card.ts` carry comments about the same trap.
    //
    // The next step down from the crumbs, `neutral`, measures 3.13:1 on a white
    // surface but only 2.95:1 on the gray-50 canvas the docs use -- under the
    // 3:1 a non-text graphic wants, and short of a fix worth defending. So the
    // separator takes the crumb's own ink and gets its subordination from
    // weight instead: a 1.5-stroke chevron at 60% of the cap height reads
    // lighter than a word in the same colour, at any contrast ratio.
    separator: 'shrink-0 text-neutral-firm group-last/item:hidden',

    // Not a button, so no focus ring and no hover: it is a gap marker, and
    // giving it an affordance would promise a destination it does not have.
    // A consumer who puts a Dropdown in the default block opts into
    // interactivity deliberately, and brings that trigger's own styling.
    // Reads at the resting crumb's weight, because it stands in for crumbs.
    // Its de-emphasis comes from being non-interactive, not from being fainter.
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

    // Hover and current share a colour: the current crumb is where the trail
    // is going and hover is a preview of going there, so one ink for both keeps
    // the row reading as a single control.
    //
    // Only three categories, where every other themed component offers seven.
    // The rest are fill colours, meant to be paired with `text-on-*` on top of
    // them -- which is exactly how `pagination.ts` uses all seven. As *ink on
    // the light surface* they are unusable at every level: success tops out at
    // 2.30:1 and secondary at 2.50:1 even at `firm`, against the 4.5:1 WCAG AA
    // wants for normal text. Breadcrumbs colour their text and have no fill, so
    // offering those categories here would only offer illegible trails.
    //
    // `firm`, not `DEFAULT`, for the same reason the base ink is firm.
    color: {
      // 8.06:1 light / 12.57:1 dark resting, rising to 12.45 / 15.35 current.
      neutral: {
        link: 'hover:text-neutral-strong data-[current=true]:text-neutral-strong'
      },
      // 16.58:1 light / 16.50:1 dark.
      primary: {
        link: 'hover:text-primary-firm data-[current=true]:text-primary-firm'
      },
      // 6.36:1 light / 8.35:1 dark.
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
