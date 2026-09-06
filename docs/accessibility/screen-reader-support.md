---
title: Screen reader support
order: 4
category: accessibility
---

# Screen reader support

Some information matters to assistive technology even when it's invisible on screen, or when
it changes without the user taking an action that would naturally draw their attention to it.
This page covers the three places Frontile handles that: live regions, labeling, and the
combobox pattern.

## Live regions

When content changes without a user interaction that would move focus there — a toast
notification appearing, or a search result count updating — screen readers need to be told
explicitly, because nothing about the DOM change otherwise gets announced.

Frontile uses `aria-live="polite"` for this in two places today:

- `NotificationsContainer` wraps its toasts in a live region, so a notification is announced
  when it appears without moving focus away from what the user was doing.
- `Command`'s result list announces its result count as the user types, so a screen reader
  user knows how many matches exist without needing to navigate into the list.

There's no reusable "announcer" utility in Frontile yet — each of these is a
component-specific `aria-live` region. If you need the same pattern in your own application
code (e.g. announcing that a background save succeeded), you'll need to add your own
`aria-live` region rather than reaching for something Frontile exports.

## Labeling

Two mechanisms cover the common labeling needs:

- **`VisuallyHidden`** hides text visually while keeping it in the accessibility tree — the
  standard way to give an icon-only button a real name. See the
  [`VisuallyHidden` docs](../../packages/frontile/src/components/utilities/visually-hidden.md)
  for examples.
- **`FormControl` and `Field`** automatically wire `aria-describedby` to point at a field's
  description and error text, and set `aria-invalid` when a field is in an error state. This
  happens for you when you use `c.describedBy(...)` as the form components already do — you
  should let it do this rather than wiring `aria-describedby` by hand, since Frontile also
  handles the case where a field has both a description and an error present at once.

## The combobox pattern

`Command` and `Autocomplete` implement the ARIA combobox pattern: the text input carries
`role="combobox"`, `aria-autocomplete="list"`, `aria-expanded` (reflecting whether the list is
open), `aria-controls` (pointing at the list), and `aria-activedescendant` (pointing at
whichever item is currently highlighted, without moving DOM focus off the input). Together
these let a screen reader track "which item is highlighted in the open list" purely from
attributes on the input the user is actually typing into.

## Used by

- [VisuallyHidden](../../packages/frontile/src/components/utilities/visually-hidden.md)
- [FormControl](../../packages/frontile/src/components/forms/form-control.md)
- [Field](../../packages/frontile/src/components/forms/field.md)
- [Command](../../packages/frontile/src/components/collections/command.md)
- [Autocomplete](../../packages/frontile/src/components/forms/autocomplete.md)
