---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# AppLayout

The application shell: a navbar and a main content area, with a sidebar and
an aside joining them in the next release. Reach for it to give every page of
an app the same frame.

> Note: `Sidebar`, `SidebarToggle`, `MenuToggle`, `Aside` and `AsideToggle`
> arrive with the next phase of `AppLayout`. The demos below use the parts
> available today: `Navbar`, `Main` and `PageHeader`.

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
- `PageHeader` renders `@title` as an `h1`.
- The inset card is decorative and hidden from assistive technology.

| Key     | Action                                                    |
| ------- | --------------------------------------------------------- |
| `Tab`   | From the top of the page, reveals and focuses the skip link |
| `Enter` | On the skip link, moves focus to the main content          |

## API

<Signature @component="AppLayout" />
<Signature @component="Navbar" />
<Signature @component="Main" />
<Signature @component="PageHeader" />
