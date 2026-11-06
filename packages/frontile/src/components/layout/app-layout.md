---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# AppLayout

The application shell: a sidebar, a navbar and a main content area. Reach for
it to give every page of an app the same frame.

## Import

```js
import { AppLayout } from 'frontile';
```

## Usage

`AppLayout` yields its parts. Each part places itself in the shell, so the
order you write them in does not matter.

By default the layout fills the viewport and `Main` scrolls on its own. The
demos on this page give the layout a fixed height so it fits on the page.

```gts preview collapsible
import { AppLayout, Button } from 'frontile';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    <AppLayout class='demo-app-layout' as |layout|>
      <layout.Navbar>
        <span class='flex-1 text-sm font-medium'>Access management</span>
        <Button @size='sm' @variant='ghost'>Help</Button>
      </layout.Navbar>
      <layout.Main>
        <layout.PageHeader
          @title='Users'
          @description='Everyone with access to this workspace.'
        />
        <p class='px-4 text-sm text-neutral-firm'>
          Page content scrolls inside the card.
        </p>
      </layout.Main>
    </AppLayout>
  </div>
</template>
```

## Variants

`inset`, the default, sets the content in a rounded card on a tinted frame, and
the sidebar sits directly on that frame with no border of its own. `attached`
runs the content edge to edge: the sidebar becomes its own bordered surface
and the navbar gets a border underneath instead of a card.

Below the `@breakpoint`, where the sidebar becomes a drawer, `inset` also goes
edge to edge: the frame's gutter and the card's rounded corners are dropped so
a phone gets the full width.

```gts preview collapsible
import { AppLayout } from 'frontile';
import { array } from '@ember/helper';
import { ViewIcon, SettingsIcon, SparklesIcon } from 'site/components/icons';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    {{#each (array 'inset' 'attached') as |variant|}}
      <AppLayout @variant={{variant}} class='demo-app-layout' as |layout|>
        <layout.Sidebar @label={{variant}} as |sidebar|>
          <sidebar.Header>
            <SparklesIcon class='shrink-0 text-primary' />
            <span class='truncate text-sm font-semibold' data-sidebar-label>
              Acme
            </span>
          </sidebar.Header>
          <sidebar.Body>
            <sidebar.Item @href='#overview' @icon={{ViewIcon}} @isActive={{true}}>
              Overview
            </sidebar.Item>
            <sidebar.Item @href='#settings' @icon={{SettingsIcon}}>
              Settings
            </sidebar.Item>
          </sidebar.Body>
        </layout.Sidebar>
        <layout.Navbar>
          <layout.SidebarToggle />
          <span class='text-sm font-medium'>{{variant}}</span>
        </layout.Navbar>
        <layout.Main>
          <layout.PageHeader
            @title='Projects'
            @description='Every project you can see.'
          />
        </layout.Main>
      </AppLayout>
    {{/each}}
  </div>
</template>
```

## Navbar placement

In the `inset` variant, `@navbarPlacement` decides whether the navbar is part
of the frame or part of the card. `frame`, the default, puts it on the tinted
background above the card. `content` makes it the card's first row.

```gts preview collapsible
import { AppLayout } from 'frontile';
import { array } from '@ember/helper';
import { ViewIcon, SettingsIcon, SparklesIcon } from 'site/components/icons';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    {{#each (array 'frame' 'content') as |placement|}}
      <AppLayout
        @navbarPlacement={{placement}}
        class='demo-app-layout'
        as |layout|
      >
        <layout.Sidebar @label={{placement}} as |sidebar|>
          <sidebar.Header>
            <SparklesIcon class='shrink-0 text-primary' />
            <span class='truncate text-sm font-semibold' data-sidebar-label>
              Acme
            </span>
          </sidebar.Header>
          <sidebar.Body>
            <sidebar.Item @href='#overview' @icon={{ViewIcon}} @isActive={{true}}>
              Overview
            </sidebar.Item>
            <sidebar.Item @href='#settings' @icon={{SettingsIcon}}>
              Settings
            </sidebar.Item>
          </sidebar.Body>
        </layout.Sidebar>
        <layout.Navbar>
          <span class='text-sm font-medium'>{{placement}}</span>
        </layout.Navbar>
        <layout.Main>
          <layout.PageHeader @title='Settings' />
        </layout.Main>
      </AppLayout>
    {{/each}}
  </div>
</template>
```

## Sidebar

`Sidebar` is a full-height `nav` landmark that takes the first column. It
yields `Header`, `Body` and `Footer` sections, `Item` links, `Folder` for a
collapsible set of items and `Group`. Give it a name with `@label` (default `Main`); if the page has more than one
navigation, each needs its own. Render one `Sidebar` per layout: the layout
gives its sidebar a fixed id, so a second one would repeat it.
`SidebarToggle` is a button that collapses and expands it.

By default the sidebar collapses to an icon rail. Each `Item`'s label is then
visually hidden but still names the link for screen readers, and it shows as
a tooltip on hover or focus. For your own markup in the header, body or
footer, wrap the text in `<span data-sidebar-label>` to hide it in the rail
the same way.

```gts preview collapsible
import { AppLayout } from 'frontile';
import { ViewIcon, SettingsIcon, SparklesIcon } from 'site/components/icons';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    <AppLayout class='demo-app-layout' as |layout|>
      <layout.Sidebar @label='Workspace' as |sidebar|>
        <sidebar.Header>
          <SparklesIcon class='shrink-0 text-primary' />
          <span class='truncate text-sm font-semibold' data-sidebar-label>
            Acme
          </span>
        </sidebar.Header>
        <sidebar.Body>
          <sidebar.Item @href='#overview' @icon={{ViewIcon}} @isActive={{true}}>
            Overview
          </sidebar.Item>
          <sidebar.Item @href='#settings' @icon={{SettingsIcon}}>
            Settings
          </sidebar.Item>
        </sidebar.Body>
      </layout.Sidebar>
      <layout.Navbar>
        <layout.SidebarToggle />
        <span class='text-sm font-medium'>Access management</span>
      </layout.Navbar>
      <layout.Main>
        <layout.PageHeader @title='Overview' />
      </layout.Main>
    </AppLayout>
  </div>
</template>
```

### Header

`Header` takes any markup: a logo, a product name, a link. Wrap text in
`<span data-sidebar-label>` so the icon rail hides it; the logo stays put.
Collapse this one with the toggle to see it.

```gts preview collapsible
import { AppLayout } from 'frontile';
import { ViewIcon, RocketIcon } from 'site/components/icons';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    <AppLayout @variant='attached' class='demo-app-layout' as |layout|>
      <layout.Sidebar @label='Custom header' as |sidebar|>
        <sidebar.Header>
          <RocketIcon class='shrink-0 text-primary' />
          <span class='truncate text-sm font-semibold' data-sidebar-label>
            Rocketry
          </span>
        </sidebar.Header>
        <sidebar.Body>
          <sidebar.Item @href='#launches' @icon={{ViewIcon}} @isActive={{true}}>
            Launches
          </sidebar.Item>
        </sidebar.Body>
      </layout.Sidebar>
      <layout.Navbar>
        <layout.SidebarToggle />
        <span class='text-sm font-medium'>Custom header</span>
      </layout.Navbar>
      <layout.Main />
    </AppLayout>
  </div>
</template>
```

### Items and groups

`Item` is a link with an optional `@icon` and its label as the block. It is
[NavItem](./nav-item) pre-bound to the sidebar, so it also knows about the icon
rail and the drawer. It takes the same routing arguments as `TabNav.Item`. With
`@href` it is a plain anchor and needs no router; set `@isActive` to mark the
current page. The active item has `aria-current="page"`.

`@isDisabled` drops the href so the link cannot be followed. `@isHidden`
renders nothing, for items the current user should not see.

Item styling lives on the item: style one with its own `@class`, which wins
over a conflicting theme class. `AppLayout`'s `@classes` style the layout's own
parts and do not reach items.

`Group` puts a heading over a set of items and names the group after it with
`@label`. In the rail the heading is visually hidden.

```gts preview collapsible
import { AppLayout } from 'frontile';
import {
  ViewIcon,
  StarIcon,
  ArchiveIcon,
  SettingsIcon,
  DeleteIcon
} from 'site/components/icons';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    <AppLayout class='demo-app-layout' as |layout|>
      <layout.Sidebar @label='Projects' as |sidebar|>
        <sidebar.Body>
          <sidebar.Group @label='Projects'>
            <sidebar.Item @href='#all' @icon={{ViewIcon}} @isActive={{true}}>
              All projects
            </sidebar.Item>
            <sidebar.Item @href='#starred' @icon={{StarIcon}}>
              Starred
            </sidebar.Item>
            <sidebar.Item
              @href='#archived'
              @icon={{ArchiveIcon}}
              @isDisabled={{true}}
            >
              Archived
            </sidebar.Item>
          </sidebar.Group>
          <sidebar.Group @label='Admin'>
            <sidebar.Item @href='#settings' @icon={{SettingsIcon}}>
              Settings
            </sidebar.Item>
            <sidebar.Item
              @href='#purge'
              @icon={{DeleteIcon}}
              @isHidden={{true}}
            >
              Purge data
            </sidebar.Item>
          </sidebar.Group>
        </sidebar.Body>
      </layout.Sidebar>
      <layout.Navbar>
        <layout.SidebarToggle />
        <span class='text-sm font-medium'>Projects</span>
      </layout.Navbar>
      <layout.Main>
        <layout.PageHeader @title='All projects' />
      </layout.Main>
    </AppLayout>
  </div>
</template>
```

### Folders

`Folder` is [NavFolder](./nav-folder) pre-bound to the sidebar: a labelled
trigger that opens and closes a set of items, one level deep. Give it a
`@label` and an optional `@icon`, and write its items as `folder.Item`. It
opens by itself when it holds the current page. In the icon rail it opens as a
flyout beside the rail, and in the drawer it is always inline.

```gts preview collapsible
import { AppLayout } from 'frontile';
import { ViewIcon, PackageIcon, SparklesIcon } from 'site/components/icons';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    <AppLayout class='demo-app-layout' as |layout|>
      <layout.Sidebar @label='Catalog' as |sidebar|>
        <sidebar.Header>
          <SparklesIcon class='shrink-0 text-primary' />
          <span class='truncate text-sm font-semibold' data-sidebar-label>
            Acme
          </span>
        </sidebar.Header>
        <sidebar.Body>
          <sidebar.Item @href='#overview' @icon={{ViewIcon}}>
            Overview
          </sidebar.Item>
          <sidebar.Folder @label='Products' @icon={{PackageIcon}} as |folder|>
            <folder.Item @href='#all-products' @isActive={{true}}>
              All products
            </folder.Item>
            <folder.Item @href='#categories'>Categories</folder.Item>
          </sidebar.Folder>
        </sidebar.Body>
      </layout.Sidebar>
      <layout.Navbar>
        <layout.SidebarToggle />
        <span class='text-sm font-medium'>Catalog</span>
      </layout.Navbar>
      <layout.Main>
        <layout.PageHeader @title='All products' />
      </layout.Main>
    </AppLayout>
  </div>
</template>
```

### Linking to routes

Pass `@route` (with `@model`, `@models` or `@query` as needed) and `Item`
renders an Ember `LinkTo` and asks the router whether it is active, so no
`@isActive` is needed. It is not rendered on this page, since the docs site has
no matching routes.

```gts
import { AppLayout } from 'frontile';
import { ViewIcon, UserIcon } from 'my-app/components/icons';

<template>
  <AppLayout as |layout|>
    <layout.Sidebar as |sidebar|>
      <sidebar.Body>
        <sidebar.Item @route='dashboard' @icon={{ViewIcon}}>
          Dashboard
        </sidebar.Item>
        <sidebar.Item @route='users.show' @model={{@currentUser.id}} @icon={{UserIcon}}>
          My profile
        </sidebar.Item>
      </sidebar.Body>
    </layout.Sidebar>
    <layout.Main>{{outlet}}</layout.Main>
  </AppLayout>
</template>
```

`@isActive` always wins over the router. The router counts a route as active
while any of its child routes is, so `@route='users'` stays active on
`users.show`; pass `@isActive` if only the exact route should light up.

### Collapse modes

`@collapsible` sets what collapsing does. `icon`, the default, shrinks the
sidebar to a rail. `offcanvas` hides it entirely while collapsed. `none` keeps
it expanded and ignores collapse.

```gts preview collapsible
import { AppLayout } from 'frontile';
import { array } from '@ember/helper';
import { ViewIcon } from 'site/components/icons';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    {{#each (array 'icon' 'offcanvas' 'none') as |mode|}}
      <AppLayout
        @defaultSidebarCollapsed={{true}}
        class='demo-app-layout'
        as |layout|
      >
        <layout.Sidebar @collapsible={{mode}} as |sidebar|>
          <sidebar.Body>
            <sidebar.Item @href='#home' @icon={{ViewIcon}}>Home</sidebar.Item>
          </sidebar.Body>
        </layout.Sidebar>
        <layout.Navbar>
          <layout.SidebarToggle />
          <span class='text-sm font-medium'>collapsible: {{mode}}</span>
        </layout.Navbar>
        <layout.Main />
      </AppLayout>
    {{/each}}
  </div>
</template>
```

### Sidebar size

`@size` picks the sidebar's width from a named preset: `default`, or `rail`, a
narrow column (80px) for a stack of icon-over-label items. A rail is meant to
stay put, so pair it with `@collapsible="none"`. The size is a preset, not a
length: for any other width, pass a width utility through `class` and set
`--app-sidebar-width` yourself if you read it.

```gts preview collapsible
import { AppLayout } from 'frontile';
import { ViewIcon } from 'site/components/icons';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    <AppLayout @variant='attached' class='demo-app-layout' as |layout|>
      <layout.Sidebar @size='rail' @collapsible='none' as |sidebar|>
        <sidebar.Body>
          <sidebar.Item
            @href='#home'
            @layout='stacked'
            @icon={{ViewIcon}}
            @shortLabel='Home'
          >Home</sidebar.Item>
          <sidebar.Item
            @href='#reports'
            @layout='stacked'
            @icon={{ViewIcon}}
            @shortLabel='Reports'
          >Reports</sidebar.Item>
          <sidebar.Item
            @href='#settings'
            @layout='stacked'
            @icon={{ViewIcon}}
            @shortLabel='Settings'
          >Settings</sidebar.Item>
        </sidebar.Body>
      </layout.Sidebar>
      <layout.Navbar>
        <span class='text-sm font-medium'>size: rail</span>
      </layout.Navbar>
      <layout.Main />
    </AppLayout>
  </div>
</template>
```

### Sidebar side

`@sidebarSide="end"` on `AppLayout` moves the sidebar to the last column. The
side is logical, so `start` is the right side in a right-to-left document. In
the `attached` variant the sidebar's border moves to the side facing the
content.

```gts preview collapsible
import { AppLayout } from 'frontile';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    <AppLayout
      @variant='attached'
      @sidebarSide='end'
      class='demo-app-layout'
      as |layout|
    >
      <layout.Sidebar as |sidebar|>
        <sidebar.Body>
          <sidebar.Item @href='#home'>Home</sidebar.Item>
        </sidebar.Body>
      </layout.Sidebar>
      <layout.Navbar>
        <span class='flex-1 text-sm font-medium'>Sidebar on the end</span>
        <layout.SidebarToggle />
      </layout.Navbar>
      <layout.Main />
    </AppLayout>
  </div>
</template>
```

### Mobile

Below `@breakpoint` (`sm` 40rem, `md` 48rem by default, `lg` 64rem) the sidebar
leaves the grid and opens as a drawer instead. These are Tailwind's default
breakpoints, and the layout measures them in JavaScript: an app that changes
`--breakpoint-sm`, `--breakpoint-md` or `--breakpoint-lg` in its theme moves
the CSS but not the layout's switch, so the two can disagree.

Below the breakpoint `SidebarToggle` opens the drawer, so on its own it covers
every width. For a separate menu button on narrow screens, put a `MenuToggle`
in the navbar, top-left by convention. `MenuToggle` shows only below the
breakpoint; to show only one button at each width, hide `SidebarToggle` below
it with `@classes`, as this demo does.

The drawer shows the same `Sidebar` block, so you write the sidebar once. It
slides in from the sidebar's side (`@sidebarSide`, following the document's
direction), always expanded. It closes on Escape, on a click outside it, from
its close button, when an `Item` in it is clicked, or when the window grows
past the breakpoint. The `Sidebar` block remounts whenever the window crosses
the breakpoint, so any state held by the components inside it starts over.

Narrow the window to below 48rem to open this one.

```gts preview collapsible
import { hash } from '@ember/helper';
import { AppLayout } from 'frontile';
import { ViewIcon, SettingsIcon, SparklesIcon } from 'site/components/icons';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    <AppLayout
      class='demo-app-layout'
      @classes={{hash sidebarToggle='hidden md:inline-flex'}}
      as |layout|
    >
      <layout.Sidebar @label='Workspace' as |sidebar|>
        <sidebar.Header>
          <SparklesIcon class='shrink-0 text-primary' />
          <span class='truncate text-sm font-semibold' data-sidebar-label>
            Acme
          </span>
        </sidebar.Header>
        <sidebar.Body>
          <sidebar.Item @href='#overview' @icon={{ViewIcon}}>
            Overview
          </sidebar.Item>
          <sidebar.Item @href='#settings' @icon={{SettingsIcon}}>
            Settings
          </sidebar.Item>
        </sidebar.Body>
      </layout.Sidebar>
      <layout.Navbar>
        <layout.MenuToggle />
        <layout.SidebarToggle />
        <span class='text-sm font-medium'>Access management</span>
      </layout.Navbar>
      <layout.Main>
        <layout.PageHeader @title='Overview' />
      </layout.Main>
    </AppLayout>
  </div>
</template>
```

### Bottom navigation

`@mobileNav="bottom"` replaces the drawer with a bar of tabs along the bottom
of the screen. Below `@breakpoint` the layout renders its yielded
[BottomNav](./bottom-nav) as a row under `Main`, and renders no `Sidebar`,
`MenuToggle` or `SidebarToggle`; the keyboard shortcut does nothing there. At
or above the breakpoint the layout shows the sidebar as usual and the
`BottomNav` renders nothing, so you write both and each appears at its own
width. An open More sheet closes when the window grows past the breakpoint.
The bar spans the full width of the layout and sits on its bottom edge in
both variants; with `inset` it covers the frame's gutter. The default,
`@mobileNav="drawer"`, is the drawer described above, and a `BottomNav` in it
never renders.

Place `<layout.BottomNav>` after `<layout.Main>`. With `@scrollMode="page"`
the bar sticks to the bottom of the viewport with `z-10`, so it rises above
in-page layers such as sticky table headers while overlays rendered later in
the page still cover it. This is a workaround: a theme-level z-index scale is
the proper fix and is a follow-up task. See
[BottomNav: Stacking order](./bottom-nav#stacking-order).

This demo shows a rail at desktop width. Narrow the window to below 48rem to
see the bar instead. The items and badge count are placeholder data.

```gts preview collapsible
import { AppLayout } from 'frontile';
import {
  ViewIcon,
  UserIcon,
  SettingsIcon,
  SparklesIcon
} from 'site/components/icons';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    <AppLayout
      @variant='attached'
      @mobileNav='bottom'
      class='demo-app-layout'
      as |layout|
    >
      <layout.Sidebar @size='rail' @collapsible='none' as |sidebar|>
        <sidebar.Body>
          <sidebar.Item
            @href='#home'
            @layout='stacked'
            @icon={{ViewIcon}}
            @isActive={{true}}
          >Home</sidebar.Item>
          <sidebar.Item
            @href='#people'
            @layout='stacked'
            @icon={{UserIcon}}
            @badge={{2}}
          >People</sidebar.Item>
          <sidebar.Item
            @href='#settings'
            @layout='stacked'
            @icon={{SettingsIcon}}
          >Settings</sidebar.Item>
        </sidebar.Body>
      </layout.Sidebar>
      <layout.Navbar>
        <SparklesIcon class='shrink-0 text-primary' />
        <span class='text-sm font-medium'>Acme</span>
      </layout.Navbar>
      <layout.Main>
        <layout.PageHeader @title='Home' />
      </layout.Main>
      <layout.BottomNav as |bar|>
        <bar.Item @href='#home' @icon={{ViewIcon}} @isActive={{true}}>
          Home
        </bar.Item>
        <bar.Item @href='#people' @icon={{UserIcon}} @badge={{2}}>
          People
        </bar.Item>
        <bar.More as |more|>
          <more.Item @href='#settings' @icon={{SettingsIcon}}>
            Settings
          </more.Item>
        </bar.More>
      </layout.BottomNav>
    </AppLayout>
  </div>
</template>
```

### Platform-style navigation

A rail with stacked icon-over-label items on desktop and a top bar, tab bar and
More sheet on a phone, built from the parts above: `@size="rail"` on the
sidebar, `@layout="stacked"` with `@shortLabel` on its items, a `Navbar` as
the phone top bar, and a `BottomNav` with a `More` tab. The full label is the
accessible name; `@shortLabel` is the visible text. `class="theme-inverse"`
on the sidebar flips it to the opposite color scheme.

The brandmark, account tile and avatar are plain markup: Frontile has no
account switcher or profile menu, so put your own in the sidebar's header and
footer and in the `Navbar`. Which item is active is a tracked value passed to
`@isActive`, so the demo needs no router; in an app, pass `@route` and the
router decides. Narrow the window to below 48rem to see the phone layout. All
names and the badge count are made-up placeholder data.

```gts preview collapsible
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import { AppLayout } from 'frontile';
import {
  ViewIcon,
  PackageIcon,
  BookIcon,
  StarIcon,
  UserIcon,
  SearchIcon,
  SparklesIcon
} from 'site/components/icons';

const PAGES = [
  {
    id: 'overview',
    label: 'Overview',
    short: 'Overview',
    icon: ViewIcon,
    badge: 2
  },
  { id: 'services', label: 'Services', short: 'Services', icon: PackageIcon },
  { id: 'billing', label: 'Billing', short: 'Billing', icon: BookIcon },
  {
    id: 'marketplace',
    label: 'Marketplace',
    short: 'Marketplace',
    icon: StarIcon
  },
  {
    id: 'referrals',
    label: 'Referral program',
    short: 'Referrals',
    icon: UserIcon
  },
  { id: 'support', label: 'Support', short: 'Support', icon: SparklesIcon }
];

export default class PlatformNavExample extends Component {
  @tracked page = 'overview';

  go = (id: string): void => {
    this.page = id;
  };

  // The first five items are tabs; the rest go in the More sheet.
  get items() {
    return PAGES.map((p) => ({ ...p, isActive: p.id === this.page }));
  }

  get tabs() {
    return this.items.slice(0, 5);
  }

  get more() {
    return this.items.slice(5);
  }

  get title(): string {
    return PAGES.find((p) => p.id === this.page)?.label ?? '';
  }

  <template>
    <div class='demo-stack demo-stack--wide not-prose'>
      <AppLayout
        @variant='attached'
        @mobileNav='bottom'
        class='demo-app-layout'
        as |layout|
      >
        <layout.Sidebar
          @size='rail'
          @collapsible='none'
          @label='Main navigation'
          class='theme-inverse'
          as |sidebar|
        >
          <sidebar.Header>
            <div class='flex flex-col items-center gap-2 py-2'>
              <SparklesIcon class='text-primary' />
              <button
                type='button'
                class='text-xs'
                aria-label='Switch account · Sample account'
              >
                Sample account
              </button>
            </div>
          </sidebar.Header>
          <sidebar.Body>
            {{#each this.items as |item|}}
              <sidebar.Item
                @layout='stacked'
                @icon={{item.icon}}
                @shortLabel={{item.short}}
                @isActive={{item.isActive}}
                @badge={{item.badge}}
                @badgeLabel={{if item.badge '2 open orders'}}
                {{on 'click' (fn this.go item.id)}}
              >{{item.label}}</sidebar.Item>
            {{/each}}
          </sidebar.Body>
          <sidebar.Footer>
            <button
              type='button'
              aria-label='Your account'
              class='mx-auto block size-8 rounded-full bg-primary'
            ></button>
          </sidebar.Footer>
        </layout.Sidebar>
        <layout.Navbar class='md:hidden'>
          <SparklesIcon class='shrink-0 text-primary' />
          <span class='flex min-w-0 flex-col'>
            <span class='text-xs'>{{this.title}}</span>
            <span class='truncate text-sm font-medium'>Sample account</span>
          </span>
          <button type='button' aria-label='Search' class='ms-auto'>
            <SearchIcon />
          </button>
          <button
            type='button'
            aria-label='Your account'
            class='size-8 shrink-0 rounded-full bg-primary'
          ></button>
        </layout.Navbar>
        <layout.Main>
          <layout.PageHeader @title={{this.title}} />
        </layout.Main>
        <layout.BottomNav as |bar|>
          {{#each this.tabs as |item|}}
            <bar.Item
              @icon={{item.icon}}
              @badge={{item.badge}}
              @badgeLabel={{if item.badge '2 open orders'}}
              @isActive={{item.isActive}}
              {{on 'click' (fn this.go item.id)}}
            >{{item.label}}</bar.Item>
          {{/each}}
          <bar.More as |more|>
            {{#each this.more as |item|}}
              <more.Item
                @icon={{item.icon}}
                @isActive={{item.isActive}}
                {{on 'click' (fn this.go item.id)}}
              >{{item.label}}</more.Item>
            {{/each}}
          </bar.More>
        </layout.BottomNav>
      </AppLayout>
    </div>
  </template>
}
```

### Keyboard shortcut

<kbd>Cmd</kbd>+<kbd>B</kbd> (<kbd>Ctrl</kbd>+<kbd>B</kbd> outside Apple
platforms) toggles the sidebar: it collapses or expands it on wide screens and
opens or closes the drawer below the breakpoint. With focus inside a layout,
only that layout toggles. With focus on the page body, the shortcut toggles
every `AppLayout` on the page; turn it off on the others with
`@toggleShortcut={{false}}`. Pick another combination with `@toggleShortcut`,
such as `'mod+shift+s'`.

The shortcut does nothing while focus is in editable content
(`contenteditable`), where the browser's own <kbd>Cmd</kbd>+<kbd>B</kbd>
makes text bold, and it does not repeat while the keys are held down. With
`@mobileNav="bottom"` it does nothing below the breakpoint, where there is no
sidebar.

### Using the sidebar on its own

Outside an `AppLayout`, pass `@state` (and, if you want the `inset` look,
`@variant`). The sidebar is as tall as its container. Give `SidebarToggle` the
same `@state`, and `@controls` with the sidebar's id so `aria-controls` points
at it.

```gts preview collapsible
import Component from '@glimmer/component';
import { Sidebar, SidebarToggle, AppLayoutState } from 'frontile';

export default class StandaloneSidebarExample extends Component {
  state = new AppLayoutState();

  <template>
    <div class='not-prose flex h-48 gap-3'>
      <Sidebar
        @state={{this.state}}
        @label='Reports'
        id='standalone-sidebar'
        as |sidebar|
      >
        <sidebar.Body>
          <sidebar.Item @href='#daily'>Daily</sidebar.Item>
        </sidebar.Body>
      </Sidebar>
      <SidebarToggle @state={{this.state}} @controls='standalone-sidebar' />
    </div>
  </template>
}
```

## Aside

`Aside` is an optional panel beside `Main`, for details, filters or help. It
renders only while `asideOpen` is true. Put an `AsideToggle` at the end of the
navbar to open and close it.

From `lg` (64rem) up the aside is a column inside the card, and `Main` narrows
to make room. Below `lg` the same block renders in a right-side drawer
instead, so you write it once. The drawer closes on Escape, on a click outside
it, or from its close button, and `asideOpen` follows. The aside's breakpoint
is always `lg`: it does not follow the layout's `@breakpoint`, which only
moves the sidebar. With `@sidebarSide="end"` the aside moves to the start
side, so the two panels stay on opposite sides of the page.

When the window narrows below `lg` while the aside is open, the aside closes
(and `asideOpen` becomes `false`) instead of reopening as a drawer. Below
`lg`, `AsideToggle` still opens it as a drawer. A layout that starts with
`asideOpen` true on a narrow screen opens the drawer, so set
`@defaultAsideOpen` only where you know the window is wide.

Name the landmark with `@label` (default `Details`). The drawer uses the same
name.

```gts preview collapsible
import { AppLayout } from 'frontile';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    <AppLayout class='demo-app-layout' as |layout|>
      <layout.Navbar>
        <span class='text-sm font-medium'>Access management</span>
        <layout.AsideToggle class='ms-auto' />
      </layout.Navbar>
      <layout.Main>
        <layout.PageHeader @title='Roles' />
      </layout.Main>
      <layout.Aside @label='Role details'>
        <h2 class='font-semibold'>Administrator</h2>
        <p class='mt-1 text-neutral-firm'>Full access to every workspace.</p>
      </layout.Aside>
    </AppLayout>
  </div>
</template>
```

## Page header

`PageHeader` is the title row at the top of a page. Place it inside `Main`.
It takes a `@title` and a `@description`; buttons for the page go in the
`<:actions>` block, and anything else under the title goes in `<:default>`.

```gts preview collapsible
import { AppLayout, Button } from 'frontile';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    <AppLayout class='demo-app-layout' as |layout|>
      <layout.Navbar>
        <span class='text-sm font-medium'>Access management</span>
      </layout.Navbar>
      <layout.Main>
        <layout.PageHeader
          @title='Roles'
          @description='Roles group the permissions you grant to people.'
        >
          <:actions>
            <Button @size='sm' @variant='outline'>Export</Button>
            <Button @size='sm' @color='primary'>New role</Button>
          </:actions>
          <:default>
            <span class='text-xs text-neutral-firm'>12 roles</span>
          </:default>
        </layout.PageHeader>
      </layout.Main>
    </AppLayout>
  </div>
</template>
```

## Sizing tokens

The layout publishes its main sizes as CSS custom properties on its root
element, so your own parts can line up with the shell:

| Property                 | Value                                                             |
| ------------------------ | ----------------------------------------------------------------- |
| `--app-navbar-height`    | `3rem`: the height of the navbar and of the sidebar header        |
| `--app-sidebar-width`    | The sidebar's drawn width, including the `inset` variant's gutter |
| `--app-bottomnav-height` | The bottom bar's height, including the safe-area inset            |

`--app-sidebar-width` is `16rem` expanded and `4rem` collapsed in the
`attached` variant, and `15rem` and `4.5rem` in `inset`. With `@size="rail"` it
is `5rem` (`attached`) or `5.75rem` (`inset`, including the gutter). It is `0px` when there
is no sidebar column: the layout has no `Sidebar`, the viewport is below the
breakpoint and the sidebar is a drawer, or the sidebar is collapsed with
`@collapsible="offcanvas"`.

The sidebar sizes itself and does not read the token, so it is for your own
styles. It is set after the first render, and is `0px` until a `Sidebar`
registers with the layout. Where a flash matters, give it a fallback, such as
`var(--app-sidebar-width, 0px)`.

This bar is fixed under the navbar and starts beside the sidebar, whatever
state the sidebar is in:

```gts
<div
  class='fixed end-0 z-10'
  style='top: var(--app-navbar-height, 3rem); inset-inline-start: var(--app-sidebar-width, 0px);'
>
  Filters
</div>
```

`--app-bottomnav-height` is `3.75rem` plus the device's bottom safe-area
inset (or `--bottomnav-safe-area`, when set) while a `BottomNav` is shown, and
`0px` otherwise: in the default drawer mode, at or above the breakpoint, or
with no `BottomNav` in the layout. Like `--app-sidebar-width`, it is set after
the first render. Use it to keep your own fixed elements, such as a floating
action button, clear of the bar:

```gts
<div
  class='fixed end-4'
  style='bottom: calc(var(--app-bottomnav-height, 0px) + 1rem);'
>
  New
</div>
```

## Scrolling

With `@scrollMode='content'`, the default, the layout is exactly the height
of the viewport and `Main` scrolls. With `@scrollMode='page'` the layout grows
with its content and the document scrolls instead, while the sidebar sticks
to the top of the viewport (inside the frame's gutter with `inset`). A
`BottomNav` is the layout's last row in `content` mode and sticks to the
bottom of the viewport in `page` mode.

## State

The layout tracks three values: `sidebarCollapsed`, `mobileSidebarOpen` and
`asideOpen`. It yields them as `state`, together with methods to change them:
`toggleSidebar`, `collapseSidebar`, `expandSidebar`, `openMobileSidebar`,
`closeMobileSidebar`, `toggleAside` and `closeAside`. The methods can be passed
straight to `@onPress` or `{{on}}`.

Each value can be set three ways:

- Uncontrolled: `@defaultAsideOpen` (and `@defaultSidebarCollapsed`,
  `@defaultMobileSidebarOpen`) sets the starting value and the layout keeps
  track of changes.
- Controlled: `@asideOpen` sets the value. A toggle calls `@onAsideOpenChange`
  with the new value, and the layout changes once you update the argument.
- Shared: pass an `AppLayoutState` as `@state`. The layout reads from it and
  writes to it, and so can anything else that holds it. When `@state` is
  passed, the individual arguments and their callbacks are ignored.

```gts preview collapsible
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { AppLayout, Button } from 'frontile';

export default class ControlledAsideExample extends Component {
  @tracked asideOpen = false;

  setAsideOpen = (value: boolean) => {
    this.asideOpen = value;
  };

  <template>
    <div class='demo-stack demo-stack--wide not-prose'>
      <AppLayout
        @asideOpen={{this.asideOpen}}
        @onAsideOpenChange={{this.setAsideOpen}}
        class='demo-app-layout'
        as |layout|
      >
        <layout.Navbar>
          <span class='flex-1 text-sm font-medium'>Billing</span>
          <Button @size='sm' @onPress={{layout.state.toggleAside}}>
            Details
          </Button>
        </layout.Navbar>
        <layout.Main>
          <layout.PageHeader
            @title='Invoices'
            @description='Details panel: {{if this.asideOpen "open" "closed"}}'
          />
        </layout.Main>
      </AppLayout>
    </div>
  </template>
}
```

### Triggering the layout from another component

To open or close parts of the layout from a component that is not inside the
`AppLayout` block, create an `AppLayoutState` and pass it to both. Store it
wherever suits the app, such as a service or a controller property. Each
`AppLayout` has its own state, so two layouts on one page stay independent.

```gts preview collapsible
import Component from '@glimmer/component';
import type { TOC } from '@ember/component/template-only';
import { AppLayout, AppLayoutState, Button } from 'frontile';

const DetailsToggle: TOC<{ Args: { state: AppLayoutState } }> = <template>
  <Button @size='sm' @onPress={{@state.toggleAside}}>
    {{if @state.asideOpen 'Hide details' 'Show details'}}
  </Button>
</template>;

export default class SharedStateExample extends Component {
  state = new AppLayoutState();

  <template>
    <div class='demo-stack demo-stack--wide not-prose'>
      <DetailsToggle @state={{this.state}} />

      <AppLayout @state={{this.state}} class='demo-app-layout' as |layout|>
        <layout.Navbar>
          <span class='text-sm font-medium'>Reports</span>
        </layout.Navbar>
        <layout.Main>
          <layout.PageHeader
            @title='Monthly report'
            @description='Details panel: {{if layout.state.asideOpen "open" "closed"}}'
          />
        </layout.Main>
      </AppLayout>
    </div>
  </template>
}
```

## Putting it together

Every part in one layout, driven by one `AppLayoutState`: a sidebar with
items and a group, both toggles, a navbar, a page header, the main content,
and an aside with its toggle. Narrow the window to see the drawers.

```gts preview collapsible
import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { AppLayout, AppLayoutState, Button } from 'frontile';
import {
  ViewIcon,
  StarIcon,
  SettingsIcon,
  SparklesIcon
} from 'site/components/icons';

export default class FullAppLayoutExample extends Component {
  state = new AppLayoutState();

  <template>
    <div class='demo-stack demo-stack--wide not-prose'>
      <AppLayout
        @state={{this.state}}
        @classes={{hash sidebarToggle='hidden md:inline-flex'}}
        class='demo-app-layout'
        as |layout|
      >
        <layout.Sidebar @label='Workspace' as |sidebar|>
          <sidebar.Header>
            <SparklesIcon class='shrink-0 text-primary' />
            <span class='truncate text-sm font-semibold' data-sidebar-label>
              Acme
            </span>
          </sidebar.Header>
          <sidebar.Body>
            <sidebar.Item @href='#all' @icon={{ViewIcon}} @isActive={{true}}>
              All projects
            </sidebar.Item>
            <sidebar.Group @label='Saved'>
              <sidebar.Item @href='#starred' @icon={{StarIcon}}>
                Starred
              </sidebar.Item>
            </sidebar.Group>
          </sidebar.Body>
          <sidebar.Footer>
            <sidebar.Item @href='#settings' @icon={{SettingsIcon}}>
              Settings
            </sidebar.Item>
          </sidebar.Footer>
        </layout.Sidebar>
        <layout.Navbar>
          <layout.MenuToggle />
          <layout.SidebarToggle />
          <span class='text-sm font-medium'>Projects</span>
          <layout.AsideToggle class='ms-auto' />
        </layout.Navbar>
        <layout.Main>
          <layout.PageHeader
            @title='All projects'
            @description='Everything in this workspace.'
          >
            <:actions>
              <Button @size='sm' @color='primary'>New project</Button>
            </:actions>
          </layout.PageHeader>
          <p class='px-4 text-sm text-neutral-firm'>
            Sidebar collapsed: {{if this.state.sidebarCollapsed 'yes' 'no'}}.
            Details open: {{if this.state.asideOpen 'yes' 'no'}}.
          </p>
        </layout.Main>
        <layout.Aside @label='Project details'>
          <h2 class='font-semibold'>All projects</h2>
          <p class='mt-1 text-neutral-firm'>12 projects, 3 starred.</p>
        </layout.Aside>
      </AppLayout>
    </div>
  </template>
}
```

## Accessibility

- `Navbar` renders a `header` landmark and `Main` renders the `main` landmark.
  Render one `AppLayout` per page so there is one of each.
- A "Skip to main content" link is the first focusable element. It is visible
  only while focused, and activating it moves focus to `Main`. Change its text
  with `@skipLinkLabel`, or remove it with `@skipLink={{false}}` if the app
  already provides one.
- `Sidebar` renders a `nav` landmark named by `@label` (default `Main`).
- `SidebarToggle` is a button named by `@label` (default "Toggle sidebar"). It
  sets `aria-expanded` to `true` while the sidebar is expanded (always, with
  `@collapsible="none"`) and `aria-controls` to the sidebar. Below the
  breakpoint it opens the drawer, and `aria-expanded` follows the drawer.
- `MenuToggle` is a button named by `@label` (default "Open menu"). It sets
  `aria-expanded` to `true` while the drawer is open and `aria-controls` to the
  sidebar.
- With `@mobileNav="bottom"`, below the breakpoint, the `BottomNav` is the
  page's navigation landmark: there is no sidebar `nav`, no drawer, and no
  `MenuToggle` or `SidebarToggle`. See [BottomNav](./bottom-nav) for the bar's
  roles and keys.
- The drawer is a modal dialog named by the sidebar's `@label`. Focus stays
  inside it while it is open. Closing it returns focus to the element that
  opened it: the toggle that opened it, otherwise the element that had focus
  when the shortcut was pressed (`MenuToggle` if focus was on the page body).
- `Item` is a link. The active item has `aria-current="page"`. A disabled
  item has no href and has `aria-disabled="true"`; with neither `@href` nor
  `@route` it is a disabled `<button>` instead. Its `@icon` is hidden from
  assistive technology, so the label is the link's name.
- `Folder` has a button trigger with `aria-expanded` and `aria-controls`, and
  its items sit in a `group` named by the trigger. In the icon rail it opens a
  flyout that follows the trigger in the DOM. <kbd>Escape</kbd> closes the
  flyout and returns focus to the trigger. See [NavFolder](./nav-folder).
- In the icon rail, `Item` labels, `Group` headings and text inside
  `[data-sidebar-label]` are visually hidden but remain in the accessibility
  tree, so each link keeps its name. Hovering or focusing an `Item` in the
  rail shows its label as a tooltip.
- `Group` renders a `group` named by its `@label`.
- `Aside` renders an `aside` landmark named by `@label` (default `Details`);
  in the drawer the dialog and the landmark inside it share that name.
- `AsideToggle` is a button named by `@label` (default "Toggle details"). It
  sets `aria-expanded` to `true` while the aside is open and `aria-controls` to
  the aside. Closing the drawer returns focus to the toggle.
- `PageHeader` renders `@title` as an `h1`.
- The inset card is decorative and hidden from assistive technology.

| Key              | Action                                                              |
| ---------------- | ------------------------------------------------------------------- |
| `Tab`            | From the top of the page, reveals and focuses the skip link         |
| `Enter`          | On the skip link, moves focus to the main content                   |
| `Cmd/Ctrl` + `B` | Collapses or expands the sidebar; below the breakpoint, opens or closes the drawer |
| `Escape`         | Closes the drawer (sidebar or aside)                                                 |

## Roadmap

These are not part of `AppLayout` yet. Each one would be added without breaking the current API.

| Not available yet | What you get today |
| --- | --- |
| Resizable sidebar and aside | Fixed widths |
| Persisted layout state | Pass `@state` and save it wherever you keep preferences, such as a cookie or `localStorage` |
| Sticky toolbar row under the navbar | One navbar row |
| Top navigation above the sidebar | The sidebar spans the full height, with nothing above it |
| Floating sidebar variant | The `inset` variant, which floats the sidebar on the frame |

## API

<Signature @component="AppLayout" />
<Signature @component="Sidebar" />
<Signature @component="NavItem" />
<Signature @component="NavFolder" />
<Signature @component="NavLink" />
<Signature @component="SidebarGroup" />
<Signature @component="SidebarToggle" />
<Signature @component="MenuToggle" />
<Signature @component="Aside" />
<Signature @component="AsideToggle" />
<Signature @component="Navbar" />
<Signature @component="Main" />
<Signature @component="PageHeader" />
