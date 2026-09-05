---
---

# SelectionIndicator

`SelectionIndicator` measures whichever element is currently selected inside
a container and publishes its geometry as CSS custom properties on that
container. It paints nothing itself — a theme decides what that geometry
becomes, which is what lets one primitive back both `SegmentedControl`'s
pill and, in the future, an underline-style `Tabs`, with no JS change
between them.

## Import

```js
import { SelectionIndicator } from 'frontile';
```

## The contract

An instance exposes two modifiers.

`setupContainer` goes on the element the custom properties are written to. It
observes that element's size and re-measures whenever it changes.

`setupTarget` goes on each candidate element, with whether it is currently
selected as its sole positional argument:

```gts
<div {{indicator.setupContainer}}>
  <button {{indicator.setupTarget isSelected}}>...</button>
</div>
```

Only the element passed `true` is measured; its geometry is written to the
container as four custom properties:

| Property         | Value                            |
| ----------------- | --------------------------------- |
| `--fr-si-x`        | The selected element's `offsetLeft`  |
| `--fr-si-y`        | The selected element's `offsetTop`   |
| `--fr-si-width`    | The selected element's `offsetWidth` |
| `--fr-si-height`   | The selected element's `offsetHeight`|

These are physical offsets (`offsetLeft` / `offsetTop`), not logical ones,
and that is deliberate: the browser has already laid the items out for the
container's writing direction, so a physical offset fed to `translate` is
correct in both LTR and RTL with no extra handling. Reaching for a logical
property like `inset-inline-start` here would flip an already-flipped value.

Once the first real measurement lands, the container gains a
`data-fr-si-ready` attribute one frame later. A CSS transition on the
indicator must be gated on this attribute (`&[data-fr-si-ready] { transition:
... }`), not applied unconditionally — otherwise the very first paint has
nothing to transition *from*, and the indicator visibly flies in from the
container's origin `(0, 0)` before settling into place. The same attribute
should gate opacity, so the indicator stays invisible until it has something
correct to show. `SegmentedControl`'s theme keys both off of it via a
`group-data-[fr-si-ready]/segmented:` variant.

If the selected target measures zero — inside a closed drawer, an inactive
tab panel — the container loses `data-fr-si-ready` instead of publishing a
collapsed box, so the indicator does not falsely mark itself ready with
nothing to show. It picks back up on its own once the target is actually
visible and a resize is observed.

## The transform / translate trap

Overriding the indicator's positioning with the seemingly obvious

```css
.my-indicator {
  transform: translateX(var(--fr-si-x));
}
```

silently applies the offset **twice**. Per CSS Transforms Level 2, the
standalone `translate` property (which is what Tailwind's `translate-x-*`
utilities emit, not `transform`) is applied *before* `transform` in the same
box's transform stack — so a theme that already positions with
`translate-x-[var(--fr-si-x)]` and an override that adds
`transform: translateX(var(--fr-si-x))` on top compose, rather than one
replacing the other, and the element ends up offset by twice `--fr-si-x`.

An override has to neutralise the shipped geometry first —
`translate: none` — and then re-derive its own box purely from the published
custom properties, as the worked underline example below does.

## Worked example: a pill indicator

This is what `SegmentedControl`'s own theme does: an absolutely positioned
box sized and moved entirely by the four custom properties.

```css
.pill-indicator {
  position: absolute;
  left: 0;
  top: 0;
  width: var(--fr-si-width);
  height: var(--fr-si-height);
  translate: var(--fr-si-x) var(--fr-si-y);
  border-radius: 9999px;
  opacity: 0;
}

.pill-indicator[data-fr-si-ready] {
  opacity: 1;
  transition:
    translate 200ms ease-out,
    width 200ms ease-out,
    height 200ms ease-out;
}
```

## Worked example: an underline indicator

Only the CSS differs — a bar pinned to the container's bottom edge, sized
from `--fr-si-x` and `--fr-si-width` alone, with the theme's `translate`,
`width`, and `top` explicitly neutralised so the two geometries cannot
compose:

```css
.underline-indicator {
  translate: none;
  width: auto;
  position: absolute;
  top: auto;
  bottom: 0;
  left: var(--fr-si-x);
  right: calc(100% - var(--fr-si-x) - var(--fr-si-width));
  height: 2px;
  opacity: 0;
}

.underline-indicator[data-fr-si-ready] {
  opacity: 1;
  transition: left 200ms ease-out, right 200ms ease-out;
}
```
