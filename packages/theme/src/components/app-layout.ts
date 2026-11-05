import { tv } from '../tw';
import { focusVisibleRing } from './shared';
import type { VariantProps } from '../tw';

// The shell is one CSS grid. The parts (sidebar, navbar, main, aside) are
// siblings in whatever order the consumer writes them, so each places itself
// in the grid rather than relying on a wrapper:
//
//            col 1      col 2              col 3
//   row 1  sidebar  |  navbar           |  navbar
//   row 2  sidebar  |  main             |  aside
//
// Empty columns and rows are `auto` and collapse to nothing, so a layout with
// no sidebar or aside needs no special casing. The inset card is a single
// decorative element (`mainCard`) drawn behind the parts in the same grid
// area; the parts round their own corners to match it.
const appLayout = tv({
  slots: {
    base: [
      'relative grid w-full text-on-surface-app',
      'grid-cols-[auto_minmax(0,1fr)_auto]'
    ],

    // `group/sidebar` plus `data-collapsed` on the element lets any descendant
    // react to the icon rail with `group-data-[collapsed=true]/sidebar:`.
    // Labels written as `<span data-sidebar-label>`, anywhere in the sidebar
    // (header, body or footer), are visually hidden in the icon rail but stay
    // in the accessibility tree (`sr-only`, never `display: none`).
    sidebar: [
      'group/sidebar col-start-1 row-[1/-1] shrink-0 flex-col',
      'data-[collapsed=true]:[&_[data-sidebar-label]]:sr-only',
      'transition-[width] duration-200',
      'motion-reduce:transition-none'
    ],
    // The sidebar's `nav` inside the mobile drawer: always expanded, as tall
    // as the drawer.
    mobileSidebar: 'group/sidebar flex min-h-0 flex-1 flex-col',
    sidebarHeader: 'flex h-12 shrink-0 items-center gap-2 px-3',
    // `Sidebar.Brand`: logo and name, meant for the header. In the rail only
    // the logo shows, centered like an item's icon; the text block is taken
    // out of the flow (`sr-only`) so it neither pushes the logo aside nor
    // leaves the accessibility tree.
    sidebarBrand: [
      ...focusVisibleRing,
      'flex min-w-0 flex-1 items-center gap-2 rounded-md',
      // Offset so the logo sits at the rail's center in both states (see
      // `navItem`): header padding is 0.75rem, the logo is 2rem wide.
      'ms-[calc((var(--sidebar-rail,4rem)_-_3.5rem)/2)]'
    ],
    // A fixed 2rem square. `data-tile="true"` tints it; without the tile the
    // consumer's logo is shown as is.
    sidebarBrandLogo: [
      'inline-flex size-8 shrink-0 items-center justify-center overflow-hidden rounded-lg',
      'data-[tile=true]:bg-primary data-[tile=true]:text-on-primary'
    ],
    sidebarBrandText: [
      'flex min-w-0 flex-1 flex-col leading-tight',
      'group-data-[collapsed=true]/sidebar:sr-only'
    ],
    sidebarBrandTitle: [
      'truncate text-sm font-semibold text-neutral-strong',
      'group-data-[collapsed=true]/sidebar:sr-only'
    ],
    sidebarBrandSubtitle: [
      'truncate text-xs text-neutral-firm',
      'group-data-[collapsed=true]/sidebar:sr-only'
    ],
    sidebarBody: 'min-h-0 flex-1 overflow-y-auto px-2',
    sidebarFooter: 'shrink-0 px-2 py-2',
    // `Sidebar.Group`: a labelled set of items. The label is visually hidden
    // in the rail like any other sidebar label.
    sidebarGroup: 'flex flex-col gap-0.5 py-2',
    sidebarGroupLabel: [
      'truncate px-2 pb-1 text-xs font-medium text-neutral-firm',
      'group-data-[collapsed=true]/sidebar:sr-only'
    ],
    sidebarToggle: [
      ...focusVisibleRing,
      'inline-flex size-9 shrink-0 items-center justify-center rounded-md',
      'text-neutral-firm hover:bg-neutral-subtle hover:text-neutral-strong'
    ],

    // Opens the mobile drawer. Hidden from `breakpoint` up (see below).
    menuToggle: [
      ...focusVisibleRing,
      'inline-flex size-9 shrink-0 items-center justify-center rounded-md',
      'text-neutral-firm hover:bg-neutral-subtle hover:text-neutral-strong'
    ],

    navbar: 'col-[2/-1] row-start-1 flex h-12 min-w-0 items-center gap-2 px-3',

    main: 'col-start-2 row-start-2 min-h-0 min-w-0 outline-none',
    mainCard: 'pointer-events-none col-[2/-1]',

    pageHeader: 'flex shrink-0 flex-wrap items-start gap-x-4 gap-y-2 px-4 py-4',
    pageHeaderContent: 'flex min-w-0 flex-1 flex-col gap-1',
    pageHeaderTitle: 'text-xl font-semibold text-neutral-strong',
    pageHeaderDescription: 'text-sm text-neutral-firm',
    pageHeaderActions: 'flex shrink-0 items-center gap-2',

    // Literal `lg:block` here, not tied to `breakpoint`: the aside is a
    // wide-viewport affordance regardless of where the sidebar collapses.
    // Below `lg` the same block renders in a Drawer instead (`mobileAside`).
    aside:
      'col-start-3 row-start-2 hidden w-72 shrink-0 overflow-y-auto p-4 text-sm lg:block',
    // The aside's `aside` element inside the drawer: as tall as the drawer.
    mobileAside: 'min-h-0 flex-1 overflow-y-auto p-4 text-sm',
    asideToggle: [
      ...focusVisibleRing,
      'inline-flex size-9 shrink-0 items-center justify-center rounded-md',
      'text-neutral-firm hover:bg-neutral-subtle hover:text-neutral-strong'
    ],

    skipLink: [
      ...focusVisibleRing,
      'sr-only focus:not-sr-only',
      'focus:absolute focus:start-2 focus:top-2 focus:z-50',
      'focus:rounded-md focus:bg-surface-app focus:px-3 focus:py-2',
      'focus:text-on-surface-app focus:shadow-md'
    ]
  },

  variants: {
    variant: {
      // The tinted frame shows through a gutter around the card.
      inset: {
        base: 'bg-neutral-subtle p-3',
        // Transparent, borderless: the sidebar floats on the tinted frame.
        sidebar: 'bg-transparent',
        mainCard:
          'rounded-xl bg-surface-app shadow-sm ring-1 ring-neutral-muted',
        aside: 'border-s border-neutral-subtle'
      },
      attached: {
        base: 'bg-surface-app',
        sidebar: 'border-e border-neutral-muted bg-surface-card',
        // Edge-to-edge content: no card chrome. The element is not rendered.
        mainCard: 'hidden',
        navbar: 'border-b border-neutral-muted bg-surface-app',
        aside: 'border-s border-neutral-muted'
      }
    },

    // `frame`: the navbar is a row on the tinted frame, above the card.
    // `content`: the card grows to cover the navbar row too.
    navbarPlacement: {
      frame: { mainCard: 'row-[2/3]' },
      content: { mainCard: 'row-[1/3]' }
    },

    // Where the sidebar stops being an off-canvas drawer and becomes inline.
    // Literal strings per breakpoint: Tailwind generates nothing from an
    // interpolated class.
    breakpoint: {
      sm: { sidebar: 'hidden sm:flex', menuToggle: 'sm:hidden' },
      md: { sidebar: 'hidden md:flex', menuToggle: 'md:hidden' },
      lg: { sidebar: 'hidden lg:flex', menuToggle: 'lg:hidden' }
    },

    collapsed: {
      true: {},
      false: {}
    },

    // `icon` shrinks to a rail, `offcanvas` hides entirely, `none` ignores
    // `collapsed` (the Sidebar passes `collapsed: false` for it).
    collapsible: {
      icon: {},
      offcanvas: {},
      none: {}
    },

    // `end` moves the sidebar to the last column and the aside to the first,
    // so the two stay on opposite sides of the page. The grid is reordered,
    // not the DOM: aside and main take columns 1 and 2, with the navbar and
    // card spanning both. Logical utilities flip all of this in a
    // right-to-left document.
    sidebarSide: {
      start: {},
      end: {
        sidebar: 'col-start-3',
        navbar: 'col-[1/-2]',
        main: 'col-start-2',
        mainCard: 'col-[1/-2]',
        aside: 'col-start-1'
      }
    },

    // The sidebar rendered in the mobile drawer. The drawer's close button
    // sits over the header's end edge, so the header leaves room for it.
    inDrawer: {
      true: { sidebarHeader: 'pe-16' },
      false: {}
    },

    // Outside an `AppLayout` there is no grid and no drawer breakpoint, so the
    // sidebar is always shown and as tall as its container.
    standalone: {
      true: { sidebar: 'flex h-full' },
      false: {}
    },

    // `content`: the shell fills the viewport and `main` scrolls itself.
    // `page`: the document scrolls and the sidebar sticks.
    scrollMode: {
      content: {
        base: 'h-dvh grid-rows-[auto_minmax(0,1fr)] overflow-hidden',
        main: 'overflow-y-auto'
      },
      page: {
        base: 'min-h-dvh grid-rows-[auto_1fr]',
        sidebar: 'sticky top-0 h-dvh self-start'
      }
    }
  },

  compoundVariants: [
    { variant: 'attached', collapsed: true, class: { sidebar: 'w-16' } },
    { variant: 'attached', collapsed: false, class: { sidebar: 'w-64' } },
    {
      variant: 'inset',
      collapsed: true,
      class: { sidebar: 'w-[4.5rem] [--sidebar-rail:3.75rem]' }
    },
    {
      variant: 'inset',
      collapsed: false,
      class: { sidebar: 'w-60 [--sidebar-rail:3.75rem]' }
    },

    // The inset sidebar floats on the frame, so it supplies its own spacing
    // to the card (the grid has no gap).
    {
      variant: 'inset',
      sidebarSide: 'start',
      class: { sidebar: 'pe-3' }
    },
    {
      variant: 'inset',
      sidebarSide: 'end',
      class: { sidebar: 'ps-3' }
    },
    // Attached: the border sits on the side facing the content.
    {
      variant: 'attached',
      sidebarSide: 'end',
      class: { sidebar: 'border-e-0 border-s' }
    },
    // The aside sits at the start with `sidebarSide="end"`; its border
    // faces the content, on its end side.
    {
      variant: 'inset',
      sidebarSide: 'end',
      class: { aside: 'border-s-0 border-e' }
    },
    {
      variant: 'attached',
      sidebarSide: 'end',
      class: { aside: 'border-s-0 border-e' }
    },

    // Page mode with the inset frame: the sticky sidebar sits inside the
    // root's `p-3` gutter, so it sticks below the top gutter and is shorter
    // by both gutters. With `top-0 h-dvh` the grid grew by the gutters and
    // the page always scrolled by 1.5rem.
    {
      variant: 'inset',
      scrollMode: 'page',
      class: { sidebar: 'top-3 h-[calc(100dvh-1.5rem)]' }
    },

    // Offcanvas: collapsed means gone, at every width. These come after
    // `standalone` and the breakpoint display classes so they win.
    {
      collapsible: 'offcanvas',
      collapsed: true,
      class: { sidebar: 'hidden' }
    },
    {
      collapsible: 'offcanvas',
      collapsed: true,
      breakpoint: 'sm',
      class: { sidebar: 'sm:hidden' }
    },
    {
      collapsible: 'offcanvas',
      collapsed: true,
      breakpoint: 'md',
      class: { sidebar: 'md:hidden' }
    },
    {
      collapsible: 'offcanvas',
      collapsed: true,
      breakpoint: 'lg',
      class: { sidebar: 'lg:hidden' }
    },

    // Main and navbar round their own corners to the card's, so content
    // scrolled inside `main` is clipped to the card's shape.
    {
      variant: 'inset',
      navbarPlacement: 'frame',
      class: { main: 'rounded-xl' }
    },
    {
      variant: 'inset',
      navbarPlacement: 'content',
      class: {
        navbar: 'rounded-t-xl border-b border-neutral-subtle',
        main: 'rounded-b-xl'
      }
    }
  ],

  defaultVariants: {
    variant: 'inset',
    navbarPlacement: 'frame',
    breakpoint: 'md',
    collapsed: false,
    collapsible: 'icon',
    sidebarSide: 'start',
    standalone: false,
    inDrawer: false,
    scrollMode: 'content'
  }
});

export { appLayout };
export type AppLayoutSlots = keyof ReturnType<typeof appLayout>;
export type AppLayoutVariants = VariantProps<typeof appLayout>;
