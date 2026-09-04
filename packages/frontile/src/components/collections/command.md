---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Command

A command palette: a search field over a ranked, optionally grouped list of commands or
destinations. Results are ordered by how well they match, so the closest one is always first.

## Import

```js
import { Command, CommandDialog } from 'frontile';
```

## Usage

The usual form is a dialog, opened from a button or from a keyboard shortcut anywhere on the
page. `mod` is Cmd on Apple platforms and Ctrl elsewhere — press it now. Pass an array to
accept several, e.g. `@shortcut={{array "/" "mod+k"}}`.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { CommandDialog, Button } from 'frontile';
import {
  UserIcon,
  StarIcon,
  SearchIcon,
  CodeIcon
} from 'site/components/icons';

const commands = [
  {
    key: 'calendar',
    label: 'Calendar',
    section: 'Suggestions',
    Icon: StarIcon
  },
  {
    key: 'search-emoji',
    label: 'Search Emoji',
    section: 'Suggestions',
    Icon: SearchIcon
  },
  {
    key: 'calculator',
    label: 'Calculator',
    section: 'Suggestions',
    Icon: CodeIcon
  },
  {
    key: 'profile',
    label: 'Profile',
    section: 'Settings',
    Icon: UserIcon,
    shortcut: 'mod+p'
  },
  {
    key: 'billing',
    label: 'Billing',
    section: 'Settings',
    Icon: CodeIcon,
    shortcut: 'mod+b'
  },
  {
    key: 'settings',
    label: 'Settings',
    section: 'Settings',
    Icon: CodeIcon,
    shortcut: 'mod+s'
  }
];

export default class CommandDialogExample extends Component {
  @tracked isOpen = false;
  @tracked lastSelected;

  open = () => (this.isOpen = true);
  close = () => (this.isOpen = false);

  select = (key) => {
    this.lastSelected = key;
    this.isOpen = false;
  };

  <template>
    <div class='flex items-center gap-4'>
      <Button @appearance='outlined' {{on 'click' this.open}}>
        Open palette
        <kbd
          class='ml-2 rounded border border-neutral-soft px-1.5 font-body text-body-2xs text-neutral'
        >⌘K</kbd>
      </Button>
      {{#if this.lastSelected}}
        <span class='font-body text-body-sm text-neutral'>Selected:
          {{this.lastSelected}}</span>
      {{/if}}
    </div>

    <CommandDialog
      @isOpen={{this.isOpen}}
      @onOpen={{this.open}}
      @onClose={{this.close}}
      @onSelect={{this.select}}
      @shortcut='mod+k'
      @items={{commands}}
      @groupBy='section'
      @label='Search commands'
      @placeholder='Type a command or search…'
      as |c|
    >
      <c.Input />
      <c.List>
        <:item as |ctx|>
          <ctx.Item @key={{ctx.key}} @shortcut={{ctx.item.shortcut}}>
            <:start><ctx.item.Icon /></:start>
            <:default>{{ctx.label}}</:default>
          </ctx.Item>
        </:item>
        <:empty>No results for "{{c.query}}"</:empty>
      </c.List>
      <c.Footer />
    </CommandDialog>
  </template>
}
```

The dialog opens with a short scale-and-rise and honors `prefers-reduced-motion` by keeping
the fade but dropping the movement. An unmodified shortcut such as `/` is ignored while the
user is typing in a field, so it still types a slash in a text input.

## Anatomy

`Command` yields the palette's parts plus its current state, so you compose the layout rather
than configuring it. The same parts are yielded by `CommandDialog`.

```gts preview
import { Command } from 'frontile';

const commands = [
  { key: 'profile', label: 'Profile' },
  { key: 'billing', label: 'Billing' }
];

<template>
  <Command @items={{commands}} @isBordered={{true}} as |c|>
    {{! the search field — carries the combobox semantics }}
    <c.Input @placeholder='Search…' />

    {{! the results — ranked, grouped, keyboard navigable }}
    <c.List>
      <:item as |ctx|>
        {{! ctx yields the item, its key, its label, and a bound Item component }}
        <ctx.Item @key={{ctx.key}}>{{ctx.label}}</ctx.Item>
      </:item>
      <:empty>Nothing matched.</:empty>
      <:loading>Searching…</:loading>
      {{! async only: shown before anything has been typed }}
      <:prompt>Start typing to search.</:prompt>
    </c.List>

    {{! keyboard hints; c.query, c.resultCount and c.isLoading are yielded too }}
    <c.Footer />
  </Command>
</template>
```

## Inline

`Command` on its own renders in place — for a page-level search, a sidebar, or inside a
custom overlay. `@isBordered` draws its own surface.

```gts preview
import { Command } from 'frontile';

const commands = [
  { key: 'profile', label: 'Profile' },
  { key: 'billing', label: 'Billing' },
  { key: 'settings', label: 'Settings' },
  { key: 'calendar', label: 'Calendar' },
  { key: 'search-emoji', label: 'Search Emoji' }
];

<template>
  <Command
    @items={{commands}}
    @isBordered={{true}}
    @placeholder='Type a command or search…'
    as |c|
  >
    <c.Input />
    <c.List>
      <:item as |ctx|>
        <ctx.Item @key={{ctx.key}}>{{ctx.label}}</ctx.Item>
      </:item>
    </c.List>
  </Command>
</template>
```

## Ranking

The default filter ranks by relevance rather than filtering in place, which is what keeps an
exact match from being buried under a longer name that merely contains the query. Type `button`
below: `Button` stays on top even though `ButtonGroup` comes first in the array.

It also matches acronyms — try `bg` for ButtonGroup, or `tb` for ToggleButton.

```gts preview
import { Command } from 'frontile';

const components = [
  { key: 'button-group', label: 'ButtonGroup' },
  { key: 'toggle-button', label: 'ToggleButton' },
  { key: 'close-button', label: 'CloseButton' },
  { key: 'button', label: 'Button' },
  { key: 'checkbox-group', label: 'CheckboxGroup' }
];

<template>
  <Command
    @items={{components}}
    @isBordered={{true}}
    @placeholder="Try 'button' or 'bg'…"
    as |c|
  >
    <c.Input />
    <c.List>
      <:item as |ctx|>
        <ctx.Item @key={{ctx.key}}>{{ctx.label}}</ctx.Item>
      </:item>
    </c.List>
  </Command>
</template>
```

By default only the item's label is searched. `@searchFields` searches more than that — a
category, keywords — with the first field primary and the rest down-weighted and combined by
max, so a weak hit on a category never outranks a strong hit on the label.

```gts preview
import { Command } from 'frontile';

const components = [
  { key: 'button', label: 'Button', section: 'Buttons' },
  { key: 'chip', label: 'Chip', section: 'Buttons' },
  { key: 'modal', label: 'Modal', section: 'Overlays' }
];

const searchFields = (item) => [item.label, item.section];

<template>
  <Command
    @items={{components}}
    @searchFields={{searchFields}}
    @isBordered={{true}}
    @placeholder="Try 'overlays'…"
    as |c|
  >
    <c.Input />
    <c.List>
      <:item as |ctx|>
        <ctx.Item @key={{ctx.key}} @description={{ctx.item.section}}>
          {{ctx.label}}
        </ctx.Item>
      </:item>
    </c.List>
  </Command>
</template>
```

Pass `@filter` to score items yourself. Return a number to rank — higher first, `0` for no
match — or a boolean to filter without reordering.

```gts preview
import { Command } from 'frontile';
import { createFuzzyFilter } from 'frontile/utils/filter';

// A lower threshold trades precision for recall: this matches `btn` to Button.
const looseFilter = createFuzzyFilter({ threshold: 0 });

const components = [
  { key: 'button', label: 'Button' },
  { key: 'checkbox', label: 'Checkbox' },
  { key: 'table', label: 'Table' }
];

<template>
  <Command
    @items={{components}}
    @filter={{looseFilter}}
    @isBordered={{true}}
    @placeholder="Try 'btn'…"
    as |c|
  >
    <c.Input />
    <c.List>
      <:item as |ctx|>
        <ctx.Item @key={{ctx.key}}>{{ctx.label}}</ctx.Item>
      </:item>
    </c.List>
  </Command>
</template>
```

## Grouping

`@groupBy` sections the results under headings. A group whose items all filter out disappears
entirely — heading and separator with it — because sections are built from the ranked results
rather than declared as markup. Type `cal` below and watch Settings go.

By default groups are ordered by their best-scoring member, so the closest match is always on
top. `@groups` pins the groups you name to the top, in that order — anything not named still
renders after them, so pinning a "Recent" section cannot hide search results.

```gts preview
import { Command } from 'frontile';
import { array } from '@ember/helper';

const commands = [
  { key: 'calendar', label: 'Calendar', section: 'Suggestions' },
  { key: 'search-emoji', label: 'Search Emoji', section: 'Suggestions' },
  { key: 'calculator', label: 'Calculator', section: 'Suggestions' },
  { key: 'profile', label: 'Profile', section: 'Settings' },
  { key: 'billing', label: 'Billing', section: 'Settings' },
  { key: 'settings', label: 'Settings', section: 'Settings' }
];

<template>
  <Command
    @items={{commands}}
    @groupBy='section'
    @groups={{array 'Suggestions' 'Settings'}}
    @disabledKeys={{array 'calculator'}}
    @isBordered={{true}}
    @placeholder='Type a command or search…'
    as |c|
  >
    <c.Input />
    <c.List>
      <:item as |ctx|>
        <ctx.Item @key={{ctx.key}}>{{ctx.label}}</ctx.Item>
      </:item>
    </c.List>
  </Command>
</template>
```

## Rows

Rows are `Listbox` options, so they take the same `:start` / `:end` blocks, `@shortcut` and
`@description`. Icons in `:start` are sized and muted for you.

```gts preview
import { Command } from 'frontile';
import { UserIcon, StarIcon, SearchIcon } from 'site/components/icons';

const commands = [
  { key: 'profile', label: 'Profile', shortcut: 'mod+p', Icon: UserIcon },
  { key: 'favorites', label: 'Favorites', shortcut: 'mod+f', Icon: StarIcon },
  { key: 'search', label: 'Search', shortcut: 'mod+k', Icon: SearchIcon }
];

<template>
  <Command @items={{commands}} @isBordered={{true}} as |c|>
    <c.Input @placeholder='Search…' />
    <c.List>
      <:item as |ctx|>
        <ctx.Item @key={{ctx.key}} @shortcut={{ctx.item.shortcut}}>
          <:start><ctx.item.Icon /></:start>
          <:default>{{ctx.label}}</:default>
        </ctx.Item>
      </:item>
    </c.List>
  </Command>
</template>
```

## Footer

`c.Footer` renders the palette's keyboard hints. Give it a block to say something else — it
yields `Kbd` for a keycap and `Hint` for one hint's layout, so custom hints match the
built-in ones without copying any classes.

```gts preview
import { Command } from 'frontile';

const commands = [
  { key: 'button', label: 'Button' },
  { key: 'checkbox', label: 'Checkbox' }
];

<template>
  <Command @items={{commands}} @isBordered={{true}} @size='sm' as |c|>
    <c.Input @placeholder='Search components…' />
    <c.List>
      <:item as |ctx|>
        <ctx.Item @key={{ctx.key}}>{{ctx.label}}</ctx.Item>
      </:item>
    </c.List>
    <c.Footer as |f|>
      <f.Hint><f.Kbd @keys='enter' /> Go to page</f.Hint>
      <f.Hint><f.Kbd @keys='mod+c' /> Copy link</f.Hint>
    </c.Footer>
  </Command>
</template>
```

## Async search

Pass `@onSearch` to fetch results instead of filtering `@items`. It is debounced, and stale
responses are discarded so the latest query always wins — a slow early request can never
overwrite a newer one. Built-in filtering is disabled, since the server did the filtering.

Before anything is typed an async palette has nothing to show and nothing to report, so it
renders the `:prompt` block rather than claiming there are no results.

```gts preview
import Component from '@glimmer/component';
import { Command } from 'frontile';

const ALL = [
  'Argentina',
  'Australia',
  'Austria',
  'Brazil',
  'Canada',
  'Denmark',
  'Finland',
  'France',
  'Germany',
  'Japan',
  'Mexico',
  'Netherlands',
  'New Zealand',
  'Norway',
  'Poland',
  'South Africa',
  'Spain',
  'Sweden'
];

export default class AsyncCommandExample extends Component {
  search = async (query) => {
    // Stand-in for a network request.
    await new Promise((resolve) => setTimeout(resolve, 400));

    if (!query) return [];

    return ALL.filter((name) =>
      name.toLowerCase().includes(query.toLowerCase())
    ).map((name) => ({ key: name.toLowerCase(), label: name }));
  };

  <template>
    <Command
      @onSearch={{this.search}}
      @isBordered={{true}}
      @placeholder='Search countries…'
      as |c|
    >
      <c.Input />
      <c.List>
        <:item as |ctx|>
          <ctx.Item @key={{ctx.key}}>{{ctx.label}}</ctx.Item>
        </:item>
        <:loading>Searching…</:loading>
        <:prompt>Search for a country…</:prompt>
        <:empty>No matches for "{{c.query}}"</:empty>
      </c.List>
    </Command>
  </template>
}
```

To filter externally without `@onSearch` — against a store you already have, say — use
`@disableFiltering` with `@query` and `@onQueryChange`.

## Mixing static and remote results

A real palette usually has both: navigation and recents you already hold, plus records that
only the server can find. `@onSearch` alone does not cover this — when it is set, the resolved
results **replace** `@items`, and local filtering is off, so static entries would disappear as
soon as the first response landed.

Instead, own the merge and reuse the library's own scorer, which is exported:

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Command } from 'frontile';
import { filterAndRankItems } from 'frontile/utils/filter';
import { array } from '@ember/helper';

const NAVIGATION = [
  { key: 'nav:accounts', label: 'Accounts', section: 'Navigation' },
  { key: 'nav:billing', label: 'Billing', section: 'Navigation' },
  { key: 'nav:settings', label: 'Settings', section: 'Navigation' }
];

const RECENTS = [{ key: 'recent:acme', label: 'Acme Corp', section: 'Recent' }];

// Stand-in for a server that matches fields the client never sees — here, a
// trade name. Try "acme": the second row has no "acme" in its label at all.
const REMOTE = [
  { key: 'acct:1', label: 'Wile E. Coyote Enterprises', section: 'Accounts' },
  { key: 'acct:2', label: 'Acme Anvils LLC', section: 'Accounts' }
];

export default class MixedCommandExample extends Component {
  @tracked query = '';
  @tracked remote = [];
  @tracked isLoading = false;

  updateQuery = async (query) => {
    this.query = query;

    if (!query.trim()) {
      this.remote = [];
      return;
    }

    this.isLoading = true;
    await new Promise((resolve) => setTimeout(resolve, 300));
    this.remote = REMOTE;
    this.isLoading = false;
  };

  // Static entries are ranked with the same scorer the component would use.
  // Remote entries are appended as-is: the server already decided.
  get items() {
    const local =
      filterAndRankItems(
        [...RECENTS, ...NAVIGATION],
        this.query,
        (item) => item.label
      ) ?? [];

    return [...local, ...this.remote];
  }

  <template>
    <Command
      @items={{this.items}}
      @query={{this.query}}
      @onQueryChange={{this.updateQuery}}
      @isLoading={{this.isLoading}}
      @disableFiltering={{true}}
      @groupBy='section'
      @groups={{array 'Recent' 'Navigation' 'Accounts'}}
      @isBordered={{true}}
      @placeholder="Try 'acme'…"
      as |c|
    >
      <c.Input />
      <c.List>
        <:item as |ctx|>
          <ctx.Item @key={{ctx.key}} @description={{ctx.item.section}}>
            {{ctx.label}}
          </ctx.Item>
        </:item>
        <:empty>No results for "{{c.query}}"</:empty>
      </c.List>
    </Command>
  </template>
}
```

Three things make this work:

- **`@disableFiltering`** stops the component re-filtering your remote results. This is the
  part that bites: the server often matches on fields the client cannot see, so running the
  local fuzzy filter over its output silently discards legitimate hits — the
  `Wile E. Coyote Enterprises` row above would score `0` against `acme` and vanish.
- **`filterAndRankItems`**, exported from `frontile/utils/filter`, ranks the static half with
  exactly the same scorer, so the two halves feel consistent. It takes the same
  `labelFor`/`@filter` shapes the component does, including an array of fields.
- **`@groups`** keeps the halves in separate, pinned sections, so you never have to decide
  whether a remote hit should outrank a nav item. Groups with nothing left disappear on their
  own — type `acme` and Navigation drops out.

Debounce the fetch and discard stale responses yourself here; that is what `@onSearch` would
otherwise have done for you.

## Sizes

`@size` sets how tall the results area is. The list keeps a minimum height on purpose: without
one the palette collapses and re-expands on every keystroke as results narrow, which reads as
jitter.

```gts preview
import { Command } from 'frontile';
import { array } from '@ember/helper';

const commands = [
  { key: 'profile', label: 'Profile' },
  { key: 'billing', label: 'Billing' }
];

<template>
  <div class='flex flex-col gap-6'>
    {{#each (array 'sm' 'md' 'lg') as |size|}}
      <Command @items={{commands}} @size={{size}} @isBordered={{true}} as |c|>
        <c.Input @placeholder='size={{size}}' />
        <c.List>
          <:item as |ctx|>
            <ctx.Item @key={{ctx.key}}>{{ctx.label}}</ctx.Item>
          </:item>
        </c.List>
      </Command>
    {{/each}}
  </div>
</template>
```

## Accessibility

`Command` implements the ARIA combobox-with-list-autocomplete pattern. The combobox semantics
live on the **input** — not on a wrapper — so focus never leaves the field while the user
arrows through results.

| Key                     | Behavior                                          |
| ----------------------- | ------------------------------------------------- |
| `ArrowDown` / `ArrowUp` | Move the active option, crossing group boundaries |
| `Home` / `PageUp`       | Activate the first option                         |
| `End` / `PageDown`      | Activate the last option                          |
| `Enter`                 | Select the active option                          |
| `Escape`                | Close the dialog                                  |

Provided for you:

- `role="combobox"` and `aria-autocomplete="list"` on the input, with `aria-activedescendant`
  pointing at the active option's id. `aria-expanded` reflects whether the listbox is actually
  rendered, and `aria-controls` is only set while it is — an empty result set replaces the
  listbox, so neither is left claiming a popup that is not there.
- A debounced `aria-live="polite"` region announcing "N results available" / "No results
  found", so the result count is not silent to a screen reader.
- `role="listbox"` on the list and `role="option"` with `aria-selected` on each row. Groups
  render as `role="group"` labelled by their heading, with the intervening list marked
  `role="none"` so the `listbox` → `option` ownership chain stays intact.
- Disabled rows (via `@disabledKeys`) get `aria-disabled` and cannot be selected.
- The dialog traps focus, focuses the input on open, and restores focus on close.

What you must supply:

- `@label` — the input's accessible name. Defaults to `"Search"`, which is rarely specific
  enough when a page has more than one search.
- Meaningful row text. An icon-only row needs its own accessible name.

Verified in `test-app/tests/integration/components/collections/command-test.gts`, which covers
the combobox attributes, `aria-activedescendant` tracking the active option, cross-group
keyboard traversal, disabled rows, and the dialog's positioning.

## API

<Signature @component="Command" />
<Signature @component="CommandInput" />
<Signature @component="CommandList" />
<Signature @component="CommandFooter" />
<Signature @component="CommandDialog" />
