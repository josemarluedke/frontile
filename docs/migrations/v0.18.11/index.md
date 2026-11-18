---
title: Upgrading to v0.18.11
order: 1
category: migrations
subcategory: v0.18.11
---

# Upgrading to v0.18.11

v0.18.11 is a patch release, but it is **not passive**. It updates the default theme
values, and the first of those changes the size of every `<Button>` in your
app, whether or not you pass `@size`. No code change is
required, but look at your buttons before you ship.

Packages affected: `frontile` and `@frontile/theme`.

## Button sizes moved down one step

The Button size scale was re-cut. Every named size now renders what the next
smaller one used to, and a new, smaller `xs` sits at the bottom.

| `@size` | Now renders           |
| ------- | --------------------- |
| `xs`    | new, the smallest     |
| `sm`    | what `xs` used to be  |
| `md`    | what `sm` used to be  |
| `lg`    | what `md` used to be  |
| `xl`    | what `lg` used to be  |
| `2xl`   | what `xl` used to be  |

The old `2xl` size is gone.

The default size is still `md`, so an unsized `<Button>` gets smaller. Label text
steps down with it (`md` is now `text-strong-md`, previously `text-strong-lg`),
as do horizontal padding and the gap between icon and label.

**What to do:** nothing, if the smaller default suits you. To keep a button at its
old size, move its `@size` up one step (`md` becomes `lg`). The old `2xl` has no
equivalent; use `2xl` and accept the next size down, or size it yourself with
`@classes`.

If you set a unit next to a Button label (`/mo`, as in the
"Label with a Unit" section of the Button docs), its
`text-body-*` class needs to move with the label. The table in that section is
updated.

## Neutral Button ink and ramp

The neutral color now uses the generated `on-neutral-subtle` ink where it used
`neutral-bolder`, and the `soft` and `subtle` variants sit one level lighter
(`neutral-muted` rather than `neutral-soft`). Hover and active states follow the
same shift. Light and dark mode both adapt automatically.

Smaller state adjustments for other colors:

- `secondary` and `tertiary` `soft`, and `success` `soft`, hover to the `subtle`
  level instead of `muted`.
- `tertiary` hover uses `tertiary` instead of `tertiary-firm` for text.
- `secondary` `plain` gains a soft background and border while pressed.

**What to do:** nothing. These are visual only. If you override Button colors with
`@classes`, check them against the new neutral ink.

## Badge

Badge text steps down to the body scale: `xs` and `sm` use `text-body-4xs`,
`md` uses `text-body-2xs`, `lg` uses `text-body-sm`. Heights, padding and radii
are unchanged, so layout does not move.

Badge gained **no new slots or arguments**. Its content is the default block,
`@value`, `@unit`, `<:startIcon>` and `<:endIcon>`, as before.

Chip now uses regular weight, matching Badge.

## Form field content

The `startContent` and `endContent` slots of inputs, the date picker and the date
input now render in `text-neutral-soft`. Icons and text placed there pick up the
softer color. Put an explicit text color on your own content if you need
something different.

## Also in this release

- `Popover` content stays inside the viewport on small screens: width is capped
  at the available room and tall content scrolls (`--popover-available-width`
  and `--popover-available-height`).

## What was deliberately not changed

These are **not** in 0.18.11, so don't expect them:

- Generated on-colors (`on-{category}-{level}`) keep their current values.
- Divider keeps its current default style.
- The focus ring is unchanged.
- Elevation and shadows are unchanged.

The next non-passive change is Badge and Chip sharing Button's text ramp and size
names (default `xs`). It will ship with its own migration note.
