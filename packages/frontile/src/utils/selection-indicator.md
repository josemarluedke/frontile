---
label: New
---

# selectionIndicator

`selectionIndicator` creates a helper that measures whichever element is currently selected inside
a container and publishes its geometry as CSS custom properties on that
container. It paints nothing itself — a theme decides what that geometry
becomes, which is what lets one primitive back both `SegmentedControl`'s
pill and, in the future, an underline-style `Tabs`, with no JS change
between them.

## Import

```js
import { selectionIndicator } from 'frontile';
```

## The contract

Call it to create an instance; the instance exposes two modifiers.

```js
indicator = selectionIndicator();
```

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
indicator must be gated on this attribute, not applied unconditionally —
otherwise the very first paint has nothing to transition *from*, and the
indicator visibly flies in from the container's origin `(0, 0)` before
settling into place. The same attribute should gate opacity, so the indicator
stays invisible until it has something correct to show.

The attribute lands on the **container**, and the indicator is a descendant of
it, so the gate is a descendant selector — `[data-fr-si-ready] .my-indicator
{ … }`, never `.my-indicator[data-fr-si-ready]`, which can never match. In
Tailwind the same relationship is spelled `group-data-[fr-si-ready]/name:`
against a `group/name` on the container, which is exactly how
`SegmentedControl`'s theme keys both opacity and the transition off of it.

If the selected target measures zero — inside a closed drawer, an inactive
tab panel — the container loses `data-fr-si-ready` instead of publishing a
collapsed box, so the indicator does not falsely mark itself ready with
nothing to show. It picks back up on its own once the target is actually
visible and a resize is observed.

## A working example

Everything above in one runnable piece: three buttons and a bar that slides
between them. The primitive supplies no styling at all — the bar's entire
appearance and geometry come from the CSS below, reading the published custom
properties.

Note the two rules the rest of this page argues for. The gate is
`.si-demo[data-fr-si-ready] .si-demo-bar` — container attribute, descendant
indicator — and the bar is positioned with `left` / `width` from
`--fr-si-x` / `--fr-si-width`, never with `transform`.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import { selectionIndicator } from 'frontile';

export default class SelectionIndicatorDemo extends Component {
  indicator = selectionIndicator();

  tabs = ['Overview', 'Activity', 'Settings'];

  @tracked current = 'Overview';

  select = (tab: string): void => {
    this.current = tab;
  };

  isSelected = (tab: string): boolean => {
    return this.current === tab;
  };

  <template>
    {{! template-lint-disable no-forbidden-elements }}
    <style>
      .si-demo {
        position: relative;
        display: inline-flex;
      }

      .si-demo-bar {
        position: absolute;
        bottom: 0;
        height: 2px;
        left: var(--fr-si-x);
        width: var(--fr-si-width);
        background: currentColor;
        opacity: 0;
      }

      .si-demo[data-fr-si-ready] .si-demo-bar {
        opacity: 1;
        transition:
          left 200ms ease-out,
          width 200ms ease-out;
      }
    </style>

    <div
      class='si-demo border-b border-neutral-soft text-primary'
      {{this.indicator.setupContainer}}
    >
      <span class='si-demo-bar'></span>

      {{#each this.tabs as |tab|}}
        <button
          type='button'
          class='px-4 py-2 text-label-md
            {{if (this.isSelected tab) "text-primary" "text-neutral-strong"}}'
          {{this.indicator.setupTarget (this.isSelected tab)}}
          {{on 'click' (fn this.select tab)}}
        >
          {{tab}}
        </button>
      {{/each}}
    </div>
  </template>
}
```

The same markup with a different stylesheet is a pill, a highlight, or a
growing outline. That is the point of publishing geometry instead of painting
it.


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

`.my-control` is the element carrying `setupContainer`, so it is the one that
gains `data-fr-si-ready`; the gated rules therefore read *container attribute,
then descendant indicator*.

```css
.my-control {
  position: relative;
}

.my-control .pill-indicator {
  position: absolute;
  left: 0;
  top: 0;
  width: var(--fr-si-width);
  height: var(--fr-si-height);
  translate: var(--fr-si-x) var(--fr-si-y);
  border-radius: 9999px;
  opacity: 0;
}

.my-control[data-fr-si-ready] .pill-indicator {
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
.my-control .underline-indicator {
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

.my-control[data-fr-si-ready] .underline-indicator {
  opacity: 1;
  transition:
    left 200ms ease-out,
    right 200ms ease-out;
}
```
