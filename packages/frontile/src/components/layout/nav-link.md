---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# NavLink

The unstyled link behind every navigation item. It handles routing, the
active state, ARIA, and disabled and hidden for you, and leaves all styling to
you. Reach for it to build a navigation row of your own; for the ready-made
row, use [NavItem](./nav-item).

## Import

```js
import { NavLink } from 'frontile';
```

## Usage

`NavLink` renders an anchor when you give it `@href`. It carries no classes,
so style it with `class` or from a stylesheet. The state is on the element as
`data-active` and `data-disabled`, ready to target.

```gts preview
import { NavLink } from 'frontile';

<template>
  <nav aria-label='Account' class='not-prose flex w-56 flex-col gap-1'>
    <NavLink
      @href='#profile'
      @isActive={{true}}
      class='rounded-md px-3 py-1.5 text-sm text-neutral-firm data-[active=true]:bg-neutral-soft data-[active=true]:font-medium'
    >
      Profile
    </NavLink>
    <NavLink
      @href='#security'
      class='rounded-md px-3 py-1.5 text-sm text-neutral-firm data-[active=true]:bg-neutral-soft data-[active=true]:font-medium'
    >
      Security
    </NavLink>
  </nav>
</template>
```

## Element

What `NavLink` renders depends on the arguments you pass.

| You pass | It renders                                                       |
| -------- | ---------------------------------------------------------------- |
| `@route` | An Ember `LinkTo`. The router decides whether it is active       |
| `@href`  | A plain anchor. No router is needed                              |
| neither  | A `<button type="button">`, for a row that runs your own handler |

`@isActive` marks the link as the current page when there is no router to ask,
and always wins over the router when there is one. `@route` also takes `@model`,
`@models` and `@query`.

`@isDisabled` removes the `href` so the link cannot be followed, and a button
gets the native `disabled` attribute. A disabled `@route` link becomes an
anchor without an `href`. `@isHidden` renders nothing.

```gts preview
import { NavLink } from 'frontile';

<template>
  <nav aria-label='Reports' class='not-prose flex w-56 flex-col gap-1'>
    <NavLink
      @href='#daily'
      class='rounded-md px-3 py-1.5 text-sm text-neutral-firm'
    >
      Anchor
    </NavLink>
    <NavLink
      class='rounded-md px-3 py-1.5 text-start text-sm text-neutral-firm'
    >
      Button
    </NavLink>
    <NavLink
      @href='#weekly'
      @isDisabled={{true}}
      class='rounded-md px-3 py-1.5 text-sm text-neutral-firm data-[disabled=true]:cursor-not-allowed data-[disabled=true]:opacity-disabled'
    >
      Disabled
    </NavLink>
  </nav>
</template>
```

## Attributes it sets

`NavLink` sets these on whichever element it renders:

| Attribute       | Value                                             |
| --------------- | ------------------------------------------------- |
| `aria-current`  | `page` while the link is active, otherwise absent |
| `data-active`   | `true` or `false`                                 |
| `aria-disabled` | `true` or `false`                                 |
| `data-disabled` | `true` or `false`                                 |

It adds no `data-part` and no classes. Everything else you pass, such as
`class`, `id`, modifiers or `...attributes`, lands on the rendered element.

## Accessibility

- The active link has `aria-current="page"`, so screen readers announce it as
  the current page.
- A disabled link has `aria-disabled="true"` and no `href`. A disabled button
  is also natively disabled, so it is skipped by <kbd>Tab</kbd> and cannot be
  activated.
- Put links in a `nav` landmark and name it with `aria-label` when the page has
  more than one.

## API

<Signature @component="NavLink" />
