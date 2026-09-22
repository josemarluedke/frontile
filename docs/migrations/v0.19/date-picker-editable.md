---
title: DatePicker Editable Trigger Migration
order: 1
category: migrations
subcategory: v0.19
---

# DatePicker Editable Trigger Migration Guide

`DatePicker` now renders a segmented, typable field by default instead of a button showing
the formatted value. `@mode="range"` is segmented too, as two groups with a separator
between them.

**Impact:** every `DatePicker`, in both modes. **Fails how?** Visually — the field looks
different and behaves differently, but nothing throws and the value contract is unchanged.

## Keeping the previous trigger

```hbs
<DatePicker @label="Start date" @placeholder="Pick a date" @isEditable={{false}} />
```

`@placeholder`, `@formatOptions` and the `:value` block continue to describe that button.
They are the arguments most likely to look like they stopped working after the upgrade:
none of them apply to a segmented field, which has its own per-segment placeholders and
reads `@formatOptions` as the list of segments to render.

## If you keep the default

The editable field's default format is numeric — `{ year: 'numeric', month: '2-digit',
day: '2-digit' }` — rather than the button's `{ dateStyle: 'medium' }`. A textual
`@formatOptions`, including `{ dateStyle: 'medium' }` itself, has no numeric segment to
type into, so the month falls back to a numeric one and the component warns. Only the month
is replaced, so a format naming other fields keeps them; a `dateStyle` preset names no
fields at all and falls back to the numeric default in full.

Two other changes come with the segmented path:

- **The calendar icon is a `<button>`.** It is the only way to open the popover, because
  clicking a segment has to put the caret in it. `@endContentPointerEvents` therefore
  defaults to `'auto'` on this path; it keeps its previous meaning, and its `'none'`
  default, under `@isEditable={{false}}`.
- **`@isClearable` no longer takes the calendar icon's place.** The clear button and the
  calendar button coexist, so a clearable picker holding a value can still be picked from.
  Under `@isEditable={{false}}` they stay either/or.

If you select Frontile's DOM yourself, note that a segmented field renders no
`[data-part="input"]` — that element is the button trigger. The segments are
`[data-part="segment"]` inside a `[data-part="group"]`, and the field's shell moves onto
`[data-part="inner-container"]`, which carries `data-invalid` and `data-disabled`.

See [DatePicker](https://frontile.dev/docs/components/forms/date-picker) and the new
[DateInput](https://frontile.dev/docs/components/forms/date-input) for the full
behaviour.
