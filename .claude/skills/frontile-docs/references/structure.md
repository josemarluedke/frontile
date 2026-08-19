# Canonical structure for a component doc

Read this before creating a new `.md` or reordering an existing one.

Contents:
- [File location and naming](#file-location-and-naming)
- [Frontmatter](#frontmatter)
- [The template](#the-template)
- [Section-by-section](#section-by-section)
- [Approved heading vocabulary](#approved-heading-vocabulary)
- [Compound and yielding components](#compound-and-yielding-components)

## File location and naming

The doc is a sibling of the component, same basename:

```
packages/frontile/src/components/buttons/button.gts
packages/frontile/src/components/buttons/button.md
```

Docfy picks it up from `site/docfy.config.mjs`, which globs
`src/components/{buttons,utilities,status,collections,forms,notifications,overlays}/**/*.md`
with `urlSchema: 'manual'`. A new file in one of those categories appears on the site with
no registration step. A file in a category that isn't in that list will not — add the
category to `docfy.config.mjs` `sources` **and** `sections` if you create one.

## Frontmatter

```yaml
---
label: New
url: modal
imports:
  - import Signature from 'site/components/signature';
---
```

| Key | When | Notes |
| --- | --- | --- |
| `imports` | Whenever the doc uses `<Signature>` — so, effectively always | Without it the tag renders as literal text |
| `label` | New components only | Renders a sidebar badge. `New` is the only value in use. Drop it after a release or two |
| `url` | Rare | Overrides the generated URL segment. Only `modal.md` and `drawer.md` use it, to keep short public URLs |

There is no `title` key — the H1 is the title.

## The template

````md
---
imports:
  - import Signature from 'site/components/signature';
---

# ComponentName

One sentence on what it's for and when to reach for it. No adjectives that don't
narrow anything down.

## Import

```js
import { ComponentName } from 'frontile';
```

## Usage

The simplest thing that works — no options, no styling, nothing the reader has to
skip past to see the shape of the API.

```gts preview
import { ComponentName } from 'frontile';

<template>
  <ComponentName>Content</ComponentName>
</template>
```

## <Feature section>

One section per axis of variation. Prose only where the demo can't speak: which
option to pick, what interacts with what.

```gts preview
…
```

## Accessibility

Keyboard table, roles and ARIA, focus behavior, screen reader notes. See the
Accessibility step in SKILL.md for what belongs here.

## API

<Signature @component="ComponentName" />
````

## Section-by-section

**H1 title.** The component name as written in code (`ButtonGroup`, not `Button Group`),
followed by one sentence. Compare `button.md`: "The Button component can be used to trigger
an action, such as submitting a form, opening a modal, and more." It says what it's for and
gives concrete occasions. That's the bar.

**`## Import`** — a bare ` ```js ` fence with the import line, nothing else. Always from
`'frontile'`.

**`## Usage`** — the minimum viable demo. This is the section most readers copy, so it
should work pasted into an empty file with no further reading. If the component genuinely
can't be used without an argument, include only that one.

**Feature sections** — one `##` per axis: appearances, intents, sizes, disabled/loading
states, selection modes, positioning. Order them the way someone learns the component:
appearance and size before edge-case behavior. Where an axis is combinatorial (every intent
in every appearance), a single `{{#each}}` demo beats twenty hand-written tags — see
`button.md`'s intents section.

**`## Accessibility`** — required. Details in SKILL.md step 4.

**`## API`** — only `<Signature @component="X" />`. If the component yields sub-components
that have their own signatures, add a tag per component, in the order a reader meets them.

## Approved heading vocabulary

Use the standard headings so the sidebar and in-page TOC stay predictable across 30+ files:

| Use | Instead of |
| --- | --- |
| `## Usage` | `## Basic Usage` |
| Feature `##` sections, named for the axis | `## Key Features` (a list of features nobody reads) |
| Prose inside the relevant section, or a `> Note:` callout | `## Important Notes` (orphaned facts) |
| Guidance inside the section it applies to | `## Best Practices` |

`## Key Features`, `## Important Notes`, and `## Best Practices` all exist in the current
docs and all suffer the same problem: they collect facts away from the thing they describe,
where readers scanning for a feature won't find them. When you touch a file that has one,
redistribute its contents into the sections they belong to.

## Compound and yielding components

For components that yield sub-components or a rich block context (`Form`, `Field`, `Table`,
`Dropdown`, `Listbox`, `Select`), the reader's first question is *what are the pieces and
how do they fit*. Answer it immediately after `## Usage` with a short section showing the
parts assembled — the existing `### Yielded Components` sections in `dropdown.md` and
`listbox.md` are the pattern:

````md
## Anatomy

```gts preview
import { Dropdown } from 'frontile';

<template>
  <Dropdown as |d|>
    <d.Trigger>Open</d.Trigger>
    <d.Menu as |Item|>
      <Item>Profile</Item>
    </d.Menu>
  </Dropdown>
</template>
```
````

Then document each part's own arguments with its own `<Signature>` tag under `## API`.
Without this, a reader has to reverse-engineer the block structure from a feature demo that
was trying to show them something else.
