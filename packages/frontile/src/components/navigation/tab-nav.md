---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# TabNav

A navigation bar styled like [Tabs](./tabs), for links that change the page.

Unlike `Tabs`, every link stays individually reachable by <kbd>Tab</kbd> and
the arrow keys are left to the browser — the ARIA tabs pattern covers in-page
panel switching, not navigation. The active link is marked with
`aria-current="page"`, which Ember's `LinkTo` does not set on its own.

## Import

```js
import { TabNav } from 'frontile';
```

## Usage

The docs site has no routes for `TabNav` to link to, so every demo on this
page uses `@href` and `@isActive` directly rather than `@route`. In an app
with routes, `@route` (below) is the tier to reach for — it derives
`@isActive` from the router for you.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import { TabNav } from 'frontile';

export default class Example extends Component {
  @tracked current = 'account';

  isCurrent = (name: string): boolean => this.current === name;

  // No router in this demo, so a plain click stands in for a route
  // transition -- `preventDefault` keeps the `#` href from touching the URL.
  select = (name: string, event: MouseEvent): void => {
    event.preventDefault();
    this.current = name;
  };

  <template>
    <TabNav @label='Settings' as |nav|>
      <nav.Item
        @href='#account'
        @isActive={{this.isCurrent 'account'}}
        {{on 'click' (fn this.select 'account')}}
      >
        Account
      </nav.Item>
      <nav.Item
        @href='#security'
        @isActive={{this.isCurrent 'security'}}
        {{on 'click' (fn this.select 'security')}}
      >
        Security
      </nav.Item>
      <nav.Item
        @href='#billing'
        @isActive={{this.isCurrent 'billing'}}
        {{on 'click' (fn this.select 'billing')}}
      >
        Billing
      </nav.Item>
    </TabNav>
  </template>
}
```

## Linking to routes

Pass `@route` (with `@models`, `@model`, or `@query` as needed) and
`nav.Item` renders an Ember `LinkTo` and derives `@isActive` from the router
itself — no `@isActive` needed. This tier isn't rendered on this page, since
the docs site has no matching routes; it is shown here as reference.

```gts
import { TabNav } from 'frontile';

<template>
  <TabNav @label='Settings' as |nav|>
    <nav.Item @route='settings.account'>Account</nav.Item>
    <nav.Item @route='settings.security'>Security</nav.Item>
    <nav.Item @route='settings.billing'>Billing</nav.Item>
  </TabNav>
</template>
```

`@isActive` always wins over anything derived from the router, so it can
still override a `@route` item when needed.

## Bring your own link component

`nav` also yields `itemClass` and `setupItem` directly, for a link
component other than `nav.Item` — `ember-link`, a custom `<AppLink>`. Apply
`itemClass` to the link's class and `{{nav.setupItem}}` (with a boolean for
whether the link is active) to its element, and it gets the same theme
classes, `data-selected`, `aria-current`, and indicator animation as
`nav.Item`. This tier isn't rendered here either, for the same reason as
`@route` above.

```gts
import { TabNav } from 'frontile';

<template>
  <TabNav @label='Settings' as |nav|>
    <a
      href='/settings/account'
      class={{nav.itemClass}}
      {{nav.setupItem true}}
    >
      Account
    </a>
  </TabNav>
</template>
```

## Variants, intents, and sizes

`TabNav` shares its theme with `Tabs`, so `@variant`, `@intent`, and `@size`
behave the same way — see [Tabs](./tabs) for each option.

```gts preview
import { TabNav } from 'frontile';

<template>
  <div class='flex flex-col items-start gap-6'>
    <TabNav @label='Solid' @variant='solid' @intent='primary' as |nav|>
      <nav.Item @href='#account' @isActive={{true}}>Account</nav.Item>
      <nav.Item @href='#security'>Security</nav.Item>
    </TabNav>

    <TabNav @label='Underline' @variant='underline' @intent='primary' as |nav|>
      <nav.Item @href='#account' @isActive={{true}}>Account</nav.Item>
      <nav.Item @href='#security'>Security</nav.Item>
    </TabNav>
  </div>
</template>
```

## Vertical

```gts preview
import { TabNav } from 'frontile';

<template>
  <TabNav @label='Settings' @orientation='vertical' as |nav|>
    <nav.Item @href='#account' @isActive={{true}}>Account</nav.Item>
    <nav.Item @href='#security'>Security</nav.Item>
    <nav.Item @href='#billing'>Billing</nav.Item>
  </TabNav>
</template>
```

## Full width

`@isFullWidth={{true}}` stretches the bar to its container and gives every
link equal width.

```gts preview
import { TabNav } from 'frontile';

<template>
  <div class='w-96 max-w-full rounded-lg border border-neutral-soft p-4'>
    <TabNav @label='Settings' @isFullWidth={{true}} as |nav|>
      <nav.Item @href='#account' @isActive={{true}}>Account</nav.Item>
      <nav.Item @href='#security'>Security</nav.Item>
    </TabNav>
  </div>
</template>
```

## Disabled links

`@isDisabled` drops the `href` as well as marking the link `aria-disabled` —
an anchor cannot be natively disabled, so removing the href is what actually
stops navigation.

```gts preview
import { TabNav } from 'frontile';

<template>
  <TabNav @label='Settings' as |nav|>
    <nav.Item @href='#account' @isActive={{true}}>Account</nav.Item>
    <nav.Item @href='#billing' @isDisabled={{true}}>Billing</nav.Item>
    <nav.Item @href='#security'>Security</nav.Item>
  </TabNav>
</template>
```

## Accessibility

`TabNav` renders a `<nav>` landmark (not a `<ul>`), and each `nav.Item` is a
plain link, not a tab — these links navigate rather than switch an in-page
panel. `TabNav` needs an accessible name from `@label`, or pass
`aria-labelledby` on `TabNav` directly.

Every link stays in the natural tab order and arrow keys are left to the
browser; there is no roving `tabindex` and no keyboard handling to document
beyond ordinary link navigation. The active link carries `aria-current="page"`
and `data-selected="true"`, both a `nav.Item` derives and `{{nav.setupItem}}`
sets for a hand-rolled link — a disabled link instead carries `aria-disabled`
and drops its `href`.

## API

<Signature @component="TabNav" />
<Signature @component="TabNavItem" />
