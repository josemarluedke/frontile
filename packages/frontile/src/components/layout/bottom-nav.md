---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# BottomNav

A bar of icon tabs along the bottom of the screen: the primary navigation on
phones.

## Import

```js
import { BottomNav } from 'frontile';
```

## Usage

Each tab is an `Item` with an `@icon` and its label as the block. The label
names the tab and shows as a tooltip. Mark the current tab with `@isActive`,
or pass `@route` and let the router decide. Items take the same arguments as
[Sidebar items](./sidebar#items), including `@badge`.

On its own the bar is fixed to the bottom of the viewport. The demos keep it
inside a frame.

```gts preview
import { BottomNav } from 'frontile';
import { ViewIcon, UserIcon, SettingsIcon } from 'site/components/icons';

<template>
  <div class='demo-stack not-prose'>
    <div
      class='relative mx-auto h-48 w-full max-w-sm overflow-hidden rounded-lg border border-neutral-subtle'
      style='transform: translateZ(0)'
    >
      <BottomNav @label='Workspace' as |bar|>
        <bar.Item @href='#overview' @icon={{ViewIcon}} @isActive={{true}}>
          Overview
        </bar.Item>
        <bar.Item @href='#members' @icon={{UserIcon}} @badge={{3}}>
          Members
        </bar.Item>
        <bar.Item @href='#settings' @icon={{SettingsIcon}}>
          Settings
        </bar.Item>
      </BottomNav>
    </div>
  </div>
</template>
```

## More sheet

`More` adds a last tab that opens a sheet of further navigation from the
bottom of the screen. It yields `Item` and `Folder`, the sidebar's items and
folders as full-width rows. Following an item closes the sheet.

Tabs never move into the sheet on their own: choose which destinations are
tabs and which go in the sheet. The tab shows active when an item inside is
the current page, and a dot when an item inside has a badge. It is not shown
when every item inside is hidden, or with `@isHidden`.

`@label` names the tab (default `More`), `@icon` replaces its ellipsis, and
`@sheetLabel` names the sheet (default the label).

> Note: `More` renders its block twice, once hidden to track the active and
> badged items and once in the open sheet. Keep `id`s and side effects
> (modifiers, analytics, data loading, a folder's `@onOpenChange`) out of it.

```gts preview collapsible
import { BottomNav } from 'frontile';
import {
  ViewIcon,
  UserIcon,
  SettingsIcon,
  BookIcon,
  PackageIcon
} from 'site/components/icons';

<template>
  <div class='demo-stack not-prose'>
    <div
      class='relative mx-auto h-48 w-full max-w-sm overflow-hidden rounded-lg border border-neutral-subtle'
      style='transform: translateZ(0)'
    >
      <BottomNav @label='Workspace' as |bar|>
        <bar.Item @href='#overview' @icon={{ViewIcon}}>Overview</bar.Item>
        <bar.Item @href='#members' @icon={{UserIcon}}>Members</bar.Item>
        <bar.More @sheetLabel='More pages' as |more|>
          <more.Item @href='#messages' @icon={{BookIcon}} @badge={{2}}>
            Messages
          </more.Item>
          <more.Item @href='#settings' @icon={{SettingsIcon}}>
            Settings
          </more.Item>
          <more.Folder @label='Account' @icon={{PackageIcon}} as |folder|>
            <folder.Item
              @href='#billing'
              @isActive={{true}}
            >Billing</folder.Item>
            <folder.Item @href='#invoices'>Invoices</folder.Item>
          </more.Folder>
        </bar.More>
      </BottomNav>
    </div>
  </div>
</template>
```

The sheet is as tall as its items, up to 80% of the viewport, and then
scrolls.

## In an AppLayout

Inside an [AppLayout](./app-layout#responsive-navigation) with
`@mobileNav='bottom'`, use the yielded `layout.BottomNav`. It shows only below
the layout's breakpoint, in place of the sidebar, as the layout's bottom row.
Above the breakpoint it renders nothing and an open sheet closes.

## Safe area

The bar and the sheet pad their bottom edge by the device's safe-area inset,
so tabs stay clear of the home indicator. The inset is only non-zero when the
page opts in to the full screen:

```html
<meta
  name="viewport"
  content="width=device-width, initial-scale=1, viewport-fit=cover"
/>
```

Set `--bottomnav-safe-area` on the bar or an ancestor to use another inset.

```gts
<BottomNav style='--bottomnav-safe-area: 0px' as |bar|>
  ...
</BottomNav>
```

## Stacking order

Modals, drawers and other overlays cover the bar. On its own the bar sets no
`z-index`, so render it before any overlay. In an `AppLayout` with
`@scrollMode='page'` it also rises above in-page layers such as sticky table
headers; keep any `PortalTarget` outside the `AppLayout`, or its overlays
render under the bar.

## Accessibility

- The bar is a `nav` landmark named by `@label` (default `Main`). Give it a
  distinct name if the page has another primary navigation.
- The active tab has `aria-current="page"`.
- Each tab's icon is hidden from assistive technology; its label is the
  accessible name and is also the tooltip shown on hover or focus.
- A `@badge` is hidden from assistive technology; its text is read after the
  label. Pass `@badgeLabel` when the bare value is unclear.
- The `More` tab is a button with `aria-haspopup="dialog"` and
  `aria-expanded`. Its label is its accessible name; it shows no tooltip.
  When it carries a dot, "has updates" is read after the label.
- The sheet is a modal dialog named by `@sheetLabel`, holding a `nav`
  landmark of the same name. Focus moves into it when it opens and is trapped
  there. Escape, the drag handle (a button) or a click on the backdrop closes
  it, and following an item closes it too. Focus then returns to the `More`
  tab.

## API

<Signature @component="BottomNav" />

### BottomNav.More

<Signature @component="BottomNavMore" />
