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

The folder's trigger shows `data-active="true"` while one of its items is
active, so you can style it. The trigger does not get `aria-current`: the
folder is not the current page, its item is. A hidden item never makes the
folder active.

A folder that is open when the page loads is open from the first paint. Opening
and closing afterwards animates.

```gts preview
import { NavFolder } from 'frontile';
import { PackageIcon, UserIcon } from 'site/components/icons';

<template>
  <nav aria-label='Admin' class='not-prose flex w-56 flex-col gap-0.5'>
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

```gts preview
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
folder opens as a flyout beside the rail instead. The flyout starts with the
folder's label, lists the items with their labels (long ones are cut short
with an ellipsis), appears without animation, and closes when you follow an
item, click outside, press <kbd>Escape</kbd> or tab out of it. Expanding the
sidebar closes it too; if focus was inside it, focus moves to the trigger.
Opening it never
changes the inline state, so expanding the sidebar again shows the folder as
you left it. A folder holding the current page still shows as active in the
rail, and a newly active item does not pop the flyout open.

In the mobile drawer a folder is always inline.

Collapse this sidebar with the toggle, then click the Products icon.

```gts preview
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
            <folder.Item @href='#inventory'>Inventory</folder.Item>
          </sidebar.Folder>
          <sidebar.Folder @label='People' @icon={{UserIcon}} as |folder|>
            <folder.Item @href='#members'>Members</folder.Item>
            <folder.Item @href='#invitations'>Invitations</folder.Item>
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

## Accessibility

- The trigger is a native `button` named by `@label`, with `aria-expanded` and
  `aria-controls` pointing at the items. In the icon rail `aria-expanded`
  follows the flyout.
- The items sit in a `group` named by the trigger. The label at the top of
  the flyout repeats that name for sighted users only, so it is hidden from
  assistive technology and is not a control.
- The trigger never has `aria-current`; the active item inside it does.
- The folder's `@icon` is hidden from assistive technology.
- A closed folder keeps its items out of the tab order and the accessibility
  tree.
- The flyout is a disclosure, not a menu: it has no `menu` role and the trigger
  has no `aria-haspopup`. It follows the trigger in the DOM, so <kbd>Tab</kbd>
  moves from the trigger into the flyout and out of it again; focus is never
  trapped.

### Keyboard

| Key                                  | Action                                                                             |
| ------------------------------------ | ---------------------------------------------------------------------------------- |
| <kbd>Enter</kbd> or <kbd>Space</kbd> | On the trigger, opens or closes the folder                                         |
| <kbd>Tab</kbd>                       | Moves through the trigger and, while open, its items. Leaving the flyout closes it |
| <kbd>Escape</kbd>                    | Closes the flyout and returns focus to the trigger                                 |

Clicking outside an open flyout closes it. Expanding the sidebar with its
keyboard shortcut while focus is in the flyout moves focus to the trigger,
which stays in place as the folder turns inline.

## API

<Signature @component="NavFolder" />
