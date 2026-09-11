---
title: DOM Anatomy Attributes Migration
order: 8
category: migrations
subcategory: v0.18
---

# DOM Anatomy Attributes Migration Guide

v0.18 gives every Frontile component a stable, documented DOM anatomy: two
attributes, `data-component` and `data-part`, replace three older and
inconsistent conventions — ad hoc `data-component` values that didn't match
any real hierarchy, one-off `data-fr-*` attributes (mostly on `Calendar` and
`Accordion`), and most of the `data-test-id` attributes that existed purely
as selectors.

**See also:** [Customizing Component Styles](../../theming/component-styles.md)
for the full contract — what the two attributes mean, how scoping works, and
its known limitation with nested components.

## Impact

**Required only if you select Frontile-rendered elements** — in your own
CSS, in `querySelector`/`closest` calls, or in tests — using any of the
retired attributes below. If you only pass `@classes`/`@class` or use
components through their public API, nothing changes for you.

## `data-component` renames

Several elements carried a `data-component` value that named something other
than the actual `tv()` config, or that belonged on an element that isn't a
real anatomy root. Each now carries the correct `data-component` (the
kebab-cased `tv()` config name, on the component's outermost element) plus a
`data-part` for the slot it renders, if any.

| Component | Old | New |
| --- | --- | --- |
| Alert | `data-component="alert"` (unchanged) + `data-test-id="alert"` | `data-component="alert"` `data-part="base"` |
| Autocomplete trigger `<input>` | `data-component="autocomplete-trigger"` + `data-test-id="trigger"` | `data-part="input"` (Autocomplete's own `input` slot; the trigger is not a separate component) |
| Checkbox `<input>` | `data-component="checkbox"` (on the `<input>`) | `data-component="checkbox"` moves to Checkbox's root; the `<input>` becomes `data-part="input"` |
| Command | `data-test-id="command"` alongside `data-component="command"` | `data-component="command"` `data-part="base"` |
| Command Dialog | `data-test-id="command-dialog"` | `data-component="command-dialog"` `data-part="base"` |
| Command Dialog panel | `data-test-id="command-dialog-panel"` | `data-part="panel"` |
| Command Footer | `data-component="command-footer"` + `data-test-id="command-footer"` | `data-part="footer"` (a part of `command`, not its own component) |
| Command Input | `data-component="command-input"` + `data-test-id="command-input"` | `data-part="input"` |
| FormControl live region | `data-component="form-feedback-live-region"` | `data-test-id="form-feedback-live-region"` (demoted — see [Kept as `data-test-id`](#kept-as-data-test-id) below) |
| Input `<input>` | `data-component="input"` (on the `<input>`) | `data-component="input"` moves to Input's root (the `FormControl` wrapper); the `<input>` becomes `data-part="input"` |
| InputOtp container | `data-component="input-otp"` (on the container `<div>`) | `data-component="input-otp"` moves to the root; the container becomes `data-part="container"` |
| InputOtp `<input>` | `data-component="input-otp-input"` | `data-part="input"` |
| NativeSelect `<select>` | `data-component="native-select"` | `data-component="native-select"` moves to NativeSelect's root (the `FormControl` wrapper); the `<select>` becomes `data-part="input"` (it keeps `data-test-id="native-select"` too — see [Kept](#kept-as-data-test-id)) |
| Radio `<input>` | `data-component="radio"` (on the `<input>`) | `data-component="radio"` moves to Radio's root; the `<input>` becomes `data-part="input"` |
| Select trigger | `data-component="select-trigger"` + `data-test-id="trigger"` | `data-part="input"` (Select's own `input` slot, not a separate component) |
| Switch | `data-component="switch"` | `data-component="switch-input"` (renamed to match the `switchInput` `tv()` config) `data-part="base"` |
| Table wrapper | `data-component="table-wrapper"` | `data-component="table"` `data-part="wrapper"` |
| Table toolbar | `data-component="table-toolbar"` (plain class, no `tv()` styling) | `data-part="toolbar"` (now themed via a real `toolbar` slot — see [Table's `toolbar` slot](#tables-toolbar-slot)) |
| Table `<table>` (composed via `SimpleTable`) | `data-component="table"` unconditionally | `data-component="table"` only when `SimpleTable` is the anatomy root (`@isRoot` true, the default); `Table` passes `@isRoot={{false}}` since its own wrapper is the real root — see [Customizing Component Styles](../../theming/component-styles.md#known-limitation-a-nested-component-can-share-a-part-name) |
| Textarea `<textarea>` | `data-component="textarea"` (on the `<textarea>`) | `data-component="textarea"` moves to Textarea's root; the `<textarea>` becomes `data-part="input"` |
| SimpleTable body/cell/column/footer/header/row | `data-component="table-body"`, `"table-cell"`, `"table-column"`, `"table-footer"`, `"table-header"`, `"table-row"` | No `data-component` — these are parts of `table`: `data-part="tbody"`, `"td"`, `"th"`, `"tfoot"`, `"thead"`, `"tr"` respectively |

## `data-fr-*` retirement

Every `data-fr-*` attribute on `Calendar` and `Accordion` is gone, replaced
by `data-component`/`data-part`. `data-fr-si-ready` is the one exception —
it is **not** an anatomy attribute; it's a lifecycle marker written by the
[selection-indicator](https://frontile.dev/docs/components/utilities/selection-indicator)
utility (used by `SegmentedControl`, `TabNav`, `Tabs`) to signal that the
indicator has measured and is ready to transition, and it was deliberately
kept as-is.

| Old | New |
| --- | --- |
| `data-fr-accordion` | `data-component="accordion"` `data-part="base"` |
| `data-fr-accordion-trigger` | `data-part="trigger"` |
| `data-fr-calendar` | `data-component="calendar"` `data-part="base"` |
| `data-fr-calendar-band` | `data-part="cell-band"` |
| `data-fr-calendar-cell` | `data-part="cell"` |
| `data-fr-calendar-day` | `data-part="day"` |
| `data-fr-calendar-day-content` | `data-part="day-content"` |
| `data-fr-calendar-footer` | `data-part="footer"` |
| `data-fr-calendar-grid` | `data-part="month-grid"` |
| `data-fr-calendar-header` | `data-part="header"` |
| `data-fr-calendar-indicator` | `data-part="indicator"` |
| `data-fr-calendar-month-select` | `data-part="month-select"` |
| `data-fr-calendar-month-value` | `data-part="month-select-value"` |
| `data-fr-calendar-next` | `data-part="nav-button"` (Calendar no longer distinguishes prev/next by attribute; both nav buttons carry the same part) |
| `data-fr-calendar-prev` | `data-part="nav-button"` |
| `data-fr-calendar-title` | `data-part="title"` |
| `data-fr-calendar-week` | `data-part="week"` |
| `data-fr-calendar-weekday` | `data-part="weekday"` |
| `data-fr-calendar-weekdays` | `data-part="weekdays-row"` |
| `data-fr-calendar-year` | `data-part="year-cell"` |
| `data-fr-calendar-year-grid` | `data-part="year-grid"` |
| `data-fr-calendar-year-trigger` | `data-part="year-trigger"` |
| `data-fr-si-ready` | **Kept, unchanged** — not an anatomy attribute |

## Removed `data-test-id`s and their replacements

Most `data-test-id` attributes that existed only to name a piece of a
component's anatomy are gone; select by `data-part` (scoped under the
component's `data-component`) instead. A handful of valued `data-test-*`
attributes that carry real state (not just an anatomy label) were
deliberately left alone — e.g. `data-test-intent` on `Alert`.

| Old `data-test-id` | New |
| --- | --- |
| `alert` | `data-component="alert"` |
| `alert-actions` | `data-part="actions"` |
| `alert-close-button` | `data-part="close-button"` |
| `alert-content` | `data-part="content"` |
| `alert-description` | `data-part="description"` |
| `alert-icon` | `data-part="icon"` |
| `alert-title` | `data-part="title"` |
| `command` | `data-component="command"` |
| `command-dialog` | `data-component="command-dialog"` |
| `command-dialog-panel` | `data-part="panel"` |
| `command-empty` | `data-part="empty"` |
| `command-footer` | `data-part="footer"` |
| `command-hint` | `data-part="footer-hint"` |
| `command-input` | `data-part="input"` |
| `command-input-wrapper` | `data-part="input-wrapper"` |
| `command-kbd` | `data-part="kbd"` |
| `command-list` | `data-part="list"` |
| `command-loading` | `data-part="loading"` |
| `command-prompt` | `data-part="empty"` |
| `divider` | `data-component="divider"` |
| `external-link` | `data-component="external-link"` |
| `external-link-icon` | `data-part="icon"` |
| `input-clear-button` | `data-part="clear-button"` |
| `input-end-content` | `data-part="end-content"` |
| `input-otp-caret` | `data-part="caret"` |
| `input-otp-cell` | `data-part="cell"` |
| `input-otp-separator` | `data-part="separator"` |
| `input-start-content` | `data-part="start-content"` |
| `kbd` | `data-component="kbd"` |
| `kbd-key` | `data-part="key"` |
| `kbd-separator` | `data-part="separator"` |
| `listbox` | `data-component="listbox"` |
| `listbox-group` | `data-component="listbox-group"` |
| `listbox-group-title` | `data-part="title"` |
| `listbox-item` | `data-component="listbox-item"` |
| `listbox-item-description` | `data-part="description"` |
| `listbox-item-label` | `data-part="label"` |
| `listbox-item-selected-icon` | `data-part="selected-icon"` |
| `listbox-item-submenu-indicator` | `data-part="submenu-indicator"` |
| `loading-spinner` | `data-component="spinner"` (Spinner already carries its own root `data-component`; the wrapping `data-test-id` was redundant) |
| `option` | *(removed, no replacement — `NativeSelectItem`'s `<option>` has no styled part of its own)* |
| `search-message` | `data-part="empty-content"` |
| `selected-chip` | `data-part="chip"` |
| `selected-chips` | `data-part="chips-container"` |
| `switch-end-content` | `data-part="end-content"` |
| `switch-start-content` | `data-part="start-content"` |
| `switch-thumb-content` | `data-part="thumb"` |
| `table` | `data-component="table"` (on the `<table>` when it is the anatomy root) |
| `table-body` | `data-part="tbody"` |
| `table-cell` | `data-part="td"` |
| `table-column` | `data-part="th"` |
| `table-empty-cell` | `data-part="empty"` |
| `table-footer` | `data-part="tfoot"` |
| `table-header` | `data-part="thead"` |
| `table-row` | `data-part="tr"` |
| `table-skeleton-row` | `data-part="skeleton-row"` |
| `trigger` | `data-part="input"` (on both `Autocomplete` and `Select` triggers) |

### Kept as `data-test-id`

Two attributes moved in the *opposite* direction — from `data-component` to
`data-test-id` — because they don't name a real anatomy root:

- **`FormControl`'s live region**: was `data-component="form-feedback-live-region"`,
  is now `data-test-id="form-feedback-live-region"`. The live region is an
  implementation detail of `FormControl`'s error announcing, not a themed
  slot or a component of its own.
- **`NativeSelect`'s `<select>`**: keeps `data-test-id="native-select"` (it
  already had this) as its stable selector, since `data-component="native-select"`
  now lives on the outer `FormControl` root, one level up — the `<select>`
  itself is `data-part="input"`. `frontile/test-support`'s `changeOption`
  helper was updated to select by `data-test-id="native-select"` rather than
  the old `data-component="native-select"`.

## Table's `@classes.base` key removed

`Table`'s `tv()` config (`packages/theme/src/components/table.ts`) no longer
has a `base` slot. It was dead: no element ever called `.base()` or rendered
a `base` part, so a `@classes={{hash base='...'}}` override was silently
doing nothing. If your app passed `@classes.base` to `Table`, remove it —
there is no behavior to preserve, and no other slot inherits its styles.

## Table's `toolbar` slot

The `<:toolbar>` block's wrapping `<div>` used to carry a hardcoded class
string (`class="table-toolbar px-4 pt-3"`) and `data-component="table-toolbar"`,
outside the `tv()` system entirely. It is now a real `toolbar` slot —
themeable via `@classes={{hash toolbar='...'}}` the same way `wrapper` and
`table` are — and the element carries `data-part="toolbar"` instead of its
own `data-component`.

## Checklist

- [ ] Replaced any selector on a retired `data-fr-*` attribute with the
      matching `[data-part="..."]` (see table above)
- [ ] Replaced any selector on a retired `data-test-id` with the matching
      `[data-component="..."]` / `[data-part="..."]` pair
- [ ] Replaced `data-component="table-wrapper"`, `"table-body"`,
      `"table-cell"`, `"table-column"`, `"table-footer"`, `"table-header"`,
      `"table-row"` and `"table-toolbar"` selectors — none of these
      `data-component` values exist anymore; they're all parts of `table`
      now
- [ ] Removed any `@classes.base` passed to `Table` — it was already a no-op
- [ ] If selecting `Switch`'s root by `data-component`, updated
      `"switch"` → `"switch-input"`
- [ ] Read [Customizing Component Styles](../../theming/component-styles.md)
      for the full `data-component`/`data-part` contract, including its
      "nearest ancestor" scoping limitation
