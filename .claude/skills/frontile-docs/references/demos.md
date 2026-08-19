# Writing demos that run

Every ` ```gts preview ` fence is compiled and rendered on frontile.dev. A demo that
doesn't compile is a broken public page, so the cost of guessing at an API here is higher
than in ordinary docs.

Contents:
- [Fence languages](#fence-languages)
- [Demos are standalone modules](#demos-are-standalone-modules)
- [Template helpers](#template-helpers)
- [State in a demo](#state-in-a-demo)
- [Styling inside demos](#styling-inside-demos)
- [Content and length](#content-and-length)

## Fence languages

| Fence | Renders as | Use for |
| --- | --- | --- |
| ` ```gts preview ` | Live component **and** source | Every demo. The default |
| ` ```gjs preview ` | Live component and source | Legacy. 50 blocks remain; convert to `gts` when you touch the file |
| ` ```js ` | Static code block | The `## Import` line |
| ` ```gts ` | Static code block | A fragment that intentionally can't run on its own |
| ` ```css ` | Static code block | Consumer-side CSS, e.g. styling a `data-*` attribute |

The `preview` keyword is what makes it live. Dropping it is the most common accidental
regression: the demo still looks right in the diff and silently stops rendering on the site.

## Demos are standalone modules

Each fence is compiled independently. Nothing carries over from an earlier demo in the same
file — every import must be repeated, including `frontile` itself.

```gts preview
import { Button } from 'frontile';

<template>
  <Button>Button</Button>
</template>
```

Top-level `<template>` is the template-only form. Anything needing state uses a class (see
below).

## Template helpers

Glimmer's built-in helper set is smaller than people expect, and the gap surfaces as a
build error rather than a fallback:

```ts
import { hash, array, fn, get, concat } from '@ember/helper';
import { on } from '@ember/modifier';
```

**`eq` does not exist**, nor do `not`, `and`, `or`, `gt`. Restructure to avoid a comparison
in the template — pass a boolean in from JS, or iterate an array — rather than reaching for
a helper package the demo can't import.

## State in a demo

Use a class component with `@glimmer/tracking`. `button.md`'s press-counter demo is the
reference shape:

```gts preview
import { Button } from 'frontile';
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';

export default class ButtonPressExample extends Component {
  @tracked pressCount = 0;

  handlePress = () => {
    this.pressCount++;
  };

  <template>
    <Button @onPress={{this.handlePress}}>
      Press me! ({{this.pressCount}})
    </Button>
  </template>
}
```

Name the class after what it demonstrates (`ButtonPressExample`), not `Demo` — the class
name is visible in the rendered source, so it's documentation too.

## Styling inside demos

Demo markup uses the same semantic utilities as the library. **There is no numbered color
scale**: `bg-primary-500` isn't a class, and it fails silently as unstyled output rather
than erroring.

Categories: `neutral`, `primary`, `secondary`, `tertiary`, `success`, `warning`, `danger`,
`inverse`, `surface-*`. Levels, low to high emphasis: `subtle`, `muted`, `soft`, `mild`,
DEFAULT (no suffix), `firm`, `strong`, `bolder`. Text that must contrast against a filled
background uses `text-on-{category}-{level}`.

```
bg-primary            text-neutral-strong     text-on-primary-firm
border-neutral-soft   bg-surface-mild
```

These adapt to dark mode through CSS variables, so a demo built from them is correct in
both themes with no extra work. A hardcoded `bg-teal-100` is not — reserve raw Tailwind
colors for demos whose whole point is showing custom styling (as `button.md` does for
`@appearance='custom'`), and say so in the surrounding prose.

For layout, keep wrappers minimal and consistent with neighbors:

```html
<div class='flex flex-wrap items-center gap-3'>
```

## Icons and helper components

Demos live in the `site` app's module space, so they can import from `site/components/…`.
Three shared resources already exist, and reaching for them beats inventing a local one:

| Import | What it is |
| --- | --- |
| `site/components/icons` | 25 SVG icon components, headed "Common icons used in documentation examples": `Accessibility`, `Archive`, `Book`, `Check`, `ChevronDown`, `Code`, `Component`, `Delete`, `Download`, `Duplicate`, `Edit`, `Logout`, `Moon`, `Package`, `Palette`, `Rocket`, `Search`, `Settings`, `Share`, `Sparkles`, `Star`, `Sun`, `Target`, `User`, `View` — each suffixed `Icon` |
| `site/components/table-demo-data` | Realistic `users` / `products` / `employees` fixtures with exported types, used across `table.md` |
| `site/components/theme-docs/*` | Purpose-built doc widgets — `ColorPaletteGrid`, `ColorSwatch`, `SurfaceShowcase` |

```gts preview
import { Button } from 'frontile';
import { DownloadIcon } from 'site/components/icons';

<template>
  <Button>
    <DownloadIcon />
    Download
  </Button>
</template>
```

**Never inline an `<svg>` in a doc.** Currently zero component docs do, and it's worth
keeping that way: an inline icon is a wall of path data between the reader and the API
being demonstrated, and it can't pick up `size-icon-*` sizing or `currentColor` consistently.
If the icon you need isn't in `site/app/components/icons.gts`, add it there — match the
existing shape (24×24 viewBox, `stroke="currentColor"`, `class="size-icon-lg"`,
`...attributes`) and export it with the `*Icon` suffix.

The same applies one level up: if a doc needs a widget to explain something — a swatch grid,
a live token preview, a spec table — build it as a real component in
`site/app/components/`, the way `theme-docs/color-palette-grid.gts` does, rather than
assembling it inline in markdown. Components used outside a fence are declared in
frontmatter:

```yaml
imports:
  - import ColorPaletteGrid from 'site/components/theme-docs/color-palette-grid';
```

Inside a ` ```gts preview ` fence, import normally in the demo body instead.

## Content and length

A demo is doing two jobs: proving the API works, and being pasteable. Both argue for short.

- Show one idea per demo. If you're adding a second concept "while we're here", it's a
  second demo or it's noise.
- Use realistic content — a demo labeled `foo` / `bar` teaches nothing about what the
  component is for, while `Save changes` / `Cancel` shows a real pairing.
- Prefer `{{#each}}` over repetition when demonstrating an enumerable axis. Twenty
  near-identical tags make the reader diff them by eye; a loop over `(array 'sm' 'md' 'lg')`
  states the axis directly.
