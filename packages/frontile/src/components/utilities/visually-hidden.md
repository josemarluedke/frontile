---
imports:
  - import Signature from 'site/components/signature';
---

# VisuallyHidden

Hides content visually while keeping it available to screen readers, for context
that assistive technology needs and the visual design does not.

## Import

```js
import { VisuallyHidden } from 'frontile';
```

## Usage

The common case is naming a control whose meaning is carried by an icon.

```gts preview
import { Button, VisuallyHidden } from 'frontile';
import { ViewIcon, EditIcon, DeleteIcon } from 'site/components/icons';

<template>
  <div class='flex gap-2'>
    <Button @appearance='outlined' @size='sm'>
      <VisuallyHidden>View details</VisuallyHidden>
      <ViewIcon />
    </Button>

    <Button @appearance='outlined' @size='sm'>
      <VisuallyHidden>Edit item</VisuallyHidden>
      <EditIcon />
    </Button>

    <Button @appearance='outlined' @size='sm' @intent='danger'>
      <VisuallyHidden>Delete item</VisuallyHidden>
      <DeleteIcon />
    </Button>
  </div>
</template>
```

## Adding context to a visual signal

Where meaning is carried by colour, shape, or position, the sighted reader gets
it for free and everyone else gets nothing. A hidden word restores it without
changing the layout.

```gts preview
import { Chip, VisuallyHidden } from 'frontile';

<template>
  <ul role='list' class='not-prose flex flex-col gap-2'>
    <li>
      <Chip @intent='success' @withDot={{true}}>
        <VisuallyHidden>Status: </VisuallyHidden>
        Operational
      </Chip>
    </li>
    <li>
      <Chip @intent='danger' @withDot={{true}}>
        <VisuallyHidden>Status: </VisuallyHidden>
        Degraded
      </Chip>
    </li>
  </ul>
</template>
```

## Announcing a change

Combined with `aria-live`, a hidden region announces something that the visual
design already shows some other way — a count that updated, a save that
finished — without printing it twice on screen.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Button, VisuallyHidden } from 'frontile';

export default class Example extends Component {
  @tracked count = 0;

  add = () => {
    this.count++;
  };

  // The announcement is a sentence, so build it in JS rather than stitching it
  // together in the template — the plural has to agree.
  get announcement(): string {
    const noun = this.count === 1 ? 'item' : 'items';
    return `${this.count} ${noun} in cart`;
  }

  <template>
    <div class='flex items-center gap-4'>
      <Button @intent='primary' @onPress={{this.add}}>Add to cart</Button>
      <span class='text-neutral-strong'>{{this.count}}</span>

      <VisuallyHidden aria-live='polite'>{{this.announcement}}</VisuallyHidden>
    </div>
  </template>
}
```

## Accessibility

The component renders a `<div class="sr-only">`, the Tailwind utility that takes
content out of the visual flow while leaving it in the accessibility tree:

```css
position: absolute;
width: 1px;
height: 1px;
padding: 0;
margin: -1px;
overflow: hidden;
clip: rect(0, 0, 0, 0);
white-space: nowrap;
border-width: 0;
```

That is a different thing from `display: none`, `visibility: hidden`, or
`hidden`, all of which remove content from the accessibility tree too. Use
those when you want content gone for everyone.

### VisuallyHidden or `aria-label`

Both name a control, and for a plain string `aria-label` is shorter:

```gts
{{! equivalent }}
<Button aria-label='Close dialog'><CloseIcon /></Button>

<Button>
  <VisuallyHidden>Close dialog</VisuallyHidden>
  <CloseIcon />
</Button>
```

Reach for `VisuallyHidden` when `aria-label` cannot do the job:

- The content is **markup**, not a string — `aria-label` takes text only.
- The content must be **translated by the same machinery as visible text**;
  attribute values are easy for translation tooling to miss.
- The content is a **live region**, as above. `aria-label` cannot announce.

Note that `aria-label` on a container **replaces** everything inside it for
screen readers, so an element with both an `aria-label` and visible text hides
that text. `VisuallyHidden` adds instead of replacing.

### Keep it out of the visible text

Hidden text is concatenated with visible text into one accessible name, so
repeating the visible label produces "Save changes Save changes":

```gts
{{! ✗ the name is read twice }}
<Button>
  <VisuallyHidden>Save changes</VisuallyHidden>
  Save changes
</Button>

{{! ✓ the hidden text supplies what the icon cannot }}
<Button>
  <VisuallyHidden>Save changes</VisuallyHidden>
  <SaveIcon />
</Button>
```

### Say which one

In a list, a generic label is announced identically on every row, so it names
the action without identifying its target:

```gts
{{! ✗ every row announces "Delete" }}
<Button><VisuallyHidden>Delete</VisuallyHidden><DeleteIcon /></Button>

{{! ✓ }}
<Button>
  <VisuallyHidden>Delete contact {{contact.name}}</VisuallyHidden>
  <DeleteIcon />
</Button>
```

### Focusable content

Anything focusable inside a `VisuallyHidden` becomes a keyboard trap in
appearance: a sighted keyboard user tabs to something they cannot see. Keep
links and controls out of it, or use a skip-link pattern that reveals itself on
focus instead.

`sr-only` comes from Tailwind, so it has to be in your generated CSS. Frontile's
own components use it, which means your Tailwind setup needs to scan the
`frontile` package — see [Installation](/docs/get-started/installation).

## API

<Signature @component="VisuallyHidden" />
