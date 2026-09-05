---
label: New
---

# rovingFocus

`rovingFocus` gives a group of related controls the keyboard behaviour the
ARIA authoring practices ask for: the group is a **single tab stop**, and once
focus is inside it the arrow keys move between the items. It owns the keyboard
and the `tabindex` bookkeeping only — it renders nothing, decides nothing about
selection, and applies no styling — which is what lets one primitive serve
`SegmentedControl`'s radiogroup today and a future `Tabs` unchanged.

## Import

```js
import { rovingFocus } from 'frontile';
```

## The contract

Construct one instance per group, then place its single modifier on every item.

```gts
<div role="radiogroup">
  <button {{roving.setupItem isSelected isDisabled}}>...</button>
</div>
```

`setupItem` takes two positional arguments, both booleans:

| Argument     | Meaning                                                    |
| ------------ | ---------------------------------------------------------- |
| `isSelected` | Whether this item is the current selection. Drives which item is the group's tab stop. |
| `isDisabled` | Whether this item should be skipped by arrow navigation and never be the tab stop. |

Items register themselves as their modifiers run and are kept sorted by
document position, not by setup order — modifier setup order is not guaranteed
to match DOM order once items are added or reordered, and navigation has to
follow what the user actually sees.

## Options are a thunk

The constructor takes a *function* returning the options, not the options
themselves:

```ts
roving = rovingFocus(() => ({
  orientation: this.args.orientation ?? 'horizontal',
  activationMode: 'automatic',
  onActivate: this.activate
}));
```

The thunk is called at the moment a key is handled, never cached. That is the
whole point: a consumer whose orientation or activation mode is a component
argument stays reactive without having to push updates into the instance, and
without the instance having to be rebuilt when an argument changes. A snapshot
taken in the constructor would freeze `@orientation` at its first value, and a
control switched from horizontal to vertical would keep answering to the wrong
arrow keys.

| Option           | Type                                | Default        |
| ---------------- | ----------------------------------- | -------------- |
| `orientation`    | `'horizontal' \| 'vertical'`        | `'horizontal'` |
| `activationMode` | `'automatic' \| 'manual'`           | `'automatic'`  |
| `onActivate`     | `(element: HTMLElement) => void`    | —              |

`onActivate` receives the **element**, not a value. Keeping the primitive
ignorant of the consumer's value type is what lets a consumer hold non-string
values against their elements and get them back unserialised; `SegmentedControl`
keeps a `Map<HTMLElement, T>` for exactly that.

## The keyboard contract

| Key                        | Behaviour                                                            |
| -------------------------- | -------------------------------------------------------------------- |
| `Tab`                      | Enters or leaves the group. Only one item inside it is tabbable.     |
| `ArrowRight` / `ArrowDown` | Moves to the next enabled item, wrapping past the last to the first. |
| `ArrowLeft` / `ArrowUp`    | Moves to the previous enabled item, wrapping past the first to the last. |
| `Home` / `End`             | Moves to the first / last enabled item.                              |

Which arrow pair is live depends on `orientation`: horizontal listens to
left/right, vertical to up/down. The other pair is left alone, so a vertical
group inside a horizontally scrolling region does not swallow left/right.

Disabled items are skipped entirely rather than focused and stepped over — the
navigation order is computed from the enabled items alone, so wrapping and
`Home`/`End` land on real targets. Any handled key calls `preventDefault()`;
anything else is left to the browser.

## Activation modes

`automatic` — the default, and what the radiogroup pattern requires — moves
selection *with* focus: every arrow, `Home`, or `End` focuses the new item and
immediately calls `onActivate` with it. Arrowing through a `SegmentedControl`
selects as it goes, exactly as a native radio group does.

`manual` moves focus only. `onActivate` is not called on arrow keys; it fires
when the user presses `Enter` or `Space` on the focused item. This is the mode
tabs want when switching panels is expensive — a user arrowing across six tabs
should not trigger six panel loads — and it is why the option exists ahead of a
`Tabs` component to use it.

In both modes the consumer decides what "activate" means. `rovingFocus` never
changes `aria-checked`, `aria-selected`, or anything else about the item.

## The roving tabindex

Exactly one item in the group carries `tabindex="0"`; every other item gets
`tabindex="-1"`, and the set is recomputed whenever an item is added, removed,
or changes its selected/disabled flags.

The tab stop is the selected item — unless nothing is selected, or the selected
item is disabled, in which case it is the **first enabled item**. That fallback
is not incidental: a radiogroup with no selection still has to be reachable by
`Tab`, and without it a fresh group with nothing chosen would have no tab stop
at all and would be skipped over entirely by keyboard users.

A group in which every item is disabled has no tab stop, which is the correct
outcome — there is nothing there to operate.

## Right-to-left

In an RTL container the right arrow moves towards the *start* of the group, so
`ArrowRight` and `ArrowLeft` swap roles. `rovingFocus` reads the focused item's
computed `direction` at the moment the key is handled, so a group inside a
`dir="rtl"` subtree behaves correctly without the consumer passing anything —
and a page that flips direction at runtime is picked up on the next keypress
rather than being frozen at construction time.

Only horizontal navigation is affected. Vertical order is the same in both
directions, so `ArrowUp`/`ArrowDown` are never swapped.

## Usage

Arrow between the options below — focus and selection move together, `Home`
and `End` jump to the ends, the disabled option is skipped, and `Tab` leaves
the group in one press rather than stepping through all four.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { rovingFocus } from 'frontile';

const options = [
  { value: 'day', label: 'Day', isDisabled: false },
  { value: 'week', label: 'Week', isDisabled: false },
  { value: 'month', label: 'Month', isDisabled: true },
  { value: 'year', label: 'Year', isDisabled: false }
];

export default class Example extends Component {
  @tracked selected = 'day';

  roving = rovingFocus(() => ({
    orientation: 'horizontal',
    activationMode: 'automatic',
    onActivate: this.activate
  }));

  activate = (element: HTMLElement): void => {
    this.selected = element.getAttribute('data-value') ?? this.selected;
  };

  isSelected = (value: string): boolean => {
    return this.selected === value;
  };

  <template>
    <div class='flex flex-col items-start gap-3'>
      <div role='radiogroup' aria-label='Date range' class='flex gap-2'>
        {{#each options as |option|}}
          <button
            type='button'
            role='radio'
            data-value={{option.value}}
            aria-checked='{{this.isSelected option.value}}'
            disabled={{option.isDisabled}}
            class='rounded-md border border-neutral-soft px-3 py-1 text-label-md
              aria-checked:border-primary aria-checked:text-primary
              disabled:cursor-not-allowed disabled:opacity-disabled'
            {{this.roving.setupItem
              (this.isSelected option.value)
              option.isDisabled
            }}
          >{{option.label}}</button>
        {{/each}}
      </div>

      <p class='text-body-sm text-neutral-strong'>Selected: {{this.selected}}</p>
    </div>
  </template>
}
```

> `rovingFocus` handles `keydown` on the items themselves, so it only reacts
> once focus is already inside the group. Selecting with the pointer stays the
> consumer's job — wire your own `click` handler alongside `setupItem`, as
> `SegmentedControl` does.
