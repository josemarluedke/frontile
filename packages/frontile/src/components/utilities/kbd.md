---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Kbd

Renders keyboard keys and shortcuts.

`Kbd` knows the common keys by name, so `"mod+k"` becomes `⌘K` on Apple
platforms and `Ctrl+K` everywhere else — one string, correct on every machine.

## Import

```js
import { Kbd } from 'frontile';
```

## Usage

Pass a shortcut to `@keys` as `+`-separated keys.

```gts preview
import { Kbd } from 'frontile';

<template>
  <div class='flex items-center gap-4 not-prose p-2'>
    <Kbd @keys='mod+k' />
    <Kbd @keys='mod+shift+p' />
    <Kbd @keys='enter' />
    <Kbd @keys='esc' />
    <Kbd @keys='up' />
  </div>
</template>
```

Anything that is not a known key renders as given, and a single letter is
capitalised. Pass a block for arbitrary content.

```gts preview
import { Kbd } from 'frontile';

<template>
  <div class='flex items-center gap-4 not-prose p-2'>
    <Kbd @keys='F5' />
    <Kbd @keys='mod+/' />
    <Kbd>Fn</Kbd>
  </div>
</template>
```

## Keys

Named keys are case-insensitive.

| Group | Names |
| --- | --- |
| Modifiers | `mod`, `meta` / `cmd` / `command`, `ctrl` / `control`, `alt` / `option`, `shift`, `win`, `fn` |
| Special | `enter` / `return`, `esc` / `escape`, `tab`, `space`, `backspace`, `del` / `delete`, `capslock`, `plus` |
| Navigation | `up`, `down`, `left`, `right`, `pageup`, `pagedown`, `home`, `end` |

Use `plus` when you need a literal `+`, since `+` is the separator.

Only three keys differ by platform:

| Name | Apple | Elsewhere |
| --- | --- | --- |
| `mod` | `⌘` | `Ctrl` |
| `ctrl` | `⌃` | `Ctrl` |
| `alt` | `⌥` | `Alt` |

Prefer `mod` for application shortcuts — it names the role, so it follows the
platform. Use `meta` only when you mean the Command key specifically.

## Display

`@display='merged'` puts every glyph in a single cap, and `@separator` places a
character between caps.

```gts preview
import { Kbd } from 'frontile';

<template>
  <div class='flex items-center gap-4 not-prose p-2'>
    <Kbd @keys='mod+k' />
    <Kbd @keys='mod+k' @display='merged' />
    <Kbd @keys='ctrl+b' @separator='+' />
  </div>
</template>
```

## Sizes

```gts preview
import { Kbd } from 'frontile';

<template>
  <div class='flex items-center gap-4 not-prose p-2'>
    <Kbd @keys='mod+k' @size='sm' />
    <Kbd @keys='mod+k' @size='md' />
    <Kbd @keys='mod+k' @size='lg' />
  </div>
</template>
```

## Appearance and intent

```gts preview
import { Kbd } from 'frontile';

const appearances = ['default', 'outlined', 'faded'];
const intents = ['default', 'primary', 'secondary', 'success', 'warning', 'danger'];

<template>
  <div class='flex flex-col gap-3 not-prose p-2'>
    {{#each appearances as |appearance|}}
      <div class='flex items-center gap-3'>
        {{#each intents as |intent|}}
          <Kbd @keys='mod+k' @appearance={{appearance}} @intent={{intent}} />
        {{/each}}
      </div>
    {{/each}}
  </div>
</template>
```

Two appearances take their colour from their surroundings rather than from
`@intent`. `inherit` keeps a hairline box drawn in the current colour, which is
what lets a keycap sit on a filled, active row without the row's theme having to
repaint it. `plain` drops the box entirely, for a quiet trailing shortcut.

```gts preview
import { Kbd } from 'frontile';

<template>
  <div class='flex flex-col gap-2 not-prose p-2'>
    <div class='flex items-center justify-between gap-3 rounded-lg bg-primary-soft text-on-primary-soft px-3 py-2'>
      <span>Open command palette</span>
      <Kbd @keys='mod+k' @appearance='inherit' @size='sm' />
    </div>
    <div class='flex items-center justify-between gap-3 rounded-lg px-3 py-2'>
      <span>Open command palette</span>
      <Kbd @keys='mod+k' @appearance='plain' @size='sm' />
    </div>
  </div>
</template>
```

`Listbox`, `Dropdown` and `Command` render their items' `@shortcut` through
`Kbd`. Their keycaps default to `inherit`, so a shortcut stays legible on an
active or filled row; pass `@shortcutAppearance` on the `Listbox` or `Dropdown`
to change every item at once.

## Platform

By default the platform is detected from the browser. Set it explicitly when
detection cannot work or would be wrong — during server rendering, where every
visitor looks non-Apple, or in tests, which would otherwise depend on the
machine running them.

```js
import { setKbdPlatform } from 'frontile';

setKbdPlatform('apple'); // or 'other', or 'auto' to detect
```

`@platform` overrides it for a single keycap.

## Accessibility

Rendered as nested `<kbd>` elements, which is how HTML expresses a key
combination.

Symbol glyphs are hidden from assistive technology and their names announced
instead, since "⌘" read aloud is meaningless. Glyphs that already read correctly
— `Esc`, `Ctrl`, a letter — are left alone, because labelling them would
announce the name twice. Named keys also carry a `title`, which helps sighted
users who do not recognise a glyph.

## API

<Signature @package="frontile" @component="Kbd" />
