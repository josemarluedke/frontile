---
title: Keyboard navigation
order: 3
category: accessibility
---

# Keyboard navigation

Several components — lists, menus, tables, and grouped controls — share the same keyboard
model rather than each inventing their own: the group is a **single Tab stop**, and once
focus is inside it, arrow keys move between items. This is the model the WAI-ARIA authoring
practices call for grids, listboxes, menus, and radio groups, and it's what makes Tab predictable
regardless of how many items a list contains.

## The shared model

- **Tab** enters or leaves the group in one press — it never steps through every item.
- **Arrow keys** move focus between items. Horizontal groups (e.g. `SegmentedControl`) use
  Left/Right; vertical groups (e.g. `Table`, `Listbox`) use Up/Down.
- **Home** / **End** jump to the first / last enabled item. Listbox also treats
  PageUp/PageDown as Home/End.
- **Typeahead** — typing a letter jumps to the next item whose text starts with it, in
  components that support text search (Listbox, Select, Autocomplete, Command).
- **Disabled items are skipped** — navigation is computed from the enabled items only, so
  wrapping and Home/End always land on something usable.
- In a right-to-left layout, horizontal groups swap Left/Right so "next"
  and "previous" still match the direction the user reads in. Vertical navigation is
  unaffected.

## Two activation styles

How arrow-key navigation relates to selection differs by component, matching how each one is
actually used:

- **Automatic activation** — arrowing to an item selects it immediately, the way a native
  radio group works. `SegmentedControl` uses this.
- **Manual activation** — arrowing only moves focus; selecting requires a separate action
  (`Enter`/`Space`, or a click). This is the right model when moving focus is cheap but
  activating is not — `Table`'s row navigation uses this, since arrowing across rows
  shouldn't fire a selection on every keystroke.

## Choosing a component

Use `SegmentedControl` when moving focus should also change the value. Use `Table` when focus
and selection must remain separate. Listbox, Dropdown, Select, Autocomplete, NativeSelect,
and Command add selection state and typeahead behavior for option collections. If you are
building a custom composite control, the public `rovingFocus` modifier provides the shared
single-tab-stop behavior.

## Used by

- [Table](../../packages/frontile/src/components/collections/table.md)
- [Listbox](../../packages/frontile/src/components/collections/listbox.md)
- [Dropdown](../../packages/frontile/src/components/collections/dropdown.md)
- [Select](../../packages/frontile/src/components/forms/select.md)
- [Autocomplete](../../packages/frontile/src/components/forms/autocomplete.md)
- [Command](../../packages/frontile/src/components/collections/command.md)
- [SegmentedControl](../../packages/frontile/src/components/buttons/segmented-control.md)
- [rovingFocus reference](../../packages/frontile/src/utils/roving-focus.md)
