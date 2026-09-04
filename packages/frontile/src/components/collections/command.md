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

`Command` renders inline. Pass `@items` and describe one row in the `:item` block.

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
  <Command @items={{commands}} @isBordered={{true}} @placeholder="Type a command or search…" as |c|>
    <c.Input />
    <c.List>
      <:item as |ctx|>
        <ctx.Item @key={{ctx.key}}>{{ctx.label}}</ctx.Item>
      </:item>
    </c.List>
  </Command>
</template>
```

## Anatomy

`Command` yields the palette's parts plus its current state, so you compose the layout rather
than configuring it.

```gts preview
import { Command } from 'frontile';

const commands = [{ key: 'profile', label: 'Profile' }];

<template>
  <Command @items={{commands}} @isBordered={{true}} as |c|>
    {{! the search field — carries the combobox semantics }}
    <c.Input @placeholder="Search…" />

    {{! the results — ranked, grouped, and keyboard navigable }}
    <c.List>
      <:item as |ctx|>
        {{! ctx yields the item, its key, its label, and a bound Item component }}
        <ctx.Item @key={{ctx.key}}>{{ctx.label}}</ctx.Item>
      </:item>
      <:empty>Nothing matched.</:empty>
      <:loading>Searching…</:loading>
    </c.List>

    {{! c.query, c.resultCount and c.isLoading are yielded too }}
    <div class="px-3 py-2 text-neutral font-label text-label-2xs">
      {{c.resultCount}} results
    </div>
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
  <Command @items={{components}} @isBordered={{true}} @placeholder="Try 'button' or 'bg'…" as |c|>
    <c.Input />
    <c.List>
      <:item as |ctx|>
        <ctx.Item @key={{ctx.key}}>{{ctx.label}}</ctx.Item>
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
top. Pass `@groups` to fix the order instead.

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
    @groupBy="section"
    @groups={{array "Suggestions" "Settings"}}
    @disabledKeys={{array "calculator"}}
    @isBordered={{true}}
    @placeholder="Type a command or search…"
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

Rows are `Listbox` options, so they take the same `:start` / `:end` blocks, `@description` and
`@shortcut`.

```gts preview
import { Command } from 'frontile';
import { UserIcon, StarIcon, SearchIcon } from 'site/components/icons';

const commands = [
  { key: 'profile', label: 'Profile', shortcut: '⌘P' },
  { key: 'favorites', label: 'Favorites', shortcut: '⌘F' },
  { key: 'search', label: 'Search', shortcut: '⌘K' }
];

const iconFor = (key) => {
  if (key === 'profile') return UserIcon;
  if (key === 'favorites') return StarIcon;
  return SearchIcon;
};

<template>
  <Command @items={{commands}} @isBordered={{true}} as |c|>
    <c.Input @placeholder="Search…" />
    <c.List>
      <:item as |ctx|>
        <ctx.Item
          @key={{ctx.key}}
          @shortcut={{ctx.item.shortcut}}
          @description="Jump to {{ctx.label}}"
        >
          <:start>
            {{#let (iconFor ctx.key) as |Icon|}}
              <Icon class="w-4 h-4 shrink-0" />
            {{/let}}
          </:start>
          <:default>{{ctx.label}}</:default>
        </ctx.Item>
      </:item>
    </c.List>
  </Command>
</template>
```

## Dialog

`CommandDialog` puts the palette in an overlay and can open it from a keyboard shortcut
anywhere in the document. `mod` is Cmd on Apple platforms and Ctrl elsewhere.

An unmodified shortcut such as `/` is ignored while the user is typing in a field, so it still
types a slash in a text input.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { CommandDialog, Button } from 'frontile';

const commands = [
  { key: 'profile', label: 'Profile', section: 'Settings' },
  { key: 'billing', label: 'Billing', section: 'Settings' },
  { key: 'calendar', label: 'Calendar', section: 'Suggestions' },
  { key: 'search-emoji', label: 'Search Emoji', section: 'Suggestions' }
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
    <Button {{on "click" this.open}}>Open palette (⌘K)</Button>

    {{#if this.lastSelected}}
      <p class="mt-3 text-neutral">Selected: {{this.lastSelected}}</p>
    {{/if}}

    <CommandDialog
      @isOpen={{this.isOpen}}
      @onOpen={{this.open}}
      @onClose={{this.close}}
      @onSelect={{this.select}}
      @shortcut="mod+k"
      @items={{commands}}
      @groupBy="section"
      @label="Search commands"
      @placeholder="Type a command or search…"
      as |c|
    >
      <c.Input />
      <c.List>
        <:item as |ctx|>
          <ctx.Item @key={{ctx.key}}>{{ctx.label}}</ctx.Item>
        </:item>
        <:empty>No results for "{{c.query}}"</:empty>
      </c.List>
    </CommandDialog>
  </template>
}
```

The dialog animates in with a short scale-and-rise, and honors
`prefers-reduced-motion` by dropping the movement while keeping the fade.

## Async search

Pass `@onSearch` to fetch results instead of filtering `@items`. It is debounced, and stale
responses are discarded so the latest query always wins — a slow early request can never
overwrite a newer one. Built-in filtering is disabled, since the server did the filtering.

```gts preview
import Component from '@glimmer/component';
import { Command } from 'frontile';

const ALL = [
  'Argentina', 'Australia', 'Austria', 'Brazil', 'Canada', 'Denmark',
  'Finland', 'France', 'Germany', 'Japan', 'Mexico', 'Netherlands',
  'New Zealand', 'Norway', 'Poland', 'South Africa', 'Spain', 'Sweden'
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
      @placeholder="Search countries…"
      as |c|
    >
      <c.Input />
      <c.List>
        <:item as |ctx|>
          <ctx.Item @key={{ctx.key}}>{{ctx.label}}</ctx.Item>
        </:item>
        <:loading>Searching…</:loading>
        <:empty>
          {{#if c.query}}No matches for "{{c.query}}"{{else}}Start typing to search.{{/if}}
        </:empty>
      </c.List>
    </Command>
  </template>
}
```

To filter externally without `@onSearch` — against a store you already have, say — use
`@disableFiltering` with `@query` and `@onQueryChange`.

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
  <div class="flex flex-col gap-4">
    {{#each (array "sm" "md" "lg") as |size|}}
      <Command @items={{commands}} @size={{size}} @isBordered={{true}} as |c|>
        <c.Input @placeholder="{{size}}" />
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

| Key | Behavior |
| --- | --- |
| `ArrowDown` / `ArrowUp` | Move the active option, crossing group boundaries |
| `Home` / `PageUp` | Activate the first option |
| `End` / `PageDown` | Activate the last option |
| `Enter` | Select the active option |
| `Escape` | Close the dialog |

Provided for you:

- `role="combobox"`, `aria-autocomplete="list"`, `aria-expanded` and `aria-controls` on the
  input, with `aria-activedescendant` pointing at the active option's id.
- `role="listbox"` on the list and `role="option"` with `aria-selected` on each row. Groups
  render as `role="group"` labelled by their heading, with the intervening list marked
  `role="none"` so the `listbox` → `option` ownership chain stays intact.
- Disabled rows (via `@disabledKeys`) get `aria-disabled` and cannot be selected.
- The dialog traps focus and restores it on close.

What you must supply:

- `@label` — the input's accessible name. Defaults to `"Search"`, which is rarely specific
  enough when a page has more than one search.
- Meaningful row text. An icon-only row needs its own accessible name.

Verified in `test-app/tests/integration/components/collections/command-test.gts`, which covers
the combobox attributes, `aria-activedescendant` tracking the active option, cross-group
keyboard traversal, and disabled rows.

## API

<Signature @component="Command" />

### Command::Input

<Signature @component="CommandInput" />

### Command::List

<Signature @component="CommandList" />

### Command::Dialog

<Signature @component="CommandDialog" />
