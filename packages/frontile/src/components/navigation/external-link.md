---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# ExternalLink

A link to another site, marked with an external-link icon.

It opens a new tab, adds `rel="noopener noreferrer"`, and appends visually
hidden text announcing the new tab — so a link that shows the icon always
behaves the way the icon promises. For in-app navigation use
[TabNav](./tab-nav) or Ember's `LinkTo`.

## Import

```js
import { ExternalLink } from 'frontile';
```

## Usage

Pass `@href`. Everything else has a default.

```gts preview
import { ExternalLink } from 'frontile';

<template>
  <div class='not-prose text-neutral-strong p-2'>
    <ExternalLink @href='https://emberjs.com'>Ember.js</ExternalLink>
  </div>
</template>
```

The anchor is `display: inline`, so a link wraps mid-phrase inside a paragraph
like any other. The icon can end up alone on the next line when the break falls
right after the last word.

```gts preview
import { ExternalLink } from 'frontile';

<template>
  <div class='not-prose text-neutral-strong max-w-xs p-2'>
    <p>
      Frontile is built on
      <ExternalLink @href='https://emberjs.com'>Ember Octane</ExternalLink>
      and styled with
      <ExternalLink @href='https://tailwindcss.com'>Tailwind CSS</ExternalLink>.
    </p>
  </div>
</template>
```

## Color

The link inherits its color and font size from the surrounding text. Tint it
with a text utility on `@class`.

```gts preview
import { ExternalLink } from 'frontile';

<template>
  <div class='not-prose flex flex-col items-start gap-3 p-2'>
    <span class='text-neutral-strong'>
      <ExternalLink @href='https://emberjs.com'>Inherited color</ExternalLink>
    </span>
    <ExternalLink @href='https://emberjs.com' @class='text-primary'>
      Primary
    </ExternalLink>
    <ExternalLink @href='https://emberjs.com' @class='text-danger'>
      Danger
    </ExternalLink>
    <p class='text-neutral text-sm'>
      The icon scales with the text, so
      <ExternalLink @href='https://emberjs.com'>a small link</ExternalLink>
      gets a small icon.
    </p>
  </div>
</template>
```

## Underline

```gts preview
import { ExternalLink } from 'frontile';

<template>
  <div class='not-prose text-neutral-strong flex flex-col items-start gap-3 p-2'>
    <ExternalLink @href='https://emberjs.com'>
      Always underlined (default)
    </ExternalLink>
    <ExternalLink @href='https://emberjs.com' @underline='hover'>
      Underlined on hover
    </ExternalLink>
    <ExternalLink @href='https://emberjs.com' @underline='none'>
      Never underlined
    </ExternalLink>
  </div>
</template>
```

## Icon placement

```gts preview
import { ExternalLink } from 'frontile';

<template>
  <div class='not-prose text-neutral-strong flex flex-col items-start gap-3 p-2'>
    <ExternalLink @href='https://emberjs.com'>Icon at the end (default)</ExternalLink>
    <ExternalLink @href='https://emberjs.com' @iconPlacement='start'>
      Icon at the start
    </ExternalLink>
  </div>
</template>
```

Pass `@showIcon={{false}}` to drop the icon. The new tab, the `rel`, and the
screen-reader announcement stay.

```gts preview
import { ExternalLink } from 'frontile';

<template>
  <div class='not-prose text-neutral-strong p-2'>
    <ExternalLink @href='https://emberjs.com' @showIcon={{false}}>
      No icon
    </ExternalLink>
  </div>
</template>
```

## Custom icon

The `:icon` block replaces the built-in glyph and keeps its size and spacing.
Named blocks require an explicit `:default` block for the link text.

```gts preview
import { ExternalLink } from 'frontile';
import { ShareIcon } from 'site/components/icons';

<template>
  <div class='not-prose text-neutral-strong p-2'>
    <ExternalLink @href='https://emberjs.com'>
      <:default>Custom icon</:default>
      <:icon><ShareIcon /></:icon>
    </ExternalLink>
  </div>
</template>
```

## Target and rel

`@target` defaults to `_blank`, and `rel` is then `noopener noreferrer`.
Setting `@target='_self'` navigates in place: no `rel` is emitted and the
new-tab announcement is dropped, since neither would be true.

`@rel` replaces the default outright — include `noopener noreferrer` yourself
if the link still opens a new tab.

```gts preview
import { ExternalLink } from 'frontile';

<template>
  <div class='not-prose text-neutral-strong flex flex-col items-start gap-3 p-2'>
    <ExternalLink @href='https://emberjs.com'>New tab (default)</ExternalLink>
    <ExternalLink @href='https://emberjs.com' @target='_self'>
      Same tab
    </ExternalLink>
    <ExternalLink
      @href='https://emberjs.com'
      @rel='noopener noreferrer nofollow'
    >
      With nofollow
    </ExternalLink>
  </div>
</template>
```

## Accessibility

The icon is `aria-hidden`, so its meaning is carried by visually hidden text
after the link label: a screen reader announces "Ember.js (opens in a new tab)".
Translate it with `@newTabLabel`, or pass an empty string to remove it when the
surrounding copy already says so.

```gts preview
import { ExternalLink } from 'frontile';

<template>
  <div class='not-prose text-neutral-strong flex flex-col items-start gap-3 p-2'>
    <ExternalLink
      @href='https://emberjs.com'
      @newTabLabel='(abre em uma nova aba)'
    >
      Translated announcement
    </ExternalLink>
    <ExternalLink @href='https://emberjs.com' @newTabLabel=''>
      No announcement
    </ExternalLink>
  </div>
</template>
```

The announcement follows `@target`: a `_self` link never gets it. Give the link
text that reads on its own — "Ember.js" rather than "click here" — since screen
reader users often navigate by a list of links stripped of surrounding prose.

Keyboard behaviour is a plain anchor's: <kbd>Tab</kbd> to focus, <kbd>Enter</kbd>
to follow. Focus shows the standard focus ring.

## API

<Signature @component="ExternalLink" />
