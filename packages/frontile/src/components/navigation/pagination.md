---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Pagination

A row of controls for moving through a paged list — page chips, previous/next,
and an optional summary of the current range. Reach for it whenever a list is
too large to show at once and the user benefits from jumping to a specific
page, rather than only scrolling further into an infinite feed.

## Import

```js
import { Pagination } from 'frontile';
```

## Usage

`@total` is the only argument the shortest working control needs: pass the
item count and `Pagination` derives the page count itself, tracks the current
page, and needs no `@onChange`.

```gts preview
import { Pagination } from 'frontile';

<template>
  <Pagination @total={{120}} />
</template>
```

## Controlled and uncontrolled

The mode is decided by whether `@page` is *passed*, not by what it holds —
the same rule [`SegmentedControl`](./segmented-control) uses for `@value`.

Without `@page` the control is uncontrolled: it tracks the current page
itself, seeded from `@defaultPage`, and `@onChange` still fires on every
navigation so you can observe the page without owning it.

```gts preview
import { Pagination } from 'frontile';

<template>
  <Pagination @total={{120}} @defaultPage={{3}} />
</template>
```

Passing `@page` makes it controlled: the rendered page then only ever
reflects what you pass, so pair it with `@onChange` and update your own
state. `@defaultPage` is ignored in this mode.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Pagination } from 'frontile';

export default class Example extends Component {
  @tracked page = 1;

  onChange = (page: number): void => {
    this.page = page;
  };

  <template>
    <Pagination
      @total={{120}}
      @page={{this.page}}
      @onChange={{this.onChange}}
    />
  </template>
}
```

## Page count

`@total` is an item count, not a page count — `@pageSize` divides it, so
`totalPages` is `ceil(total / pageSize)`. A `@total` of 45 with the default
`@pageSize` of 10 renders 5 pages.

```gts preview
import { Pagination } from 'frontile';

<template>
  <Pagination @total={{45}} @pageSize={{10}} />
</template>
```

## Window size

`@siblingCount` sets how many page chips show on either side of the current
page. The first and last pages are always pinned, and that boundary is not
configurable.

The window keeps a constant number of slots as the page moves, so the row
never reflows as you page through — a chip near the middle of a long list
takes exactly as much space as one at either end.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Pagination } from 'frontile';

export default class Example extends Component {
  @tracked page = 10;

  onChange = (page: number): void => {
    this.page = page;
  };

  <template>
    <div class='flex flex-col items-start gap-3'>
      <Pagination
        @total={{200}}
        @siblingCount={{0}}
        @page={{this.page}}
        @onChange={{this.onChange}}
        aria-label='Sibling count 0'
      />
      <Pagination
        @total={{200}}
        @siblingCount={{1}}
        @page={{this.page}}
        @onChange={{this.onChange}}
        aria-label='Sibling count 1'
      />
      <Pagination
        @total={{200}}
        @siblingCount={{2}}
        @page={{this.page}}
        @onChange={{this.onChange}}
        aria-label='Sibling count 2'
      />
    </div>
  </template>
}
```

## Edge controls

`@showEdges` adds jump-to-first and jump-to-last controls at the ends of the
row, for a list long enough that reaching either end by paging through
siblings would take a while.

```gts preview
import { Pagination } from 'frontile';

<template>
  <Pagination @total={{500}} @defaultPage={{10}} @showEdges={{true}} />
</template>
```

## Previous and next only

Set `@showPages={{false}}` for a control with no page chips — just previous
and next. Use it for cursor-style paging, where the total item count isn't
known up front.

```gts preview
import { Pagination } from 'frontile';

<template>
  <Pagination @total={{120}} @showPages={{false}} />
</template>
```

## Summary

Providing the `<:summary>` block adds a row reporting the current range,
yielding `from`, `to`, `total`, `page`, and `totalPages`. It also switches the
layout to push the controls to the far edge, since there's now something to
justify the row against.

```gts preview
import { Pagination } from 'frontile';

<template>
  <Pagination @total={{120}} @pageSize={{10}} @defaultPage={{2}}>
    <:summary as |s|>
      Showing {{s.from}}-{{s.to}} of {{s.total}}
    </:summary>
  </Pagination>
</template>
```

## Links

The `<:item>` block is the deep-linking escape hatch: it replaces the page
chips with your own markup — a `LinkTo`, an anchor with a real `href` — so
each page is a navigable URL rather than a button that only calls
`@onChange`. Previous and next remain buttons in this mode; only the page
chips are replaced.

The block yields `page`, `isActive`, `classNames` (the same classes the
built-in chip would use), and `setupItem`, a modifier that writes
`data-active` and `aria-current="page"` onto whatever element you apply it
to.

```gts preview
import { Pagination } from 'frontile';

<template>
  <Pagination @total={{50}} @defaultPage={{2}}>
    <:item as |i|>
      <a
        href='/results?page={{i.page}}'
        class={{i.classNames}}
        {{i.setupItem i.isActive}}
      >{{i.page}}</a>
    </:item>
  </Pagination>
</template>
```

## Sizes

```gts preview
import { Pagination } from 'frontile';

<template>
  <div class='flex flex-col items-start gap-3'>
    <Pagination @total={{50}} @size='sm' aria-label='Small' />
    <Pagination @total={{50}} @size='md' aria-label='Medium' />
    <Pagination @total={{50}} @size='lg' aria-label='Large' />
  </div>
</template>
```

## Intents

`@intent` colors the active page chip's fill.

```gts preview
import { Pagination } from 'frontile';

<template>
  <div class='flex flex-col items-start gap-3'>
    <Pagination @total={{50}} @defaultPage={{2}} @intent='default' aria-label='Default intent' />
    <Pagination @total={{50}} @defaultPage={{2}} @intent='primary' aria-label='Primary intent' />
    <Pagination @total={{50}} @defaultPage={{2}} @intent='secondary' aria-label='Secondary intent' />
    <Pagination @total={{50}} @defaultPage={{2}} @intent='tertiary' aria-label='Tertiary intent' />
    <Pagination @total={{50}} @defaultPage={{2}} @intent='success' aria-label='Success intent' />
    <Pagination @total={{50}} @defaultPage={{2}} @intent='warning' aria-label='Warning intent' />
    <Pagination @total={{50}} @defaultPage={{2}} @intent='danger' aria-label='Danger intent' />
  </div>
</template>
```

## Disabled

`@isDisabled` disables every control in the row.

```gts preview
import { Pagination } from 'frontile';

<template>
  <Pagination @total={{50}} @defaultPage={{3}} @isDisabled={{true}} />
</template>
```

## Accessibility

`Pagination` renders a `<nav>` landmark, named by `@label` (defaulting to
`'pagination'`) — set it explicitly when a page has more than one pagination
control. The active page chip carries `aria-current="page"`; every other
chip carries none.

The ellipsis marking a gap in the page row is `aria-hidden`, with a visually
hidden "More pages" label so screen readers still get a name for it.

Every control — previous, next, the edge jumps, and each page chip — stays
individually reachable by <kbd>Tab</kbd>, with no roving `tabindex`. These
are navigation targets rather than a composite widget, so each one is its own
stop rather than being grouped under a single tab-managed focus point.

## API

<Signature @component="Pagination" />
