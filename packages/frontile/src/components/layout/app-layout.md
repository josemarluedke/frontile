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
            <sidebar.Item @href='#settings' @icon={{SettingsIcon}}>
              Settings
            </sidebar.Item>
          </sidebar.Body>
        </layout.Sidebar>
        <layout.Navbar>
          <layout.MenuToggle />
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
            <SparklesIcon class='size-5 shrink-0 text-primary' />
            <span class='truncate text-sm font-semibold' data-sidebar-label>
              Acme
            </span>
          </sidebar.Header>
          <sidebar.Body>
            <sidebar.Item
              @href='#overview'
              @icon={{ViewIcon}}
              @isActive={{true}}
            >
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

`layout.Sidebar` is a full-height `nav` landmark that takes the first column and
collapses to an icon rail. It is documented on its own page: see
[Sidebar](./sidebar) for the header, items, folders, groups, collapse modes,
sizes, mobile drawer and standalone use.

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
`attached` variant, and `15rem` and `3.75rem` in `inset`. With `@size="rail"` it
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
            @description='Details panel: {{if
              layout.state.asideOpen
              "open"
              "closed"
            }}'
          />
        </layout.Main>
      </AppLayout>
    </div>
  </template>
}
```

## Putting it together

Every part in one layout, driven by one `AppLayoutState`: a sidebar with
items and a group, its toggle, a navbar, a page header, the main content,
and an aside with its toggle. Narrow the window to see the drawers.

```gts preview collapsible
import Component from '@glimmer/component';
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
      <AppLayout @state={{this.state}} class='demo-app-layout' as |layout|>
        <layout.Sidebar @label='Workspace' as |sidebar|>
          <sidebar.Header>
            <SparklesIcon class='size-5 shrink-0 text-primary' />
            <span class='truncate text-sm font-semibold' data-sidebar-label>
              Acme
            </span>
            <sidebar.Toggle class='ml-auto' />
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
            Sidebar collapsed:
            {{if this.state.sidebarCollapsed 'yes' 'no'}}. Details open:
            {{if this.state.asideOpen 'yes' 'no'}}.
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
- `Toggle` (`sidebar.Toggle`, or `layout.SidebarToggle` outside the sidebar)
  is a button named by `@label` (default "Toggle sidebar"). It sets
  `aria-expanded` to `true` while the sidebar is expanded (always, with
  `@collapsible="none"`) and `aria-controls` to the sidebar. Below the
  breakpoint `layout.SidebarToggle` opens the drawer, and `aria-expanded`
  follows the drawer; `sidebar.Toggle` renders nothing there.
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
  when it opened (`MenuToggle` if focus was on the page body).
- `Item` is a link. The active item has `aria-current="page"`. A disabled
  item has no href and has `aria-disabled="true"`; with neither `@href` nor
  `@route` it is a disabled `<button>` instead. Its `@icon` is hidden from
  assistive technology, so the label is the link's name.
- `Folder` has a button trigger with `aria-expanded` and `aria-controls`, and
  its items sit in a `group` named by the trigger. In the icon rail the
  trigger is a menu button and the items are link items of a `menu` named by
  it: the arrow keys move between them, <kbd>Enter</kbd> follows one, and
  <kbd>Escape</kbd> closes the menu and returns focus to the trigger. See
  [Sidebar](./sidebar#folder-behavior).
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

| Key              | Action                                                                             |
| ---------------- | ---------------------------------------------------------------------------------- |
| `Tab`            | From the top of the page, reveals and focuses the skip link                        |
| `Enter`          | On the skip link, moves focus to the main content                                  |
| `Cmd/Ctrl` + `B` | Collapses or expands the sidebar; below the breakpoint, opens or closes the drawer |
| `Escape`         | Closes the drawer (sidebar or aside)                                               |

## Roadmap

These are not part of `AppLayout` yet. Each one would be added without breaking the current API.

| Not available yet                   | What you get today                                                                          |
| ----------------------------------- | ------------------------------------------------------------------------------------------- |
| Resizable sidebar and aside         | Fixed widths                                                                                |
| Persisted layout state              | Pass `@state` and save it wherever you keep preferences, such as a cookie or `localStorage` |
| Sticky toolbar row under the navbar | One navbar row                                                                              |
| Top navigation above the sidebar    | The sidebar spans the full height, with nothing above it                                    |
| Floating sidebar variant            | The `inset` variant, which floats the sidebar on the frame                                  |

## API

<Signature @component="AppLayout" />
<Signature @component="MenuToggle" />
<Signature @component="Aside" />
<Signature @component="AsideToggle" />
<Signature @component="Navbar" />
<Signature @component="Main" />
<Signature @component="PageHeader" />
