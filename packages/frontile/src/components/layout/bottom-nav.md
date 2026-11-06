---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# BottomNav

A bar of icon tabs along the bottom of the screen, for the primary navigation
on small viewports. Each tab is a [NavItem](./nav-item) in its `icon` layout.

## Import

```js
import { BottomNav } from 'frontile';
```

## Usage

`BottomNav` yields `Item`, which is `NavItem` with `@layout="icon"` already
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

## API

<Signature @component="BottomNav" />
