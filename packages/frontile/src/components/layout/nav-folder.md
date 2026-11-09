---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# NavFolder

A collapsible group of navigation items under one labelled trigger. Reach for
it to tuck related links, such as the pages of one section, behind a single
row. It is built from [NavLink](./nav-link) and [NavItem](./nav-item), and
holds one level of items: a folder does not contain other folders.

## Import

```js
import { NavFolder } from 'frontile';
```

## Usage

`NavFolder` takes a `@label` and an optional `@icon`, and yields `Item`, a
[NavItem](./nav-item) that belongs to the folder. It starts closed.

Inside a [Sidebar](./app-layout#sidebar), write `sidebar.Folder` instead. It
is `NavFolder` pre-bound to the sidebar, so it also follows the icon rail and
the mobile drawer. The arguments are the same. `NavFolder` imported directly is
the standalone form, for navigation outside a sidebar.

Folders also work inside a [BottomNav](./bottom-nav#more-sheet) `More` sheet,
as `more.Folder`. There they are always inline.

```gts preview
import { NavFolder } from 'frontile';
import { PackageIcon } from 'site/components/icons';

<template>
  <nav aria-label='Catalog' class='not-prose w-56'>
    <NavFolder @label='Products' @icon={{PackageIcon}} as |folder|>
      <folder.Item @href='#all-products'>All products</folder.Item>
      <folder.Item @href='#categories'>Categories</folder.Item>
      <folder.Item @href='#inventory'>Inventory</folder.Item>
    </NavFolder>
  </nav>
</template>
```

## The current page

A folder holding the current page opens by itself, on load and whenever one of
its items newly becomes the current page. It never reopens on its own after
the user closes it.

The folder's trigger has no active styling: the item inside it is the current
page, so only that item is filled. The trigger still carries
`data-active="true"` while one of its items is active, as a hook if you want to
style it yourself. It does not get `aria-current`: the folder is not the
current page, its item is. A hidden item never makes the folder active.

A folder that is open when the page loads is open from the first paint. Opening
and closing afterwards animates.

```gts preview
import { NavFolder } from 'frontile';
import { PackageIcon, UserIcon } from 'site/components/icons';

<template>
  <nav aria-label='Admin' class='not-prose flex w-56 flex-col gap-1'>
    <NavFolder @label='Products' @icon={{PackageIcon}} as |folder|>
      <folder.Item @href='#all-products' @isActive={{true}}>
        All products
      </folder.Item>
      <folder.Item @href='#categories'>Categories</folder.Item>
    </NavFolder>
    <NavFolder @label='People' @icon={{UserIcon}} as |folder|>
      <folder.Item @href='#members'>Members</folder.Item>
      <folder.Item @href='#invitations'>Invitations</folder.Item>
    </NavFolder>
  </nav>
</template>
```

## Open state

`@defaultOpen` sets the initial state. For a folder you control, pass `@open`
and update it from `@onOpenChange`, which is called with the requested state
on every change, including an automatic open for the current page. A clicked
trigger then only calls `@onOpenChange`; the folder changes once you update
`@open`. `@onOpenChange` is also called for a folder you do not control.

```gts preview collapsible
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Button, NavFolder } from 'frontile';
import { PackageIcon } from 'site/components/icons';

export default class ControlledFolderExample extends Component {
  @tracked open = false;

  setOpen = (value: boolean) => {
    this.open = value;
  };

  toggle = () => {
    this.open = !this.open;
  };

  <template>
    <div class='not-prose flex flex-col items-start gap-3'>
      <Button @size='sm' @onPress={{this.toggle}}>
        {{if this.open 'Close' 'Open'}}
        the folder
      </Button>
      <nav aria-label='Catalog' class='w-56'>
        <NavFolder
          @label='Products'
          @icon={{PackageIcon}}
          @open={{this.open}}
          @onOpenChange={{this.setOpen}}
          as |folder|
        >
          <folder.Item @href='#all-products'>All products</folder.Item>
          <folder.Item @href='#categories'>Categories</folder.Item>
        </NavFolder>
      </nav>
    </div>
  </template>
}
```

## Hidden folders

`@isHidden` hides the folder. A folder is also hidden when it has no items, or
when every item is hidden, so a section the user may not see leaves no empty
row behind. A hidden folder stays in the page with the `hidden` attribute, so it
is not visible, not focusable and not read by screen readers.

## In a sidebar

Inside a `Sidebar` the folder is an inline disclosure: its items appear
beneath the trigger.

In the collapsed icon rail the trigger shows only its icon, with the folder's
label as a tooltip on hover or focus, like the rail items beside it. The
tooltip appears at once and never over the open menu. There the folder opens
as a [Dropdown](../collections/dropdown) menu beside the rail instead: its
items become link items of the menu, with their icons and labels (long ones
are cut short with an ellipsis), and the current page is marked. The menu has
no heading; it is named by the trigger. It closes when you follow an item,
click outside, press <kbd>Escape</kbd> or tab out of it, and expanding the
sidebar closes it too. Opening it never changes the inline state, so
expanding the sidebar again shows the folder as you left it. A folder holding
the current page still reports `data-active` in the rail while its menu is
closed, and a newly active item does not pop the menu open.

In the rail the folder's items render as menu rows, so put only
`folder.Item` in the folder's block. Any other content renders twice: once
hidden, so the folder can track which item is active, and once inside the
menu. An item's own `@class` and `data-part="nav-item"` do not apply to its
menu row.

In the mobile drawer a folder is always inline.

Collapse this sidebar with the toggle, then click the Products icon.

```gts preview collapsible
import { AppLayout } from 'frontile';
import {
  PackageIcon,
  SparklesIcon,
  UserIcon,
  ViewIcon
} from 'site/components/icons';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    <AppLayout
      @defaultSidebarCollapsed={{true}}
      class='demo-app-layout'
      as |layout|
    >
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
            <folder.Item @href='#inventory'>Inventory</folder.Item>
          </sidebar.Folder>
          <sidebar.Folder @label='People' @icon={{UserIcon}} as |folder|>
            <folder.Item @href='#members'>Members</folder.Item>
            <folder.Item @href='#invitations'>Invitations</folder.Item>
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

## Accessibility

- The trigger is a native `button` named by `@label`. Inline it is a
  disclosure, with `aria-expanded` and `aria-controls` pointing at the items,
  which sit in a `group` named by the trigger.
- In the icon rail the trigger is a menu button instead (`aria-haspopup`,
  `aria-expanded`, `aria-controls`). The items are `menuitem`s of a `menu`
  named by the trigger (`aria-labelledby`); each holds a real link, so it
  still opens in a new tab. A disabled item is `aria-disabled` and has no
  link to follow.
- The trigger never has `aria-current`; the active item inside it does.
- The folder's `@icon` is hidden from assistive technology.
- A closed folder keeps its items out of the tab order and the accessibility
  tree.

### Keyboard

Inline:

| Key                                  | Action                                               |
| ------------------------------------ | ---------------------------------------------------- |
| <kbd>Enter</kbd> or <kbd>Space</kbd> | On the trigger, opens or closes the folder           |
| <kbd>Tab</kbd>                       | Moves through the trigger and, while open, its items |

In the icon rail:

| Key                                                                            | Action                                                                                       |
| ------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------- |
| <kbd>Enter</kbd>, <kbd>Space</kbd>, <kbd>ArrowDown</kbd> or <kbd>ArrowUp</kbd> | On the trigger, opens the menu                                                               |
| Letters                                                                        | On the trigger, opens the menu; in the menu, moves to the next item whose label starts with them |
| <kbd>ArrowDown</kbd> or <kbd>ArrowUp</kbd>                                     | In the menu, moves between the items, skipping disabled ones                                 |
| <kbd>Enter</kbd>                                                               | Follows the item's link and closes the menu                                                  |
| <kbd>Escape</kbd>                                                              | Closes the menu and returns focus to the trigger                                             |
| <kbd>Tab</kbd>                                                                 | Closes the menu and returns focus to the trigger                                             |

Clicking outside an open menu closes it, and so does expanding the sidebar.

## API

<Signature @component="NavFolder" />
