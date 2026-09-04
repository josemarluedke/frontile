# `Command` — a command palette / search component for Frontile

**Status:** design approved, pending implementation plan
**Date:** 2026-09-03
**Research:** [`docs/superpowers/research/command-palette-prior-art.md`](../research/command-palette-prior-art.md)

---

## 1. Motivation

The docs site's "jump to" palette (`site/app/components/docfy/docfy-jump-to.gts`) is a bespoke
`Overlay` + raw `<input>` + hand-rolled `selectedIndex` loop, backed by `fuse.js` at
`threshold: 0.4`. Searching `button` surfaces `ButtonGroup` above `Button`.

Investigation found the defect is **not** docs-site-specific. It is a structural property of
predicate-based filtering, and Frontile ships it in two more places.

### 1.1 The ranking defect, measured

`cmdk` (the React palette everyone copies) applies `PENALTY_NOT_COMPLETE = 0.99` **flat, once**,
regardless of how many characters are left unmatched:

| query | `Button` | `ButtonGroup` |
| --- | --- | --- |
| `b` … `butto` | 0.98990100 | 0.98990100 — **exact tie** |
| `button` | 0.99990000 | 0.98990100 |

For the entire time the user is typing a prefix, the two score bit-for-bit identically and the
stable sort falls through to registration order. `ButtonGroup` does not out-rank `Button` on
merit; there is no tiebreak at all. (`PENALTY_DISTANCE_FROM_START` is declared but never used, so
there is no "match nearer the start" term either.)

`fuse.js` has a different but related flaw: its Bitap error-distance model cannot express *how
much of the target was left over*, so completeness is not representable at any threshold.

### 1.2 The same bug in shipped Frontile components

`autocomplete.gts` and `select/select.gts` contain this identical block:

```ts
const filter = this.args.filter || defaultFilter;
return this.args.items?.filter((item) =>
  filter(keyAndLabelForItem(item).label, query)
);
```

with

```ts
// utils/listManager.ts
function defaultFilter(itemValue: string, filterValue: string): boolean {
  return itemValue.toLowerCase().includes(filterValue.toLowerCase());
}
```

`@filter` is typed `(itemValue, inputValue) => boolean`. **A boolean predicate can filter but never
reorder**, so results are always returned in source order. A filterable `Select` over
alphabetically-ordered items reproduces the `Button`/`ButtonGroup` complaint exactly.

Fixing ranking is therefore a library-wide improvement, not a docs-site patch.

---

## 2. Goals / non-goals

**Goals**

- A `Command` component in the library: palette dialog, grouped results, ranked filtering,
  async search, keyboard-first, accessible, animated.
- Fix ranking for `Command`, `Autocomplete`, and filterable `Select` in one place.
- Add group/section support to `Listbox` (currently absent), reused by all three.
- Make the docs site the first real consumer; drop `fuse.js`.

**Non-goals (v1)**

- Virtualized lists.
- Nested / multi-page palettes ("push a subcommand view").
- Vim bindings (`ctrl-n`/`ctrl-p`).
- Recents persistence *inside the library* — see §10.

---

## 3. Dependency decision: `fuzzysort`

A hand-written tiered scorer was designed, then **rejected on evidence**. Both `match-sorter` and
`fuzzysort` were installed and run against the case that motivated this work:

```
=== match-sorter ===                       === fuzzysort ===
b     Button > Button Group > ButtonGroup  b     Button > ButtonGroup > Button Group
butt  Button > Button Group > ButtonGroup  butt  Button > ButtonGroup > Button Group
bg    Button Group > Checkbox Group > …    bg    ButtonGroup > Button Group
tab   Tab > Table > Tabs                   tab   Tab > Tabs > Table
```

Both rank `Button` first at every prefix length. The predicted "ties then falls back to
alphabetical" failure of `match-sorter` **did not occur**; the correctness case for a custom
scorer does not exist.

`fuzzysort` is chosen over `match-sorter` on two grounds:

1. **API fit.** Our `@filter` contract (§4) is inherently per-item. `fuzzysort.single(query,
   target)` returns a per-item score (`0.941` for `butt`/`Button` vs `0.875` for
   `butt`/`ButtonGroup`) and `null` for no match. `match-sorter` exports only array-in/array-out
   (`matchSorter`, `matchSorterWithRankInfo`) — there is no per-item scoring function, so it
   cannot implement the contract without redesigning it.
2. **Weight.** `fuzzysort` v4 has **zero dependencies**. `match-sorter` pulls `@babel/runtime` and
   `remove-accents`.

Secondary benefits: `fuzzysort` handles camelCase acronyms correctly (`bg` → `ButtonGroup`, which
matters when half the corpus is camelCase component names) and returns `indexes`
(`[0,2,5]` for `btn`/`Button`), which gives `<mark>` highlighting for free.

`fuse.js` is removed from `site/`. Note this is not a like-for-like swap: `fuzzysort` becomes a
runtime dependency of the published `frontile` package (where `fuse.js` never was), while the site
sheds one. That is a deliberate trade — ranking is core to `Autocomplete` and `Select`, not just
to the docs site.

**Verified during implementation.** Two findings, both now covered by tests:

- `fuzzysort.single('', target)` returns `null`, so a **blank query would have filtered every item
  out**, leaving a palette empty until the first keystroke. `defaultFilter` short-circuits an empty
  query to `1`.
- Scores asymptote well above `0` (a 3-character subsequence across an 1800-character target still
  scores ~0.15), so the "legitimate match scoring exactly `0`" risk is theoretical. It is clamped to
  `Number.EPSILON` anyway, since `0` is load-bearing in the contract.

### 3.1 Match threshold and the substring floor

Replacing `includes()` with fuzzy matching admits results the old filter never returned. Measured
against a 30-item country list: `sa` went from **0 matches to 6** (only `South Africa` legitimate),
`ia` from 4 to 11.

Two facts shape the fix:

1. **`fuzzysort.single()` applies no threshold at all**, while `fuzzysort.go()` defaults to
   `threshold: 0.5`. Scoring one item at a time — which the `@filter` contract requires — silently
   opts out of the library's own quality bar. Verified: `go('sa', ['Spain'])` returns `[]` while
   `single('sa', 'Spain')` returns `0.358`.
2. **A threshold alone is not safe.** Genuine substring matches score *below* 0.5 —
   `ma` -> `Guatemala` is 0.500, `an` -> `Netherlands` 0.462, `an` -> `Switzerland` 0.447 — so any
   useful threshold would drop results the old filter returned.

So the default combines a threshold at fuzzysort's own `0.5` with a **substring floor**: an item
whose label contains the query is scored at no less than the threshold, whatever fuzzysort thought
of it. That makes the filter a *strict superset* of the old `includes()` default **by construction
rather than by measurement** — raising the threshold can never make an old result disappear, it can
only remove matches that are new.

Net effect:

- every result `includes()` returned is still returned, so no silent loss for existing
  `Autocomplete` / `Select` consumers;
- scattered mid-word subsequences (`sa` -> `Spain` 0.358, `ra` -> `Argentina`, `xo` -> `Mexico`) are
  cut;
- acronyms are gained: `bg` -> `ButtonGroup` (0.722), `nz` -> `New Zealand` (0.732).

The accepted cost is that `btn` -> `Button` (0.318) does not match: fuzzysort cannot distinguish it
from `sa` -> `Spain`, since both are scattered mid-word subsequences. `createFuzzyFilter({ threshold })`
trades precision for that recall.

Covered by a property test asserting the superset guarantee over a corpus, not just on examples.

## 4. `@filter` widened to `boolean | number`

```ts
/**
 * Score or match an item against the current input text.
 *
 * Return a **number** to rank: higher sorts first, `0` means no match, and the
 * list is sorted by score descending. Return a **boolean** to filter only,
 * preserving the order of `@items`.
 */
filter?: (itemValue: string, inputValue: string) => boolean | number;
```

Backwards compatible: existing boolean filters keep working and keep source order. Numeric returns
opt into ranking.

`defaultFilter` becomes the `fuzzysort`-backed scorer for `Autocomplete`, `Select` and `Command`.
**This changes result order for existing consumers** and is documented as a behavior change in the
v0.18 migration guide, with the escape hatch being an explicit boolean `@filter`.

### 4.1 Shared helper (deduplication)

The identical `filteredItems` logic in `autocomplete.gts` and `select.gts` collapses into one
helper, so the ranking change lands in a single place:

```ts
// utils/filter.ts
export function filterAndRankItems<T>(
  items: T[] | undefined,
  query: string,
  labelFor: (item: T) => string,
  filter: FilterFn = defaultFilter
): T[] | undefined;
```

`labelFor` is required rather than defaulting to `String(item)`: Frontile items are typically
`{ key, label }` objects, where `String(item)` yields `"[object Object]"` and silently matches
nothing.

Behavior: a blank or whitespace-only query returns `items` untouched; results are normalized to a
score (`true` -> `1`, `false` -> `0`, numbers as-is, anything `<= 0` or `NaN` dropped) and then
**stable**-sorted descending.

Normalizing `true` to a *full* match matters: recording it as `0` — as a first cut did — sorted
every boolean match below every numeric one, including the very weakest. And because the sort is
stable, a purely boolean filter scores every match identically and therefore preserves the order of
`@items` exactly, so backwards compatibility falls out of the normalization instead of needing a
separate "did anything return a number?" flag.

Multi-field records score per-field and take a **weighted max, never a sum** — a sum lets three
weak field hits beat one exact title match. `fuzzysort.go` supports weighted `keys` natively.

---

## 5. Grouping and filtering

This is the part the reference screenshots pin down: in the unfiltered state two groups render
with headings and a separator between them; typing `calen` leaves only `Calendar` under
`Suggestions`, and the `Settings` group — heading and separator included — disappears entirely.

### 5.1 Empty-group hiding is free

Because `<c.List>` renders from a **ranked array** rather than hiding DOM children, a group with
no surviving items is simply never rendered. There is no visibility tracking and no `forceMount`
escape hatch. cmdk needs both only because its items are React children it cannot introspect;
Glimmer's keyed `{{#each}}` over sorted data reorders and omits natively.

### 5.2 Group ordering

Two legitimate models, both supported:

- **Pinned order** (`@groups={{array "Recent" "Navigation"}}`) — the named groups are hoisted to
  the top in that order. Groups *not* named still render after them, ranked; pinning must not be
  able to hide results, which is why this pins rather than filters.
- **Best-match order** (default when `@groups` is omitted) — rank globally, then partition by
  group key, ordering groups by their best-scoring member. This is what docs search wants: an
  exact `Button` hit should top the list regardless of category.

`@groupBy` is a key name or a function over the record.

### 5.3 Separators

Rendered **between** rendered groups, never trailing. Derived, not authored, so the screenshot
behavior (separator disappears with its group) is automatic. An explicit `<c.Separator>` remains
available for custom layouts.

### 5.4 Listbox group support (new)

`Listbox` gains a section/group concept, since it has none today. Markup follows the APG listbox
grouping pattern:

```html
<ul role="listbox">
  <li role="group" aria-labelledby="grp-1">
    <span id="grp-1">Suggestions</span>
    <ul role="none">
      <li role="option" aria-selected="false">…</li>
    </ul>
  </li>
</ul>
```

Implemented as `<l.Group @title="..." @withDivider={{true}} as |g|>` yielding a manager-bound
`g.Item`. `@title` follows the `ListboxSection`-style naming this component family mirrors, rather
than cmdk's `heading`; note Frontile otherwise uses `@label` for visible text labels, but that is
consistently a *form control* label, which a section heading is not.

The heading `<span>` carries no ARIA role — a `span` has none to suppress, and `aria-labelledby`
takes its accessible name from the text regardless.

**No `ListManager` changes are required.** Navigation order is derived from the live DOM via
`compareDocumentPosition`, not from registration order:

```ts
get #orderedItems(): ListItem[] {
  return this.#items
    .filter((item) => item.el.isConnected)
    .sort((a, b) => { const position = a.el.compareDocumentPosition(b.el); ... });
}
```

Nesting options inside a group wrapper leaves document order unchanged, so flat traversal across
group boundaries is correct by construction. Grouping is therefore a markup + theme change only.
Still covered by an integration test (arrow-down from the last item of group 1 lands on the first
item of group 2).

### 5.5 Active item across re-ranking

Every keystroke re-ranks the list. The active item resets to the first visible item
(`ListManager`'s existing `autoActivateMode: 'first'`). Two things to watch:

- The known `ListManager` `isActive` flake — Glimmer DOM writes can fire `focusout` synchronously
  mid-render. Re-ranking makes this more likely, so it needs an explicit test.
- `aria-activedescendant` must point at a **rendered, visible** option id, and be removed when
  nothing is active.

### 5.6 Fixed list height

The screenshots keep the panel height constant as results shrink. A `min-height` on the list
prevents the palette from collapsing and re-expanding on every keystroke, which reads as jitter.
Exposed as a theme variant.

### 5.8 Forward compatibility: submenus are a different concept

`Dropdown` will eventually need nested sub-lists. **Groups must not be stretched to serve that
case.** They differ on every axis:

| | Groups (this spec) | Submenus (future) |
| --- | --- | --- |
| ARIA | `role="group"` + `aria-labelledby` | nested `role="menu"`; parent gets `aria-haspopup` / `aria-expanded` |
| Keyboard | none — one flat traversal | `->` enters, `<-` exits; each level has its own active item |
| Rendering | inline | portaled popover |
| `ListManager` | one, unchanged | one **per level** |

The decisive constraint is the DOM-order derivation above. `Popover` portals by default
(`renderInPlace` is opt-in), so a submenu's options are siblings of `<body>`, not descendants of
the parent `<ul>`. `compareDocumentPosition` between a parent option and a portaled child option is
meaningless, so **a single flat `ListManager` cannot model a submenu at all.**

Recommended future shape (explicitly out of scope here): `Listbox` stays a flat primitive;
submenus become `Dropdown::SubMenu` — a `Popover` wrapping a nested `Listbox @type="menu"` with its
own `ListManager`, plus a coordinator for focus handoff and closing the deepest level first on
`Escape`. This composes existing primitives rather than teaching `ListManager` hierarchy.

Nothing in the group design forecloses this, because groups add no `ListManager` concepts.

### 5.7 Already supported by `ListboxItem`

The screenshot rows need no new item API: leading icons use the existing `:start` block, the
right-aligned `⌘P` uses the existing `@shortcut` arg and its `shortcut` tv slot, and the dimmed
`Calculator` row is `@disabledKeys`.

---

## 6. Async

`Command` adopts `Autocomplete`'s existing, proven contract verbatim rather than importing cmdk's
vocabulary (`shouldFilter`):

| Arg | Behavior |
| --- | --- |
| `@onSearch(query) => Promise<T[]> \| T[]` | Debounced; stale responses discarded (latest query wins); disables built-in filtering |
| `@searchDebounce` | Default `250` |
| `@isLoading` | Renders `<c.Loading>` |
| `@disableFiltering` | Render `@items` as-is |
| `@inputValue` / `@onInputChange` | Controlled text |

Blank-query async state renders a "start typing" prompt, mirroring `isSearchPromptState`.

---

## 7. Anatomy

`Command` composes existing primitives exactly as `Autocomplete` does (`Popover` + input +
`Listbox` + `ListManager`), swapping the popover for an overlay:

```gts
<Command::Dialog @isOpen={{this.isOpen}} @onClose={{this.close}} @shortcut="mod+k" as |c|>
  <c.Input @placeholder="Type a command or search…" />
  <c.List @items={{this.records}} @groupBy="category" as |item|>
    <c.Item @key={{item.id}} @shortcut={{item.shortcut}} @onSelect={{this.go}}>
      <:start><item.Icon /></:start>
      <:default>{{item.title}}</:default>
    </c.Item>
  </c.List>
  <c.Footer />
</Command::Dialog>
```

`<c.List>` wraps `Listbox`; `<c.Item>` wraps `ListboxItem`, inheriting its `role`,
`aria-selected`, stable `itemId` and tv slots. `<Command>` is usable without the dialog for inline
palettes.

---

## 7.1 Visual design (as built)

The first cut was verified by DOM state and tests but never actually looked at, and it looked
poor. The rebuilt design follows shadcn's *site* command menu (the version with the inset
search field), mapped onto Frontile tokens:

- **Panel**: `p-2`, `rounded-xl`, `bg-surface-modal`, `border-surface-overlay-mild`, plus
  `ring-4 ring-neutral-soft/40` + `shadow-2xl` in the dialog — the soft outer ring is what
  separates the panel from the scrim; a shadow alone reads flat against a dark backdrop.
- **Input**: inset as its own field — `h-9 rounded-md border-neutral-soft bg-neutral-subtle/60`
  — rather than a flush input with a bottom border.
- **Rows**: `min-h-9 rounded-md px-3`, label `text-body-sm font-medium` (14px), a transparent
  border that becomes `border-neutral-soft` + `bg-neutral-subtle/80` when active; shortcuts
  render as plain muted text (`tracking-widest`, no keycap border); leading `<svg>`s are
  `size-4 text-neutral` unless the consumer sizes/colors them.
- **Group headings**: `text-body-2xs font-medium text-neutral` (medium, not the semibold label
  face), inset `px-3 pt-2 pb-1`; dividers between groups get `my-1`.
- **Footer** (`c.Footer`, new part): `h-10` bar bleeding to the panel edges
  (`-mx-2 -mb-2`), `bg-neutral-subtle/60 border-t`, `text-body-2xs font-medium text-neutral`,
  with `Kbd` keycaps (`h-5 rounded border bg-surface-modal text-[0.7rem]`). Default content is
  ↑↓ Navigate · ↵ Select · Esc Close; a block replaces it and is handed `Kbd`.
- **Inline (`@isBordered`)**: `min-w-[28rem]` — a shrink-wrapped flex parent otherwise sizes
  the palette to its widest row (208px in the docs), which is what made everything look
  oversized.

Four bugs found only by looking, all now covered by tests or verified in the browser:

1. `@disableFlexContent` on `Overlay` stripped `fixed inset-0`, so the dialog rendered in-flow
   at the bottom of the page with no backdrop.
2. The dialog bound tv slot *functions* to `class` without invoking them, so the panel had no
   styles at all.
3. `overlay-transition--command-*` classes were never emitted: ember-css-transitions composes
   class names at runtime, so Tailwind cannot see them — every overlay transition must be
   listed in `packages/theme/src/plugin/safelist.ts`.
4. Row/heading overrides written as template literals (`${row}:px-3`) generated nothing:
   Tailwind scans source text for complete class strings. Descendant utilities must be
   literal.

Also: `test-app` cannot observe Tailwind class names on `Overlay`, because other test modules
call `registerCustomStyles({ overlay })` process-wide. Assert on a variant class registered by
the test itself (the Modal tests' pattern) instead.

## 8. Motion

New `command` transition in `packages/theme/src/components/command.ts`:

- Backdrop fade ~120ms.
- Panel `scale(0.96 → 1)` + 4px rise, ~150ms, fast-out curve.
- **Rows never animate.** Animating rows while the list re-ranks on each keystroke is what makes
  palettes feel laggy.
- Wrapped in `prefers-reduced-motion` → plain fade.

CSS only, via `ember-css-transitions` (already an `Overlay` dependency). No JS animation runtime.

---

## 9. Accessibility

Per APG "Combobox with List Autocomplete":

- `role="combobox"`, `aria-autocomplete="list"`, `aria-expanded`, `aria-controls` on the **input**
  (note: shadcn-ember puts `role="combobox"` on the root with a hardcoded `aria-expanded="true"`,
  which is wrong; do not copy it).
- `aria-activedescendant` on the input → the active `ListboxItem`'s `itemId`.
- One `aria-selected="true"` at a time; `data-active` for styling.
- Focus never leaves the input. `Esc` closes. `Home`/`End` behave as text-editing keys.
- Debounced `aria-live="polite"` sr-only region: "N results available" / "No results found".
- `guidFor(this)` ids so multiple palettes can coexist.

---

## 10. Docs site integration

`docfy-jump-to.gts` becomes a thin consumer:

- Records built from `docfy.flat`: title, `parentLabel`, headings, keywords.
- Grouped by category (best-match group ordering, §5.2).
- `/` retained, `⌘K` added; `/` suppressed while focus is in a text field.
- **Recents live site-side, not in the library.** Persistence keys, privacy and what counts as
  "recent" are application concerns; the component supports it by receiving a different `@items`
  array when the query is blank.
- `fuse.js` removed from `site/package.json`.

---

## 11. File layout

```
packages/frontile/src/
  utils/filter.ts                       ← NEW: createFuzzyFilter, defaultFilter, filterAndRankItems
                                        ← scoreRecord (multi-field) still pending
  utils/listManager.ts                  ← defaultFilter re-exported from utils/filter; widen FilterFn
  components/collections/
    listbox/listbox.gts                 ← yields Group
    listbox/group.gts                   ← NEW
    command/command.gts                 ← root: query state, ranking, grouping, async, context
    command/input.gts, list.gts, item.gts, group.gts, empty.gts, loading.gts, dialog.gts
    command.md                          ← co-located docs (live Docfy demos)
  components/forms/autocomplete.gts     ← use filterAndRankItems
  components/forms/select/select.gts    ← use filterAndRankItems
packages/theme/src/components/command.ts  ← NEW tv() slots + motion
packages/theme/src/components/listbox.ts  ← group heading slots
site/app/components/docfy/docfy-jump-to.gts  ← rewritten as consumer
docs/migrations/v0.18/…                 ← ranking behavior change
```

---

## 12. Testing

Written in this order:

1. **Unit — ranking regression table** (`test-app/tests/unit/`). The literal complaint as a test:
   `butt` → `Button` before `ButtonGroup`, at every prefix length. Plus `bg` → `ButtonGroup`,
   `tab` → `Tab`, and the `fuzzysort` zero-score edge case from §3.
2. **Unit — `filterAndRankItems`**: empty query passthrough, boolean filters preserve source
   order, numeric filters sort descending, equal scores are stable.
3. **Integration — `Listbox` groups**: rendering, ARIA structure, arrow-key traversal across group
   boundaries.
4. **Integration — `Command`**: empty-group hiding (the screenshot case), separator derivation,
   active-item reset on re-rank, `ListManager` `isActive` flake under re-ranking,
   `aria-activedescendant` correctness, async loading/empty/prompt states, `⌘K`/`/` binding and
   `/` suppression in text fields.
5. **Regression — `Autocomplete` / `Select`**: existing boolean `@filter` consumers keep source
   order.

---

## 13. Risks

| Risk | Mitigation |
| --- | --- |
| `defaultFilter` change reorders results in shipped components | Documented in v0.18 migration guide; boolean `@filter` restores old behavior; regression tests |
| `ListManager` `isActive` flake, aggravated by re-ranking | Explicit test early; fall back to a Command-local registry if it proves unstable |
| Fuzzy matching is looser than `includes()`, admitting noise | Threshold at fuzzysort's own 0.5 **plus** a substring floor, so the filter is a superset of the old behavior by construction; property test over a corpus |
| A `@filter` mixing booleans and numbers orders incoherently | `true` normalizes to a full match; single stable sort for every case |
| Listbox group markup regresses existing `Listbox` a11y | Groups are opt-in; existing ungrouped markup path unchanged and still tested |
