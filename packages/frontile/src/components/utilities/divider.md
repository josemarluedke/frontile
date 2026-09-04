---
imports:
  - import Signature from 'site/components/signature';
---

# Divider

A Divider is designed to delineate and separate content.

## Import

```js
import { Divider } from 'frontile';
```

## Usage

A horizontal divider renders an `<hr>`.

```gts preview
import { Divider } from 'frontile';

<template>
  <div class='text-neutral-strong not-prose p-2'>
    <p>
      Quisque nibh est, posuere non purus eu, auctor molestie quam. Mauris ante
      sapien, accumsan et nibh eget, ultricies aliquam orci.
    </p>
    <Divider @class='my-2' />
    <p>
      Vestibulum non justo enim. Etiam sed neque lobortis, suscipit elit id,
      dapibus erat. Nulla cursus scelerisque elit, id dictum urna iaculis a.
    </p>
  </div>
</template>
```

## Orientation

`@orientation='vertical'` renders a `<div>` instead, because `<hr>` cannot
express a vertical rule.

The vertical divider is styled `h-full`, which resolves against its parent — so
the parent needs a **definite** height. `items-stretch` alone is not enough:
`height: 100%` of an auto-height container computes to zero, and the divider
disappears.

```gts preview
import { Divider } from 'frontile';

<template>
  <div class='text-neutral-strong not-prose flex h-8 items-stretch gap-4 p-2'>
    <span>Overview</span>
    <Divider @orientation='vertical' />
    <span>Pricing</span>
    <Divider @orientation='vertical' />
    <span>Support</span>
  </div>
</template>
```

If the row's height has to stay content-driven, override the height on the
divider itself instead:

```gts preview
import { Divider } from 'frontile';

<template>
  <div class='text-neutral-strong not-prose flex items-center gap-4 p-2'>
    <span>Overview</span>
    <Divider @orientation='vertical' @class='h-4' />
    <span>Pricing</span>
    <Divider @orientation='vertical' @class='h-4' />
    <span>Support</span>
  </div>
</template>
```

## Changing the element

`@as` renders a different tag from the one the orientation would pick. This
matters when the surrounding markup constrains what is valid — an `<hr>` is not
allowed as a direct child of `<ul>`, so a divider between list items has to be
an `<li>`.

```gts preview
import { Divider } from 'frontile';

<template>
  <ul class='text-neutral-strong not-prose w-48 p-2'>
    <li>Recently opened</li>
    <li>Shared with me</li>
    <Divider @as='li' @class='my-2' />
    <li>Trash</li>
  </ul>
</template>
```

## Accessibility

The divider carries `role="separator"`, so assistive technology reports a
boundary between groups rather than skipping over it silently. A separator with
no `tabindex` is not focusable and takes no keyboard interaction.

A vertical divider also gets `aria-orientation="vertical"`, because the
`separator` role is horizontal by default — without it a vertical rule is
reported the wrong way round. Horizontal dividers need no such attribute, and
`<hr>` carries its orientation implicitly.

A divider is a visual and structural boundary, not a label. If the two sides of
it are meaningfully different regions, say so with headings or a landmark —
`<section aria-labelledby>`, `<nav>` — rather than relying on the line to carry
that meaning. Screen reader users navigating by heading or landmark never
encounter the separator at all.

## API

<Signature @component="Divider" />
