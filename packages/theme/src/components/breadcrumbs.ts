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
      'text-neutral',
      'transition-colors duration-200',
      'motion-reduce:transition-none',
      // The current crumb is the only weight change in the trail: colour alone
      // is not a sufficient distinction, and it is the one crumb a reader
      // scans for.
      'data-[current=true]:font-medium',
      'aria-disabled:cursor-not-allowed aria-disabled:opacity-disabled aria-disabled:pointer-events-none'
    ],

    // Muted below the resting crumb: it is punctuation, not content, and a
    // separator with the same weight as the labels reads as a sixth crumb.
    separator: 'shrink-0 text-neutral-muted group-last/item:hidden',

    // Not a button, so no focus ring and no hover: it is a gap marker, and
    // giving it an affordance would promise a destination it does not have.
    // A consumer who puts a Dropdown in the default block opts into
    // interactivity deliberately, and brings that trigger's own styling.
    ellipsis:
      'inline-flex shrink-0 items-center justify-center select-none text-neutral'
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
    // is going and hover is a preview of going there, so one ink for both
    // keeps the row reading as a single control.
    color: {
      neutral: {
        link: 'hover:text-neutral-strong data-[current=true]:text-neutral-strong'
      },
      primary: {
        link: 'hover:text-primary data-[current=true]:text-primary'
      },
      secondary: {
        link: 'hover:text-secondary data-[current=true]:text-secondary'
      },
      tertiary: {
        link: 'hover:text-tertiary data-[current=true]:text-tertiary'
      },
      success: {
        link: 'hover:text-success data-[current=true]:text-success'
      },
      warning: {
        link: 'hover:text-warning data-[current=true]:text-warning'
      },
      danger: {
        link: 'hover:text-danger data-[current=true]:text-danger'
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
