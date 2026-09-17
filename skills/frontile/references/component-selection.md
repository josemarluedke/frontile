# Frontile Component Selection

Judgment calls between components that look similar but aren't interchangeable. Verified
against each component's source and co-located `.md` under `packages/frontile/src/components/`.
For arguments, read the component's own `.md` or `.d.ts`.

## Modal vs Drawer vs Popover

All three are built on the shared `Overlay` primitive (`overlays/overlay.gts`) and inherit its
accessibility behavior (focus trap, escape-to-close, outside-click). What differs is placement
and weight:

- **Modal** — centered dialog over the page. "The Modal component is a centered dialog that
  appears over the main content" (`overlays/modal.md`). Reach for it for a focused task that
  blocks the rest of the page: confirmation, a form that must be completed or cancelled.
- **Drawer** — slide-out panel from an edge, with drag-to-dismiss support
  (`modifiers/drag-to-dismiss` wired in via `overlays/drawer.gts`). "A slide-out panel that
  appears from any edge of the screen" (`overlays/drawer.md`). Reach for it for supplementary
  content that keeps spatial context with the trigger: filters, details panel, mobile nav.
- **Popover** — small overlay anchored to a trigger element, can open on click, hover, or focus
  (`overlays/popover.md`). Reach for it for a small amount of content tied to one control, such
  as a menu, a tooltip-like explanation, or a compact form, rather than a full task flow.

Wrong choice here is mostly a UX weight mismatch, not an accessibility break, since all three
inherit Overlay's a11y behavior.

## Select vs NativeSelect vs Autocomplete

All three exist and are distinct components, verified in `packages/frontile/src/components/forms/`:

- **NativeSelect** (`native-select.gts`) wraps the browser's own `<select>`. "Reach for it when
  you want the platform's picker — the native dropdown on mobile, the OS list box on desktop —
  instead of the custom listbox that Select renders" (`native-select.md`). Best default for a
  plain, short, single-choice list, especially on mobile where the OS picker is the more
  familiar and performant interaction.
- **Select** (`select.gts`, built on `Listbox` + `Popover`) is a custom dropdown listbox
  supporting single or multiple selection (multiple selections render as removable chips) and
  built-in filtering, with a hidden native `<select>` kept in sync for form submission
  (`select.md`). Reach for it when you need multi-select, custom option rendering, or filtering
  inside a still-relatively-short list.
- **Autocomplete** (`autocomplete.gts`, also built on `Listbox` + `Popover`) combines a text
  input with a listbox popover, following the WAI-ARIA combobox pattern; single-selection only.
  Per its own doc: "Use Autocomplete when the list is long enough that typing beats scrolling...
  Use Select when scanning a short list is faster than typing, or when you need multiple
  selection" (`autocomplete.md`).

Rule of thumb: native picker by default → `Select` once you need multi-select or in-list
filtering with a short list → `Autocomplete` once the list is long enough that typing is faster
than scrolling.

## Table vs SimpleTable

Both exist (`collections/table.md`, `collections/simple-table.md`). Real tradeoff is
data-driven-rendering vs manual composition:

- **Table** renders automatically from `@columns` + `@items`: sorting, column visibility, sticky
  headers, row selection, scrollable containers, loading/empty states.
- **SimpleTable** renders only the HTML table structure (`<table>`/`<thead>`/`<tbody>`/`<tfoot>`)
  with Frontile's styling, block-form yielded for full manual control, with no data management.
  Its own doc says explicitly: "For automatic rendering with sticky elements and data management,
  use Table instead" (`simple-table.md`).

Reach for `Table` whenever you have a `@columns`/`@items` shape and want sorting/selection/sticky
behavior for free. Reach for `SimpleTable` when the layout is bespoke enough (irregular rows,
custom grouping) that automatic column-driven rendering would fight you.

## Alert vs toast notification (NotificationCard / NotificationsContainer)

Verified in `status/alert.md`: "Displays an important message inline in the page. Reach for
Alert, rather than the notifications service, when the message is part of the page and should
stay there until the page or the consumer removes it — a notification is transient and
dismisses itself."

- **Alert** — inline, persistent until explicitly removed. Use for page-level state: form
  validation summary, a persistent warning banner tied to page content.
  Import: `import { Alert } from 'frontile';`.
- **NotificationCard / NotificationsContainer** — driven by the injected `NotificationsService`
  (`packages/frontile/src/services/notifications.ts`), rendered as a stack of transient,
  self-dismissing toasts (`notifications/notification-card.gts`,
  `notifications/notifications-container.gts`). Use for ephemeral feedback about an action that
  just happened (saved, failed, item removed) that should not persist in the page's content flow.

Choosing Alert for a transient toast (or vice versa) is a UX/persistence mismatch more than an
accessibility one, but a toast used for content the user needs to re-find later (e.g. a
validation error) is a real usability regression since it disappears on its own.

## Button vs ToggleButton vs SegmentedControl vs Chip

Overlapping visuals, different semantics, verified per component `.md`:

- **Button** (`buttons/button.md`) — triggers a one-shot action (submit, open a modal, navigate).
  No persistent on/off state.
- **ToggleButton** (`buttons/toggle-button.md`) — "allows to toggle a selection on or off...
  switching between two states or modes." Carries boolean pressed/selected state itself
  (renders with `aria-pressed` semantics as a toggle, not a momentary action). Use for a single
  binary option (e.g. bold on/off in a toolbar), not for an action that fires once.
- **SegmentedControl** (`buttons/segmented-control.md`) — "A row (or column) of mutually
  exclusive options with a single indicator that slides between them. Use it in place of a small
  RadioGroup or a set of ToggleButtons whenever the choice is small, fixed, and always visible."
  This is single-select among 3+ fixed options, functionally a styled radiogroup (confirmed in
  `buttons/segmented-control/item.gts`: renders `role="radio"`/native radio inputs and uses
  `rovingFocus`). Using a row of independent `ToggleButton`s instead of `SegmentedControl` for
  mutually-exclusive choices is a real accessibility bug: `ToggleButton`s are independent toggles
  with no roving-tabindex/radiogroup semantics, so screen-reader users won't hear "1 of 3
  selected" and arrow-key navigation between options won't work.
- **Chip** (`buttons/chip.md`) — "compact elements that represent an input, attribute, or
  action — a filter that has been applied, a tag on a record, a value selected in a multi-select
  field." Not an interactive control for choosing between options; it's a compact display/removal
  unit (e.g. what `Select`'s multi-select mode renders per selected value).

Rule: one-shot action → `Button`. Single independent on/off → `ToggleButton`. Mutually-exclusive
choice among a small fixed set → `SegmentedControl` (never a row of `ToggleButton`s: that drops
required radiogroup semantics). Representing an applied value/tag → `Chip`.

## Listbox vs Dropdown

Both exist in `collections/`. `listbox.md`: "A listbox presents a list of options allowing users
to select one or multiple items. It serves as the foundation for other components like Select
and Dropdown menus." `dropdown.md`: "A menu activated by a button, representing a set of actions
or displaying a list of options for user selection. Built on top of Popover and Listbox
components."

- **Listbox** is the lower-level primitive: an always-visible (or you-position-it) list with
  selection and keyboard nav. `Select`, `Autocomplete`, and `Dropdown` are all built on it.
- **Dropdown** = `Listbox` + `Popover` + a trigger button, pre-wired as a menu that opens/closes.

Reach for `Dropdown` directly for a standard "click button, get a menu" interaction. Reach for
`Listbox` directly only when composing your own overlay/trigger behavior that none of `Select`,
`Autocomplete`, or `Dropdown` already covers. It is the escape hatch, not the default.

## Modifiers/utilities invoked in templates, not rendered as components

These are plain functions/classes from `packages/frontile/src/utils/` and
`packages/frontile/src/modifiers/`, imported from `frontile` like anything else, but they are
**not components**. Never write `<Press />`, `<Ref />`, etc. Verified invocation form for each:

| Utility              | What it is                                                                                             | Verified invocation                                                                                                                                                                                                                                                                                                                                                                                  |
| -------------------- | ------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `press`              | A modifier (not a class) for cross-platform press interactions                                         | `<button {{press onPressStart=this.a onPressEnd=this.b onPress=this.c}}>...</button>` — used directly as an element modifier, supports named args (`press.md`).                                                                                                                                                                                                                                      |
| `ref`                | Factory returning a `Ref` instance with a `.setup` modifier and a `.current` tracked property          | `myRef = ref<HTMLDivElement>();` in the class, then `<div {{this.myRef.setup}}>` in the template; read the element back via `this.myRef.current` (`utils/ref.md`, `utils/ref.ts`).                                                                                                                                                                                                                   |
| `rovingFocus`        | Factory returning a `RovingFocus` instance whose `.setupItem` modifier goes on every item in the group | `roving = rovingFocus(() => ({ orientation: 'horizontal' }));` then `<button {{this.roving.setupItem}}>` on each item — `setupItem` takes no arguments itself; it reads selected/disabled state live from the element's own attributes (`utils/roving-focus.md`). Options are passed as a **thunk** (`() => options`), not a plain object, so a reactive arg stays live.                             |
| `dragToDismiss`      | A modifier taking named args directly                                                                  | `{{dragToDismiss axis='y' direction=1 isEnabled=true onDismiss=this.close handleSelector="[data-test-id='panel-handle']"}}` on the draggable element (`modifiers/drag-to-dismiss.md`).                                                                                                                                                                                                               |
| `toggleState`        | Factory returning a `ToggleState` instance with a tracked `.current` boolean and a `.toggle` method    | `toggle = toggleState(true);` in the class; `this.toggle.current` to read, `{{on 'click' this.toggle.toggle}}` or `this.toggle.toggle()` to flip — `.toggle` also accepts an explicit boolean or a change `Event` (reads `event.currentTarget.checked`) (`utils/toggle.md`, `utils/toggle.ts`).                                                                                                      |
| `selectionIndicator` | Factory returning a `SelectionIndicator` instance with two modifiers                                   | `indicator = selectionIndicator();` then `<div {{this.indicator.setupContainer}}>` on the container and `<button {{this.indicator.setupTarget isSelected}}>` on each candidate, passing the selected boolean as the sole positional arg (`utils/selection-indicator.md`). For consumers that can't use a modifier, `.claim(element)` / `.release(element)` are the same operations as plain methods. |

They come in two shapes, and mixing them up is the usual error:

- **Used directly as element modifiers** — `press` and `dragToDismiss`. Import and apply them
  straight to an element with named args: `{{press onPress=this.go}}`.
- **Factories returning an instance** — `ref`, `rovingFocus`, `toggleState`,
  `selectionIndicator`. Call the lowercase factory in a class field, then invoke the modifier
  _off the instance_: `{{this.myRef.setup}}`.

None of the six is a component. None is ever invoked as `<PascalCase />`.
