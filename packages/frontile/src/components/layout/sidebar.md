---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Sidebar

`Sidebar` is a full-height `nav` landmark that takes the first column. It
yields `Header`, `Body` and `Footer` sections, `Item` links, `Folder` for a
collapsible set of items, `Group` and `Toggle`. Give it a name with `@label`
(default `Main`); if the page has more than one navigation, each needs its own.
Render one `Sidebar` per layout: the layout gives its sidebar a fixed id, so a
second one would repeat it.

## Import

```js
import { Sidebar } from 'frontile';
```

## Usage

`Toggle` is the button that collapses and expands the sidebar. There is no
default toggle: place `<sidebar.Toggle />` where you want it, usually in
`Header` next to the brand. In the icon rail the header stacks its children,
so the brand sits above the toggle without any CSS from you. In the phone
drawer `Toggle` renders nothing (the drawer is always expanded and has its own
close button), so the same markup works at every width. Put a
`layout.MenuToggle` in the `Navbar` to open the drawer.

`layout.SidebarToggle` is the same button for use outside the sidebar, such as
in a `Navbar` or `PageHeader`; see [Collapse modes](#collapse-modes) for when
you need it.

By default the sidebar collapses to an icon rail. Each `Item`'s label is then
visually hidden but still names the link for screen readers, and it shows as
a tooltip on hover or focus. For your own markup in the header, body or
footer, wrap the text in `<span data-sidebar-label>` to hide it in the rail
the same way.

## Alignment and spacing

The header, body and footer share one set of lines, so they stack without any
padding of your own. A row's hover and active fill starts a small gutter in
from the sidebar's edge (`0.5rem` in `attached`; none in `inset`, where the
frame's padding is the gutter), so it never touches the edge of the window or
the content. Icons, header brand and group labels start at one content line,
which sits where the icon is centered in the collapsed rail, so nothing moves
when the sidebar collapses. A trailing icon or badge, and the header's
`Toggle`, end `1rem` from the edge.

Rows in the `Body`, a `Group` or a `Folder` are `0.25rem` apart. To line your
own markup up with the items, give a brand icon `size-5` and put other
content in a row styled like an item. A bare `Toggle` in the `Footer` lines up
by itself. In the header, put `class='ml-auto'` on a `Toggle` that follows the
brand, or `mr-auto` when the sidebar is on the end side; the collapsed rail
ignores both.

Collapsing and expanding move the header with the width. The header's height
eases, the brand stays where it is, the `Toggle` fades in under it when the
rail closes and slides out with the edge when it opens, and a
`<span data-sidebar-label>` fades in as the sidebar finishes opening. For the
brand to stay put, give it the icon size, `size-5`, as these demos do. With
`prefers-reduced-motion` they all switch instantly.

```gts preview collapsible
import { AppLayout } from 'frontile';
import { ViewIcon, SettingsIcon, SparklesIcon } from 'site/components/icons';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    <AppLayout class='demo-app-layout' as |layout|>
      <layout.Sidebar @label='Workspace' as |sidebar|>
        <sidebar.Header>
          <SparklesIcon class='size-5 shrink-0 text-primary' />
          <span class='truncate text-sm font-semibold' data-sidebar-label>
            Acme
          </span>
          <sidebar.Toggle class='ml-auto' />
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
        <layout.MenuToggle />
        <span class='text-sm font-medium'>Access management</span>
      </layout.Navbar>
      <layout.Main>
        <layout.PageHeader @title='Overview' />
      </layout.Main>
    </AppLayout>
  </div>
</template>
```

## Header

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
          <RocketIcon class='size-5 shrink-0 text-primary' />
          <span class='truncate text-sm font-semibold' data-sidebar-label>
            Acme
          </span>
          <sidebar.Toggle class='ml-auto' />
        </sidebar.Header>
        <sidebar.Body>
          <sidebar.Item @href='#launches' @icon={{ViewIcon}} @isActive={{true}}>
            Launches
          </sidebar.Item>
        </sidebar.Body>
      </layout.Sidebar>
      <layout.Navbar>
        <layout.MenuToggle />
        <span class='text-sm font-medium'>Custom header</span>
      </layout.Navbar>
      <layout.Main />
    </AppLayout>
  </div>
</template>
```

## Items and groups

`Item` is a link with an optional `@icon` and its label as the block. It is
aware of the icon rail and the drawer. It takes the same routing arguments as `TabNav.Item`. With
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
        <sidebar.Header><sidebar.Toggle class='ml-auto' /></sidebar.Header>
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
        <layout.MenuToggle />
        <span class='text-sm font-medium'>Projects</span>
      </layout.Navbar>
      <layout.Main>
        <layout.PageHeader @title='All projects' />
      </layout.Main>
    </AppLayout>
  </div>
</template>
```

## Folders

`Folder` is a labelled
trigger that opens and closes a set of items, one level deep. Give it a
`@label` and an optional `@icon`, and write its items as `folder.Item`. It
opens by itself when it holds the current page. In the icon rail it opens as a
[Dropdown](../collections/dropdown) menu of its items beside the rail, and in
the drawer it is always inline.

```gts preview collapsible
import { AppLayout } from 'frontile';
import { ViewIcon, PackageIcon, SparklesIcon } from 'site/components/icons';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    <AppLayout class='demo-app-layout' as |layout|>
      <layout.Sidebar @label='Catalog' as |sidebar|>
        <sidebar.Header>
          <SparklesIcon class='size-5 shrink-0 text-primary' />
          <span class='truncate text-sm font-semibold' data-sidebar-label>
            Acme
          </span>
          <sidebar.Toggle class='ml-auto' />
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
        <layout.MenuToggle />
        <span class='text-sm font-medium'>Catalog</span>
      </layout.Navbar>
      <layout.Main>
        <layout.PageHeader @title='All products' />
      </layout.Main>
    </AppLayout>
  </div>
</template>
```

## Item layouts

`@layout` sets how an `Item` arranges its icon and label.

- `inline`, the default, puts the label beside the icon. In a collapsed
  sidebar the label is hidden and the icon stays put.
- `stacked` puts a small label under the icon, with the current page marked by
  a rounded fill behind the icon. Give `@shortLabel` for the text shown under
  the icon; without it the block text is shown. A stacked item ignores the
  sidebar's collapsed state.
- `icon` shows the icon alone in a 44px hit target. The label shows as a
  tooltip on hover or focus, opening immediately with no delay. An icon item
  also ignores the collapsed state.

`stacked` and `icon` suit a `@size='rail'` sidebar.

```gts preview collapsible
import { Sidebar } from 'frontile';
import { ViewIcon, SettingsIcon, UserIcon } from 'site/components/icons';

<template>
  <div class='not-prose flex flex-wrap items-start gap-8 rounded-lg bg-surface-card p-4'>
    <Sidebar @collapsible='none' @label='Inline' class='w-48' as |sidebar|>
      <sidebar.Body>
        <sidebar.Item @href='#overview' @icon={{ViewIcon}} @isActive={{true}}>
          Overview
        </sidebar.Item>
        <sidebar.Item @href='#members' @icon={{UserIcon}}>
          Members
        </sidebar.Item>
      </sidebar.Body>
    </Sidebar>
    <Sidebar
      @collapsible='none'
      @size='rail'
      @label='Stacked'
      as |sidebar|
    >
      <sidebar.Body>
        <sidebar.Item
          @href='#overview'
          @layout='stacked'
          @icon={{ViewIcon}}
          @shortLabel='Home'
          @isActive={{true}}
        >
          Overview
        </sidebar.Item>
        <sidebar.Item
          @href='#settings'
          @layout='stacked'
          @icon={{SettingsIcon}}
          @shortLabel='Prefs'
        >
          Settings
        </sidebar.Item>
      </sidebar.Body>
    </Sidebar>
    <Sidebar
      @collapsible='none'
      @size='rail'
      @label='Icon only'
      as |sidebar|
    >
      <sidebar.Body>
        <sidebar.Item
          @href='#overview'
          @layout='icon'
          @icon={{ViewIcon}}
          @isActive={{true}}
        >
          Overview
        </sidebar.Item>
        <sidebar.Item @href='#members' @layout='icon' @icon={{UserIcon}}>
          Members
        </sidebar.Item>
      </sidebar.Body>
    </Sidebar>
  </div>
</template>
```

## Item badges

`@badge` shows a count or short status as a pill on the icon's top corner. An
item without an icon shows it at the end of the row. Nothing is shown for
`undefined`, `null`, `0` or an empty string. Screen readers hear the badge
after the label; set `@badgeLabel` to word it, such as "3 unread".

```gts preview
import { Sidebar } from 'frontile';
import { ViewIcon, UserIcon } from 'site/components/icons';

<template>
  <div class='not-prose'>
    <Sidebar @collapsible='none' @label='Inbox' class='w-48' as |sidebar|>
      <sidebar.Body>
        <sidebar.Item
          @href='#inbox'
          @icon={{ViewIcon}}
          @badge={{3}}
          @badgeLabel='3 unread'
        >
          Inbox
        </sidebar.Item>
        <sidebar.Item @href='#members' @icon={{UserIcon}}>
          Members
        </sidebar.Item>
      </sidebar.Body>
    </Sidebar>
  </div>
</template>
```

## Item routing and state

`@route` (with `@model`, `@models` or `@query` as needed) renders an Ember
`LinkTo` and lets the router decide whether the item is active. `@href` renders
a plain anchor. An item with neither is a `<button>`, for a row that runs your
own handler: attach it with the `on` modifier.

`@isActive` marks the current page and always wins over the router.
`@isDisabled` drops the `href` and dims the item; a disabled item with neither
`@href` nor `@route` is a disabled `<button>`. `@isHidden` renders nothing.

```gts preview
import { Sidebar } from 'frontile';
import { ArchiveIcon, DeleteIcon, StarIcon } from 'site/components/icons';

<template>
  <div class='not-prose'>
    <Sidebar @collapsible='none' @label='Projects' class='w-48' as |sidebar|>
      <sidebar.Body>
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
        <sidebar.Item @href='#purge' @icon={{DeleteIcon}} @isHidden={{true}}>
          Purge data
        </sidebar.Item>
      </sidebar.Body>
    </Sidebar>
  </div>
</template>
```

An `Item` renders an `<a>` (with `@route` or `@href`) or a `<button>`, and
inside a collapsed folder's menu an `<li>` menu row. Its `Element` is
`HTMLAnchorElement | HTMLButtonElement | HTMLLIElement`, so `...attributes` you
pass must suit all of them. It sets `aria-current`, `aria-disabled`,
`data-active` and `data-disabled` on whichever it renders.

## Folder behavior

A folder holding the current page opens by itself, on load and whenever one of
its items newly becomes the current page. It never reopens on its own after the
user closes it. A folder that is open when the page loads is open from the
first paint; opening and closing afterwards animates.

The trigger has no active styling: the item inside it is the current page, so
only that item is filled. The trigger still carries `data-active="true"` while
one of its items is active, as a hook if you want to style it yourself. It does
not get `aria-current`. A hidden item never makes the folder active.

`@defaultOpen` sets the initial state. For a folder you control, pass `@open`
and update it from `@onOpenChange`, which is called with the requested state on
every change, including an automatic open for the current page. A clicked
trigger then only calls `@onOpenChange`; the folder changes once you update
`@open`. `@onOpenChange` is also called for a folder you do not control, and
not when the menu of the collapsed icon rail opens or closes.

`@isHidden` hides the folder. A folder is also hidden when it has no items, or
when every item is hidden, so a section the user may not see leaves no empty
row behind.

In the collapsed icon rail the trigger shows only its icon, with the folder's
label as a tooltip on hover or focus. The folder opens as a
[Dropdown](../collections/dropdown) menu beside the rail instead: its items
become link items of the menu, with their icons and labels, and the current
page is marked. The menu has no heading; it is named by the trigger. It closes
when you follow an item, click outside, press <kbd>Escape</kbd> or tab out of
it, and expanding the sidebar closes it too. Opening it never changes the
inline state. In the rail the folder's items render as menu rows, so put only
`folder.Item` in the folder's block: any other content renders twice, once
hidden and once inside the menu. An item's own `@class` and
`data-part="nav-item"` do not apply to its menu row.

Folders also work inside a [BottomNav](./bottom-nav#more-sheet) `More` sheet,
as `more.Folder`. There they are always inline.

## Item and folder styling

An item's look comes from the theme. Add classes to one item with `@class`;
they are merged with the item's own, so a class that conflicts with a theme
class wins. `AppLayout`'s `@classes` does not reach items.

```gts preview
import { Sidebar } from 'frontile';
import { StarIcon } from 'site/components/icons';

<template>
  <div class='not-prose'>
    <Sidebar @collapsible='none' @label='Favorites' class='w-48' as |sidebar|>
      <sidebar.Body>
        <sidebar.Item @href='#starred' @icon={{StarIcon}} @class='text-primary'>
          Starred
        </sidebar.Item>
      </sidebar.Body>
    </Sidebar>
  </div>
</template>
```

## Linking to routes

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
        <sidebar.Item
          @route='users.show'
          @model={{@currentUser.id}}
          @icon={{UserIcon}}
        >
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

## Custom toggle placement

`Toggle` can go anywhere in the sidebar. This one sits in the `Footer`, below
the items. It is the same button wherever it is: it keeps its name and
`aria-expanded`, and it stays visible in the collapsed rail.

```gts preview collapsible
import { AppLayout } from 'frontile';
import { ViewIcon, SettingsIcon, SparklesIcon } from 'site/components/icons';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    <AppLayout class='demo-app-layout' as |layout|>
      <layout.Sidebar @label='Footer toggle' as |sidebar|>
        <sidebar.Header>
          <SparklesIcon class='size-5 shrink-0 text-primary' />
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
        <sidebar.Footer>
          <sidebar.Toggle />
        </sidebar.Footer>
      </layout.Sidebar>
      <layout.Navbar>
        <layout.MenuToggle />
        <span class='text-sm font-medium'>Toggle in the footer</span>
      </layout.Navbar>
      <layout.Main />
    </AppLayout>
  </div>
</template>
```

## Collapse modes

`@collapsible` sets what collapsing does. `icon`, the default, shrinks the
sidebar to a rail. `offcanvas` hides it entirely while collapsed. `none` keeps
it expanded and ignores collapse.

Each demo collapses with the `Toggle` in its sidebar header. An `offcanvas`
sidebar that is collapsed is not on screen, so a `Toggle` inside it cannot bring
it back. Show `layout.SidebarToggle` in the `Navbar` while the sidebar is
collapsed, as the `offcanvas` demo does with `layout.state.sidebarCollapsed`.

```gts preview collapsible
import { AppLayout } from 'frontile';
import { array, hash } from '@ember/helper';
import { ViewIcon } from 'site/components/icons';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    {{#each
      (array
        (hash name='icon')
        (hash name='offcanvas' reopen=true)
        (hash name='none')
      )
      as |mode|
    }}
      <AppLayout class='demo-app-layout' as |layout|>
        <layout.Sidebar @collapsible={{mode.name}} as |sidebar|>
          <sidebar.Header><sidebar.Toggle class='ml-auto' /></sidebar.Header>
          <sidebar.Body>
            <sidebar.Item @href='#home' @icon={{ViewIcon}}>Home</sidebar.Item>
          </sidebar.Body>
        </layout.Sidebar>
        <layout.Navbar>
          {{#if mode.reopen}}
            {{#if layout.state.sidebarCollapsed}}
              <layout.SidebarToggle />
            {{/if}}
          {{/if}}
          <span class='text-sm font-medium'>collapsible: {{mode.name}}</span>
        </layout.Navbar>
        <layout.Main />
      </AppLayout>
    {{/each}}
  </div>
</template>
```

## Sidebar size

`@size` picks the sidebar's width from a named preset: `default`, or `rail`, a
narrow column (80px) for a stack of icon-over-label items. A rail is meant to
stay put, so pair it with `@collapsible="none"`. The size is a preset, not a
length: for any other width, pass a width utility through `class` and set
`--app-sidebar-width` yourself if you read it.

In a rail the header centers its content over the same column as the items, so
a brand icon lines up with them.

```gts preview collapsible
import { AppLayout } from 'frontile';
import { ViewIcon } from 'site/components/icons';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    <AppLayout @variant='attached' class='demo-app-layout' as |layout|>
      <layout.Sidebar @size='rail' @collapsible='none' as |sidebar|>
        <sidebar.Header>
          <ViewIcon class='size-5 shrink-0 text-primary' />
        </sidebar.Header>
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

## Sidebar side

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
        <sidebar.Header><sidebar.Toggle class='mr-auto' /></sidebar.Header>
        <sidebar.Body>
          <sidebar.Item @href='#home'>Home</sidebar.Item>
        </sidebar.Body>
      </layout.Sidebar>
      <layout.Navbar>
        <layout.MenuToggle />
        <span class='text-sm font-medium'>Sidebar on the end</span>
      </layout.Navbar>
      <layout.Main />
    </AppLayout>
  </div>
</template>
```

## Mobile

Below `@breakpoint` (`sm` 40rem, `md` 48rem by default, `lg` 64rem) the sidebar
leaves the grid and opens as a drawer instead. These are Tailwind's default
breakpoints, and the layout measures them in JavaScript: an app that changes
`--breakpoint-sm`, `--breakpoint-md` or `--breakpoint-lg` in its theme moves
the CSS but not the layout's switch, so the two can disagree.

Put a `MenuToggle` in the navbar, top-left by convention, to open the drawer.
`MenuToggle` shows only below the breakpoint. `sidebar.Toggle` renders nothing
in the drawer, so a header that holds one needs no extra handling and phones
never see two toggles.

The drawer shows the same `Sidebar` block, so you write the sidebar once. It
slides in from the sidebar's side (`@sidebarSide`, following the document's
direction), always expanded. It closes on Escape, on a click outside it, from
its close button, when an `Item` in it is clicked, or when the window grows
past the breakpoint. The `Sidebar` block remounts whenever the window crosses
the breakpoint, so any state held by the components inside it starts over.

Narrow the window to below 48rem to open this one.

```gts preview collapsible
import { AppLayout } from 'frontile';
import { ViewIcon, SettingsIcon, SparklesIcon } from 'site/components/icons';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    <AppLayout class='demo-app-layout' as |layout|>
      <layout.Sidebar @label='Workspace' as |sidebar|>
        <sidebar.Header>
          <SparklesIcon class='size-5 shrink-0 text-primary' />
          <span class='truncate text-sm font-semibold' data-sidebar-label>
            Acme
          </span>
          <sidebar.Toggle class='ml-auto' />
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
        <span class='text-sm font-medium'>Access management</span>
      </layout.Navbar>
      <layout.Main>
        <layout.PageHeader @title='Overview' />
      </layout.Main>
    </AppLayout>
  </div>
</template>
```

## Bottom navigation

`@mobileNav="bottom"` replaces the drawer with a bar of tabs along the bottom
of the screen. Below `@breakpoint` the layout renders its yielded
[BottomNav](./bottom-nav) as a row under `Main`. There is no sidebar there, so
`Sidebar` (and its yielded `Toggle`), `MenuToggle` and `SidebarToggle` render
nothing. At or above the breakpoint the layout shows the sidebar as usual and
the `BottomNav` renders nothing, so you write both and each appears at its own
width. An open More sheet closes when the window grows past the breakpoint.
The bar spans the full width of the layout and sits on its bottom edge in
both variants; with `inset` it covers the frame's gutter. The default,
`@mobileNav="drawer"`, is the drawer described above, and a `BottomNav` in it
never renders.

Place `<layout.BottomNav>` after `<layout.Main>`. With `@scrollMode="page"`
the bar sticks to the bottom of the viewport with `z-10`, so it rises above
in-page layers such as sticky table headers. The layout root isolates that
`z-10`, so overlays still cover the bar. See
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
        <SparklesIcon class='size-5 shrink-0 text-primary' />
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

## Rail and bottom bar

A rail with stacked icon-over-label items on desktop that becomes a top bar, a
bottom tab bar and a More sheet on a phone, built from the parts above:
`@size="rail"` on the sidebar, `@layout="stacked"` with `@shortLabel` on its
items, a `Navbar` as the phone top bar, and a `BottomNav` with a `More` tab.
The full label is the accessible name; `@shortLabel` is the visible text.

The account tile and avatar are plain markup: Frontile has no account switcher
or profile menu, so put your own in the sidebar's header and footer and in the
`Navbar`. Which item is active is a tracked value passed to
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
    short: 'Market',
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

export default class RailNavExample extends Component {
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
          as |sidebar|
        >
          <sidebar.Header>
            <button
              type='button'
              aria-label='Switch account · Sample account'
              class='mx-auto flex size-9 items-center justify-center rounded-lg bg-neutral-soft text-xs font-medium'
            >
              SA
            </button>
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
          <SparklesIcon class='size-5 shrink-0 text-primary' />
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

## Using the sidebar on its own

Outside an `AppLayout`, pass `@state` (and, if you want the `inset` look,
`@variant`). The sidebar is as tall as its container. `sidebar.Toggle` inside it
toggles that `@state`. To put the toggle outside the sidebar, as here, give
`SidebarToggle` the same `@state`, and `@controls` with the sidebar's id so
`aria-controls` points at it.

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

## Accessibility

- The sidebar is a `nav` landmark named by `@label`.
- The active item has `aria-current="page"`. A disabled item has
  `aria-disabled="true"` and no `href`; a disabled button is also natively
  disabled and skipped by <kbd>Tab</kbd>.
- An item's `@icon` is hidden from assistive technology, so the label is the
  link's name. In the `stacked` layout `@shortLabel` is hidden from assistive
  technology; the full label still names the link, and so it does in the
  `icon` layout and in the icon rail.
- A `@badge` is hidden from assistive technology and its text is read after the
  label, so give `@badgeLabel` when the bare value is unclear.
- A folder's trigger is a native `button` named by `@label`. Inline it is a
  disclosure, with `aria-expanded` and `aria-controls` pointing at the items,
  which sit in a `group` named by the trigger. In the icon rail it is a menu
  button instead (`aria-haspopup`, `aria-expanded`, `aria-controls`), and the
  items are `menuitem`s of a `menu` named by the trigger; each holds a real
  link, so it still opens in a new tab. The trigger never has `aria-current`;
  the active item inside it does. A closed folder keeps its items out of the
  tab order and the accessibility tree.

### Folder keyboard

Inline:

| Key                                  | Action                                               |
| ------------------------------------ | ---------------------------------------------------- |
| <kbd>Enter</kbd> or <kbd>Space</kbd> | On the trigger, opens or closes the folder           |
| <kbd>Tab</kbd>                       | Moves through the trigger and, while open, its items |

In the icon rail:

| Key                                                                            | Action                                                                                           |
| ------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------ |
| <kbd>Enter</kbd>, <kbd>Space</kbd>, <kbd>ArrowDown</kbd> or <kbd>ArrowUp</kbd> | On the trigger, opens the menu                                                                   |
| Letters                                                                        | On the trigger, opens the menu; in the menu, moves to the next item whose label starts with them |
| <kbd>ArrowDown</kbd> or <kbd>ArrowUp</kbd>                                     | In the menu, moves between the items, skipping disabled ones                                     |
| <kbd>Enter</kbd>                                                               | Follows the item's link and closes the menu                                                      |
| <kbd>Escape</kbd>                                                              | Closes the menu and returns focus to the trigger                                                 |
| <kbd>Tab</kbd>                                                                 | Closes the menu and returns focus to the trigger                                                 |

Clicking outside an open menu closes it, and so does expanding the sidebar.

## API

<Signature @component="Sidebar" />
<Signature @component="NavItem" />
<Signature @component="NavFolder" />
<Signature @component="SidebarGroup" />
<Signature @component="SidebarToggle" />
