import { tv } from '../tw';
import { focusVisibleRing } from './shared';
import type { VariantProps } from '../tw';

const appLayout = tv({
  slots: {
    base: 'flex w-full text-on-surface-app',

    // The region that sits beside the sidebar. The sidebar is always full
    // height; nothing is ever placed above it.
    frame: 'flex min-w-0 flex-1 flex-col',

    sidebar: [
      'shrink-0 flex-col',
      'transition-[width] duration-200',
      'motion-reduce:transition-none'
    ],
    sidebarHeader: 'flex h-12 shrink-0 items-center gap-2 px-3',
    sidebarBody: 'min-h-0 flex-1 overflow-y-auto px-2',
    sidebarFooter: 'shrink-0 px-2 py-2',

    navbar: 'flex h-12 shrink-0 items-center gap-2 px-3',

    main: 'min-w-0 flex-1',
    mainCard: 'flex min-h-0 min-w-0 flex-1 flex-col',
    pageHeader: 'flex shrink-0 items-center gap-2 px-4 py-3',

    // Literal `lg:block` here, not tied to `breakpoint`: the aside is a
    // wide-viewport affordance regardless of where the sidebar collapses.
    aside: 'hidden w-72 shrink-0 overflow-y-auto p-4 text-sm lg:block',

    skipLink: [
      ...focusVisibleRing,
      'sr-only focus:not-sr-only',
      'focus:absolute focus:left-2 focus:top-2 focus:z-50',
      'focus:rounded-md focus:bg-surface-card focus:px-3 focus:py-2',
      'focus:text-on-surface-card focus:shadow-sm'
    ]
  },

  variants: {
    variant: {
      inset: {
        base: 'bg-neutral-subtle',
        // Transparent, borderless: the sidebar floats on the tinted frame.
        sidebar: 'bg-transparent py-3 pl-3',
        mainCard:
          'overflow-hidden rounded-xl border border-neutral-muted bg-surface-app shadow-sm',
        navbar: 'border-b border-neutral-subtle',
        aside: 'border-l border-neutral-subtle'
      },
      attached: {
        base: 'bg-surface-app',
        sidebar: 'border-r border-neutral-muted bg-surface-card',
        // Edge-to-edge content: no card chrome.
        mainCard: 'bg-surface-app',
        navbar: 'border-b border-neutral-muted bg-surface-app',
        aside: 'border-l border-neutral-muted'
      }
    },

    // `frame`: the navbar spans the whole frame beside the sidebar, outside the
    // content card. `content`: it moves inside the card, above the content.
    navbarPlacement: {
      frame: {},
      content: {}
    },

    // Where the sidebar stops being an off-canvas drawer and becomes inline.
    // Literal strings per breakpoint: Tailwind generates nothing from an
    // interpolated class.
    breakpoint: {
      sm: { sidebar: 'hidden sm:flex' },
      md: { sidebar: 'hidden md:flex' },
      lg: { sidebar: 'hidden lg:flex' }
    },

    collapsed: {
      true: {},
      false: {}
    },

    // `content`: the shell fills the viewport and `main` scrolls itself.
    // `page`: the document scrolls and the sidebar sticks.
    scrollMode: {
      content: {
        base: 'h-dvh overflow-hidden',
        main: 'overflow-y-auto'
      },
      page: {
        base: 'min-h-dvh',
        sidebar: 'sticky top-0 h-dvh self-start'
      }
    }
  },

  compoundVariants: [
    { variant: 'attached', collapsed: true, class: { sidebar: 'w-16' } },
    { variant: 'attached', collapsed: false, class: { sidebar: 'w-64' } },
    { variant: 'inset', collapsed: true, class: { sidebar: 'w-[4.5rem]' } },
    { variant: 'inset', collapsed: false, class: { sidebar: 'w-60' } },

    // Inset keeps the card inside a padded gutter so the tinted frame shows.
    {
      variant: 'inset',
      class: { frame: 'p-3' }
    },
    // Navbar inside the card for `content`; on the frame it floats on the tint.
    {
      variant: 'inset',
      navbarPlacement: 'frame',
      class: { navbar: 'border-b-0' }
    },
    {
      variant: 'inset',
      scrollMode: 'page',
      class: { mainCard: 'overflow-visible' }
    }
  ],

  defaultVariants: {
    variant: 'inset',
    navbarPlacement: 'content',
    breakpoint: 'md',
    collapsed: false,
    scrollMode: 'content'
  }
});

export { appLayout };
export type AppLayoutSlots = keyof ReturnType<typeof appLayout>;
export type AppLayoutVariants = VariantProps<typeof appLayout>;
