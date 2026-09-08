---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Accordion

A vertically stacked set of headings that each reveal a section of content. Use
it to collapse long secondary material — FAQs, settings groups, detail panels —
so the page stays scannable.

For a single expandable region with no grouping and no coordination, reach for
[Collapsible](../utilities/collapsible), which is the primitive this is built on.

## Import

```js
import { Accordion } from 'frontile';
```

## Usage

`@title` and the default block cover the common case. Nothing needs a key.

```gts preview
import { Accordion } from 'frontile';

<template>
  <div class='demo-stack'>
    <Accordion as |a|>
      <a.Item @title='What are your shipping options?'>
        Standard shipping arrives in three to five business days. Express arrives
        the next business day.
      </a.Item>
      <a.Item @title='What is your return policy?'>
        Unopened items can be returned within thirty days for a full refund.
      </a.Item>
      <a.Item @title='How can I contact support?'>
        Email support@example.com, or use the chat widget in the bottom corner.
      </a.Item>
    </Accordion>
  </div>
</template>
```

## Starting open

`@isDefaultOpen` on an item opens it on first render. In `single` mode, if
several items declare it, the first in document order wins.

```gts preview
import { Accordion } from 'frontile';

<template>
  <div class='demo-stack'>
    <Accordion as |a|>
      <a.Item @title='Shipping' @isDefaultOpen={{true}}>
        Three to five business days.
      </a.Item>
      <a.Item @title='Returns'>Thirty days, unopened.</a.Item>
    </Accordion>
  </div>
</template>
```

## Several open at once

```gts preview
import { Accordion } from 'frontile';

<template>
  <div class='demo-stack'>
    <Accordion @selectionMode='multiple' as |a|>
      <a.Item @title='Shipping' @isDefaultOpen={{true}}>
        Three to five business days.
      </a.Item>
      <a.Item @title='Returns' @isDefaultOpen={{true}}>
        Thirty days, unopened.
      </a.Item>
      <a.Item @title='Support'>Email or chat.</a.Item>
    </Accordion>
  </div>
</template>
```

## Keys, and when you need them

An item's `@key` names it so something outside the accordion can address it —
controlled mode, a query parameter, persisted state. Without one an item still
works; it simply is not addressable. Identity then falls back to a generated id,
never to a position, so an item behind an `{{#if}}` cannot inherit its
neighbour's open state.

## Controlled and uncontrolled

The mode is decided by whether `@keys` is _passed_, not by what it holds. Omit
it and `Accordion` tracks the open items itself; write it at all — including
`@keys={{undefined}}` — and it is controlled.

Note this differs from [Tabs](../navigation/tabs), which names its arguments
`@value`/`@defaultValue`. Tabs holds one scalar selection; an accordion holds a
_set_ of open items identified by each item's `@key`.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { Accordion, Button } from 'frontile';

export default class ControlledAccordion extends Component {
  @tracked openKeys = ['shipping'];

  setOpenKeys = (keys) => {
    this.openKeys = keys;
  };

  openAll = () => {
    this.openKeys = ['shipping', 'returns'];
  };

  <template>
    <div class='demo-stack'>
      <Button @size='sm' {{on 'click' this.openAll}}>Open all</Button>

      <Accordion
        @selectionMode='multiple'
        @keys={{this.openKeys}}
        @onChange={{this.setOpenKeys}}
        as |a|
      >
        <a.Item @key='shipping' @title='Shipping'>
          Three to five business days.
        </a.Item>
        <a.Item @key='returns' @title='Returns'>
          Thirty days, unopened.
        </a.Item>
      </Accordion>
    </div>
  </template>
}
```

## Variants

```gts preview
import { array } from '@ember/helper';
import { Accordion } from 'frontile';

<template>
  <div class='demo-stack'>
    {{#each (array 'outlined' 'ghost' 'faded' 'enclosed') as |variant|}}
      <div>
        <p class='text-label-sm text-neutral-firm mb-2'>{{variant}}</p>
        <Accordion @variant={{variant}} as |a|>
          <a.Item @title='First item' @isDefaultOpen={{true}}>Some value 1…</a.Item>
          <a.Item @title='Second item'>Some value 2…</a.Item>
          <a.Item @title='Third item'>Some value 3…</a.Item>
        </Accordion>
      </div>
    {{/each}}
  </div>
</template>
```

## Sizes

```gts preview
import { array } from '@ember/helper';
import { Accordion } from 'frontile';

<template>
  <div class='demo-stack'>
    {{#each (array 'sm' 'md' 'lg') as |size|}}
      <Accordion @size={{size}} as |a|>
        <a.Item @title='First item' @isDefaultOpen={{true}}>Some value 1…</a.Item>
        <a.Item @title='Second item'>Some value 2…</a.Item>
      </Accordion>
    {{/each}}
  </div>
</template>
```

## Subtitles, icons and a custom indicator

Named blocks take over whenever the argument shortcuts are not enough. Two
Ember rules to know:

- **A default block cannot coexist with named blocks** — the moment you use
  `<:title>`, the body has to become `<:content>`.
- **Block params go on the named block, not the invocation tag.** Write
  `<:indicator as |i|>`, not `<a.Item as |i|>` — the latter errors with "the
  invocation tag cannot take block params" once any named block is present.

Every block yields `{{isOpen}}` and `{{toggle}}`.

```gts preview
import { Accordion, Avatar } from 'frontile';

<template>
  <div class='demo-stack'>
    <Accordion as |a|>
      <a.Item @key='team'>
        <:startContent><Avatar @name='Ada Lovelace' @size='sm' /></:startContent>
        <:title>Team</:title>
        <:subtitle>Three members</:subtitle>
        <:indicator as |i|>{{if i.isOpen '−' '+'}}</:indicator>
        <:content>Ada, Grace and Katherine.</:content>
      </a.Item>

      <a.Item @title='Billing' @subtitle='Plans and invoices'>
        Monthly or annual, cancel anytime.
      </a.Item>
    </Accordion>
  </div>
</template>
```

## Disabled items

```gts preview
import { Accordion } from 'frontile';

<template>
  <div class='demo-stack'>
    <Accordion as |a|>
      <a.Item @title='Available'>You can open this one.</a.Item>
      <a.Item @title='Unavailable' @isDisabled={{true}}>
        You cannot reach this.
      </a.Item>
    </Accordion>
  </div>
</template>
```

## Keeping one open

`@isCollapsible={{false}}` stops the open item from being closed, so something
is always showing. It applies to `single` mode only.

```gts preview
import { Accordion } from 'frontile';

<template>
  <div class='demo-stack'>
    <Accordion @isCollapsible={{false}} as |a|>
      <a.Item @title='First item' @isDefaultOpen={{true}}>Some value 1…</a.Item>
      <a.Item @title='Second item'>Some value 2…</a.Item>
    </Accordion>
  </div>
</template>
```

## Accessibility

`Accordion` implements the WAI-ARIA accordion pattern.

- Each trigger is a real `<button>` wrapped in a heading. Set `@headingLevel`
  to whatever fits the surrounding page outline — it defaults to `3`, which is
  wrong as often as it is right.
- The trigger carries `aria-expanded` and `aria-controls`; the panel is a
  `role="region"` labelled by its trigger.
- **Every header is its own tab stop**, as the pattern requires. Tab moves
  through the headers; Enter and Space toggle. Arrow Down and Arrow Up move
  between headers and wrap, Home and End jump to the first and last, and
  disabled headers are stepped over.
- Closed panels are `inert`, so anything focusable inside them leaves the tab
  order rather than being reachable by Tab while invisible.
- Content stays in the DOM when closed, so find-in-page and search engines can
  still reach it.
- The open/close animation is skipped for users who prefer reduced motion.

## API

<Signature @component="Accordion" />
<Signature @component="AccordionItem" />
