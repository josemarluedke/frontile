---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# AppLayout

The application shell: a sidebar, a navbar and a main content area. Reach for
it to give every page of an app the same frame.

> Note: `Aside` and `AsideToggle` arrive with the next phase of `AppLayout`.
> The demos below use the parts available today: `Sidebar`, `SidebarToggle`,
> `MenuToggle`, `Navbar`, `Main` and `PageHeader`.

## Import

```js
import { AppLayout } from 'frontile';
```

## Usage

`AppLayout` yields its parts. Each part places itself in the shell, so the
order you write them in does not matter.

By default the layout fills the viewport and `Main` scrolls on its own. The
demos on this page give the layout a fixed height so it fits on the page.

```gts preview
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

`inset`, the default, sets the content in a rounded card on a tinted frame.
`attached` runs the content edge to edge, with a border under the navbar
instead of a card.

```gts preview
import { AppLayout } from 'frontile';
import { array } from '@ember/helper';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    {{#each (array 'inset' 'attached') as |variant|}}
      <AppLayout @variant={{variant}} class='demo-app-layout' as |layout|>
        <layout.Navbar>
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

```gts preview
import { AppLayout } from 'frontile';
import { array } from '@ember/helper';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    {{#each (array 'frame' 'content') as |placement|}}
      <AppLayout
        @navbarPlacement={{placement}}
        class='demo-app-layout'
        as |layout|
      >
        <layout.Navbar>
          <span class='text-sm font-medium'>navbarPlacement: {{placement}}</span>
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

`Sidebar` is a full-height `nav` landmark that takes the first column. It
yields `Header`, `Body` and `Footer`. Give it a name with `@label` (default
`Main`); if the page has more than one navigation, each needs its own.
`SidebarToggle` is a button that collapses and expands it.

By default the sidebar collapses to an icon rail. Wrap each item's text in
`<span data-sidebar-label>`, in the header, body or footer, and it is visually
hidden in the rail while staying available to screen readers, so every link
keeps its name.

```gts preview
import { AppLayout } from 'frontile';
import { ViewIcon, SettingsIcon } from 'site/components/icons';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    <AppLayout class='demo-app-layout' as |layout|>
      <layout.Sidebar @label='Workspace' as |sidebar|>
        <sidebar.Header>
          <span class='text-sm font-semibold' data-sidebar-label>Acme</span>
        </sidebar.Header>
        <sidebar.Body>
          <a href='#overview' class='flex items-center gap-2 px-2 py-2 text-sm'>
            <ViewIcon />
            <span data-sidebar-label>Overview</span>
          </a>
          <a href='#settings' class='flex items-center gap-2 px-2 py-2 text-sm'>
            <SettingsIcon />
            <span data-sidebar-label>Settings</span>
          </a>
        </sidebar.Body>
      </layout.Sidebar>
      <layout.Navbar>
        <layout.SidebarToggle />
        <span class='text-sm font-medium'>Access management</span>
      </layout.Navbar>
      <layout.Main>
        <layout.PageHeader @title='Overview' />
      </layout.Main>
    </AppLayout>
  </div>
</template>
```

### Collapse modes

`@collapsible` sets what collapsing does. `icon`, the default, shrinks the
sidebar to a rail. `offcanvas` hides it entirely while collapsed. `none` keeps
it expanded and ignores collapse.

```gts preview
import { AppLayout } from 'frontile';
import { array } from '@ember/helper';
import { ViewIcon } from 'site/components/icons';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    {{#each (array 'icon' 'offcanvas' 'none') as |mode|}}
      <AppLayout
        @defaultSidebarCollapsed={{true}}
        class='demo-app-layout'
        as |layout|
      >
        <layout.Sidebar @collapsible={{mode}} as |sidebar|>
          <sidebar.Body>
            <a href='#home' class='flex items-center gap-2 px-2 py-2 text-sm'>
              <ViewIcon />
              <span data-sidebar-label>Home</span>
            </a>
          </sidebar.Body>
        </layout.Sidebar>
        <layout.Navbar>
          <layout.SidebarToggle />
          <span class='text-sm font-medium'>collapsible: {{mode}}</span>
        </layout.Navbar>
        <layout.Main />
      </AppLayout>
    {{/each}}
  </div>
</template>
```

### Sidebar side

`@sidebarSide="end"` on `AppLayout` moves the sidebar to the last column. The
side is logical, so `start` is the right side in a right-to-left document. In
the `attached` variant the sidebar's border moves to the side facing the
content.

```gts preview
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
        <sidebar.Body>
          <a href='#home' class='block px-2 py-2 text-sm'>
            <span data-sidebar-label>Home</span>
          </a>
        </sidebar.Body>
      </layout.Sidebar>
      <layout.Navbar>
        <span class='flex-1 text-sm font-medium'>Sidebar on the end</span>
        <layout.SidebarToggle />
      </layout.Navbar>
      <layout.Main />
    </AppLayout>
  </div>
</template>
```

### Mobile

Below `@breakpoint` (`sm` 40rem, `md` 48rem by default, `lg` 64rem) the sidebar
leaves the grid and opens as a drawer instead. Put a `MenuToggle` in the
navbar, top-left by convention, to open it. `MenuToggle` shows only below the
breakpoint, so it can sit beside a `SidebarToggle`, which collapses the sidebar
on wider screens.

The drawer shows the same `Sidebar` block, so you write the sidebar once. It
slides in from the sidebar's side (`@sidebarSide`, following the document's
direction), always expanded. It closes on Escape, on a click outside it, from
its close button, or when the window grows past the breakpoint.

Narrow the window to below 48rem to open this one.

```gts preview
import { AppLayout } from 'frontile';
import { ViewIcon, SettingsIcon } from 'site/components/icons';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    <AppLayout class='demo-app-layout' as |layout|>
      <layout.Sidebar @label='Workspace' as |sidebar|>
        <sidebar.Header>
          <span class='text-sm font-semibold' data-sidebar-label>Acme</span>
        </sidebar.Header>
        <sidebar.Body>
          <a href='#overview' class='flex items-center gap-2 px-2 py-2 text-sm'>
            <ViewIcon />
            <span data-sidebar-label>Overview</span>
          </a>
          <a href='#settings' class='flex items-center gap-2 px-2 py-2 text-sm'>
            <SettingsIcon />
            <span data-sidebar-label>Settings</span>
          </a>
        </sidebar.Body>
      </layout.Sidebar>
      <layout.Navbar>
        <layout.MenuToggle />
        <layout.SidebarToggle />
        <span class='text-sm font-medium'>Access management</span>
      </layout.Navbar>
      <layout.Main>
        <layout.PageHeader @title='Overview' />
      </layout.Main>
    </AppLayout>
  </div>
</template>
```

### Keyboard shortcut

<kbd>Cmd</kbd>+<kbd>B</kbd> (<kbd>Ctrl</kbd>+<kbd>B</kbd> outside Apple
platforms) toggles the sidebar: it collapses or expands it on wide screens and
opens or closes the drawer below the breakpoint. It responds only while focus
is inside the layout or on the page itself, so a second layout on the page is
left alone. Pick another combination with `@toggleShortcut`, such as
`'mod+shift+s'`, or turn it off with `@toggleShortcut={{false}}`.

### Using the sidebar on its own

Outside an `AppLayout`, pass `@state` (and, if you want the `inset` look,
`@variant`). The sidebar is as tall as its container. Give `SidebarToggle` the
same `@state`, and `@controls` with the sidebar's id so `aria-controls` points
at it.

```gts preview
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
          <a href='#daily' class='block px-2 py-2 text-sm'>
            <span data-sidebar-label>Daily</span>
          </a>
        </sidebar.Body>
      </Sidebar>
      <SidebarToggle @state={{this.state}} @controls='standalone-sidebar' />
    </div>
  </template>
}
```

## Page header

`PageHeader` is the title row at the top of a page. Place it inside `Main`.
It takes a `@title` and a `@description`; buttons for the page go in the
`<:actions>` block, and anything else under the title goes in `<:default>`.

```gts preview
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

## Scrolling

With `@scrollMode='content'`, the default, the layout is exactly the height
of the viewport and `Main` scrolls. With `@scrollMode='page'` the layout grows
with its content and the document scrolls instead.

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

```gts preview
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

```gts preview
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
            @description='Details panel: {{if layout.state.asideOpen "open" "closed"}}'
          />
        </layout.Main>
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
- `SidebarToggle` is a button named by `@label` (default "Toggle sidebar"). It
  sets `aria-expanded` to `true` while the sidebar is expanded (always, with
  `@collapsible="none"`) and `aria-controls` to the sidebar.
- `MenuToggle` is a button named by `@label` (default "Open menu"). It sets
  `aria-expanded` to `true` while the drawer is open and `aria-controls` to the
  sidebar.
- The drawer is a modal dialog named by the sidebar's `@label`. Focus stays
  inside it while it is open, and closing it returns focus to `MenuToggle`.
- In the icon rail, text inside `[data-sidebar-label]` is visually hidden but
  remains in the accessibility tree, so each link keeps its name.
- `PageHeader` renders `@title` as an `h1`.
- The inset card is decorative and hidden from assistive technology.

| Key              | Action                                                              |
| ---------------- | ------------------------------------------------------------------- |
| `Tab`            | From the top of the page, reveals and focuses the skip link         |
| `Enter`          | On the skip link, moves focus to the main content                   |
| `Cmd/Ctrl` + `B` | Collapses or expands the sidebar; below the breakpoint, opens or closes the drawer |
| `Escape`         | Closes the drawer                                                   |

## API

<Signature @component="AppLayout" />
<Signature @component="Sidebar" />
<Signature @component="SidebarToggle" />
<Signature @component="MenuToggle" />
<Signature @component="Navbar" />
<Signature @component="Main" />
<Signature @component="PageHeader" />
