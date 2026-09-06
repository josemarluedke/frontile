---
title: Filter Ranking
order: 5
category: migrations
subcategory: v0.18
---

# Filtered lists are now ranked by relevance

`Autocomplete` and filterable `Select` used to filter with a case-insensitive
"contains" check and render whatever survived **in the order you passed it**.
They now score each item and list the closest match first.

Nothing to change unless you pass your own `@filter`. The results are ordered
differently, which is the point.

## Why it changed

The old default could only answer "does this item match?", never "how well?":

```ts
// before
function defaultFilter(itemValue: string, filterValue: string): boolean {
  return itemValue.toLowerCase().includes(filterValue.toLowerCase());
}
```

A predicate filters but cannot reorder, so an exact match sat wherever `@items`
happened to put it. Typing `button` into a list ordered alphabetically returned
`ButtonGroup` above `Button` — both "match", and source order decided the rest.

## What you get now

Typing `butt`:

| | Before | After |
| --- | --- | --- |
| 1 | ButtonGroup | **Button** |
| 2 | Button Group | ButtonGroup |
| 3 | Button | Button Group |

Acronyms also match now, which "contains" could never do:

- `bg` → `ButtonGroup`
- `nz` → `New Zealand`
- `prog` → `ProgressBar`

**Nothing that matched before stops matching.** The threshold is calibrated so
every result the old `includes()` filter returned is still returned; the change
is additive plus reordering.

## `@filter` accepts a score

```ts
filter?: (itemValue: string, inputValue: string) => boolean | number;
```

Return a **number** to rank — higher sorts first, `0` means no match. Return a
**boolean** to filter only, preserving the order of `@items`.

Existing boolean filters are unaffected:

```gts
{{! still works exactly as before, including source ordering }}
<Autocomplete @filter={{this.startsWith}} @items={{this.items}} />
```

```ts
startsWith = (itemValue: string, inputValue: string) =>
  itemValue.toLowerCase().startsWith(inputValue.toLowerCase());
```

### Keeping the old behavior

Pass the previous implementation explicitly:

```ts
const containsFilter = (itemValue: string, inputValue: string) =>
  itemValue.toLowerCase().includes(inputValue.toLowerCase());
```

```gts
<Select @isFilterable={{true}} @filter={{containsFilter}} @items={{this.items}} />
```

## Tuning how loose matching is

Fuzzy matching is looser than "contains", so a threshold keeps out noise. It
cannot distinguish a useful abbreviation from a coincidence — `btn` → `Button`
and `sa` → `Spain` are the same shape, both scattered mid-word subsequences —
so the default favors precision and matches neither.

To trade precision for recall, build your own:

```ts
import { createFuzzyFilter } from 'frontile/utils/filter';

// matches btn -> Button, at the cost of also matching sa -> Spain
const looseFilter = createFuzzyFilter({ threshold: 0 });
```

```gts
<Autocomplete @filter={{looseFilter}} @items={{this.items}} />
```

`DEFAULT_MATCH_THRESHOLD` is `0.4`. Raise it for stricter matching, lower it for
looser.
