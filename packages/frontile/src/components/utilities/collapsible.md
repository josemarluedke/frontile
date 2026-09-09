---
imports:
  - import Signature from 'site/components/signature';
---

# Collapsible

An unstyled wrapper that animates its content's height and opacity as it opens
and closes. It is the primitive behind [Accordion](../disclosure/accordion) —
reach for this when you need a single expandable region and want to own the
trigger, the state and the markup yourself.

Building a set of coordinated sections? Use
[Accordion](../disclosure/accordion) instead. It handles the open-item state,
the WAI-ARIA wiring, the keyboard pattern and focus containment, all of which
are easy to get wrong by hand.

## Import

```js
import { Collapsible } from 'frontile';
```

## Usage

`@isOpen` is required and the component is fully controlled: keep the state in the parent and render your own trigger. Expanding animates height and opacity over `0.4s`, collapsing over `0.2s`; once expanded the height is set back to `auto` so content can keep growing.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Collapsible, Button } from 'frontile';

export default class BasicCollapsible extends Component {
  @tracked isOpen = false;

  toggle = () => {
    this.isOpen = !this.isOpen;
  };

  <template>
    <div class='max-w-md'>
      <Button @intent='primary' @onPress={{this.toggle}}>
        {{if this.isOpen 'Hide' 'Show'}}
        Content
      </Button>

      <Collapsible @isOpen={{this.isOpen}}>
        <div
          class='p-8 mt-4 bg-primary-subtle rounded-lg border border-primary-soft'
        >
          <p class='text-neutral-strong'>
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse
            malesuada lacus ex, sit amet blandit leo lobortis eget.
          </p>
        </div>
      </Collapsible>
    </div>
  </template>
}
```

## Initial Height

`@initialHeight` keeps part of the content visible while collapsed — the "Read more" pattern. Opacity stays at `1` instead of fading out, and only the height animates. Include the unit in the value (`80px`, `5rem`) — a bare number isn't a valid CSS height and is ignored.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Collapsible, Button } from 'frontile';

export default class PreviewCollapsible extends Component {
  @tracked isOpen = false;

  toggle = () => {
    this.isOpen = !this.isOpen;
  };

  <template>
    <div
      class='max-w-md border border-neutral-subtle rounded-lg overflow-hidden'
    >
      <Collapsible @isOpen={{this.isOpen}} @initialHeight='80px'>
        <div class='p-6 bg-neutral-subtle'>
          <h3 class='text-lg font-semibold mb-2'>Article Title</h3>
          <p class='text-neutral'>
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse
            malesuada lacus ex, sit amet blandit leo lobortis eget. Lorem ipsum
            dolor sit amet, consectetur adipiscing elit. Suspendisse malesuada
            lacus ex, sit amet blandit leo lobortis eget. Sed hendrerit turpis
            nec dolor maximus, vitae facilisis lectus scelerisque.
          </p>
        </div>
      </Collapsible>

      <div class='px-6 py-3 bg-neutral-subtle border-t border-neutral-subtle'>
        <Button @size='sm' @appearance='minimal' @onPress={{this.toggle}}>
          {{if this.isOpen 'Read Less' 'Read More'}}
        </Button>
      </div>
    </div>
  </template>
}
```

## Initially Open

Passing `@isOpen={{true}}` on the first render shows the content immediately, with no opening animation. Closing it afterwards animates as usual.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Collapsible, Button } from 'frontile';

export default class InitiallyOpen extends Component {
  @tracked isOpen = true;

  toggle = () => {
    this.isOpen = !this.isOpen;
  };

  <template>
    <div class='max-w-md border border-primary-soft rounded-lg overflow-hidden'>
      <h3
        class='p-4 font-semibold bg-primary-subtle border-b border-primary-soft'
      >
        Welcome Message
      </h3>

      <Collapsible @isOpen={{this.isOpen}}>
        <div class='p-4'>
          <p class='text-neutral mb-4'>
            Thank you for signing up! Here are some quick tips to get started.
          </p>
          <ul class='space-y-2 text-neutral'>
            <li>→ Complete your profile</li>
            <li>→ Connect your accounts</li>
            <li>→ Explore the dashboard</li>
          </ul>
        </div>
      </Collapsible>

      <div class='px-4 py-3 bg-neutral-subtle border-t border-neutral-subtle'>
        <Button @size='sm' @appearance='minimal' @onPress={{this.toggle}}>
          {{if this.isOpen 'Dismiss' 'Show Again'}}
        </Button>
      </div>
    </div>
  </template>
}
```

## Nested Collapsibles

A Collapsible can contain others. The outer one measures its content when it opens, so a nested panel that expands later grows the outer panel with it.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { fn } from '@ember/helper';
import { Collapsible, Button } from 'frontile';

export default class NestedCollapsibles extends Component {
  @tracked isParentOpen = false;
  @tracked openChildren: Record<string, boolean> = {};

  subcategories = [
    { id: 'one', title: 'Subcategory 1', body: 'Details for subcategory 1' },
    { id: 'two', title: 'Subcategory 2', body: 'Details for subcategory 2' }
  ];

  toggleParent = () => {
    this.isParentOpen = !this.isParentOpen;
  };

  toggleChild = (id: string) => {
    this.openChildren = { ...this.openChildren, [id]: !this.openChildren[id] };
  };

  isChildOpen = (id: string) => {
    return !!this.openChildren[id];
  };

  <template>
    <div
      class='max-w-md border border-neutral-subtle rounded-lg overflow-hidden'
    >
      <div class='p-4 bg-neutral-subtle'>
        <Button
          @appearance='minimal'
          @class='w-full text-left font-semibold'
          @onPress={{this.toggleParent}}
          aria-expanded='{{this.isParentOpen}}'
        >
          Category
          <span class='float-right'>{{if this.isParentOpen '▲' '▼'}}</span>
        </Button>
      </div>

      <Collapsible @isOpen={{this.isParentOpen}}>
        <div class='p-4 space-y-2'>
          {{#each this.subcategories as |sub|}}
            <div class='border border-neutral-subtle rounded overflow-hidden'>
              <div class='p-3 bg-neutral-subtle'>
                <Button
                  @appearance='minimal'
                  @size='sm'
                  @class='w-full text-left'
                  @onPress={{fn this.toggleChild sub.id}}
                  aria-expanded='{{this.isChildOpen sub.id}}'
                >
                  {{sub.title}}
                  <span class='float-right'>
                    {{if (this.isChildOpen sub.id) '−' '+'}}
                  </span>
                </Button>
              </div>

              <Collapsible @isOpen={{this.isChildOpen sub.id}}>
                <p class='p-3 text-sm text-neutral'>{{sub.body}}</p>
              </Collapsible>
            </div>
          {{/each}}
        </div>
      </Collapsible>
    </div>
  </template>
}
```

## Accessibility

Collapsible renders a plain `<div>` with no roles or ARIA of its own, and it has no trigger — the disclosure semantics are yours to supply. It forwards `...attributes`, so `id`, `role`, and `aria-*` can be set on it directly.

- Use a real `<button>` (or Frontile's `Button`) as the trigger, so Enter, Space, and focus work without extra code.
- Put `aria-expanded` on the trigger, mirroring the same state you pass to `@isOpen`.
- Point `aria-controls` at the Collapsible's `id`, and give the Collapsible `role="region"` when it holds a self-contained chunk of content.
- `Collapsible` animates a box; it does not manage focus. While collapsed its
  content is `height: 0` but still in the tab order, so add `inert` yourself
  when the content holds anything focusable — or use
  [Accordion](../disclosure/accordion), which does it for you.
- Building an accordion by hand also means owning the heading structure, the
  `aria-expanded`/`aria-controls` round trip and the arrow-key pattern.
  [Accordion](../disclosure/accordion) implements all of it.

```gts
<button
  type="button"
  aria-expanded={{this.isOpen}}
  aria-controls="content-1"
  {{on "click" this.toggle}}
>
  Toggle Content
</button>

<Collapsible @isOpen={{this.isOpen}} id="content-1" role="region">
  Content here
</Collapsible>
```

> **Note:** Transitions are registered with an Ember test waiter, so `await settled()` in tests resolves only after the open or close animation has finished.

## API

<Signature @component="Collapsible" />
