---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# AppLayout

The application shell: a sidebar, a navbar, the main content and an optional
side panel, arranged for desktop and rearranged for phones.

## Import

```js
import { AppLayout } from 'frontile';
```

## Usage

`AppLayout` yields its parts, and each part places itself, so the order you
write them in does not matter. The layout fills the viewport and `Main`
scrolls on its own.

Below the `md` breakpoint the sidebar moves into a drawer, opened by
`MenuToggle`. Expand the demo and pick _Phone_ to try it.

```gts preview collapsible
import { AppLayout } from 'frontile';
import DemoFrame from 'site/components/demo-frame';
import {
  ViewIcon,
  UserIcon,
  SettingsIcon,
  SparklesIcon
} from 'site/components/icons';

<template>
  <DemoFrame @id='usage' @label='App shell'>
    <AppLayout as |layout|>
      <layout.Sidebar as |sidebar|>
        <sidebar.Header>
          <SparklesIcon class='size-5 shrink-0 text-primary' />
          <span class='truncate text-sm font-semibold' data-sidebar-label>
            Acme
          </span>
          <sidebar.Toggle class='ml-auto' />
        </sidebar.Header>
        <sidebar.Body>
          <sidebar.Item @href='#overview' @icon={{ViewIcon}} @isActive={{true}}>
            Overview
          </sidebar.Item>
          <sidebar.Item @href='#members' @icon={{UserIcon}}>
            Members
          </sidebar.Item>
          <sidebar.Item @href='#settings' @icon={{SettingsIcon}}>
            Settings
          </sidebar.Item>
        </sidebar.Body>
      </layout.Sidebar>
      <layout.Navbar>
        <layout.MenuToggle />
        <span class='text-sm font-medium'>Overview</span>
      </layout.Navbar>
      <layout.Main>
        <layout.PageHeader
          @title='Overview'
          @description='Activity across your workspace.'
        />
      </layout.Main>
    </AppLayout>
  </DemoFrame>
</template>
```

## Anatomy

| Part                           | What it is                                                                   |
| ------------------------------ | ---------------------------------------------------------------------------- |
| `Navbar`                       | The top bar, a `header` landmark                                             |
| `Sidebar`                      | The navigation column; see [Sidebar](./sidebar)                              |
| `Main`                         | The page content, the `main` landmark                                        |
| `PageHeader`                   | A title row with actions, placed inside `Main`                               |
| `Aside`                        | An optional panel beside `Main` for details or filters                       |
| `BottomNav`                    | A tab bar that replaces the sidebar on phones; see [BottomNav](./bottom-nav) |
| `MenuToggle`                   | Opens the sidebar's drawer on small screens                                  |
| `SidebarToggle`, `AsideToggle` | Collapse the sidebar, open the aside, from outside them                      |

## Variants

`inset`, the default, sets the content in a rounded card on a tinted frame.
`attached` runs the content edge to edge, with the sidebar on the same tinted
ground and borders between the sidebar, navbar and content. The layout draws
these, not the parts: a `Sidebar` on its own has neither. On phones both
variants run edge to edge.

```gts preview collapsible
import { AppLayout } from 'frontile';
import { array, concat } from '@ember/helper';
import DemoFrame from 'site/components/demo-frame';
import { ViewIcon, SettingsIcon, SparklesIcon } from 'site/components/icons';

<template>
  <div class='demo-stack demo-stack--wide'>
    {{#each (array 'inset' 'attached') as |variant|}}
      <DemoFrame @id={{variant}} @label={{concat 'Variant: ' variant}}>
        <AppLayout @variant={{variant}} as |layout|>
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
            <code class='text-sm'>@variant='{{variant}}'</code>
          </layout.Navbar>
          <layout.Main>
            <layout.PageHeader @title='Overview' />
          </layout.Main>
        </AppLayout>
      </DemoFrame>
    {{/each}}
  </div>
</template>
```

### Navbar placement

In the `inset` variant, `@navbarPlacement` decides what the navbar belongs to.
`frame`, the default, puts it on the frame with the sidebar: use it for
app-wide controls such as search and the account menu. `content` makes it the
card's first row, part of the page: use it for the page's own breadcrumb and
actions.

```gts preview collapsible
import { AppLayout, Avatar, Breadcrumbs, Button } from 'frontile';
import DemoFrame from 'site/components/demo-frame';
import {
  PackageIcon,
  SearchIcon,
  SettingsIcon,
  ViewIcon
} from 'site/components/icons';

<template>
  <div class='demo-stack demo-stack--wide'>
    <DemoFrame @id='navbar-frame' @label='Navbar placement: frame'>
      <AppLayout @navbarPlacement='frame' as |layout|>
        <layout.Sidebar @label='Frame' as |sidebar|>
          <sidebar.Body>
            <sidebar.Item @href='#overview' @icon={{ViewIcon}}>
              Overview
            </sidebar.Item>
            <sidebar.Item
              @href='#orders'
              @icon={{PackageIcon}}
              @isActive={{true}}
            >
              Orders
            </sidebar.Item>
            <sidebar.Item @href='#settings' @icon={{SettingsIcon}}>
              Settings
            </sidebar.Item>
          </sidebar.Body>
        </layout.Sidebar>
        <layout.Navbar>
          <layout.MenuToggle />
          <Button @size='xs' @variant='outline' @class='ms-auto'>
            <SearchIcon class='size-4' />
            Search
          </Button>
          <Avatar @name='Sample User' @size='sm' />
        </layout.Navbar>
        <layout.Main>
          <layout.PageHeader
            @title='Orders'
            @description='Everything placed in the last 30 days.'
          />
        </layout.Main>
      </AppLayout>
    </DemoFrame>

    <DemoFrame @id='navbar-content' @label='Navbar placement: content'>
      <AppLayout @navbarPlacement='content' as |layout|>
        <layout.Sidebar @label='Content' as |sidebar|>
          <sidebar.Body>
            <sidebar.Item @href='#overview' @icon={{ViewIcon}}>
              Overview
            </sidebar.Item>
            <sidebar.Item
              @href='#orders'
              @icon={{PackageIcon}}
              @isActive={{true}}
            >
              Orders
            </sidebar.Item>
            <sidebar.Item @href='#settings' @icon={{SettingsIcon}}>
              Settings
            </sidebar.Item>
          </sidebar.Body>
        </layout.Sidebar>
        <layout.Navbar>
          <layout.MenuToggle />
          <Breadcrumbs as |b|>
            <b.Item @href='#orders'>Orders</b.Item>
            <b.Item>#1042</b.Item>
          </Breadcrumbs>
          <Button @size='xs' @variant='outline' @class='ms-auto'>
            Refund
          </Button>
        </layout.Navbar>
        <layout.Main>
          <layout.PageHeader
            @title='Order #1042'
            @description='Paid · 3 items · Ships tomorrow'
          />
        </layout.Main>
      </AppLayout>
    </DemoFrame>
  </div>
</template>
```

## Frame gradient

The frame behind the layout is flat by default. `@frameGradient` adds a faint
left-to-right tint, strongest behind the sidebar and fading across the content:

| Value            | Look                                                                                                 |
| ---------------- | ---------------------------------------------------------------------------------------------------- |
| `neutral`        | Your theme's `neutral` at 16%, fading to a neutral grey. A neutral ground that needs no brand color. |
| `primary`        | Your theme's `primary` at 16%, fading to a neutral grey. Set your own `primary` to change the color. |
| `none` (default) | Flat: no gradient, just the variant's surface.                                                       |

The tint sits over the variant's `surface-app` or `surface-canvas` (black in
dark mode). With a gradient the inset card defaults to `translucent`, so the
tint shows through it, as black at 50% in dark mode. A flat frame keeps the
card opaque. Set `@cardSurface` to override either. Everything is built from
theme tokens, so it follows light and dark mode and nothing is hard-coded.
There is no per-color option: an app that wants a different tint sets its own
`primary` (or the stops below).

The two stops are the `--app-frame-gradient-from` and `--app-frame-gradient-to`
custom properties on the layout root. Set them through `@classes` to swap a
color and keep the gradient, or set `--app-frame-gradient` to any CSS `<image>`:

```gts
import { AppLayout } from 'frontile';
import { hash } from '@ember/helper';

<template>
  {{! Brand tint }}
  <AppLayout @frameGradient='primary' />

  {{! Neutral }}
  <AppLayout @frameGradient='neutral' />

  {{! Flat, the default }}
  <AppLayout @frameGradient='none' />

  {{! Your own stops, using theme tokens }}
  <AppLayout
    @classes={{hash
      base='[--app-frame-gradient-from:var(--color-secondary-subtle)] [--app-frame-gradient-to:transparent]'
    }}
  />
</template>
```

```gts preview collapsible
import { AppLayout } from 'frontile';
import { array } from '@ember/helper';
import DemoFrame from 'site/components/demo-frame';
import { ViewIcon, SettingsIcon, SparklesIcon } from 'site/components/icons';

<template>
  <div class='demo-stack demo-stack--wide'>
    {{#each (array 'neutral' 'primary' 'none') as |gradient|}}
      <DemoFrame @id={{gradient}} @label={{gradient}}>
        <AppLayout @frameGradient={{gradient}} as |layout|>
          <layout.Sidebar @label={{gradient}} as |sidebar|>
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
            <code class='text-sm'>@frameGradient='{{gradient}}'</code>
          </layout.Navbar>
          <layout.Main>
            <layout.PageHeader @title='Overview' />
          </layout.Main>
        </AppLayout>
      </DemoFrame>
    {{/each}}
  </div>
</template>
```

`@cardSurface` has no effect on `attached`, which has no card. The translucent
card is `surface-app` at 50%: black at 50% in dark mode, white at 50% in light.

```gts preview
import { AppLayout } from 'frontile';
import DemoFrame from 'site/components/demo-frame';

<template>
  <DemoFrame @id='frame-gradient' @label='Translucent card'>
    <AppLayout @cardSurface='translucent' as |layout|>
      <layout.Navbar>Gradient frame</layout.Navbar>
      <layout.Main>
        <layout.PageHeader @title='Overview' />
      </layout.Main>
    </AppLayout>
  </DemoFrame>
</template>
```

## Sidebar toggle

`sidebar.Toggle` sits inside the sidebar. To collapse the sidebar from
anywhere else in the layout, such as the start of the navbar, use the yielded
`layout.SidebarToggle`. Below the breakpoint the same button opens the
drawer, so it can stand in for `MenuToggle`. It pairs well with
`@collapsible='offcanvas'`, where the sidebar has no room left for a toggle of
its own.

```gts preview collapsible
import { AppLayout } from 'frontile';
import DemoFrame from 'site/components/demo-frame';
import {
  ViewIcon,
  PackageIcon,
  SettingsIcon,
  SparklesIcon
} from 'site/components/icons';

<template>
  <DemoFrame @id='navbar-toggle' @label='Sidebar toggle in the navbar'>
    <AppLayout as |layout|>
      <layout.Sidebar @collapsible='offcanvas' as |sidebar|>
        <sidebar.Header>
          <SparklesIcon class='size-5 shrink-0 text-primary' />
          <span class='truncate text-sm font-semibold'>Acme</span>
        </sidebar.Header>
        <sidebar.Body>
          <sidebar.Item @href='#overview' @icon={{ViewIcon}} @isActive={{true}}>
            Overview
          </sidebar.Item>
          <sidebar.Item @href='#orders' @icon={{PackageIcon}}>
            Orders
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
  </DemoFrame>
</template>
```

## Responsive navigation

Below `@breakpoint` (`sm` 40rem, `md` 48rem by default, `lg` 64rem) the
sidebar leaves the page. These are Tailwind's default breakpoints, read in
JavaScript, so changing `--breakpoint-*` in your theme does not move them.

By default (`@mobileNav='drawer'`) it opens as a drawer from its side, as in
[Usage](#usage). Put a `MenuToggle` in the navbar to open it; it shows only
below the breakpoint, and `sidebar.Toggle` hides there, so one set of markup
works at every width. The drawer closes on <kbd>Escape</kbd>, a click outside,
a followed `Item`, or when the window grows past the breakpoint.

With `@mobileNav='bottom'` the layout shows its [BottomNav](./bottom-nav) as
a tab bar instead, and the sidebar and its toggles render nothing. Write both
the `Sidebar` and the `BottomNav`; each appears at its own width. Place
`BottomNav` after `Main`. Expand this demo and pick _Phone_.

```gts preview collapsible
import { AppLayout } from 'frontile';
import DemoFrame from 'site/components/demo-frame';
import {
  ViewIcon,
  UserIcon,
  SettingsIcon,
  SparklesIcon
} from 'site/components/icons';

<template>
  <DemoFrame @id='bottom-nav' @label='Bottom navigation'>
    <AppLayout @mobileNav='bottom' as |layout|>
      <layout.Sidebar as |sidebar|>
        <sidebar.Header>
          <SparklesIcon class='size-5 shrink-0 text-primary' />
          <span class='truncate text-sm font-semibold' data-sidebar-label>
            Acme
          </span>
          <sidebar.Toggle class='ml-auto' />
        </sidebar.Header>
        <sidebar.Body>
          <sidebar.Item @href='#home' @icon={{ViewIcon}} @isActive={{true}}>
            Home
          </sidebar.Item>
          <sidebar.Item @href='#people' @icon={{UserIcon}} @badge={{2}}>
            People
          </sidebar.Item>
          <sidebar.Item @href='#settings' @icon={{SettingsIcon}}>
            Settings
          </sidebar.Item>
        </sidebar.Body>
      </layout.Sidebar>
      <layout.Navbar>
        <span class='text-sm font-medium'>Home</span>
      </layout.Navbar>
      <layout.Main>
        <layout.PageHeader @title='Home' />
      </layout.Main>
      <layout.BottomNav as |bar|>
        <bar.Item @href='#home' @icon={{ViewIcon}} @isActive={{true}}>
          Home
        </bar.Item>
        <bar.Item @href='#people' @icon={{UserIcon}} @badge={{2}}>
          People
        </bar.Item>
        <bar.Item @href='#settings' @icon={{SettingsIcon}}>
          Settings
        </bar.Item>
      </layout.BottomNav>
    </AppLayout>
  </DemoFrame>
</template>
```

The sidebar's block remounts when the window crosses the breakpoint, so state
held by components inside it starts over.

## Sidebar side

`@sidebarSide='end'` moves the sidebar to the last column, the aside to the
first, and the drawer to the end edge. Sides are logical, so `start` is the
right in a right-to-left page.

```gts preview collapsible
import { AppLayout } from 'frontile';
import DemoFrame from 'site/components/demo-frame';
import { ViewIcon, SettingsIcon } from 'site/components/icons';

<template>
  <DemoFrame @id='sidebar-end' @label='Sidebar on the end'>
    <AppLayout @variant='attached' @sidebarSide='end' as |layout|>
      <layout.Sidebar as |sidebar|>
        <sidebar.Header><sidebar.Toggle class='mr-auto' /></sidebar.Header>
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
        <span class='text-sm font-medium'>Overview</span>
        <layout.MenuToggle class='ms-auto' />
      </layout.Navbar>
      <layout.Main>
        <layout.PageHeader @title='Overview' />
      </layout.Main>
    </AppLayout>
  </DemoFrame>
</template>
```

## Aside

`Aside` is a panel beside `Main` for details, filters or help, shown while
the layout's `asideOpen` is true. `AsideToggle` opens and closes it, and
renders nothing while the layout has no `Aside`, so a page without one shows
no toggle. From `lg` (64rem) up it is a column and `Main` narrows; below `lg`
the same block opens as a drawer.

If the window narrows while the aside is open, it closes rather than popping
up as a drawer. A layout that starts with the aside open on a narrow screen
does open the drawer, so set `@defaultAsideOpen` only where the window is
wide.

```gts preview collapsible
import { AppLayout } from 'frontile';
import DemoFrame from 'site/components/demo-frame';

<template>
  <DemoFrame @id='aside' @label='Aside'>
    <AppLayout as |layout|>
      <layout.Navbar>
        <span class='text-sm font-medium'>Access management</span>
        <layout.AsideToggle class='ms-auto' />
      </layout.Navbar>
      <layout.Main>
        <layout.PageHeader @title='Roles' />
      </layout.Main>
      <layout.Aside @label='Role details'>
        <h2 class='font-semibold'>Administrator</h2>
        <p class='mt-1 text-sm text-neutral-firm'>
          Full access to every workspace.
        </p>
      </layout.Aside>
    </AppLayout>
  </DemoFrame>
</template>
```

## Page header

`PageHeader` is the title row at the top of `Main`: a `@title`, a
`@description`, buttons in `<:actions>`, and anything else under the title in
`<:default>`.

```gts preview collapsible
import { AppLayout, Button, Chip } from 'frontile';
import DemoFrame from 'site/components/demo-frame';

<template>
  <DemoFrame @id='page-header' @label='Page header'>
    <AppLayout as |layout|>
      <layout.Navbar>
        <span class='text-sm font-medium'>Access management</span>
      </layout.Navbar>
      <layout.Main>
        <layout.PageHeader
          @title='Roles'
          @description='Roles group the permissions you grant to people.'
        >
          <:actions>
            <Button @size='xs' @variant='outline'>Export</Button>
            <Button @size='xs' @color='primary'>New role</Button>
          </:actions>
          <:default>
            <Chip @size='sm'>12 roles</Chip>
          </:default>
        </layout.PageHeader>
      </layout.Main>
    </AppLayout>
  </DemoFrame>
</template>
```

## Scrolling

By default (`@scrollMode='content'`) the layout is the height of the viewport
and `Main` scrolls. With `@scrollMode='page'` the layout grows with its
content and the document scrolls, while the sidebar sticks to the top and a
`BottomNav` to the bottom. Use `page` when the browser's own scrolling
matters: scroll restoration, anchor links, pull-to-refresh on phones.

```gts preview collapsible
import { AppLayout } from 'frontile';
import { array } from '@ember/helper';
import DemoFrame from 'site/components/demo-frame';
import { BookIcon, ViewIcon } from 'site/components/icons';

<template>
  <DemoFrame @id='page-scroll' @label='Page scrolling'>
    <AppLayout @scrollMode='page' @variant='attached' as |layout|>
      <layout.Sidebar @label='Guides' as |sidebar|>
        <sidebar.Body>
          <sidebar.Item @href='#start' @icon={{BookIcon}} @isActive={{true}}>
            Getting started
          </sidebar.Item>
          <sidebar.Item @href='#concepts' @icon={{ViewIcon}}>
            Concepts
          </sidebar.Item>
        </sidebar.Body>
      </layout.Sidebar>
      <layout.Navbar>
        <layout.MenuToggle />
        <span class='text-sm font-medium'>Guides</span>
      </layout.Navbar>
      <layout.Main>
        <layout.PageHeader @title='Getting started' />
        <div class='flex flex-col gap-4 px-4 pb-8 text-sm text-neutral-firm'>
          {{#each (array 1 2 3 4 5 6 7 8) as |step|}}
            <section>
              <h2 class='font-semibold text-neutral-strong'>Step {{step}}</h2>
              <p>Scroll the page: the sidebar stays where it is.</p>
            </section>
          {{/each}}
        </div>
      </layout.Main>
    </AppLayout>
  </DemoFrame>
</template>
```

## State

The layout tracks `sidebarCollapsed`, `mobileSidebarOpen` and `asideOpen`, and
yields them as `layout.state` with methods that change them:
`toggleSidebar`, `collapseSidebar`, `expandSidebar`, `openMobileSidebar`,
`closeMobileSidebar`, `toggleAside` and `closeAside`. Pass a method straight
to `@onPress` or `{{on}}`.

Each value can be:

- **Uncontrolled**: `@defaultSidebarCollapsed`, `@defaultMobileSidebarOpen`
  and `@defaultAsideOpen` set where it starts.
- **Controlled**: `@sidebarCollapsed`, `@mobileSidebarOpen` and `@asideOpen`
  set it, and the matching `@on…Change` callback receives the requested
  value. The layout changes once you update the argument.
- **Shared**: an `AppLayoutState` passed as `@state`. Anything holding it can
  read and change the layout. The individual arguments are then ignored.

```gts preview collapsible
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { AppLayout, Button } from 'frontile';
import DemoFrame from 'site/components/demo-frame';

export default class ControlledAsideExample extends Component {
  @tracked asideOpen = false;

  setAsideOpen = (value: boolean) => {
    this.asideOpen = value;
  };

  <template>
    <DemoFrame @id='controlled' @label='Controlled aside'>
      <AppLayout
        @asideOpen={{this.asideOpen}}
        @onAsideOpenChange={{this.setAsideOpen}}
        as |layout|
      >
        <layout.Navbar>
          <span class='text-sm font-medium'>Billing</span>
          <Button
            @size='xs'
            @class='ms-auto'
            @onPress={{layout.state.toggleAside}}
          >
            {{if this.asideOpen 'Hide details' 'Show details'}}
          </Button>
        </layout.Navbar>
        <layout.Main>
          <layout.PageHeader @title='Invoices' />
        </layout.Main>
        <layout.Aside @label='Invoice details'>
          <p class='text-sm'>Invoice #1042 · Paid</p>
        </layout.Aside>
      </AppLayout>
    </DemoFrame>
  </template>
}
```

### From outside the layout

Create an `AppLayoutState` where both sides can reach it, such as a service,
and pass it to the layout as `@state`. Each layout has its own state, so two
layouts on a page stay independent.

```gts preview collapsible
import Component from '@glimmer/component';
import type { TOC } from '@ember/component/template-only';
import { AppLayout, AppLayoutState, Button } from 'frontile';
import DemoFrame from 'site/components/demo-frame';

const DetailsButton: TOC<{ Args: { state: AppLayoutState } }> = <template>
  <Button @size='xs' @onPress={{@state.toggleAside}}>
    {{if @state.asideOpen 'Hide details' 'Show details'}}
  </Button>
</template>;

export default class SharedStateExample extends Component {
  state = new AppLayoutState();

  <template>
    <div class='demo-stack demo-stack--wide'>
      <DetailsButton @state={{this.state}} />
      <DemoFrame @id='shared' @label='Shared state'>
        <AppLayout @state={{this.state}} as |layout|>
          <layout.Navbar>
            <span class='text-sm font-medium'>Reports</span>
            <layout.AsideToggle class='ms-auto' />
          </layout.Navbar>
          <layout.Main>
            <layout.PageHeader @title='Monthly report' />
          </layout.Main>
          <layout.Aside @label='Report details'>
            <p class='text-sm'>Generated on the 1st of each month.</p>
          </layout.Aside>
        </AppLayout>
      </DemoFrame>
    </div>
  </template>
}
```

## Sizing tokens

The layout sets its sizes as CSS custom properties on its root, for your own
elements to line up with:

| Property                 | Value                                                                     |
| ------------------------ | ------------------------------------------------------------------------- |
| `--app-navbar-height`    | `3rem`                                                                    |
| `--app-sidebar-width`    | The sidebar column's width, including the `inset` gutter; `0px` when none |
| `--app-bottomnav-height` | The bottom bar's height, including the safe-area inset; `0px` when hidden |

The width and bottom-bar tokens are set after the first render, so give them a
fallback. A toolbar fixed under the navbar and beside the sidebar:

```gts
<div
  class='fixed end-0'
  style='top: var(--app-navbar-height, 3rem); inset-inline-start: var(--app-sidebar-width, 0px);'
>
  Filters
</div>
```

## Examples

### Dashboard

A workspace with grouped navigation, a folder, an account menu in the
navbar, page actions and a details panel.

```gts preview collapsible
import { AppLayout, Avatar, Button } from 'frontile';
import { array } from '@ember/helper';
import DemoFrame from 'site/components/demo-frame';
import {
  ViewIcon,
  PackageIcon,
  BookIcon,
  StarIcon,
  SettingsIcon,
  SearchIcon,
  PlusIcon,
  SparklesIcon
} from 'site/components/icons';

<template>
  <DemoFrame @id='dashboard' @label='Dashboard'>
    <AppLayout as |layout|>
      <layout.Sidebar @label='Workspace' as |sidebar|>
        <sidebar.Header>
          <SparklesIcon class='size-5 shrink-0 text-primary' />
          <span class='truncate text-sm font-semibold' data-sidebar-label>
            Acme
          </span>
          <sidebar.Toggle class='ml-auto' />
        </sidebar.Header>
        <sidebar.Body>
          <sidebar.Item @href='#overview' @icon={{ViewIcon}} @isActive={{true}}>
            Overview
          </sidebar.Item>
          <sidebar.Folder @label='Products' @icon={{PackageIcon}} as |folder|>
            <folder.Item @href='#catalog'>Catalog</folder.Item>
            <folder.Item @href='#pricing'>Pricing</folder.Item>
          </sidebar.Folder>
          <sidebar.Item @href='#orders' @icon={{BookIcon}} @badge={{4}}>
            Orders
          </sidebar.Item>
          <sidebar.Group @label='Saved'>
            <sidebar.Item @href='#q3' @icon={{StarIcon}}>Q3 review</sidebar.Item>
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
        <Button @size='xs' @variant='outline' @class='ms-auto'>
          <SearchIcon class='size-4' />
          Search
        </Button>
        <layout.AsideToggle />
        <Avatar @name='Sample User' @size='sm' />
      </layout.Navbar>
      <layout.Main>
        <layout.PageHeader
          @title='Overview'
          @description='The last 30 days in your workspace.'
        >
          <:actions>
            <Button @size='xs' @color='primary'>
              <PlusIcon class='size-4' />
              New order
            </Button>
          </:actions>
        </layout.PageHeader>
        <div class='grid gap-3 px-4 pb-4 sm:grid-cols-3'>
          {{#each (array 'Revenue' 'Orders' 'Customers') as |metric|}}
            <div class='rounded-lg border border-neutral-soft p-4'>
              <p class='text-sm text-neutral-firm'>{{metric}}</p>
              <p class='mt-1 text-xl font-semibold'>—</p>
            </div>
          {{/each}}
        </div>
      </layout.Main>
      <layout.Aside @label='Activity'>
        <h2 class='font-semibold'>Activity</h2>
        <p class='mt-1 text-sm text-neutral-firm'>No new activity.</p>
      </layout.Aside>
    </AppLayout>
  </DemoFrame>
</template>
```

### List and detail

Selecting a row opens its details in the aside, through `layout.state`. On a
phone the details open as a drawer.

```gts preview collapsible
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { AppLayout, AppLayoutState, Listbox } from 'frontile';
import DemoFrame from 'site/components/demo-frame';

const PEOPLE: Record<string, { role: string; team: string }> = {
  'Avery Kim': { role: 'Administrator', team: 'Platform' },
  'Blake Moreno': { role: 'Editor', team: 'Marketing' },
  'Casey Lin': { role: 'Viewer', team: 'Finance' }
};

export default class ListDetailExample extends Component {
  state = new AppLayoutState();
  people = Object.keys(PEOPLE);
  @tracked selected: string[] = [];

  get person() {
    const name = this.selected[0];
    return name ? { name, ...PEOPLE[name] } : undefined;
  }

  select = (keys: string[]) => {
    this.selected = keys;
    this.state.asideOpen = keys.length > 0;
  };

  <template>
    <DemoFrame @id='list-detail' @label='List and detail'>
      <AppLayout @state={{this.state}} as |layout|>
        <layout.Navbar>
          <span class='text-sm font-medium'>People</span>
        </layout.Navbar>
        <layout.Main>
          <layout.PageHeader @title='People' />
          <div class='px-2'>
            <Listbox
              @selectionMode='single'
              @items={{this.people}}
              @selectedKeys={{this.selected}}
              @onSelectionChange={{this.select}}
            />
          </div>
        </layout.Main>
        <layout.Aside @label='Person details'>
          {{#if this.person}}
            <h2 class='font-semibold'>{{this.person.name}}</h2>
            <p class='mt-1 text-sm text-neutral-firm'>
              {{this.person.role}}
              ·
              {{this.person.team}}
            </p>
          {{/if}}
        </layout.Aside>
      </AppLayout>
    </DemoFrame>
  </template>
}
```

### Rail and bottom bar

A mobile-first app: a rail of stacked items on desktop, and on a phone a top
bar, a bottom tab bar and a More sheet. The active page is a tracked value
so the demo needs no router; in an app, pass `@route` instead. The account
buttons are your own markup.

```gts preview collapsible
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import { AppLayout, Avatar } from 'frontile';
import DemoFrame from 'site/components/demo-frame';
import {
  ViewIcon,
  PackageIcon,
  BookIcon,
  StarIcon,
  UserIcon,
  SparklesIcon
} from 'site/components/icons';

const PAGES = [
  { id: 'overview', label: 'Overview', icon: ViewIcon, badge: 2 },
  { id: 'services', label: 'Services', icon: PackageIcon },
  { id: 'billing', label: 'Billing', icon: BookIcon },
  { id: 'market', label: 'Marketplace', short: 'Market', icon: StarIcon },
  {
    id: 'referrals',
    label: 'Referral program',
    short: 'Referrals',
    icon: UserIcon
  },
  { id: 'support', label: 'Support', icon: SparklesIcon }
];

export default class RailAppExample extends Component {
  @tracked page = 'overview';

  go = (id: string) => {
    this.page = id;
  };

  get items() {
    return PAGES.map((p) => ({ ...p, isActive: p.id === this.page }));
  }

  // The first four pages are tabs on a phone; the rest go in More.
  get tabs() {
    return this.items.slice(0, 4);
  }

  get more() {
    return this.items.slice(4);
  }

  get title() {
    return PAGES.find((p) => p.id === this.page)?.label;
  }

  <template>
    <DemoFrame @id='rail-app' @label='Rail and bottom bar'>
      <AppLayout @variant='attached' @mobileNav='bottom' as |layout|>
        <layout.Sidebar @size='rail' @collapsible='none' as |sidebar|>
          <sidebar.Header>
            <SparklesIcon class='size-5 shrink-0 text-primary' />
          </sidebar.Header>
          <sidebar.Body>
            {{#each this.items as |item|}}
              <sidebar.Item
                @layout='stacked'
                @icon={{item.icon}}
                @shortLabel={{item.short}}
                @isActive={{item.isActive}}
                @badge={{item.badge}}
                {{on 'click' (fn this.go item.id)}}
              >{{item.label}}</sidebar.Item>
            {{/each}}
          </sidebar.Body>
          <sidebar.Footer>
            <Avatar @name='Sample User' @size='sm' class='mx-auto' />
          </sidebar.Footer>
        </layout.Sidebar>
        <layout.Navbar class='md:hidden'>
          <SparklesIcon class='size-5 shrink-0 text-primary' />
          <span class='text-sm font-medium'>{{this.title}}</span>
          <Avatar @name='Sample User' @size='sm' class='ms-auto' />
        </layout.Navbar>
        <layout.Main>
          <layout.PageHeader @title={{this.title}} />
        </layout.Main>
        <layout.BottomNav as |bar|>
          {{#each this.tabs as |item|}}
            <bar.Item
              @icon={{item.icon}}
              @badge={{item.badge}}
              @isActive={{item.isActive}}
              {{on 'click' (fn this.go item.id)}}
            >{{item.label}}</bar.Item>
          {{/each}}
          <bar.More as |more|>
            {{#each this.more as |item|}}
              <more.Item
                @icon={{item.icon}}
                @isActive={{item.isActive}}
                {{on 'click' (fn this.go item.id)}}
              >{{item.label}}</more.Item>
            {{/each}}
          </bar.More>
        </layout.BottomNav>
      </AppLayout>
    </DemoFrame>
  </template>
}
```

## Accessibility

- `Navbar` is a `header` landmark and `Main` the `main` landmark. Render one
  `AppLayout` per page so there is one of each.
- A "Skip to main content" link is the first focusable element, visible only
  while focused. Change its text with `@skipLinkLabel`, or remove it with
  `@skipLink={{false}}` if the app has its own.
- The sidebar's drawer is a modal dialog named by the sidebar's `@label`.
  Focus stays inside while it is open and returns to the element that opened
  it.
- `MenuToggle` (default "Open menu"), `SidebarToggle` (default "Toggle
  sidebar") and `AsideToggle` (default "Toggle details") are buttons named by
  `@label`, with `aria-expanded`. `aria-controls` names what they open while
  it is on the page, so a drawer is named only while it is open. Without a
  `Sidebar` (or an `Aside`) in the layout, its toggles render nothing.
- `Aside` is an `aside` landmark named by `@label` (default `Details`); as a
  drawer, the dialog has the same name.
- `PageHeader` renders `@title` as an `h1`.
- With `@mobileNav='bottom'` on a phone, the `BottomNav` is the page's
  navigation; see [BottomNav](./bottom-nav#accessibility).
- Items, groups and folders are covered on the [Sidebar](./sidebar#accessibility) page.

| Key               | Action                                                    |
| ----------------- | --------------------------------------------------------- |
| <kbd>Tab</kbd>    | From the top of the page, shows and focuses the skip link |
| <kbd>Escape</kbd> | Closes the open drawer                                    |

## API

<Signature @component="AppLayout" />

### Navbar

<Signature @component="Navbar" />

### Main

<Signature @component="Main" />

### PageHeader

<Signature @component="PageHeader" />

### Aside

<Signature @component="Aside" />

### AsideToggle

<Signature @component="AsideToggle" />

### MenuToggle

<Signature @component="MenuToggle" />
