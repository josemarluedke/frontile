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

`inset`, the default, sets the content in a rounded card on a tinted frame, and
the sidebar sits directly on that frame with no border of its own. `attached`
runs the content edge to edge: the sidebar becomes its own bordered surface
and the navbar gets a border underneath instead of a card.

```gts preview
import { AppLayout } from 'frontile';
import { array } from '@ember/helper';
import { ViewIcon, SettingsIcon, SparklesIcon } from 'site/components/icons';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    {{#each (array 'inset' 'attached') as |variant|}}
      <AppLayout @variant={{variant}} class='demo-app-layout' as |layout|>
        <layout.Sidebar @label={{variant}} as |sidebar|>
          <sidebar.Header>
            <sidebar.Brand @title='Acme' @href='#'>
              <:logo><SparklesIcon /></:logo>
            </sidebar.Brand>
          </sidebar.Header>
          <sidebar.Body>
            <sidebar.Item @href='#overview' @icon={{ViewIcon}} @isActive={{true}}>
              Overview
            </sidebar.Item>
            <sidebar.Item @href='#settings' @icon={{SettingsIcon}}>
              Settings
            </sidebar.Item>
          </sidebar.Body>
        </layout.Sidebar>
        <layout.Navbar>
          <layout.SidebarToggle />
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
            <sidebar.Brand @title='Acme' @href='#'>
              <:logo><SparklesIcon /></:logo>
            </sidebar.Brand>
          </sidebar.Header>
          <sidebar.Body>
            <sidebar.Item @href='#overview' @icon={{ViewIcon}} @isActive={{true}}>
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

`Sidebar` is a full-height `nav` landmark that takes the first column. It
yields `Header`, `Body` and `Footer` sections, `Item` links, `Group` and
`Brand`. Give
it a name with `@label` (default `Main`); if the page has more than one
navigation, each needs its own. Render one `Sidebar` per layout: the layout
gives its sidebar a fixed id, so a second one would repeat it.
`SidebarToggle` is a button that collapses and expands it.

By default the sidebar collapses to an icon rail. Each `Item`'s label is then
visually hidden but still names the link for screen readers, and it shows as
a tooltip on hover or focus. For your own markup in the header, body or
footer, wrap the text in `<span data-sidebar-label>` to hide it in the rail
the same way.

```gts preview
import { AppLayout } from 'frontile';
import { ViewIcon, SettingsIcon, SparklesIcon } from 'site/components/icons';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    <AppLayout class='demo-app-layout' as |layout|>
      <layout.Sidebar @label='Workspace' as |sidebar|>
        <sidebar.Header>
          <sidebar.Brand @title='Acme' @href='#'>
            <:logo><SparklesIcon /></:logo>
          </sidebar.Brand>
        </sidebar.Header>
        <sidebar.Body>
          <sidebar.Item @href='#overview' @icon={{ViewIcon}} @isActive={{true}}>
            Overview
          </sidebar.Item>
          <sidebar.Item @href='#settings' @icon={{SettingsIcon}}>
            Settings
          </sidebar.Item>
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

### Brand

`Brand` shows the product's logo and name, and goes in the `Header`. Pass
the name as `@title`, an optional second line as `@subtitle`, and the logo in
the `<:logo>` block. With `@href` the logo and text are one link, named by the
title. Brand is optional: the header takes any markup.

The logo sits in a 2rem square on a `primary` tile. In the icon rail only the
logo shows, centered over the item icons; the title and subtitle are visually
hidden but still name the link. Collapse this one with the toggle to see it.

```gts preview
import { AppLayout } from 'frontile';
import { ViewIcon, SettingsIcon, SparklesIcon } from 'site/components/icons';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    <AppLayout class='demo-app-layout' as |layout|>
      <layout.Sidebar @label='Workspace' as |sidebar|>
        <sidebar.Header>
          <sidebar.Brand @title='Acme' @subtitle='Workspace' @href='#'>
            <:logo><SparklesIcon /></:logo>
          </sidebar.Brand>
        </sidebar.Header>
        <sidebar.Body>
          <sidebar.Item @href='#overview' @icon={{ViewIcon}} @isActive={{true}}>
            Overview
          </sidebar.Item>
          <sidebar.Item @href='#settings' @icon={{SettingsIcon}}>
            Settings
          </sidebar.Item>
        </sidebar.Body>
      </layout.Sidebar>
      <layout.Navbar>
        <layout.SidebarToggle />
        <span class='text-sm font-medium'>Overview</span>
      </layout.Navbar>
      <layout.Main>
        <layout.PageHeader @title='Overview' />
      </layout.Main>
    </AppLayout>
  </div>
</template>
```

When your logo has its own colors, set `@tile={{false}}` to show it as is, in
the same square. For a header `Brand` does not fit, write your own markup and
wrap its text in `<span data-sidebar-label>` so the rail hides it, as the
second layout here does.

```gts preview
import { AppLayout } from 'frontile';
import { ViewIcon, RocketIcon } from 'site/components/icons';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    <AppLayout @variant='attached' class='demo-app-layout' as |layout|>
      <layout.Sidebar @label='Own logo' as |sidebar|>
        <sidebar.Header>
          <sidebar.Brand @title='Rocketry' @tile={{false}}>
            <:logo><RocketIcon class='text-primary' /></:logo>
          </sidebar.Brand>
        </sidebar.Header>
        <sidebar.Body>
          <sidebar.Item @href='#launches' @icon={{ViewIcon}} @isActive={{true}}>
            Launches
          </sidebar.Item>
        </sidebar.Body>
      </layout.Sidebar>
      <layout.Navbar>
        <layout.SidebarToggle />
        <span class='text-sm font-medium'>@tile=false</span>
      </layout.Navbar>
      <layout.Main />
    </AppLayout>
    <AppLayout @variant='attached' class='demo-app-layout' as |layout|>
      <layout.Sidebar @label='Custom header' as |sidebar|>
        <sidebar.Header>
          <RocketIcon class='shrink-0 text-primary' />
          <span class='truncate text-sm font-semibold' data-sidebar-label>
            Rocketry
          </span>
        </sidebar.Header>
        <sidebar.Body>
          <sidebar.Item @href='#launches' @icon={{ViewIcon}} @isActive={{true}}>
            Launches
          </sidebar.Item>
        </sidebar.Body>
      </layout.Sidebar>
      <layout.Navbar>
        <layout.SidebarToggle />
        <span class='text-sm font-medium'>Custom header</span>
      </layout.Navbar>
      <layout.Main />
    </AppLayout>
  </div>
</template>
```

### Items and groups

`Item` is a link with an optional `@icon` and its label as the block. It takes
the same routing arguments as `TabNav.Item`. With `@href` it is a plain anchor
and needs no router; set `@isActive` to mark the current page. The active item
has `aria-current="page"`.

`@isDisabled` drops the href so the link cannot be followed. `@isHidden`
renders nothing, for items the current user should not see.

`Group` puts a heading over a set of items and names the group after it with
`@label`. In the rail the heading is visually hidden.

```gts preview
import { AppLayout } from 'frontile';
import {
  ViewIcon,
  StarIcon,
  ArchiveIcon,
  SettingsIcon,
  DeleteIcon
} from 'site/components/icons';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    <AppLayout class='demo-app-layout' as |layout|>
      <layout.Sidebar @label='Projects' as |sidebar|>
        <sidebar.Body>
          <sidebar.Group @label='Projects'>
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
          </sidebar.Group>
          <sidebar.Group @label='Admin'>
            <sidebar.Item @href='#settings' @icon={{SettingsIcon}}>
              Settings
            </sidebar.Item>
            <sidebar.Item
              @href='#purge'
              @icon={{DeleteIcon}}
              @isHidden={{true}}
            >
              Purge data
            </sidebar.Item>
          </sidebar.Group>
        </sidebar.Body>
      </layout.Sidebar>
      <layout.Navbar>
        <layout.SidebarToggle />
        <span class='text-sm font-medium'>Projects</span>
      </layout.Navbar>
      <layout.Main>
        <layout.PageHeader @title='All projects' />
      </layout.Main>
    </AppLayout>
  </div>
</template>
```

### Linking to routes

Pass `@route` (with `@model`, `@models` or `@query` as needed) and `Item`
renders an Ember `LinkTo` and asks the router whether it is active, so no
`@isActive` is needed. It is not rendered on this page, since the docs site has
no matching routes.

```gts
import { AppLayout } from 'frontile';
import { ViewIcon, UserIcon } from 'my-app/components/icons';

<template>
  <AppLayout as |layout|>
    <layout.Sidebar as |sidebar|>
      <sidebar.Body>
        <sidebar.Item @route='dashboard' @icon={{ViewIcon}}>
          Dashboard
        </sidebar.Item>
        <sidebar.Item @route='users.show' @model={{@currentUser.id}} @icon={{UserIcon}}>
          My profile
        </sidebar.Item>
      </sidebar.Body>
    </layout.Sidebar>
    <layout.Main>{{outlet}}</layout.Main>
  </AppLayout>
</template>
```

`@isActive` always wins over the router. The router counts a route as active
while any of its child routes is, so `@route='users'` stays active on
`users.show`; pass `@isActive` if only the exact route should light up.

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
            <sidebar.Item @href='#home' @icon={{ViewIcon}}>Home</sidebar.Item>
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
          <sidebar.Item @href='#home'>Home</sidebar.Item>
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
leaves the grid and opens as a drawer instead. These are Tailwind's default
breakpoints, and the layout measures them in JavaScript: an app that changes
`--breakpoint-sm`, `--breakpoint-md` or `--breakpoint-lg` in its theme moves
the CSS but not the layout's switch, so the two can disagree.

Below the breakpoint `SidebarToggle` opens the drawer, so on its own it covers
every width. For a separate menu button on narrow screens, put a `MenuToggle`
in the navbar, top-left by convention. `MenuToggle` shows only below the
breakpoint; to show only one button at each width, hide `SidebarToggle` below
it with `@classes`, as this demo does.

The drawer shows the same `Sidebar` block, so you write the sidebar once. It
slides in from the sidebar's side (`@sidebarSide`, following the document's
direction), always expanded. It closes on Escape, on a click outside it, from
its close button, when an `Item` in it is clicked, or when the window grows
past the breakpoint. The `Sidebar` block remounts whenever the window crosses
the breakpoint, so any state held by the components inside it starts over.

Narrow the window to below 48rem to open this one.

```gts preview
import { hash } from '@ember/helper';
import { AppLayout } from 'frontile';
import { ViewIcon, SettingsIcon, SparklesIcon } from 'site/components/icons';

<template>
  <div class='demo-stack demo-stack--wide not-prose'>
    <AppLayout
      class='demo-app-layout'
      @classes={{hash sidebarToggle='hidden md:inline-flex'}}
      as |layout|
    >
      <layout.Sidebar @label='Workspace' as |sidebar|>
        <sidebar.Header>
          <sidebar.Brand @title='Acme' @href='#'>
            <:logo><SparklesIcon /></:logo>
          </sidebar.Brand>
        </sidebar.Header>
        <sidebar.Body>
          <sidebar.Item @href='#overview' @icon={{ViewIcon}}>
            Overview
          </sidebar.Item>
          <sidebar.Item @href='#settings' @icon={{SettingsIcon}}>
            Settings
          </sidebar.Item>
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
opens or closes the drawer below the breakpoint. With focus inside a layout,
only that layout toggles. With focus on the page body, the shortcut toggles
every `AppLayout` on the page; turn it off on the others with
`@toggleShortcut={{false}}`. Pick another combination with `@toggleShortcut`,
such as `'mod+shift+s'`.

The shortcut does nothing while focus is in editable content
(`contenteditable`), where the browser's own <kbd>Cmd</kbd>+<kbd>B</kbd>
makes text bold, and it does not repeat while the keys are held down.

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
          <sidebar.Item @href='#daily'>Daily</sidebar.Item>
        </sidebar.Body>
      </Sidebar>
      <SidebarToggle @state={{this.state}} @controls='standalone-sidebar' />
    </div>
  </template>
}
```

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

```gts preview
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
with its content and the document scrolls instead, while the sidebar sticks
to the top of the viewport (inside the frame's gutter with `inset`).

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

## Putting it together

Every part in one layout, driven by one `AppLayoutState`: a sidebar with
items and a group, both toggles, a navbar, a page header, the main content,
and an aside with its toggle. Narrow the window to see the drawers.

```gts preview
import Component from '@glimmer/component';
import { hash } from '@ember/helper';
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
      <AppLayout
        @state={{this.state}}
        @classes={{hash sidebarToggle='hidden md:inline-flex'}}
        class='demo-app-layout'
        as |layout|
      >
        <layout.Sidebar @label='Workspace' as |sidebar|>
          <sidebar.Header>
            <sidebar.Brand @title='Acme' @subtitle='Projects' @href='#'>
              <:logo><SparklesIcon /></:logo>
            </sidebar.Brand>
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
          <layout.SidebarToggle />
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
            Sidebar collapsed: {{if this.state.sidebarCollapsed 'yes' 'no'}}.
            Details open: {{if this.state.asideOpen 'yes' 'no'}}.
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
- `SidebarToggle` is a button named by `@label` (default "Toggle sidebar"). It
  sets `aria-expanded` to `true` while the sidebar is expanded (always, with
  `@collapsible="none"`) and `aria-controls` to the sidebar. Below the
  breakpoint it opens the drawer, and `aria-expanded` follows the drawer.
- `MenuToggle` is a button named by `@label` (default "Open menu"). It sets
  `aria-expanded` to `true` while the drawer is open and `aria-controls` to the
  sidebar.
- The drawer is a modal dialog named by the sidebar's `@label`. Focus stays
  inside it while it is open. Closing it returns focus to the element that
  opened it: the toggle that opened it, otherwise the element that had focus
  when the shortcut was pressed (`MenuToggle` if focus was on the page body).
- `Item` is a link. The active item has `aria-current="page"`. A disabled
  item has no href and has `aria-disabled="true"`. Its `@icon` is hidden from
  assistive technology, so the label is the link's name.
- In the icon rail, `Item` labels, `Group` headings and text inside
  `[data-sidebar-label]` are visually hidden but remain in the accessibility
  tree, so each link keeps its name. Hovering or focusing an `Item` in the
  rail shows its label as a tooltip.
- `Group` renders a `group` named by its `@label`.
- `Brand` with `@href` is a link named by its `@title` (and `@subtitle`).
  In the rail its text is visually hidden but keeps naming the link.
- `Aside` renders an `aside` landmark named by `@label` (default `Details`);
  in the drawer the dialog and the landmark inside it share that name.
- `AsideToggle` is a button named by `@label` (default "Toggle details"). It
  sets `aria-expanded` to `true` while the aside is open and `aria-controls` to
  the aside. Closing the drawer returns focus to the toggle.
- `PageHeader` renders `@title` as an `h1`.
- The inset card is decorative and hidden from assistive technology.

| Key              | Action                                                              |
| ---------------- | ------------------------------------------------------------------- |
| `Tab`            | From the top of the page, reveals and focuses the skip link         |
| `Enter`          | On the skip link, moves focus to the main content                   |
| `Cmd/Ctrl` + `B` | Collapses or expands the sidebar; below the breakpoint, opens or closes the drawer |
| `Escape`         | Closes the drawer (sidebar or aside)                                                 |

## API

<Signature @component="AppLayout" />
<Signature @component="Sidebar" />
<Signature @component="SidebarItem" />
<Signature @component="SidebarGroup" />
<Signature @component="SidebarBrand" />
<Signature @component="SidebarToggle" />
<Signature @component="MenuToggle" />
<Signature @component="Aside" />
<Signature @component="AsideToggle" />
<Signature @component="Navbar" />
<Signature @component="Main" />
<Signature @component="PageHeader" />
