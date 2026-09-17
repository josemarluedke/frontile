---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Breadcrumbs

An ordered trail of links ending in the current page, for showing where the
current page sits in a hierarchy.

Like [TabNav](./tab-nav), it does not use roving focus: every crumb is a
link, so each one stays individually reachable by <kbd>Tab</kbd> and the
arrow keys are left to the browser.

## Import

```js
import { Breadcrumbs } from 'frontile';
```

## Usage

The docs site has no routes for `Breadcrumbs` to link to, so every demo on
this page uses `@href` rather than `@route`. In an app with routes, `@route`
(below) is the tier to reach for — it derives the current crumb from the
router for you.

A crumb with no link target at all is the current page: `<b.Item>` needs no
arguments to say "you are here."

```gts preview
import { Breadcrumbs } from 'frontile';

<template>
  <Breadcrumbs as |b|>
    <b.Item @href='/'>Home</b.Item>
    <b.Item @href='/library'>Library</b.Item>
    <b.Item>Data</b.Item>
  </Breadcrumbs>
</template>
```

`Breadcrumbs` has two authoring forms. The block form above gives full
control over each crumb, and is the one to reach for by default. The
`@items` form, covered under [Collapsing long trails](#collapsing-long-trails),
renders the trail from a plain array instead — worth it once the trail is
long enough that you want it to collapse automatically.

## Linking to routes

Pass `@route` (with `@model`, `@models`, or `@query` as needed) and `b.Item`
renders an Ember `LinkTo`, deriving its current state from the router — no
`@isCurrent` needed. This tier isn't rendered on this page, since the docs
site has no matching routes; it is shown here as reference.

```gts
import { Breadcrumbs } from 'frontile';

<template>
  <Breadcrumbs as |b|>
    <b.Item @route='library.index'>Library</b.Item>
    <b.Item @route='library.item' @model={{@item.id}}>{{@item.title}}</b.Item>
  </Breadcrumbs>
</template>
```

`@isCurrent` always wins over the router, in both directions — pass it to
override a route crumb that the router would otherwise mark current, or to
force one current that isn't.

## Collapsing long trails

Once a trail gets long, the middle can be collapsed behind an ellipsis
marker. There are two ways to get one, matching the two authoring forms.

### `@items` and `@maxItems`

Passing `@items` renders the trail from an array instead of from blocks, and
is what makes `@maxItems` meaningful — yielded blocks can't be counted before
they render, so in the block form there's nothing for `@maxItems` to divide.
Once `@items.length` exceeds `@maxItems`, the middle collapses into an
ellipsis marker — the same one `b.Ellipsis` renders when placed by hand,
below — that announces how many crumbs it stands in for.

```gts preview
import { Breadcrumbs } from 'frontile';

const trail = [
  { label: 'Home', href: '/' },
  { label: 'Library', href: '/library' },
  { label: 'Data', href: '/library/data' },
  { label: 'Reports', href: '/library/data/reports' },
  { label: 'Q3' }
];

<template>
  <Breadcrumbs @items={{trail}} @maxItems={{3}} />
</template>
```

`@itemsBeforeCollapse` and `@itemsAfterCollapse` (each defaulting to `1`)
move where the split happens:

```gts preview
import { Breadcrumbs } from 'frontile';

const trail = [
  { label: 'Home', href: '/' },
  { label: 'Library', href: '/library' },
  { label: 'Data', href: '/library/data' },
  { label: 'Reports', href: '/library/data/reports' },
  { label: 'Q3' }
];

<template>
  <Breadcrumbs
    @items={{trail}}
    @maxItems={{4}}
    @itemsBeforeCollapse={{2}}
    @itemsAfterCollapse={{1}}
  />
</template>
```

Each entry in `@items` takes `label` (its text) plus the same arguments as
`b.Item` — `route`/`model`/`models`/`query` or `href`, `isCurrent`,
`isDisabled`. A crumb with neither `route` nor `href` is the current page,
exactly as in the block form.

### A manual `<b.Ellipsis />`

In the block form, you place the ellipsis yourself — useful when the trail
doesn't come from a flat array, or the collapse point isn't a simple count:

```gts preview
import { Breadcrumbs } from 'frontile';

<template>
  <Breadcrumbs as |b|>
    <b.Item @href='/'>Home</b.Item>
    <b.Ellipsis @hiddenCount={{2}} />
    <b.Item>Q3</b.Item>
  </Breadcrumbs>
</template>
```

`@hiddenCount` drives the visually-hidden announcement ("2 more levels"); pass
it whenever you know how many crumbs the marker stands in for. Omit it and
the announcement falls back to an uncounted "More levels" rather than making
you count your own crumbs.

Passing a block replaces the glyph and takes over the announcement entirely
— this is where a `Dropdown` listing the hidden crumbs goes. The block
yields `hiddenCount` and `hiddenItems` (empty unless you pass `@hiddenItems`),
so you can render the crumbs it stands in for:

```gts preview
import { Breadcrumbs } from 'frontile';

const hidden = [{ label: 'Library' }, { label: 'Data' }];

<template>
  <Breadcrumbs as |b|>
    <b.Item @href='/'>Home</b.Item>
    <b.Ellipsis @hiddenItems={{hidden}} as |e|>
      <button type='button' class='text-neutral-muted'>
        {{e.hiddenItems.length}}
        hidden &hellip;
      </button>
    </b.Ellipsis>
    <b.Item>Q3</b.Item>
  </Breadcrumbs>
</template>
```

In the `@items` form, the same two blocks are available as named blocks —
`:item` to render every crumb yourself, and `:ellipsis` to render the
auto-placed marker — so `@maxItems` still computes the split while you
control the markup:

```gts
import { Breadcrumbs } from 'frontile';

<template>
  <Breadcrumbs @items={{@trail}} @maxItems={{3}}>
    <:item as |ctx|>
      <li class={{ctx.itemClass}}>
        <span class={{ctx.linkClass}}>{{ctx.item.label}}</span>
      </li>
    </:item>
    <:ellipsis as |e|>
      <button type='button'>{{e.hiddenCount}} hidden</button>
    </:ellipsis>
  </Breadcrumbs>
</template>
```

## Custom separator

`@separator` replaces the chevron glyph between crumbs with any component:

```gts preview
import { Breadcrumbs } from 'frontile';

const Slash = <template><span>/</span></template>;

<template>
  <Breadcrumbs @separator={{Slash}} as |b|>
    <b.Item @href='/'>Home</b.Item>
    <b.Item @href='/library'>Library</b.Item>
    <b.Item>Data</b.Item>
  </Breadcrumbs>
</template>
```

## Sizes, colors, and underline

`@size` (`sm` / `md` / `lg`, default `md`) scales the text and separator
glyph. `@color` picks the hover and current-page ink from the seven semantic
categories (default `neutral`). `@underline` (`always` / `hover` / `none`,
default `hover`) controls when a crumb's link is underlined — the current
crumb is never underlined in any mode, since it doesn't go anywhere.

```gts preview
import { Breadcrumbs } from 'frontile';

<template>
  <div class='demo-stack items-start'>
    <Breadcrumbs @size='sm' @color='primary' as |b|>
      <b.Item @href='/'>Home</b.Item>
      <b.Item>Small, primary</b.Item>
    </Breadcrumbs>

    <Breadcrumbs @size='lg' @color='success' @underline='always' as |b|>
      <b.Item @href='/'>Home</b.Item>
      <b.Item>Large, always underlined</b.Item>
    </Breadcrumbs>
  </div>
</template>
```

## Disabled crumbs

`@isDisabled` drops the `href` as well as marking the crumb `aria-disabled` —
an anchor can't be natively disabled, so removing the href is what actually
stops navigation. It only affects a linked crumb; an unlinked crumb (no
`@route` or `@href`) never receives `aria-disabled`, since it isn't a link to
begin with.

```gts preview
import { Breadcrumbs } from 'frontile';

<template>
  <Breadcrumbs as |b|>
    <b.Item @href='/'>Home</b.Item>
    <b.Item @href='/library' @isDisabled={{true}}>Library</b.Item>
    <b.Item>Data</b.Item>
  </Breadcrumbs>
</template>
```

## Bring your own link component

`b` also yields `itemClass`, `linkClass`, `separatorClass`, and `setupItem`
directly, for a link component other than `b.Item` — `ember-link`, a custom
`<AppLink>`. Apply `linkClass` to the link's class and `{{b.setupItem
isCurrent}}` to its element (with a boolean for whether it's the current
crumb), and it gets the same theme classes and ARIA as `b.Item`. Wrap it in
an `<li>` with `itemClass`, and add the separator yourself with
`separatorClass`:

```gts
import { Breadcrumbs } from 'frontile';

<template>
  <Breadcrumbs as |b|>
    <li class={{b.itemClass}}>
      <a href='/library' class={{b.linkClass}} {{b.setupItem false}}>
        Library
      </a>
      <span class={{b.separatorClass}} aria-hidden='true'>/</span>
    </li>
    <li class={{b.itemClass}}>
      <span class={{b.linkClass}} {{b.setupItem true}}>Data</span>
    </li>
  </Breadcrumbs>
</template>
```

## Accessibility

`Breadcrumbs` renders a `<nav>` landmark with an accessible name from
`@label` (default `'Breadcrumb'`), wrapping an `<ol>` — the trail is an
ordered list. Every crumb stays in the natural tab order; there is no roving
`tabindex` and no keyboard handling beyond ordinary link navigation.

The current crumb carries `aria-current="page"` and is rendered as a
`<span>`, not a link, since it doesn't go anywhere. `Breadcrumbs.Item`
derives current from, in order: an explicit `@isCurrent`; the router, for a
`@route` crumb; then the fallback that a crumb with no link target at all is
the page you're on. Only the last statically-current crumb keeps
`aria-current`, since two would be invalid — `Breadcrumbs` warns if `@items`
produces more than one.

A separator follows every crumb, including the last — it is hidden by CSS
rather than omitted, and carries `aria-hidden="true"` either way, so it never
reaches assistive technology.

An ellipsis marker with no block carries `aria-hidden="true"` on its glyph
and a visually-hidden announcement ("N more levels", or "More levels" without
a count). Supplying a block to `b.Ellipsis` suppresses that built-in
announcement, since the block's own content — typically a button that opens
a menu — carries its own accessible name.

## API

<Signature @component="Breadcrumbs" />
<Signature @component="BreadcrumbsItem" />
<Signature @component="BreadcrumbsEllipsis" />
