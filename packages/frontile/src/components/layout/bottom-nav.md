---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# BottomNav

A bar of icon tabs along the bottom of the screen, for the primary navigation
on small viewports. Each tab is a [Sidebar](./sidebar#item-layouts) `Item` in its `icon` layout.

## Import

```js
import { BottomNav } from 'frontile';
```

## Usage

`BottomNav` yields `Item`, a sidebar `Item` with `@layout="icon"` already
set. Give each tab an `@icon` and its label as the block: the label names the
tab for assistive technology and shows as a tooltip above it. Set `@isActive`
on the current tab, or pass `@route` to let the router decide. `@badge` shows
a count on the tab's icon.

Standalone, the bar is fixed to the bottom of the viewport. The demo below
confines it to a frame with a transform, which makes the frame its containing
block.

```gts preview
import { BottomNav } from 'frontile';
import { ViewIcon, UserIcon, SettingsIcon } from 'site/components/icons';

<template>
  <div
    class='not-prose relative h-48 w-full max-w-sm overflow-hidden rounded-lg border border-neutral-subtle'
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
</template>
```

## More sheet

`BottomNav` also yields `More`, a last tab that opens a sheet from the bottom
of the screen with further navigation. `More` yields `Item` and `Folder`:
the [sidebar](./sidebar#items-and-groups) `Item` and `Folder` as full-width rows, with
folders opening inline. Following an item closes the sheet.

The tab follows what is inside it, even while the sheet is closed:

- It shows active when an item inside is active, including one in a folder.
  It is never `aria-current`; the item is the current page.
- It shows a dot when an item inside has a `@badge`.
- Hidden items count for neither, and the tab is not rendered when every item
  inside is hidden. `@isHidden` hides the tab outright.

The sheet holds exactly what you put in the block. Tabs never move into it on
their own when the bar runs out of room, so choose which destinations are tabs
and which go in the sheet.

The block is rendered twice: once hidden, all the time, to track which item is
active or badged, and once in the open sheet. Avoid `id`s and side effects,
such as modifiers, analytics or data loading, inside it. That includes
`@onOpenChange` on a folder in the block: the hidden copy's active-item logic
can call it on load, and the sheet's copy can call it again when the sheet
opens.

`@label` names the tab (default `More`), `@icon` replaces its ellipsis icon,
and `@sheetLabel` names the sheet (default the label). In the demo, Billing is
the current page and Messages has unread items (made-up data).

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
  <div
    class='not-prose relative h-48 w-full max-w-sm overflow-hidden rounded-lg border border-neutral-subtle'
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
          <folder.Item @href='#billing' @isActive={{true}}>Billing</folder.Item>
          <folder.Item @href='#invoices'>Invoices</folder.Item>
        </more.Folder>
      </bar.More>
    </BottomNav>
  </div>
</template>
```

The sheet is as tall as its items, up to 80% of the viewport, and scrolls past
that. Its bottom padding is the same safe-area inset as the bar's.

## Safe area

The bar pads its bottom edge by the device's safe-area inset, so tabs stay
clear of the home indicator, and grows by the same amount. The inset is only
non-zero when the page opts in to the full screen:

```html
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />
```

To use another inset, set `--bottomnav-safe-area` on the bar or an ancestor.
It defaults to `env(safe-area-inset-bottom, 0px)`.

```gts
<BottomNav style='--bottomnav-safe-area: 0px' as |bar|>
  ...
</BottomNav>
```

## Stacking order

The bar sets no `z-index`. Overlays such as modals and drawers stack by their
place in the document, so render `BottomNav` before them.

Known limitation: this is a workaround. When the bar sits in a scrolling page
it needs to rise above in-page layers (`z-10`) while staying below overlays,
and Frontile has no shared z-index scale to express that. A theme-level z-index
scale is the proper fix and is a follow-up task.

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
