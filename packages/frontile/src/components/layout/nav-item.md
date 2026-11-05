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
  <nav aria-label='Workspace' class='not-prose flex w-56 flex-col gap-0.5'>
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
  <nav aria-label='Projects' class='not-prose flex w-56 flex-col gap-0.5'>
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

## Styling

An item's look comes from the theme. Add classes to one item with `@class`;
they are appended to the item's own. `AppLayout`'s `@classes` does not reach
items.

```gts preview
import { NavItem } from 'frontile';
import { StarIcon } from 'site/components/icons';

<template>
  <nav aria-label='Favorites' class='not-prose flex w-56 flex-col gap-0.5'>
    <NavItem @href='#starred' @icon={{StarIcon}} @class='text-primary'>
      Starred
    </NavItem>
  </nav>
</template>
```

`@layout` sets how the icon and label are arranged. `inline`, the only value
today and the default, puts the label beside the icon.

## Accessibility

- The active item has `aria-current="page"`.
- A disabled item has `aria-disabled="true"` and no `href`; a disabled button
  is also natively disabled and skipped by <kbd>Tab</kbd>.
- The `@icon` is hidden from assistive technology, so the label is the link's
  name.
- In a sidebar's icon rail the label is visually hidden but still names the
  link, and it shows as a tooltip on hover or focus.
- Put items in a `nav` landmark. `Sidebar` provides one, named by its `@label`.

## API

<Signature @component="NavItem" />
