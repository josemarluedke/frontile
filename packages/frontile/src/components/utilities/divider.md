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
  <div class='demo-stack text-neutral-strong'>
    <p>
      Quisque nibh est, posuere non purus eu, auctor molestie quam. Mauris ante
      sapien, accumsan et nibh eget, ultricies aliquam orci.
    </p>
    <Divider />
    <p>
      Vestibulum non justo enim. Etiam sed neque lobortis, suscipit elit id,
      dapibus erat. Nulla cursus scelerisque elit, id dictum urna iaculis a.
    </p>
  </div>
</template>
```

## Variants

`@variant='sketch'` swaps the flat rule for a hand-drawn one. It stretches to
any width without distorting: the artwork is a near-horizontal filled shape, so
scaling it horizontally changes only how often it wobbles, never its thickness.

```gts preview
import { Divider } from 'frontile';

<template>
  <div class='demo-stack items-center'>
    <div class='bg-surface-card w-full max-w-sm rounded-2xl p-6'>
    <ul class='text-neutral-strong space-y-2'>
      <li>Parental controls</li>
      <li>Guest network</li>
      <li>Security &amp; malware blocking</li>
    </ul>
    <Divider @variant='sketch' @class='my-5' />
      <div class='text-neutral-strong flex items-baseline justify-between'>
        <span>Starting at</span>
        <span><strong>$10.00</strong> /mo</span>
      </div>
    </div>
  </div>
</template>
```

The line takes its colour from the element's background. By default that is the
`divider` token, which is translucent — 15% ink over whatever sits behind it — so
one divider reads correctly on a page, a card or a tinted panel without being
retuned for each. A utility class recolours it:

```gts preview
import { Divider } from 'frontile';

<template>
  <div class='demo-stack'>
    <Divider @variant='sketch' />
    <Divider @variant='sketch' @class='bg-primary' />
    <Divider @variant='sketch' @class='bg-danger' />
  </div>
</template>
```

`sketch` is horizontal only. The artwork cannot be squashed into a vertical
rule, so `@orientation='vertical'` ignores it and renders the plain line.

## Orientation

`@orientation='vertical'` renders a `<div>` instead, because `<hr>` cannot
express a vertical rule.

`@variant='sketch'` has no effect on a vertical divider — see Variants.

The vertical divider is styled `h-full`, which resolves against its parent — so
the parent needs a **definite** height. `items-stretch` alone is not enough:
`height: 100%` of an auto-height container computes to zero, and the divider
disappears.

```gts preview
import { Divider } from 'frontile';

<template>
  <div class='demo-stack items-center'>
    <div class='text-neutral-strong flex h-8 items-stretch gap-4'>
      <span>Overview</span>
      <Divider @orientation='vertical' />
      <span>Pricing</span>
      <Divider @orientation='vertical' />
      <span>Support</span>
    </div>
  </div>
</template>
```

If the row's height has to stay content-driven, override the height on the
divider itself instead:

```gts preview
import { Divider } from 'frontile';

<template>
  <div class='demo-stack items-center'>
    <div class='text-neutral-strong flex items-center gap-4'>
      <span>Overview</span>
      <Divider @orientation='vertical' @class='h-4' />
      <span>Pricing</span>
      <Divider @orientation='vertical' @class='h-4' />
      <span>Support</span>
    </div>
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
  <div class='demo-stack items-center'>
    <ul class='text-neutral-strong w-48'>
      <li>Recently opened</li>
      <li>Shared with me</li>
      <Divider @as='li' @class='my-2' />
      <li>Trash</li>
    </ul>
  </div>
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
