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
      sidebar: 'w-60 [--sidebar-rail:3rem]',
      token: '[--app-sidebar-width:15rem]'
    },
    collapsed: {
      sidebar: 'w-[3.75rem] [--sidebar-rail:3rem]',
      token: '[--app-sidebar-width:3.75rem]'
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

// The layout's icon buttons (sidebar, menu and aside toggles). Same radius and
// hover fill as a navigation row, so a toggle in the sidebar header reads as
// one of its rows. `neutral-muted` stays visible on the frame's ground as
// well as on the content surface.
const iconButton = [
  ...focusVisibleRing,
  'inline-flex size-9 shrink-0 items-center justify-center rounded-lg',
  'text-neutral-firm hover:bg-neutral-muted hover:text-neutral-strong'
];

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
      // Expanding, a label fades in once the width has mostly opened. It is
      // already visually hidden when collapsing, so the fade-out is unseen.
      'data-[collapsed=true]:[&_[data-sidebar-label]]:opacity-0',
      '[&_[data-sidebar-label]]:transition-opacity [&_[data-sidebar-label]]:delay-100 [&_[data-sidebar-label]]:duration-150',
      // `visibility` is listed so an offcanvas sidebar stays visible while it
      // closes and becomes hidden only once its width reaches 0.
      'transition-[width,padding,visibility] duration-200',
      'motion-reduce:transition-none motion-reduce:[&_[data-sidebar-label]]:transition-none'
    ],
    // The sidebar's `nav` inside the mobile drawer: always expanded, as tall
    // as the drawer.
    mobileSidebar: 'group/sidebar flex min-h-0 flex-1 flex-col',
    // The drawer's close button, merged over the Drawer's own position. The
    // drawer is portalled out of the layout, so the layout's custom
    // properties do not reach it: the values are the defaults written out.
    // The 36px button is centered in the 3rem header row (top 6px), and its
    // icon ends 22px from the edge, where a row's trailing content does.
    drawerCloseButton: 'top-1.5 right-3.5 rtl:right-auto rtl:left-3.5',
    // In the icon rail the header stacks its children: the brand on its
    // content line (where the items' icons sit, so it does not move when the
    // rail opens) and the `Toggle` under it. The end is the gutter, so the
    // toggle's fill lines up with a row's.
    //
    // The layout flips in one frame while the width eases over 200ms, so the
    // header carries its own motion. Its content box is always the navbar
    // height (`box-content`), so the row centers the same way in both states;
    // the stacked toggle hangs below it in `padding-bottom`, which eases on the
    // width's curve, so the body glides rather than jumps. The toggle fades in
    // at its new spot on collapse, and `overflow-x-clip` keeps a toggle that is
    // still arriving inside the narrow rail on expand (0.375rem of clip margin
    // leaves its focus ring visible). A header that is only a `Toggle` keeps
    // its one row.
    //
    // The two ends mirror each other: the brand's start and the end toggle's
    // icon are both half a rail minus half an icon from the sidebar's edge,
    // the same inset a row gives its icon and its trailing chevron or badge.
    // The end padding is that inset less the toggle's 0.5rem icon padding.
    sidebarHeader: [
      'box-content flex h-(--app-navbar-height,3rem) shrink-0 items-center gap-2 pb-0 ps-[calc((var(--sidebar-rail,4rem)_-_1.25rem)/2)] pe-[calc(var(--sidebar-rail,4rem)/2_-_1.125rem)]',
      'overflow-x-clip [overflow-clip-margin:0.375rem]',
      'transition-[padding-bottom] duration-200 motion-reduce:transition-none',
      'group-data-[collapsed=true]/sidebar:flex-col',
      'group-data-[collapsed=true]/sidebar:items-start',
      'group-data-[collapsed=true]/sidebar:*:shrink-0',
      // An `ml-auto` meant for the expanded row (a toggle pushed to the end)
      // would shove a stacked child aside.
      'group-data-[collapsed=true]/sidebar:*:mx-0',
      // Brand and toggle: the brand's top is where a 1.25rem icon centered in
      // the navbar height sits, so only the toggle travels.
      'group-data-[collapsed=true]/sidebar:has-[>*:not([data-part=sidebar-toggle])]:pb-10',
      'group-data-[collapsed=true]/sidebar:has-[>*:not([data-part=sidebar-toggle])]:*:first:mt-[calc((var(--app-navbar-height,3rem)-1.25rem)/2)]',
      'group-data-[collapsed=true]/sidebar:not-has-[>*:not([data-part=sidebar-toggle])]:justify-center',
      // The toggle's icon sits 0.5rem inside its fill; pull the fill back so
      // the icon lands on the content line, centered in the rail.
      'group-data-[collapsed=true]/sidebar:*:data-[part=sidebar-toggle]:-ms-2',
      'group-data-[collapsed=true]/sidebar:*:data-[part=sidebar-toggle]:animate-[frontile-fade-in_160ms_60ms_ease-out_backwards]',
      'group-data-[collapsed=true]/sidebar:*:data-[part=sidebar-toggle]:motion-reduce:animate-none'
    ],
    // Where a row's fill starts, from the sidebar's edge: `--sidebar-gutter`
    // (0.5rem by default, 0 in the inset variant, whose frame is the gutter).
    // The items' rail-centering, the header and the footer use it too.
    // `--sidebar-clip` is the room the scrolling body leaves for the focus
    // ring, which it would clip at its edge. It is padding with an equal
    // negative margin, so it does not move the rows: they start at the gutter.
    // The body is a column with the rows' 4px gap, so items placed straight in
    // it are spaced like those in a `Group` (a column that must not shrink).
    // With no header above it or footer below it, the body insets its first
    // and last rows by the gutter, as it does their sides. Inset's gutter is
    // 0: the frame's padding already holds them off the edge.
    sidebarBody: [
      '-mx-(--sidebar-clip,0px) flex min-h-0 flex-1 flex-col gap-1 overflow-y-auto *:shrink-0 px-[calc(var(--sidebar-gutter,0.5rem)+var(--sidebar-clip,0px))]',
      'first:pt-(--sidebar-gutter,0.5rem) last:pb-(--sidebar-gutter,0.5rem)'
    ],
    // A bare `Toggle` is offset so its icon sits on the content line.
    sidebarFooter: [
      'shrink-0 px-(--sidebar-gutter,0.5rem) py-2',
      '*:data-[part=sidebar-toggle]:ms-[calc((var(--sidebar-rail,4rem)_-_1.25rem)/2_-_var(--sidebar-gutter,0.5rem)_-_0.5rem)]'
    ],
    // `Sidebar.Group`: a labelled set of items. The label is visually hidden
    // in the rail like any other sidebar label.
    sidebarGroup: 'flex flex-col gap-1 py-2',
    sidebarGroupLabel: [
      'truncate ps-[calc((var(--sidebar-rail,4rem)_-_1.25rem)/2_-_var(--sidebar-gutter,0.5rem))] pe-2 pb-1 font-label text-label-2xs text-neutral-firm',
      'group-data-[collapsed=true]/sidebar:sr-only'
    ],
    sidebarToggle: iconButton,

    // Opens the mobile drawer. Hidden from `breakpoint` up (see below).
    menuToggle: iconButton,

    // The navbar's side padding is the page header's, so its text lines up
    // with the page's. A toggle at either end is pulled back by its 0.5rem
    // icon padding, so its icon lines up instead of its fill.
    navbar: [
      'col-[2/-1] row-start-1 flex h-(--app-navbar-height,3rem) min-w-0 items-center gap-2 px-4',
      '[&>[data-part$=-toggle]:first-child]:-ms-2 [&>[data-part$=-toggle]:last-child]:-me-2'
    ],

    main: 'col-start-2 row-start-2 min-h-0 min-w-0 outline-none',
    mainCard: 'pointer-events-none col-[2/-1]',

    // `BottomNav` inside the layout: the third row, across every column.
    // Merged over the bar's own (standalone, `fixed`) classes; the scroll
    // mode decides how it is positioned (see `scrollMode`).
    bottomNav: 'col-[1/-1] row-start-3',

    pageHeader: 'flex shrink-0 flex-wrap items-start gap-x-4 gap-y-2 px-4 py-4',
    pageHeaderContent: 'flex min-w-0 flex-1 flex-col gap-1',
    pageHeaderTitle: 'font-header text-header-lg text-neutral-strong',
    pageHeaderDescription: 'font-body text-body-sm text-neutral-firm',
    pageHeaderActions: 'flex shrink-0 items-center gap-2',

    // Literal `lg:block` here, not tied to `breakpoint`: the aside is a
    // wide-viewport affordance regardless of where the sidebar collapses.
    // Below `lg` the same block renders in a Drawer instead (`mobileAside`).
    aside:
      'col-start-3 row-start-2 hidden w-72 shrink-0 overflow-y-auto p-4 font-body text-body-sm lg:block',
    // The aside's `aside` element inside the drawer: as tall as the drawer.
    mobileAside: 'min-h-0 flex-1 overflow-y-auto p-4 font-body text-body-sm',
    asideToggle: iconButton,
    // PROTOTYPE: a `layout.Region` target. Its children lay out as if they
    // were children of the region's parent.
    region: 'contents',

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
      // The tinted frame shows through a gutter around the card. The content
      // is the lit surface in both schemes: on a `canvas` frame in light, and
      // in dark, where `app` is black, `canvas` content on an `app` frame.
      inset: {
        base: 'bg-surface-canvas p-3 dark:bg-surface-app',
        // Transparent, borderless: the sidebar floats on the tinted frame.
        // The frame's own padding is the gutter, so rows start at the sidebar's
        // edge. 0.375rem of clip room clears the 5px focus ring, which the
        // scrolling body would otherwise clip at its edge.
        sidebar:
          'bg-transparent [--sidebar-clip:0.375rem] [--sidebar-gutter:0px]',
        mainCard:
          'rounded-xl bg-surface-app shadow-sm ring-1 ring-neutral-muted dark:bg-surface-canvas',
        aside: 'border-s border-neutral-muted',
        // The bottom bar runs edge to edge: it pulls out over the frame's
        // side and bottom gutter (`p-3`).
        bottomNav: '-mx-3 -mb-3'
      },
      // The sidebar's ground and border are the layout's (see the compound
      // variants), so a standalone sidebar draws neither.
      attached: {
        base: 'bg-surface-app dark:bg-surface-canvas',
        // Edge-to-edge content: no card chrome. The element is not rendered.
        mainCard: 'hidden',
        navbar:
          'border-b border-neutral-muted bg-surface-app dark:bg-surface-canvas',
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
      // The sidebar closes to no width, so its contents fade rather than
      // being seen squeezed: out quickly on collapse, back in once the width
      // has mostly opened (the delay, cleared while collapsing).
      offcanvas: {
        sidebar: [
          'overflow-x-clip',
          '*:transition-opacity *:delay-100 *:duration-150 motion-reduce:*:transition-none'
        ]
      },
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
    // sits at the end of the first row: the header leaves room for it, and a
    // body with no header above it leaves that row empty.
    inDrawer: {
      true: {
        sidebarHeader: 'pe-[3.625rem]',
        sidebarBody: 'first:pt-(--app-navbar-height,3rem)'
      },
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
        // `isolate` keeps the z-indexes below (the sticky bar, the sidebar
        // lifted for a flyout) inside the shell. Overlays portal to the end
        // of the body with no z-index of their own, so they paint above the
        // whole shell by DOM order. Without it, any positive z-index in here
        // would paint over every Modal, Drawer and Popover.
        base: 'isolate min-h-dvh grid-rows-[auto_1fr]',
        // No z-index: nothing in `main` needs to pass under it, and overlays
        // (Modal, Drawer, Popover, Tooltip, a rail `NavFolder`'s menu) are
        // portalled out of the shell.
        sidebar: 'sticky top-0 h-dvh self-start',
        // The document scrolls, so the bar sticks to the bottom of the
        // viewport over the content. `z-10` lifts it over in-page layers
        // (z-10 is the highest used in content; a tie goes to the later
        // element, so the bar should come after `Main` in the DOM). The
        // root's `isolate` keeps it under overlays.
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
      class: { sidebar: '[--sidebar-gutter:0.3125rem]' }
    },
    // The rail's items are centered columns (icon over label), and the header
    // assumes a 4rem `--sidebar-rail` that this 5rem column does not set. Give
    // it the body's gutter on both sides and center its content, so a brand
    // sits over the same box as the items. A group label is centered likewise.
    {
      sidebarSize: 'rail',
      class: {
        sidebarHeader:
          'ps-(--sidebar-gutter,0.5rem) pe-(--sidebar-gutter,0.5rem) justify-center',
        sidebarGroupLabel: 'ps-0 pe-0 text-center'
      }
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
    // Attached: the sidebar sits on the frame's ground, the same
    // ground the inset variant's sidebar floats on, with a border on
    // the side facing the content. Only in a layout: standalone, the sidebar
    // is transparent and borderless, and its container decides both.
    {
      variant: 'attached',
      standalone: false,
      class: {
        sidebar:
          'border-e border-neutral-muted bg-surface-canvas dark:bg-surface-app'
      }
    },
    {
      variant: 'attached',
      standalone: false,
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

    // Offcanvas: collapsed is no width, no gutter, no border, and once the
    // width transition ends, `invisible`, so its links leave the tab order
    // and the accessibility tree. Comes after the width variants so `w-0`
    // wins.
    {
      collapsible: 'offcanvas',
      collapsed: true,
      class: {
        sidebar: 'invisible w-0 border-0 ps-0 pe-0 *:opacity-0 *:delay-0'
      }
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
        navbar: 'rounded-t-xl border-b border-neutral-muted',
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
