# Autocomplete Component Design

Date: 2026-07-10
Status: Approved for implementation

## Goal

Add an `Autocomplete` component to Frontile: a text input combined with a listbox popover
that lets users filter options by typing (type-ahead), including options loaded
asynchronously from an API. It complements `Select` (click-to-open, fixed options) with an
input-first interaction following the WAI-ARIA 1.2 combobox pattern.

## Prior art surveyed

- **HeroUI Autocomplete** — `inputValue`/`onInputChange`, `defaultFilter`, `isLoading`,
  `allowsCustomValue`, `isClearable`, `menuTrigger`.
- **React Aria ComboBox** — controlled `inputValue` + `items`; when items are controlled the
  component does no filtering (async pattern); `allowsCustomValue`; `loadingState`.
- **ember-power-select** — `@search` action returning a promise; the component owns
  loading state and race handling. The Ember ecosystem standard for async search.
- **Headless UI Combobox / MUI Autocomplete** — similar shapes; MUI adds `freeSolo`,
  `filterOptions`.

## Approaches considered

1. **Extend `Select` with more args** (e.g. `@isCombobox`). Rejected: `Select`'s trigger is a
   button-or-input hybrid already stretched by `@isFilterable`; combobox semantics
   (input-first, aria-activedescendant, custom values) would bloat it further.
2. **New `Autocomplete` component reusing `Popover` + `Listbox` + `FormControl` +
   `NativeSelect`** (same primitives as `Select`). **Chosen** — mirrors Select's proven
   architecture and API naming, keeps each component focused.
3. Headless-only combobox primitive + styled wrapper. Rejected for now: no other Frontile
   component follows that split; YAGNI.

## API

```gts
<Autocomplete
  @items={{this.items}}
  @selectedKey={{this.key}}
  @onSelectionChange={{this.setKey}}
  @placeholder="Search…"
/>
```

### Args

Mirrors `Select` (discriminated union for single/multiple selection):

- `@items`, `@selectionMode` (`'single'` default | `'multiple'`), `@selectedKey` /
  `@selectedKeys`, `@onSelectionChange`, `@disabledKeys`, `@allowEmpty`, `@onAction`
- FormControl shared args (`@label`, `@description`, `@errors`, `@isInvalid`, `@isRequired`)
- Popover pass-through args (`@placement`, `@renderInPlace`, etc.), `@popoverSize`
- `@inputSize`, `@classes`, `@placeholder`, `@isDisabled`, `@name`, `@isClearable`,
  `@isLoading`, `@hideEmptyContent`, `@onBlur`, `@startContentPointerEvents`,
  `@endContentPointerEvents`

New, autocomplete-specific:

- `@inputValue?: string` + `@onInputChange?: (value: string) => void` — optionally
  controlled input text.
- `@filter?: (itemValue: string, inputValue: string) => boolean` — overrides the default
  case-insensitive "contains" filter.
- `@disableFiltering?: boolean` — render `@items` as-is (parent filters, e.g. server-side).
- `@onSearch?: (query: string) => Promise<T[]> | T[]` — async convenience (ember-power-select
  style). When provided, the component calls it (debounced) as the user types, shows the
  loading spinner while pending, ignores stale responses (latest wins), and renders the
  resolved items. Internal filtering is disabled. `@items` acts as the initial/default list.
- `@searchDebounce?: number` — debounce for `@onSearch`, default 250ms.
- `@allowsCustomValue?: boolean` — keep free text on blur/close instead of reverting to the
  selected item's label.

### Blocks

Same as Select: `:item`, `:default` (declarative `<l.Item>`), `:startContent`,
`:endContent`, `:emptyContent`. Empty content also covers "no results" during async search
(default text "No results found.").

### Anatomy & behavior

- Visible `<input role="combobox" aria-autocomplete="list">` is both the popover trigger and
  anchor. `aria-expanded`/`aria-controls` come from Popover's trigger modifier;
  `aria-activedescendant` is kept in sync via Listbox's `@onActiveItemChange` (the component
  assigns an id to the active option's element by `data-key` lookup).
- Hidden `NativeSelect` (VisuallyHidden) for form submission via `@name`, as in Select.
- Typing opens the menu, filters items, auto-activates the first result; ArrowUp/Down
  navigate (Listbox keyboard events bound to the input); Enter selects the active item;
  Escape closes.
- Single mode: selecting fills the input with the item's label and closes the popover.
- Multiple mode: popover stays open; input text is kept so users can keep refining.
- On close/blur without a selection the input reverts to the selected label (or empty),
  unless `@allowsCustomValue`.
- Clear button (`@isClearable`) clears selection + input text.
- End content shows spinner when loading, clear button when clearable+selected, otherwise a
  search/chevron icon.

## Theme

`autocomplete = tv({ extend: select })` in `packages/theme/src/components/forms/forms.ts`,
plus `AutocompleteVariants`/`AutocompleteSlots` types. Consumed via `useStyles()`.

## Files

1. `packages/theme/src/components/forms/forms.ts` — styles + types
2. `packages/frontile/src/components/forms/autocomplete.gts` — component
3. `packages/frontile/src/components/forms/index.ts`, `packages/frontile/src/template-registry.ts` — exports
4. `packages/frontile/src/components/forms/autocomplete.md` — docs with live demos
5. `test-app/tests/integration/components/forms/autocomplete-test.gts` — tests

## Testing

Integration tests: rendering items, typing filters, keyboard navigation + Enter selection,
single and multiple selection flows, input revert on close, `@allowsCustomValue`,
`@disableFiltering`, `@onSearch` async flow (resolves items, loading spinner, stale-response
race), clear button, disabled state, ARIA attributes (role, aria-autocomplete,
aria-expanded, aria-activedescendant), hidden native select form integration.
