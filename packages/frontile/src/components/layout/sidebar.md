---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Sidebar

Vertical navigation for an app: links, groups and folders in a full-height
column that can collapse to an icon rail.

## Import

```js
import { Sidebar } from 'frontile';
```

## Usage

`Sidebar` yields its parts. Put `Item` links in `Body`, give each an `@href`
(or a `@route`) and its label as the block, and mark the current page with
`@isActive`. The sidebar is as tall as its container.

```gts preview
import { Sidebar } from 'frontile';

<template>
  <div class='not-prose h-56'>
    <Sidebar as |sidebar|>
      <sidebar.Body>
        <sidebar.Item @href='#inbox' @isActive={{true}}>Inbox</sidebar.Item>
        <sidebar.Item @href='#drafts'>Drafts</sidebar.Item>
        <sidebar.Item @href='#sent'>Sent</sidebar.Item>
      </sidebar.Body>
    </Sidebar>
  </div>
</template>
```

## Anatomy

- `Header`, `Body` and `Footer` stack top to bottom; `Body` takes the free
  space and scrolls. Header and footer hold your own markup, such as a brand
  or an account menu.
- `Item` is a link, or a button when it has neither `@href` nor `@route`.
- `Group` puts a heading over a set of items.
- `Folder` is a trigger that opens and closes a set of items.
- `Toggle` collapses and expands the sidebar. There is no default toggle:
  place it where you want it.

```gts preview collapsible
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { Sidebar } from 'frontile';
import {
  ViewIcon,
  StarIcon,
  PackageIcon,
  SettingsIcon,
  LogoutIcon,
  SparklesIcon
} from 'site/components/icons';

export default class SidebarAnatomyExample extends Component {
  @tracked signedOut = false;

  signOut = () => {
    this.signedOut = true;
  };

  <template>
    <div class='demo-stack demo-stack--wide not-prose'>
      <div
        class='flex h-96 overflow-hidden rounded-lg border border-neutral-soft'
      >
        <Sidebar @label='Workspace' as |sidebar|>
          <sidebar.Header>
            <SparklesIcon class='size-5 shrink-0 text-primary' />
            <span class='truncate text-sm font-semibold' data-sidebar-label>
              Acme
            </span>
            <sidebar.Toggle class='ml-auto' />
          </sidebar.Header>
          <sidebar.Body>
            <sidebar.Item
              @href='#overview'
              @icon={{ViewIcon}}
              @isActive={{true}}
            >
              Overview
            </sidebar.Item>
            <sidebar.Folder @label='Products' @icon={{PackageIcon}} as |folder|>
              <folder.Item @href='#all-products'>All products</folder.Item>
              <folder.Item @href='#categories'>Categories</folder.Item>
            </sidebar.Folder>
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
            <sidebar.Item @icon={{LogoutIcon}} {{on 'click' this.signOut}}>
              Sign out
            </sidebar.Item>
          </sidebar.Footer>
        </Sidebar>
        <p class='flex-1 p-4 text-sm text-neutral-firm'>
          {{if
            this.signedOut
            'Signed out.'
            'Collapse the sidebar with its toggle.'
          }}
        </p>
      </div>
    </div>
  </template>
}
```

## Items

`@icon` takes an icon component; the label is the block. An item with
`@href` is a plain anchor; with neither `@href` nor `@route` it is a
`<button>` for your own handler, attached with the `on` modifier, like
_Sign out_ above.

- `@isActive` marks the current page.
- `@isDisabled` dims the item and drops its `href`, so it cannot be followed.
- `@isHidden` renders nothing, for items the current user should not see.

```gts preview collapsible
import { Sidebar } from 'frontile';
import {
  ViewIcon,
  StarIcon,
  ArchiveIcon,
  DeleteIcon
} from 'site/components/icons';

<template>
  <div class='not-prose h-56'>
    <Sidebar @label='Projects' as |sidebar|>
      <sidebar.Body>
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
        <sidebar.Item @href='#purge' @icon={{DeleteIcon}} @isHidden={{true}}>
          Purge data
        </sidebar.Item>
      </sidebar.Body>
    </Sidebar>
  </div>
</template>
```

An item's element is an `<a>`, a `<button>`, or an `<li>` row inside a
collapsed folder's menu, so attributes you pass to it must suit all three.

### Badges

`@badge` shows a count or short status on the icon's corner, or at the end of
the row for an item without an icon. `0`, `null`, `undefined` and `''` show
nothing. Screen readers hear the badge after the label; `@badgeLabel` words
it, such as "3 unread".

```gts preview
import { Sidebar } from 'frontile';
import { BookIcon, UserIcon } from 'site/components/icons';

<template>
  <div class='not-prose h-40'>
    <Sidebar @label='Inbox' as |sidebar|>
      <sidebar.Body>
        <sidebar.Item
          @href='#messages'
          @icon={{BookIcon}}
          @badge={{3}}
          @badgeLabel='3 unread'
        >
          Messages
        </sidebar.Item>
        <sidebar.Item @href='#requests' @badge='New'>
          Access requests
        </sidebar.Item>
        <sidebar.Item @href='#members' @icon={{UserIcon}}>
          Members
        </sidebar.Item>
      </sidebar.Body>
    </Sidebar>
  </div>
</template>
```

### Linking to routes

With `@route` (plus `@model`, `@models` or `@query` as needed) an item renders
a `LinkTo`, and the router decides whether it is active. A parent route counts
as active on its child routes, so `@route='users'` stays active on
`users.show`. `@isActive` always wins over the router; pass it when only an
exact match should light up.

```gts
<sidebar.Item @route='dashboard' @icon={{ViewIcon}}>Dashboard</sidebar.Item>
<sidebar.Item @route='users.show' @model={{@currentUser.id}} @icon={{UserIcon}}>
  My profile
</sidebar.Item>
```

## Groups

`Group` puts a heading over a set of items and names the set after it with
`@label`.

```gts preview collapsible
import { Sidebar } from 'frontile';
import {
  ViewIcon,
  StarIcon,
  UserIcon,
  SettingsIcon
} from 'site/components/icons';

<template>
  <div class='not-prose h-72'>
    <Sidebar as |sidebar|>
      <sidebar.Body>
        <sidebar.Group @label='Projects'>
          <sidebar.Item @href='#all' @icon={{ViewIcon}} @isActive={{true}}>
            All projects
          </sidebar.Item>
          <sidebar.Item @href='#starred' @icon={{StarIcon}}>
            Starred
          </sidebar.Item>
        </sidebar.Group>
        <sidebar.Group @label='Admin'>
          <sidebar.Item @href='#members' @icon={{UserIcon}}>
            Members
          </sidebar.Item>
          <sidebar.Item @href='#settings' @icon={{SettingsIcon}}>
            Settings
          </sidebar.Item>
        </sidebar.Group>
      </sidebar.Body>
    </Sidebar>
  </div>
</template>
```

## Folders

`Folder` opens and closes a set of items, one level deep. Give it a `@label`,
an optional `@icon`, and write its items as `folder.Item`.

A folder holding the current page opens by itself, on load and whenever one of
its items becomes the current page, but never reopens after the user closes
it. `@defaultOpen` sets the starting state otherwise. To control it, pass
`@open` and update it from `@onOpenChange`, which is also called for the
automatic open.

The trigger is not styled active, since the item inside is the current page,
but it carries `data-active="true"` for your own styles. A folder with no
visible items is hidden, so a section the user may not see leaves no empty row.

```gts preview
import { Sidebar } from 'frontile';
import { PackageIcon, BookIcon } from 'site/components/icons';

<template>
  <div class='not-prose h-64'>
    <Sidebar @label='Catalog' as |sidebar|>
      <sidebar.Body>
        <sidebar.Folder @label='Products' @icon={{PackageIcon}} as |folder|>
          <folder.Item @href='#all-products' @isActive={{true}}>
            All products
          </folder.Item>
          <folder.Item @href='#categories'>Categories</folder.Item>
        </sidebar.Folder>
        <sidebar.Folder @label='Reports' @icon={{BookIcon}} as |folder|>
          <folder.Item @href='#sales'>Sales</folder.Item>
          <folder.Item @href='#inventory'>Inventory</folder.Item>
        </sidebar.Folder>
      </sidebar.Body>
    </Sidebar>
  </div>
</template>
```

## Collapsing

`Toggle` collapses the sidebar to an icon rail and expands it again. In the
rail:

- Item labels and group headings are visually hidden but still name the links
  for screen readers, and each label shows as a tooltip on hover or focus.
- A folder opens as a [Dropdown](../collections/dropdown) menu beside the
  rail. Only put `folder.Item` in a folder's block: anything else renders
  twice in the rail.
- Your own text in the header, body or footer stays visible unless you wrap
  it in `<span data-sidebar-label>`, which hides it the same way.

Collapse this sidebar, then hover the icons and open the folder.

```gts preview collapsible
import { Sidebar } from 'frontile';
import {
  ViewIcon,
  PackageIcon,
  StarIcon,
  SparklesIcon
} from 'site/components/icons';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    <div
      class='flex h-80 overflow-hidden rounded-lg border border-neutral-soft'
    >
      <Sidebar @label='Workspace' as |sidebar|>
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
          <sidebar.Folder @label='Products' @icon={{PackageIcon}} as |folder|>
            <folder.Item @href='#all-products'>All products</folder.Item>
            <folder.Item @href='#categories'>Categories</folder.Item>
          </sidebar.Folder>
          <sidebar.Group @label='Saved'>
            <sidebar.Item @href='#starred' @icon={{StarIcon}}>
              Starred
            </sidebar.Item>
          </sidebar.Group>
        </sidebar.Body>
      </Sidebar>
      <p class='flex-1 p-4 text-sm text-neutral-firm'>Page content</p>
    </div>
  </div>
</template>
```

### Collapse modes

`@collapsible` sets what collapsing does: `icon` (the default) shrinks the
sidebar to a rail, `offcanvas` hides it, and `none` keeps it expanded.

A hidden sidebar cannot hold the button that brings it back, so put a
`SidebarToggle` outside it. Give the toggle and the sidebar the same
`AppLayoutState` as `@state`, and pass the sidebar's id as `@controls` so the
toggle's `aria-controls` points at it.

```gts preview collapsible
import Component from '@glimmer/component';
import { Sidebar, SidebarToggle, AppLayoutState } from 'frontile';
import { ViewIcon, BookIcon } from 'site/components/icons';

export default class CollapseModesExample extends Component {
  modes = ['icon', 'offcanvas', 'none'].map((name) => ({
    name,
    id: `collapse-mode-${name}`,
    state: new AppLayoutState()
  }));

  <template>
    <div class='demo-stack demo-stack--wide not-prose'>
      {{#each this.modes as |mode|}}
        <div
          class='flex h-40 overflow-hidden rounded-lg border border-neutral-soft'
        >
          <Sidebar
            @state={{mode.state}}
            @collapsible={{mode.name}}
            @label={{mode.name}}
            id={{mode.id}}
            as |sidebar|
          >
            <sidebar.Body>
              <sidebar.Item @href='#home' @icon={{ViewIcon}}>Home</sidebar.Item>
              <sidebar.Item @href='#docs' @icon={{BookIcon}}>Docs</sidebar.Item>
            </sidebar.Body>
          </Sidebar>
          <div class='flex flex-1 items-start gap-2 p-2 text-sm'>
            <SidebarToggle @state={{mode.state}} @controls={{mode.id}} />
            <code class='py-2'>@collapsible='{{mode.name}}'</code>
          </div>
        </div>
      {{/each}}
    </div>
  </template>
}
```

### Toggle placement

`Toggle` works anywhere inside the sidebar and stays visible in the rail. In
the header, put `class='ml-auto'` on it to push it to the end; in the footer it
lines up with the items by itself.

```gts preview
import { Sidebar } from 'frontile';
import { ViewIcon, SettingsIcon } from 'site/components/icons';

<template>
  <div class='not-prose h-56'>
    <Sidebar @label='Footer toggle' as |sidebar|>
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
    </Sidebar>
  </div>
</template>
```

## Item layouts and the rail

`@layout` sets how an item arranges its icon and label:

- `inline` (default): the label beside the icon.
- `stacked`: a small label under the icon. `@shortLabel` replaces the visible
  text; the full label still names the link.
- `icon`: the icon alone, with the label as a tooltip.

`stacked` and `icon` ignore collapsing and suit `@size='rail'`, a narrow
column meant to stay put, so pair it with `@collapsible='none'`. A rail
centers its header over the items.

```gts preview collapsible
import { Sidebar } from 'frontile';
import {
  ViewIcon,
  SettingsIcon,
  UserIcon,
  SparklesIcon
} from 'site/components/icons';

<template>
  <div class='not-prose flex h-64 flex-wrap items-start gap-8'>
    <Sidebar @collapsible='none' @label='Inline' as |sidebar|>
      <sidebar.Body>
        <sidebar.Item @href='#overview' @icon={{ViewIcon}} @isActive={{true}}>
          Overview
        </sidebar.Item>
        <sidebar.Item @href='#members' @icon={{UserIcon}}>
          Members
        </sidebar.Item>
      </sidebar.Body>
    </Sidebar>
    <Sidebar @collapsible='none' @size='rail' @label='Stacked' as |sidebar|>
      <sidebar.Header>
        <SparklesIcon class='size-5 shrink-0 text-primary' />
      </sidebar.Header>
      <sidebar.Body>
        <sidebar.Item
          @href='#overview'
          @layout='stacked'
          @icon={{ViewIcon}}
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
    <Sidebar @collapsible='none' @size='rail' @label='Icon only' as |sidebar|>
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

## Styling

On its own the sidebar is a bordered surface (`@variant='attached'`); in an
`AppLayout` it follows the layout's variant.

The header, body and footer share one content line, so items, group headings
and your own markup line up without padding of your own. To keep a brand in
place when the sidebar collapses, give its icon `size-5`, as the demos do.

`@class` on the sidebar or on an item is merged with the theme's classes, so a
conflicting class wins. Use it on the sidebar for another width, such as
`@class='w-48'`. That width holds in the rail too, so pair it with
`@collapsible='none'`.

```gts preview
import { Sidebar } from 'frontile';
import { StarIcon, ViewIcon } from 'site/components/icons';

<template>
  <div class='not-prose h-32'>
    <Sidebar @label='Favorites' @class='w-48' @collapsible='none' as |sidebar|>
      <sidebar.Body>
        <sidebar.Item @href='#all' @icon={{ViewIcon}}>All</sidebar.Item>
        <sidebar.Item @href='#starred' @icon={{StarIcon}} @class='text-primary'>
          Starred
        </sidebar.Item>
      </sidebar.Body>
    </Sidebar>
  </div>
</template>
```

## In an AppLayout

Inside an [AppLayout](./app-layout), use the yielded `layout.Sidebar`. It
shares the layout's state, takes the first column (or the last, with
`@sidebarSide='end'`), and on small screens moves into a drawer or gives way
to a [BottomNav](./bottom-nav). Render one `Sidebar` per layout. The
[AppLayout](./app-layout#responsive-navigation) page shows each of these.

## Accessibility

- The sidebar is a `nav` landmark named by `@label` (default `Main`). Give
  each navigation on the page its own name.
- The active item has `aria-current="page"`. A disabled item has
  `aria-disabled="true"` and no `href`; a disabled button is natively disabled.
- An item's `@icon` and `@shortLabel` are hidden from assistive technology, so
  the full label names the link in every layout and in the rail.
- A `@badge` is read after the label; give `@badgeLabel` when the bare value
  is unclear.
- `Group` is a `group` named by its `@label`.
- `Toggle` is a button named by `@label` (default "Toggle sidebar"), with
  `aria-expanded` and `aria-controls` pointing at the sidebar.
- A folder's trigger is a button named by `@label`. Inline it is a disclosure
  (`aria-expanded`, `aria-controls`) over a `group` of its items. In the rail
  it is a menu button, and its items are link items of a `menu`, so they
  still open in a new tab. A closed folder keeps its items out of the tab
  order.

### Folder keyboard

Inline:

| Key                                  | Action                                               |
| ------------------------------------ | ---------------------------------------------------- |
| <kbd>Enter</kbd> or <kbd>Space</kbd> | On the trigger, opens or closes the folder           |
| <kbd>Tab</kbd>                       | Moves through the trigger and, while open, its items |

In the icon rail:

| Key                                                                            | Action                                                                 |
| ------------------------------------------------------------------------------ | ---------------------------------------------------------------------- |
| <kbd>Enter</kbd>, <kbd>Space</kbd>, <kbd>ArrowDown</kbd> or <kbd>ArrowUp</kbd> | On the trigger, opens the menu                                         |
| Letters                                                                        | Opens the menu, or moves to the next item whose label starts with them |
| <kbd>ArrowDown</kbd> or <kbd>ArrowUp</kbd>                                     | In the menu, moves between items, skipping disabled ones               |
| <kbd>Enter</kbd>                                                               | Follows the item's link and closes the menu                            |
| <kbd>Escape</kbd> or <kbd>Tab</kbd>                                            | Closes the menu and returns focus to the trigger                       |

## API

<Signature @component="Sidebar" />

### Item

<Signature @component="NavItem" />

### Folder

<Signature @component="NavFolder" />

### Group

<Signature @component="SidebarGroup" />

### SidebarToggle

<Signature @component="SidebarToggle" />
