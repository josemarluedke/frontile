---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# NavItem

A styled navigation link: an optional icon and a label, with the current page
highlighted. Reach for it for the links in a sidebar or any other vertical
navigation. It is built on [NavLink](./nav-link), which does the routing and
the ARIA, and groups into [NavFolder](./nav-folder).

## Import

```js
import { NavItem } from 'frontile';
```

## Usage

Give `NavItem` an `@href` and its label as the block. `@icon` takes an icon
component and shows it before the label. Set `@isActive` on the item for the
current page.

Inside a [Sidebar](./app-layout#sidebar), write `sidebar.Item` instead. It is
`NavItem` pre-bound to the sidebar, so it also follows the icon rail and the
mobile drawer. The arguments are the same. `NavItem` imported directly is the
standalone form, for navigation outside a sidebar.

```gts preview
import { NavItem } from 'frontile';
import { ViewIcon, SettingsIcon, UserIcon } from 'site/components/icons';

<template>
  <nav aria-label='Workspace' class='not-prose flex w-56 flex-col gap-1'>
    <NavItem @href='#overview' @icon={{ViewIcon}} @isActive={{true}}>
      Overview
    </NavItem>
    <NavItem @href='#members' @icon={{UserIcon}}>
      Members
    </NavItem>
    <NavItem @href='#settings' @icon={{SettingsIcon}}>
      Settings
    </NavItem>
  </nav>
</template>
```

## Routing

`NavItem` takes the same routing arguments as `TabNav.Item`. With `@href` it is
a plain anchor and needs no router; set `@isActive` to mark the current page.
With `@route` (and `@model`, `@models` or `@query` as needed) it renders an
Ember `LinkTo` and asks the router whether it is active, so no `@isActive` is
needed.

`@isActive` always wins over the router. The router counts a route as active
while any of its child routes is, so `@route='users'` stays active on
`users.show`; pass `@isActive` if only the exact route should light up.

```gts
import { NavItem } from 'frontile';

<template>
  <NavItem @route='dashboard'>Dashboard</NavItem>
  <NavItem @route='users.show' @model={{@currentUser.id}}>My profile</NavItem>
</template>
```

An item with neither `@route` nor `@href` is a `<button>`, for a row that runs
your own handler: attach it with the `on` modifier.

## Disabled and hidden

`@isDisabled` drops the `href` so the link cannot be followed, and dims the
item. A disabled item with neither `@href` nor `@route` is a disabled
`<button>`. `@isHidden` renders nothing, for items the current user should not
see.

```gts preview
import { NavItem } from 'frontile';
import { ArchiveIcon, DeleteIcon, StarIcon } from 'site/components/icons';

<template>
  <nav aria-label='Projects' class='not-prose flex w-56 flex-col gap-1'>
    <NavItem @href='#starred' @icon={{StarIcon}}>Starred</NavItem>
    <NavItem @href='#archived' @icon={{ArchiveIcon}} @isDisabled={{true}}>
      Archived
    </NavItem>
    <NavItem @href='#purge' @icon={{DeleteIcon}} @isHidden={{true}}>
      Purge data
    </NavItem>
  </nav>
</template>
```

## Element type

`NavItem` renders an `<a>` (with `@route` or `@href`) or a `<button>`, and
inside a collapsed `NavFolder`'s menu an `<li>` menu row. Its `Element`
signature is `HTMLAnchorElement | HTMLButtonElement | HTMLLIElement`, so
`...attributes` you pass must suit all of them.

## Styling

An item's look comes from the theme. Add classes to one item with `@class`;
they are merged with the item's own, so a class that conflicts with a theme
class wins, like the text color here. `AppLayout`'s `@classes` does not reach
items.

Items do not space themselves: stack them in a column with `gap-1`, as these
demos do. Inside a `Sidebar` that is already done, and the row's padding lines
its icon up with the rest of the sidebar.

```gts preview
import { NavItem } from 'frontile';
import { StarIcon } from 'site/components/icons';

<template>
  <nav aria-label='Favorites' class='not-prose flex w-56 flex-col gap-1'>
    <NavItem @href='#starred' @icon={{StarIcon}} @class='text-primary'>
      Starred
    </NavItem>
  </nav>
</template>
```

## Layouts

`@layout` sets how the icon and label are arranged.

- `inline`, the default, puts the label beside the icon. Inside a collapsed
  [Sidebar](./app-layout#sidebar) the label is hidden and the icon stays put.
- `stacked` puts a small label under the icon, with the current page marked by
  a rounded fill behind the icon. Give `@shortLabel` for the text shown under the icon;
  without it the block text is shown. A stacked item ignores the sidebar's
  collapsed state.
- `icon` shows the icon alone in a 44px hit target. The label shows as a
  tooltip on hover or focus, opening immediately with no delay. An icon item also
  ignores the collapsed state.

```gts preview collapsible
import { NavItem } from 'frontile';
import { ViewIcon, SettingsIcon, UserIcon } from 'site/components/icons';

<template>
  <div class='not-prose flex flex-wrap items-start gap-8 rounded-lg bg-surface-card p-4'>
    <nav aria-label='Inline' class='flex w-48 flex-col gap-1'>
      <NavItem @href='#overview' @icon={{ViewIcon}} @isActive={{true}}>
        Overview
      </NavItem>
      <NavItem @href='#members' @icon={{UserIcon}}>Members</NavItem>
    </nav>
    <nav aria-label='Stacked' class='flex gap-1'>
      <NavItem
        @href='#overview'
        @layout='stacked'
        @icon={{ViewIcon}}
        @shortLabel='Home'
        @isActive={{true}}
      >
        Overview
      </NavItem>
      <NavItem
        @href='#settings'
        @layout='stacked'
        @icon={{SettingsIcon}}
        @shortLabel='Prefs'
      >
        Settings
      </NavItem>
    </nav>
    <nav aria-label='Icon only' class='flex gap-1'>
      <NavItem
        @href='#overview'
        @layout='icon'
        @icon={{ViewIcon}}
        @isActive={{true}}
      >
        Overview
      </NavItem>
      <NavItem @href='#members' @layout='icon' @icon={{UserIcon}}>
        Members
      </NavItem>
    </nav>
  </div>
</template>
```

## Badges

`@badge` shows a count or short status as a pill on the icon's top corner. An
item without an icon shows it at the end of the row. Nothing is shown for
`undefined`, `null`, `0` or an empty string. Screen readers hear the badge
after the label; set `@badgeLabel` to word it, such as "3 unread".

```gts preview
import { NavItem } from 'frontile';
import { ViewIcon, UserIcon } from 'site/components/icons';

<template>
  <div class='not-prose flex flex-wrap items-start gap-8 rounded-lg bg-surface-card p-4'>
    <nav aria-label='Inbox' class='flex w-48 flex-col gap-1'>
      <NavItem @href='#inbox' @icon={{ViewIcon}} @badge={{3}} @badgeLabel='3 unread'>
        Inbox
      </NavItem>
      <NavItem @href='#members' @icon={{UserIcon}}>Members</NavItem>
    </nav>
    <nav aria-label='Inbox stacked' class='flex gap-1'>
      <NavItem
        @href='#inbox'
        @layout='stacked'
        @icon={{ViewIcon}}
        @shortLabel='Inbox'
        @badge='9+'
        @badgeLabel='more than nine unread'
      >
        Inbox
      </NavItem>
    </nav>
  </div>
</template>
```

## Accessibility

- The active item has `aria-current="page"`.
- A disabled item has `aria-disabled="true"` and no `href`; a disabled button
  is also natively disabled and skipped by <kbd>Tab</kbd>.
- In the `stacked` layout `@shortLabel` is hidden from assistive technology;
  the full label is still the link's name. The `icon` layout names the link
  the same way.
- A `@badge` is hidden from assistive technology and its text is read after
  the label, so give `@badgeLabel` when the bare value is unclear.
- The `@icon` is hidden from assistive technology, so the label is the link's
  name.
- In a sidebar's icon rail the `inline` layout's label is visually hidden but still names the
  link, and it shows as a tooltip on hover or focus, opening immediately with no
  delay.
- Put items in a `nav` landmark. `Sidebar` provides one, named by its `@label`.

## API

<Signature @component="NavItem" />
