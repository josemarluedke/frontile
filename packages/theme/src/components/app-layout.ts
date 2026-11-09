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
//   row 3  bottom nav (all columns; only with `bottomNavRow: 'shown'`)
//
// Empty columns and rows are `auto` and collapse to nothing, so a layout with
// no sidebar or aside needs no special casing. The inset card is a single
// decorative element (`mainCard`) drawn behind the parts in the same grid
// area; the parts round their own corners to match it.
// The sidebar's drawn width per variant and collapse state, written once.
// `sidebar` is the sidebar's own width class; `token` sets the root's
// published `--app-sidebar-width` to the same length. The sidebar does NOT
// read the token: the token is `0px` until a `Sidebar` registers with the
// layout (after the first render), and the sidebar's width must not depend
// on that. Class names are literal strings so Tailwind can see them.
// The inset widths include the `pe-3`/`ps-3` gutter (border box).
// `rail` is the narrow preset for a stacked-label rail (icon over a short
// label). It is meant for `collapsible="none"`, so it has no collapsed row:
// collapsed widths are the default size's.
const sidebarWidths = {
  attached: {
    expanded: { sidebar: 'w-64', token: '[--app-sidebar-width:16rem]' },
    collapsed: { sidebar: 'w-16', token: '[--app-sidebar-width:4rem]' },
    rail: { sidebar: 'w-20', token: '[--app-sidebar-width:5rem]' }
  },
  inset: {
    expanded: {
      sidebar: 'w-60 [--sidebar-rail:3.75rem]',
      token: '[--app-sidebar-width:15rem]'
    },
    collapsed: {
      sidebar: 'w-[4.5rem] [--sidebar-rail:3.75rem]',
      token: '[--app-sidebar-width:4.5rem]'
    },
    // 80px plus the 12px `pe-3`/`ps-3` gutter.
    rail: {
      sidebar: 'w-[5.75rem]',
      token: '[--app-sidebar-width:5.75rem]'
    }
  }
} as const;

const sidebarWidthVariants = (['attached', 'inset'] as const).flatMap(
  (variant) => [
    // Collapsed widths are the same for every size.
    {
      variant,
      collapsed: true,
      class: { sidebar: sidebarWidths[variant].collapsed.sidebar }
    },
    {
      variant,
      collapsed: false,
      sidebarSize: 'default' as const,
      class: { sidebar: sidebarWidths[variant].expanded.sidebar }
    },
    {
      variant,
      collapsed: false,
      sidebarSize: 'rail' as const,
      class: { sidebar: sidebarWidths[variant].rail.sidebar }
    },
    {
      variant,
      sidebarColumn: 'shown' as const,
      sidebarSize: 'default' as const,
      class: { base: sidebarWidths[variant].expanded.token }
    },
    {
      variant,
      sidebarColumn: 'shown' as const,
      sidebarSize: 'rail' as const,
      class: { base: sidebarWidths[variant].rail.token }
    },
    {
      variant,
      sidebarColumn: 'collapsed' as const,
      class: { base: sidebarWidths[variant].collapsed.token }
    }
  ]
);

// Below the breakpoint the inset frame goes edge to edge: no gutter, no card
// chrome, and the bottom bar needs no negative margins to escape the gutter.
// Literal strings per breakpoint: Tailwind generates nothing from an
// interpolated class. `max-sm` etc. are the exact complement of `sm:` etc.
const edgeToEdge = {
  sm: {
    base: 'max-sm:p-0',
    card: 'max-sm:rounded-none max-sm:shadow-none max-sm:ring-0',
    radius: 'max-sm:rounded-none',
    bar: 'max-sm:mx-0 max-sm:mb-0'
  },
  md: {
    base: 'max-md:p-0',
    card: 'max-md:rounded-none max-md:shadow-none max-md:ring-0',
    radius: 'max-md:rounded-none',
    bar: 'max-md:mx-0 max-md:mb-0'
  },
  lg: {
    base: 'max-lg:p-0',
    card: 'max-lg:rounded-none max-lg:shadow-none max-lg:ring-0',
    radius: 'max-lg:rounded-none',
    bar: 'max-lg:mx-0 max-lg:mb-0'
  }
} as const;

const edgeToEdgeVariants = (['sm', 'md', 'lg'] as const).flatMap(
  (breakpoint) => {
    const e = edgeToEdge[breakpoint];
    return [
      {
        variant: 'inset' as const,
        breakpoint,
        class: { base: e.base, mainCard: e.card, bottomNav: e.bar }
      },
      {
        variant: 'inset' as const,
        breakpoint,
        navbarPlacement: 'frame' as const,
        class: { main: e.radius }
      },
      {
        variant: 'inset' as const,
        breakpoint,
        navbarPlacement: 'content' as const,
        class: { navbar: e.radius, main: e.radius }
      }
    ];
  }
);

const appLayout = tv({
  slots: {
    // Publishes the shell's sizes as custom properties, for the parts below
    // and for consumers (sticky offsets, custom parts):
    //
    // - `--app-navbar-height`: the height of the navbar and of the sidebar
    //   header, so the two stay on one row.
    // - `--app-sidebar-width`: the sidebar's drawn width, border box (it
    //   includes the inset variant's `pe-3`/`ps-3` gutter), set by the
    //   `sidebarColumn` variant below. Published for consumers only (the
    //   sidebar sizes itself): it settles after the first render, `0px` until
    //   a Sidebar registers, so use a fallback where a flash matters. `0px`
    //   when there is no sidebar column:
    //   no Sidebar in the layout, below the breakpoint, or collapsed with
    //   `collapsible="offcanvas"`.
    // - `--app-bottomnav-height`: the `BottomNav` bar's full height, the row
    //   plus the safe-area inset (the literals in `bottom-nav.ts`), set
    //   by the `bottomNavRow` variant below. `0px` when no bar is shown, so
    //   consumers can offset by it unconditionally.
    //
    // The navbar and sidebar header read `--app-navbar-height` (always set)
    // with a literal fallback for parts rendered outside an `AppLayout`.
    base: [
      'relative grid w-full text-on-surface-app',
      'grid-cols-[auto_minmax(0,1fr)_auto]',
      '[--app-navbar-height:3rem]'
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
    // In the icon rail the header stacks its children (logo above `Toggle`)
    // and grows taller than the navbar if it has to; its 12px side padding
    // leaves room for the 36px toggle in the 4rem rail.
    sidebarHeader: [
      'flex h-(--app-navbar-height,3rem) shrink-0 items-center gap-2 px-3',
      'group-data-[collapsed=true]/sidebar:h-auto',
      'group-data-[collapsed=true]/sidebar:min-h-(--app-navbar-height,3rem)',
      'group-data-[collapsed=true]/sidebar:flex-col',
      'group-data-[collapsed=true]/sidebar:justify-center',
      'group-data-[collapsed=true]/sidebar:py-2'
    ],
    // Side padding comes from `--sidebar-body-px` (0.5rem by default; the
    // inset variant sets it to 0), which the items' rail-centering uses too.
    sidebarBody:
      'min-h-0 flex-1 overflow-y-auto px-[var(--sidebar-body-px,0.5rem)]',
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

    navbar:
      'col-[2/-1] row-start-1 flex h-(--app-navbar-height,3rem) min-w-0 items-center gap-2 px-3',

    main: 'col-start-2 row-start-2 min-h-0 min-w-0 outline-none',
    mainCard: 'pointer-events-none col-[2/-1]',

    // `BottomNav` inside the layout: the third row, across every column.
    // Merged over the bar's own (standalone, `fixed`) classes; the scroll
    // mode decides how it is positioned (see `scrollMode`).
    bottomNav: 'col-[1/-1] row-start-3',

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
        // 0.375rem clears the 5px focus ring, which the scrolling body would
        // otherwise clip at its edge.
        sidebar: 'bg-transparent [--sidebar-body-px:0.375rem]',
        mainCard:
          'rounded-xl bg-surface-app shadow-sm ring-1 ring-neutral-muted',
        aside: 'border-s border-neutral-subtle',
        // The bottom bar runs edge to edge: it pulls out over the frame's
        // side and bottom gutter (`p-3`).
        bottomNav: '-mx-3 -mb-3'
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

    // What the layout's root reports for `--app-sidebar-width`: `shown` and
    // `collapsed` take the width from `variant` (compound variants below);
    // `none` is no sidebar column. Set by `AppLayout` only.
    sidebarColumn: {
      shown: {},
      collapsed: {},
      none: { base: '[--app-sidebar-width:0px]' }
    },

    // Whether the layout shows a `BottomNav` row: `@mobileNav="bottom"`,
    // below the breakpoint, with a `BottomNav` registered. `shown` adds the
    // third `auto` row (compound variants below) and publishes the bar's
    // height; the row height and safe-area expression must match `bottom-nav.ts`,
    // written out because Tailwind generates nothing from an interpolated class.
    // Set by `AppLayout` only.
    bottomNavRow: {
      shown: {
        base: '[--app-bottomnav-height:calc(3.75rem+var(--bottomnav-safe-area,env(safe-area-inset-bottom,0px)))]'
      },
      none: { base: '[--app-bottomnav-height:0px]' }
    },

    // The sidebar's width preset: `default`, or `rail` for a narrow
    // icon-over-label rail. Set by `Sidebar`, and by `AppLayout` for the root's
    // token. Defaults to `default` so existing callers are unchanged.
    sidebarSize: {
      default: {},
      rail: {}
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
        main: 'overflow-y-auto',
        // A plain grid row under `main`, which scrolls on its own.
        bottomNav: 'static'
      },
      page: {
        base: 'min-h-dvh grid-rows-[auto_1fr]',
        // No z-index: overlays (Modal, Drawer, Popover, Tooltip, a rail
        // `NavFolder`'s menu) have none and stack by coming later in the DOM,
        // so a lifted sidebar would cover them.
        sidebar: 'sticky top-0 h-dvh self-start',
        // The document scrolls, so the bar sticks to the bottom of the
        // viewport over the content. `z-10` is a workaround until the theme
        // has a z-index scale: it lifts the bar over in-page layers (z-10 is
        // the highest used in content) while overlays, which have no
        // z-index and stack by DOM order, still cover it. That only holds if
        // the bar comes after `Main` in the DOM.
        bottomNav: 'sticky bottom-0 z-10'
      }
    }
  },

  compoundVariants: [
    // The sidebar's own width and the root's `--app-sidebar-width` both come
    // from `sidebarWidths`, so they cannot drift.
    ...sidebarWidthVariants,

    // The rail is 5rem wide, so its body gives up some side padding to the
    // stacked labels. 0.3125rem still clears the 5px focus ring.
    {
      sidebarSize: 'rail',
      class: { sidebar: '[--sidebar-body-px:0.3125rem]' }
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

    // The bottom nav's row, after the navbar and main rows.
    {
      scrollMode: 'content',
      bottomNavRow: 'shown',
      class: { base: 'grid-rows-[auto_minmax(0,1fr)_auto]' }
    },
    {
      scrollMode: 'page',
      bottomNavRow: 'shown',
      class: { base: 'grid-rows-[auto_1fr_auto]' }
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
    },
    ...edgeToEdgeVariants
  ],

  defaultVariants: {
    variant: 'inset',
    navbarPlacement: 'frame',
    breakpoint: 'md',
    collapsed: false,
    collapsible: 'icon',
    sidebarColumn: 'shown',
    bottomNavRow: 'none',
    sidebarSide: 'start',
    sidebarSize: 'default',
    standalone: false,
    inDrawer: false,
    scrollMode: 'content'
  }
});

export { appLayout };
export type AppLayoutSlots = keyof ReturnType<typeof appLayout>;
export type AppLayoutVariants = VariantProps<typeof appLayout>;
