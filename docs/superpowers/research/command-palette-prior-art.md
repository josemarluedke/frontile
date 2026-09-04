# Command Palette Prior Art — research for a Frontile `Command` component

Research date: 2026-09-03. All findings verified against primary sources (raw source files
where possible); URLs cited inline.

**Headline finding:** cmdk's `command-score` does *not* actually rank `ButtonGroup` above
`Button` for the full query `"button"` — but it **ties them exactly** for every partial prefix
(`b`, `bu`, `but`, `butt`, `butto`), because its "target is longer than the query" penalty is a
single flat constant that ignores *how much* longer. Ties fall through to DOM/insertion order,
so `ButtonGroup` visibly sits above `Button` for the entire time the user is typing. See
[§1.4](#14-the-actual-ranking-bug-measured) for measured numbers.

---

## 1. cmdk (pacocoursey/cmdk)

Source: <https://github.com/pacocoursey/cmdk>
Scoring: <https://github.com/pacocoursey/cmdk/blob/main/cmdk/src/command-score.ts>
(note: the file lives at `cmdk/src/`, not `src/`)
Core: <https://github.com/pacocoursey/cmdk/blob/main/cmdk/src/index.tsx>

### 1.1 Component anatomy

| Component | Selector | Notes |
| --- | --- | --- |
| `Command` | `[cmdk-root]` | Root. Controlled via `value` / `onValueChange`. Values are always `.trim()`ed. |
| `Command.Dialog` | `[cmdk-dialog]`, `[cmdk-overlay]` | Composes Radix Dialog. `open` / `onOpenChange`, optional `container` portal target. |
| `Command.Input` | `[cmdk-input]` | Forwards all props to `<input>`. Controlled via `value` / `onValueChange`. |
| `Command.List` | `[cmdk-list]` | Scroll container. Exposes CSS var `--cmdk-list-height` for animated height. |
| `Command.Item` | `[cmdk-item]`, `[data-selected]`, `[data-disabled]` | `onSelect`, unique `value` (inferred from text content if omitted), `keywords`, `forceMount`. |
| `Command.Group` | `[cmdk-group]`, `[cmdk-group-heading]`, `[hidden]` | `heading`, `value` (required if no heading), `forceMount`. Hidden via attribute, **not** unmounted. |
| `Command.Empty` | `[cmdk-empty]` | Auto-renders only when the filtered count is 0. |
| `Command.Separator` | `[cmdk-separator]` | Rendered when search is empty, or `alwaysRender`. |
| `Command.Loading` | `[cmdk-loading]` | Rendered while you say you're loading; has `progress`. |

Plus a `useCommandState(selector)` hook (built on `useSyncExternalStore`) for reading `search`,
`value`, `filtered.count` etc. from outside — used for dynamic empty states.

Other root props: `loop` (arrow keys wrap), `vimBindings` (ctrl+n/p/j/k), `disablePointerSelection`
(don't let hover steal the active item — important for keyboard-first palettes), `label`
(accessible name).

### 1.2 The controlled `value` model

`Command`'s `value` is **the active/highlighted item's value**, not the search text. This is the
single most important API decision to copy:

```tsx
const [value, setValue] = React.useState('')
<Command value={value} onValueChange={setValue}>
```

Search text is separate, on `Command.Input` (`value` / `onValueChange`). Keeping "what is
highlighted" and "what is typed" as two independent controlled channels is what makes
`aria-activedescendant`, mouse-hover-syncs-highlight, and "reset highlight to first result on new
query" all trivially expressible.

### 1.3 `shouldFilter={false}` — the async/server-search escape hatch

Both the filtering and the sorting are gated on the same condition, in `index.tsx`:

```ts
function sort() {
  if (!state.current.search || propsRef.current.shouldFilter === false) return
  …
}
function filterItems() {
  if (!state.current.search || propsRef.current.shouldFilter === false) { /* all visible */ }
  …
}
```

So `shouldFilter={false}` turns `Command` into a pure presentation + keyboard-nav shell: you own
matching, ranking and ordering (debounced fetch → render items in server order). Everything else
— arrow keys, `Enter`, active-item tracking, empty state, groups — keeps working. **This is the
right seam for a docs-site palette backed by a prebuilt index or an API.**

### 1.4 The `filter` prop

```ts
type CommandFilter = (value: string, search: string, keywords?: string[]) => number
const defaultFilter: CommandFilter = (value, search, keywords) => commandScore(value, search, keywords)
```

Return `0` to hide the item; any positive number is the rank. Note the signature gives you only
the item's `value` string plus `keywords` — there is **no per-field structure**, which is exactly
why a docs palette (title vs section vs body) outgrows it. Frontile should widen this.

Sorting semantics (`index.tsx` `sort()`):

- Items are sorted by score descending, then **re-appended into the DOM** in that order.
- A group's score is the **max** of its items' scores; groups are sorted by that.
- Ungrouped items float above groups.
- `Array.prototype.sort` is stable, so **equal scores preserve source order** — this is where the
  reported bug lives.

### 1.5 `command-score` — the actual constants

Verbatim from `cmdk/src/command-score.ts`:

```js
var SCORE_CONTINUE_MATCH = 1,        // match continues the previous match (or is at index 0)
    SCORE_SPACE_WORD_JUMP = 0.9,     // match starts a new word after whitespace/hyphen
    SCORE_NON_SPACE_WORD_JUMP = 0.8, // match starts a new word after \ / _ + . # " @ [ ( { &
    SCORE_CHARACTER_JUMP = 0.17,     // match is mid-word (the "fuzzy" case)
    SCORE_TRANSPOSITION = 0.1,       // user swapped two letters
    PENALTY_SKIPPED = 0.999,         // per skipped character between matches
    PENALTY_CASE_MISMATCH = 0.9999,  // matched, but wrong case
    PENALTY_DISTANCE_FROM_START = 0.9,
    PENALTY_NOT_COMPLETE = 0.99      // target has characters left over after the query is exhausted

var IS_GAP_REGEXP    = /[\\\/_+.#"@\[\(\{&]/,
    COUNT_GAPS_REGEXP= /[\\\/_+.#"@\[\(\{&]/g,
    IS_SPACE_REGEXP  = /[\s-]/,
    COUNT_SPACE_REGEXP=/[\s-]/g
```

Heuristics worth stealing:

- **Multiplicative, recursive, memoized.** `commandScoreInner(string, abbrev, lowerString,
  lowerAbbrev, stringIndex, abbrevIndex, memo)` tries every occurrence of the next query char and
  keeps the max. Memo key is `` `${stringIndex},${abbreviationIndex}` ``. Because scores multiply
  and all factors are ≤ 1, a perfect contiguous full match is exactly `1`.
- **Word-jump tiers.** Space/hyphen jumps (0.9) beat punctuation jumps (0.8) beat mid-word jumps
  (0.17). The 0.17 cliff is what makes acronym-ish fuzzy matches rank far below substring matches.
- **Gap penalty** is `PENALTY_SKIPPED ** skippedChars` — deliberately tiny (0.999), so it only
  breaks ties; the comment says it won't reorder relative to the `SCORE_*` tiers "until 100
  characters are inserted between matches."
- **Case-match bonus** is likewise a 0.9999 penalty for mismatched case — pure tie-break
  ("`HTML` more likely than `haml` when `HM` is typed").
- **Transposition** handling: if the previous target char equals the *next* query char, it tries
  consuming two query chars at once and multiplies by `SCORE_TRANSPOSITION = 0.1`. There's an
  explicit carve-out for duplicate letters (`ref #7428`).
- **Aliases/keywords** are handled by *string concatenation*, not separate scoring:
  ```js
  string = aliases?.length ? `${string + ' ' + aliases.join(' ')}` : string
  ```
  Cheap, but it means keywords dilute the length-completeness penalty and can produce spurious
  cross-field matches (query chars satisfied half from the title, half from a keyword).
- **`PENALTY_DISTANCE_FROM_START` is declared but never used.** Dead constant in current `main`.
  There is no "match nearer the start of the string is better" term at all.

### 1.6 The actual ranking bug, measured

I ran the real `command-score.ts` against a Frontile-like item list. Scores:

| query | `Button` | `ButtonGroup` | `Button Group` | `Toggle Button` |
| --- | --- | --- | --- | --- |
| `b` | 0.98990100 | **0.98990100** | 0.98990100 | 0.89091090 |
| `bu` | 0.98990100 | **0.98990100** | 0.98990100 | 0.89091090 |
| `but` | 0.98990100 | **0.98990100** | 0.98990100 | 0.89091090 |
| `butt` | 0.98990100 | **0.98990100** | 0.98990100 | 0.89091090 |
| `butto` | 0.98990100 | **0.98990100** | 0.98990100 | 0.89091090 |
| `button` | 0.99990000 | 0.98990100 | 0.98990100 | 0.89991000 |
| `Button` | 1.00000000 | 0.99000000 | 0.99000000 | 0.90000000 |

Diagnosis:

1. `PENALTY_NOT_COMPLETE` is applied **once**, as a flat `0.99`, the moment the query runs out
   before the target does. It does not scale with the number of leftover characters. So `Button`
   (2 leftover chars for `butt`) and `ButtonGroup` (7 leftover) score **bit-for-bit identically**.
2. With identical scores, cmdk's stable sort preserves registration/DOM order. If `ButtonGroup`
   is declared first (alphabetically it is: `button-group.md` before `button.md` in many
   sitemaps), it renders first and is auto-highlighted — the reported symptom.
3. Only at the exact full word does `Button` win, and only by `0.0100` (one
   `PENALTY_NOT_COMPLETE` step) — a hair-thin margin that any added weighting can flip.

**Fix, stated plainly: the ranking function must include a target-length term (or an explicit
"query covers the whole target" tier), not a flat completeness penalty.** See [§7](#7-recommended-scoring-function).

---

## 2. shadcn/ui Command

<https://ui.shadcn.com/docs/components/base/command>

Anatomy (a thin styled wrapper over cmdk, or over Base UI in the `base` variant):

```
Command
├── CommandInput
└── CommandList
    ├── CommandEmpty
    ├── CommandGroup (heading)
    │   └── CommandItem…
    ├── CommandSeparator
    └── CommandGroup
        └── CommandItem…
```

Plus `CommandShortcut` (right-aligned `⌘K`-style hint) and `CommandDialog` (Dialog + Command,
with a visually-hidden `DialogTitle`/`DialogDescription` for a11y).

The palette pattern is just a document-level keydown + a boolean:

```js
useEffect(() => {
  const down = (e) => {
    if (e.key === 'k' && (e.metaKey || e.ctrlKey)) { e.preventDefault(); setOpen(o => !o) }
  }
  document.addEventListener('keydown', down)
  return () => document.removeEventListener('keydown', down)
}, [])
```

Design takeaways: the dialog is `p-0 overflow-hidden`; the input row is a bordered flex row with a
leading search icon; group headings are `text-xs font-medium text-muted-foreground`; the active
item is styled purely off `data-[selected=true]`, never `:focus` (DOM focus stays on the input).

---

## 3. shadcn-ember (IgnaceMaes) — the Ember/Glimmer port

Sources read verbatim:
- `apps/v4/registry/new-york-v4/ui/command.gts` (549 lines) —
  <https://github.com/IgnaceMaes/shadcn-ember/blob/main/apps/v4/registry/new-york-v4/ui/command.gts>
- `apps/v4/app/components/command-menu.gts` —
  <https://github.com/IgnaceMaes/shadcn-ember/blob/main/apps/v4/app/components/command-menu.gts>

(Note: the path in the original brief, `apps/v4/app/components/ui/command.gts`, 404s; the real
file is under `apps/v4/registry/new-york-v4/ui/`.)

### 3.1 How they wired it in Glimmer

- **Context propagation** uses `ember-provide-consume-context`, with two string-keyed contexts:

  ```ts
  const CommandContext = 'command-context' as const;
  const CommandGroupContext = 'command-group-context' as const;
  ```

  `Command` `@provide(CommandContext)`s `{ search, setSearch, selectedValue, setSelectedValue,
  allGroups }`; `CommandGroup` `@provide`s `{ items }`; `CommandItem` / `CommandInput` /
  `CommandEmpty` / `CommandSeparator` `@consume` them.

- **Registration** is done with `ember-modifier` modifiers plus `registerDestructor`, pushing into
  `TrackedArray`s:

  ```ts
  registerWithGroup = modifier(() => {
    const item: CommandItemData = {
      value: this.args.value,
      keywords: this.args.keywords || [],
      isVisible: () => this.isVisible,
      isDisabled: () => this.args.disabled ?? false,
    };
    this.groupContext.items.push(item);
    registerDestructor(this, () => { /* splice out */ });
  });
  ```

  The registry stores **thunks** (`isVisible: () => this.isVisible`) rather than values, so
  consumers re-read through the item's own tracked getters. Clean trick; worth copying.

- **Filtering is naive `includes()`** — no ranking at all:

  ```ts
  get isVisible(): boolean {
    const search = this.context.search?.trim();
    if (!search) return true;
    const searchLower = search.toLowerCase();
    return this.args.value.toLowerCase().includes(searchLower)
      || (this.args.keywords ?? []).some(k => k.toLowerCase().includes(searchLower));
  }
  ```

  Consequence: **no sorting whatsoever.** Items stay in template order. This port has the
  "ButtonGroup above Button" problem in its most acute form — and in fact `command-menu.gts`
  passes `@value={{item.route}}` (e.g. `docs.components.button-group`), so users are matching
  against route slugs, not titles.

- **Keyboard nav is DOM-query-based**, not registry-based — `handleKeyDown` on the root does
  `querySelectorAll('[data-slot="command-item"]:not([hidden]):not([data-disabled="true"])')`,
  finds the index of `[data-selected="true"]`, clamps ±1 (no looping), sets `selectedValue` from
  `data-value`, and `scrollIntoView({ block: 'nearest', behavior: 'smooth' })`. `Enter` does
  `selectedItem?.click()`.

- **Initial/reset selection** goes through `requestAnimationFrame`:

  ```ts
  setSearch = (value: string) => {
    this.search = value;
    requestAnimationFrame(() => { this.selectedValue = this.firstVisibleItem; });
  };
  ```

  i.e. wait for the render that applies the new filter, *then* pick the first visible item.

- **Dialog composition**: `CommandDialog` renders `Dialog > DialogHeader.sr-only(Title,
  Description) > DialogContent > Command`, and re-styles the inner parts through a long list of
  arbitrary-variant selectors (`[&_[data-slot=command-item]]:px-2` …). `CommandInput` autofocuses
  itself via a modifier that first checks `element.closest('[data-slot="dialog-content"]')`.

- **`cmd+k` binding** comes from `ember-keyboard`: `{{onKey "cmd+k" this.toggleOpen}}` and
  `{{onKey "/" this.toggleOpen}}` at the top of the template.

### 3.2 Tradeoffs they made (and what Frontile should do differently)

| Their choice | Consequence | Frontile alternative |
| --- | --- | --- |
| Substring `includes()` filter | No ranking; ties everywhere; the exact bug we're fixing | Pluggable ranking fn, default = tiered scorer (§7) |
| `querySelectorAll` for nav | Couples nav to DOM/CSS; breaks with virtualization; smooth-scroll on keyheld is janky | Drive nav off the tracked item registry; `block: 'nearest'`, `behavior: 'auto'` |
| `role="combobox"` on the **root div**, `tabindex="0"` | Wrong per APG — combobox belongs on the input; `aria-expanded="true"` is hardcoded | See §6 |
| `id="command-list"` hardcoded | Two palettes on one page collide | `guidFor` / `{{unique-id}}` |
| Items unmounted via `{{#if this.isVisible}}` **and** `hidden={{…}}` | Redundant; loses `forceMount` semantics | One mechanism; add `@forceMount` |
| No `Command.Loading`, no async story | Can't do server-side search | Add `@shouldFilter={{false}}` + `<Command.Loading>` |
| String-literal context keys | Fine, but untyped across packages | Typed context key symbol/const exported from the package |

Their sibling registry does have a `Kbd` component, used for the `⌘K` affordance in the trigger
button — Frontile currently has no `Kbd`; worth considering as a companion.

---

## 4. HeroUI Pro Command

<https://heroui.pro/docs/react/components/command>

Deeper anatomy than cmdk — it models the *chrome* as components too:

```
Command
├── Command.Backdrop        (variant: opaque | blur | transparent, isDismissable)
├── Command.Container       (positioning wrapper)
└── Command.Dialog          (size: sm | md | lg)
    ├── Command.Header
    ├── Command.InputGroup  (prefix slot, input, clear button, suffix slot)
    ├── Command.List
    │   ├── Command.Group (heading)
    │   ├── Command.Item
    │   └── Command.Separator
    └── Command.Footer      (keyboard hints live here)
```

Feature surface: controlled/uncontrolled `inputValue` / `defaultInputValue`, custom `filter`
overriding the default case-insensitive match, `renderEmptyState` callback, nested groups.

Motion treatment: staged enter (backdrop + container fade + zoom, 150–200 ms) / faster exit
(~100 ms fade); items shift background on hover/focus/press; **animations disabled under
`prefers-reduced-motion`**. The explicit `Header` / `Footer` slots and the `InputGroup`
prefix/suffix slots are the two ideas most worth borrowing — every real palette (Linear, Vercel,
DocSearch) needs a footer for keyboard hints and a prefix for a "mode" chip.

---

## 5. UX conventions from DocSearch / Vercel / Linear

<https://algolia-docsearch.mintlify.app/guides/recent-searches>,
<https://www.mintlify.com/algolia/docsearch/guides/keyboard-shortcuts>

- **Binding:** `⌘K` / `Ctrl+K` toggles; `/` opens (but does not close) and is suppressed while
  focus is in an input/textarea/contenteditable; `Esc` always closes and is not disableable.
- **Zero-query state is not empty.** DocSearch shows *favorites* first, then *recent searches*
  (most recent first). Persisted in `localStorage` under `__DOCSEARCH_FAVORITE_SEARCHES__` /
  `__DOCSEARCH_RECENT_SEARCHES__`, suffixed with the index name to avoid collisions. Each row has
  a hover-revealed `×` to delete. Nothing leaves the browser.
- **Grouping** follows the docs hierarchy `lvl0…lvl6`: `lvl0` becomes the group heading (the
  section/nav category), `lvl1` the result title, deeper levels the breadcrumb line beneath.
- **Result rows** carry a leading type icon (page / heading / anchor / "content"), a two-line
  title + breadcrumb, and a trailing enter/arrow glyph on the active row.
- **Footer hints** are near-universal: `↵ to select · ↑↓ to navigate · esc to close`. Linear and
  Vercel additionally show a contextual hint that changes with the active item's type.
- **Loading:** show the list with a subtle top progress bar / skeleton rows rather than swapping
  to a spinner — swapping causes height thrash and destroys the highlighted row.
- **Empty:** "No results for `"…"`" echoing the query, plus an escape hatch (a "search all docs"
  or "ask AI" row). Never an unlabelled blank box.
- **Linear-style "pages"/modes:** `Backspace` on an empty input pops out of a sub-mode; typing
  `>` or `@` switches mode. Worth designing the API to *allow* this (a `@pages` stack or just
  consumer-controlled item sets) even if v1 doesn't ship it.

---

## 6. Accessibility — combobox with list autocomplete

Primary source: WAI-ARIA APG, *Combobox with List Autocomplete* —
<https://www.w3.org/WAI/ARIA/apg/patterns/combobox/examples/combobox-autocomplete-list/>

### Required markup

```html
<label for="cmd-input" class="sr-only">Search documentation</label>
<input
  id="cmd-input"
  role="combobox"
  type="text"
  autocomplete="off"
  aria-autocomplete="list"
  aria-expanded="true"          <!-- reflects popup visibility, not dialog visibility -->
  aria-controls="cmd-listbox"
  aria-activedescendant="cmd-opt-3"   <!-- omit entirely when nothing is active -->
/>

<ul id="cmd-listbox" role="listbox" aria-label="Search results">
  <li role="group" aria-labelledby="grp-1">        <!-- group wrapper -->
    <div id="grp-1" role="presentation">Components</div>
    <li id="cmd-opt-3" role="option" aria-selected="true">Button</li>
  </li>
</ul>

<div aria-live="polite" class="sr-only">12 results available.</div>
```

Rules that are easy to get wrong:

1. **DOM focus never leaves the input.** Options are "visually focused" only, via
   `aria-activedescendant`. Options must not have `tabindex`.
2. `role="combobox"` goes on the **input**, not a wrapper div (shadcn-ember gets this wrong).
3. `aria-expanded` must *track* popup state. Hardcoding `"true"` (shadcn-ember) is a lie to AT
   when the list is empty.
4. Exactly one option carries `aria-selected="true"` at a time; do **not** put `aria-selected` on
   every option. (`data-selected` for styling is separate and fine.)
5. `aria-activedescendant` must reference an id that currently exists and is visible. If you hide
   filtered-out items with `hidden`, the active id must not point at one.
6. Group headings need `role="presentation"` (or be referenced via `aria-labelledby` from a
   `role="group"`) — a bare `<div>` between `role="option"` children breaks the listbox's required
   child structure.
7. **`aria-live` for counts:** a `polite`, `sr-only` region announcing "N results available" /
   "No results found", debounced (~250–500 ms) so it doesn't fire per keystroke.
8. Inside a dialog, give the dialog an accessible name and description — shadcn/ui uses a
   visually-hidden `DialogTitle` + `DialogDescription`; do the same, and keep focus trapped.

### Keyboard interaction (APG table)

| Key | Behavior |
| --- | --- |
| `↓` | Move visual focus to next option (first, if none). DOM focus stays on the input. |
| `↑` | Move visual focus to previous option; from the first, wrap to the last. |
| `Alt+↓` | Open the listbox without moving visual focus. |
| `Enter` | Select the active option, close the popup. |
| `Esc` | Close the popup; if already closed, clear the input. (In a dialog: close the dialog.) |
| `Home` / `End` | Return focus to the input, caret to start/end. **Do not** hijack for first/last option. |
| Printable chars | Type into the input, refilter. |

Additional palette conventions beyond APG: `Tab` should close the palette (or move to the footer),
`PageUp`/`PageDown` jump ~10 rows, and pointer hover should set the active item *unless* the user
is mid-keyboard-navigation (cmdk's `disablePointerSelection`; the usual trick is to ignore
`mousemove` until the pointer actually moves after a key press).

---

## 7. Ranking: a recommendation

### 7.1 Why not Fuse.js

Fuse.js is a Bitap/approximate-string-match engine (<https://www.fusejs.io/>). Its model:

- Score is **0 = perfect, 1 = total mismatch** (inverted vs everything else).
- `threshold` (default `0.6`) is where matching gives up; `location` (default `0`) is where the
  pattern is *expected*; `distance` (default `100`) scales how much drift from `location` is
  tolerated. Effective window ≈ `threshold × distance` = 60 chars.
- `ignoreLocation` disables the positional term entirely.
- Multi-field search uses `keys` with per-key `weight`, combined as a weighted geometric mean.

Why it mis-ranks a component index:

1. **Bitap tolerates edits and errors; it does not reward completeness.** "How much of the target
   is left over" is not part of the score, so `Button` and `ButtonGroup` are again near-identical
   for `button` — Fuse's positional term is the only differentiator and it's tiny.
2. **The score is an error distance, so it saturates.** Once several candidates are all "0 errors
   near location 0", they're all `~0` and the ordering is arbitrary/insertion-order.
3. **`threshold` is a cliff, not a ranking.** Tuning it trades false negatives for a flood of
   garbage fuzzy matches; it never fixes the ordering of the good matches.
4. **Field weights multiply an already-flat score**, so a weak title match plus a strong body
   match can outrank an exact title match.

Fuse is the right tool for typo tolerance over prose. It is the wrong tool for a short-string
command index where *exactness* and *brevity* are the signal.

### 7.2 fzf / Sublime-style scoring

fzf (`src/algo/algo.go`, <https://github.com/junegunn/fzf/blob/master/src/algo/algo.go>) uses an
additive Smith-Waterman DP with these constants:

```go
scoreMatch               = 16
scoreGapStart            = -3
scoreGapExtension        = -1
bonusBoundary            = scoreMatch / 2          // 8
bonusNonWord             = scoreMatch / 2          // 8
bonusCamel123            = bonusBoundary + scoreGapExtension  // 7
bonusConsecutive         = -(scoreGapStart + scoreGapExtension) // 4
bonusFirstCharMultiplier = 2
bonusBoundaryWhite       = bonusBoundary + 2       // 10
bonusBoundaryDelimiter   = bonusBoundary + 1       // 9
```

Phases: ASCII prefilter to bound the search window → per-position character-class bonuses →
DP matrix over (pattern prefix × text position) trading match vs gap → backtrace for the matched
positions (useful for highlighting). Omission/mismatch of a pattern character is **not** allowed —
it's strictly a subsequence matcher, like cmdk.

Ideas worth taking: **additive** scoring (easier to reason about and to add tie-breakers to than
cmdk's multiplicative chain), **first-character bonus doubling**, the **camelCase boundary bonus**
(`bonusCamel123`), and the **backtrace giving you match indices for free** — you want those to
render `<mark>` highlights in the palette.

What fzf deliberately does *not* do, and we must: fzf's `--tiebreak=length` is an explicit,
separate tie-break stage. The lesson is that **length preference belongs in the ranking function
by default for a command palette**, not as an opt-in.

### 7.3 Recommended: a small tiered scorer

Design principle: **a coarse tier decides the order; continuous terms only break ties within a
tier.** This makes "exact beats prefix beats word-boundary beats substring beats subsequence"
structurally guaranteed rather than emergent from constant tuning — which is precisely what cmdk's
multiplicative chain fails to guarantee.

Ordered tiers:

| Tier | Base | Meaning |
| --- | --- | --- |
| Exact (case-sensitive) | 1000 | `Button` for query `Button` |
| Exact (case-insensitive) | 900 | `Button` for `button` |
| Prefix | 800 | `Button`/`ButtonGroup` for `butt` |
| Word-boundary substring | 700 | `Toggle Button` for `button`; `ButtonGroup` for `group` (camelCase counts) |
| Substring (mid-word) | 600 | `Checkbox` for `heck` |
| Acronym / initials | 400 | `Button Group` for `bg` |
| Subsequence (fuzzy) | 200 | `Button` for `btn` |
| No match | 0 | hide |

Within-tier terms (all small relative to the 100-point tier gap):

- `+60 × (query.length / target.length)` — **the length term. This is the fix.** For `butt`:
  `Button` gets `+40`, `ButtonGroup` gets `+21.8`.
- `+30 × contiguity` for the subsequence tier only (`1 / numberOfRuns`).
- `−20 × min(matchIndex, 20)/20` for substring tiers — earlier is better.
- `+0.5` if the case matches exactly (pure tie-break, mirrors cmdk's `PENALTY_CASE_MISMATCH`).

```ts
// packages/frontile/src/utils/command-score.ts  (sketch — not yet written to packages/)
const T_EXACT = 1000, T_IEXACT = 900, T_PREFIX = 800,
      T_WORD  = 700,  T_SUBSTR = 600, T_ACRONYM = 400, T_SUBSEQ = 200;

const BOUNDARY = /[\s\-_/.:]/;
const isBoundary = (s: string, i: number) =>
  i === 0 ||
  BOUNDARY.test(s[i - 1]!) ||
  (/[a-z0-9]/.test(s[i - 1]!) && /[A-Z]/.test(s[i]!)); // camelCase

function initials(s: string) {
  let out = '';
  for (let i = 0; i < s.length; i++) if (isBoundary(s, i)) out += s[i]!.toLowerCase();
  return out;
}

/** Greedy left-to-right subsequence; contiguity = 1 / number of contiguous runs. */
function subsequence(t: string, q: string) {
  let qi = 0, runs = 0, prev = -2, first = -1;
  for (let i = 0; i < t.length && qi < q.length; i++) {
    if (t[i] === q[qi]) {
      if (first < 0) first = i;
      if (i !== prev + 1) runs++;
      prev = i; qi++;
    }
  }
  return qi < q.length ? null : { contiguity: 1 / runs, first };
}

export function score(target: string, query: string): number {
  if (!query) return 1;
  if (!target) return 0;

  const tl = target.toLowerCase();
  const ql = query.toLowerCase();
  const lenRatio  = ql.length / tl.length;
  const caseBonus = target.startsWith(query) ? 0.5 : 0;

  let base = 0, pos = 0, quality = 0;

  if (target === query)        base = T_EXACT;
  else if (tl === ql)          base = T_IEXACT;
  else if (tl.startsWith(ql))  base = T_PREFIX;
  else {
    const idx = tl.indexOf(ql);
    if (idx >= 0) { base = isBoundary(target, idx) ? T_WORD : T_SUBSTR; pos = idx; }
    else if (ql.length > 1 && initials(target).includes(ql)) base = T_ACRONYM;
    else {
      const m = subsequence(tl, ql);
      if (!m) return 0;
      base = T_SUBSEQ; pos = m.first; quality = m.contiguity;
    }
  }

  const posPenalty = base <= T_SUBSTR ? Math.min(pos, 20) / 20 : 0;
  return base + 60 * lenRatio + 30 * quality - 20 * posPenalty + caseBonus;
}
```

Measured output on a Frontile-shaped list (this was actually run, not estimated):

```
b            Button(810.0) > ButtonGroup(805.5) > Button Group(805.0) > ToggleButton(705.0) > Close Button(705.0)
but          Button(830.0) > ButtonGroup(816.4) > Button Group(815.0) > ToggleButton(715.0) > Close Button(715.0)
butt         Button(840.0) > ButtonGroup(821.8) > Button Group(820.0) > ToggleButton(720.0) > Close Button(720.0)
button       Button(960.0) > ButtonGroup(832.7) > Button Group(830.0) > ToggleButton(730.0) > Close Button(730.0)
Button       Button(1060.5) > ButtonGroup(833.2) > Button Group(830.5) > ToggleButton(730.0) > Close Button(730.0)
buttongroup  ButtonGroup(960.0) > Button Group(270.0)
bg           ButtonGroup(410.9) > Button Group(410.0) > Checkbox Group(218.6)
group        ButtonGroup(727.3) > Button Group(725.0) > Checkbox Group(721.4)
```

`Button` wins at **every** prefix length, with a clear margin, and no ties. Compare the cmdk table
in §1.6.

Known rough edges of the sketch, to address in implementation:

- `buttongroup` vs `Button Group` scores only 270 (subsequence) because separators aren't
  normalized. Fix: also score against a separator-stripped form of the target and take the max.
- Whole-word-vs-prefix for multi-word queries: split the query on whitespace, score each token,
  require all tokens to match (AND), combine as `min(tokenScores) + mean(tokenScores)/10`.
- Cache `tl`, `initials(target)` and the normalized form per item — the index is static for a docs
  site, so precompute once.

### 7.4 Multi-field scoring

cmdk's alias-concatenation is the thing to *not* copy. Score each field independently and take a
weighted max, never a sum (a sum lets three weak fields beat one exact title match):

```ts
interface CommandRecord {
  title: string;            // "Button"
  section?: string;         // "Components / Buttons"
  keywords?: string[];      // ["cta", "action", "submit"]
  body?: string;            // first paragraph / heading text
}

const DEFAULT_WEIGHTS = { title: 1, keywords: 0.8, section: 0.6, body: 0.35 };

export function scoreRecord(rec: CommandRecord, query: string, weights = DEFAULT_WEIGHTS) {
  let best = 0;
  for (const [field, w] of Object.entries(weights)) {
    const v = rec[field as keyof CommandRecord];
    if (!v) continue;
    for (const s of Array.isArray(v) ? v : [v]) best = Math.max(best, score(s, query) * w);
  }
  return best;
}
```

Weight rationale: an exact **body** hit (`1000 × 0.35 = 350`) must never outrank a **title**
prefix hit (`~840`). Multiplying the tiered score by a weight < 1 preserves that ordering by
construction, as long as `min(weight) × T_EXACT < T_SUBSEQ`-adjacent titles is what you want —
check the arithmetic when tuning. Optionally add a small, separate **recency/frecency** bonus for
recently-selected items (`+50` for top-5 recents), applied *after* scoring and only when a query
is present.

---

## 8. Recommendations for Frontile

### 8.1 API shape

Follow cmdk's anatomy (it's what everyone knows), with HeroUI's chrome slots, expressed in
Frontile's yielded-component idiom:

```gts
<Command
  @value={{this.activeValue}}          {{! active/highlighted item }}
  @onValueChange={{this.setActive}}
  @search={{this.query}}               {{! typed text }}
  @onSearchChange={{this.setQuery}}
  @shouldFilter={{true}}               {{! false => you own filtering+ordering }}
  @filter={{this.customScore}}         {{! (value, search, keywords) => number }}
  @loop={{true}}
  @label="Search documentation"
  as |c|
>
  <c.Input @placeholder="Search…" />
  <c.List>
    <c.Loading @progress={{this.progress}} />
    <c.Empty>No results for "{{this.query}}"</c.Empty>
    <c.Group @heading="Components">
      <c.Item @value="button" @keywords={{array "cta" "action"}} @onSelect={{this.go}}>
        Button
        <c.Shortcut>⌘B</c.Shortcut>
      </c.Item>
    </c.Group>
    <c.Separator />
  </c.List>
  <c.Footer />
</Command>

<Command::Dialog @isOpen={{this.isOpen}} @onClose={{this.close}} @shortcut="mod+k" as |c|>
  …same inner blocks…
</Command::Dialog>
```

- Widen `@filter` beyond cmdk's `(value, search, keywords)` to accept the item's full record so
  multi-field weighting is expressible without stuffing everything into `value`.
- Ship the §7.3 scorer as the default *and* export it (`import { commandScore } from
  'frontile/utils'`) so consumers can reuse or compose it.
- Add `@disablePointerSelection` and `@vimBindings` (cheap, and keyboard-first users expect them).
- Expose match indices from the scorer so `<c.Item>` can yield highlight ranges for `<mark>`.

### 8.2 Implementation notes for Glimmer

- Reuse Frontile's existing **`ListManager`** (already powering `Listbox` / `Select`) for
  registration, active-item tracking and keyboard nav rather than reinventing shadcn-ember's
  `querySelectorAll` approach. It already handles `aria-activedescendant`-style semantics. *Check
  the known `isActive` flake first* — Glimmer DOM writes can fire `focusout` synchronously
  mid-render.
- Reuse `@frontile/overlays` `Modal`/`Overlay` for `Command::Dialog`; do not hand-roll a dialog.
- Sorting: prefer **rendering a sorted array** (`{{#each this.rankedItems}}`) over cmdk's
  DOM-reordering-via-`appendChild`. Glimmer's keyed `{{#each}}` does this natively and correctly;
  cmdk only reorders the DOM because React can't reorder children it doesn't own. This is a
  genuine advantage of the Glimmer port — take it. It does mean the "declarative
  `<Command.Item>` children" API needs a two-pass render (register → rank → render) or an
  `@items`-array-driven variant. **Recommend shipping both**: an `@items` array form (sortable,
  virtualizable, the docs-site path) plus a declarative form (composable, unsorted-or-stably-
  sorted, the "menu of fixed actions" path).
- `⌘K` binding: don't depend on `ember-keyboard`; a small `{{on-global-key "mod+k"}}` modifier or a
  service in `@frontile/utilities` keeps the dep surface flat. Suppress `/` while focus is in a
  text field.
- Ids: `guidFor(this)` for the listbox/option ids so multiple palettes can coexist.

### 8.3 Accessibility checklist (from §6)

- `role="combobox"` + `aria-autocomplete="list"` + `aria-expanded` + `aria-controls` on the
  **input**; `role="listbox"` on the list; `role="option"` + `aria-selected` on items.
- `aria-activedescendant` on the input, pointing at a *rendered, visible* option id; removed when
  nothing is active.
- One `aria-selected="true"` at a time. `data-active` for styling.
- Debounced `aria-live="polite"` sr-only region: "N results available" / "No results found".
- Group heading with `role="presentation"`, wrapper `role="group" aria-labelledby`.
- `Esc` closes; `Home`/`End` stay in the input; focus never leaves the input.
- Honor `prefers-reduced-motion` for the dialog enter/exit (HeroUI does; make it default).

### 8.4 Docs-site payoff

Frontile's own docs site is the obvious first consumer, and it exercises everything: `lvl0`-style
grouping from the Docfy nav, multi-field records (component title / category / `.md` headings /
keywords), a zero-query recents list in `localStorage`, and the `Button` vs `ButtonGroup` ranking
case as a regression test. Suggest building the scorer + a unit test table (`butt` → `Button`
first) *before* the component.

---

## Sources

- cmdk repo — <https://github.com/pacocoursey/cmdk>
- cmdk `command-score.ts` — <https://github.com/pacocoursey/cmdk/blob/main/cmdk/src/command-score.ts>
- cmdk `index.tsx` — <https://github.com/pacocoursey/cmdk/blob/main/cmdk/src/index.tsx>
- shadcn/ui Command — <https://ui.shadcn.com/docs/components/base/command>
- shadcn-ember `ui/command.gts` — <https://github.com/IgnaceMaes/shadcn-ember/blob/main/apps/v4/registry/new-york-v4/ui/command.gts>
- shadcn-ember `command-menu.gts` — <https://github.com/IgnaceMaes/shadcn-ember/blob/main/apps/v4/app/components/command-menu.gts>
- HeroUI Pro Command — <https://heroui.pro/docs/react/components/command>
- fzf `algo.go` — <https://github.com/junegunn/fzf/blob/master/src/algo/algo.go>
- Fuse.js — <https://www.fusejs.io/> and <https://www.fusejs.io/fuzzy-search.html>
- WAI-ARIA APG, Combobox with List Autocomplete — <https://www.w3.org/WAI/ARIA/apg/patterns/combobox/examples/combobox-autocomplete-list/>
- DocSearch recent searches — <https://algolia-docsearch.mintlify.app/guides/recent-searches>
- DocSearch keyboard shortcuts — <https://www.mintlify.com/algolia/docsearch/guides/keyboard-shortcuts>
- Algolia Autocomplete recent-searches plugin — <https://www.algolia.com/doc/ui-libraries/autocomplete/api-reference/autocomplete-plugin-recent-searches/createLocalStorageRecentSearchesPlugin>
