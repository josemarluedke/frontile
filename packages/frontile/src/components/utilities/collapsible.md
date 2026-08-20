---
imports:
  - import Signature from 'site/components/signature';
---

# Collapsible

An unstyled wrapper that animates its content's height and opacity as it opens and closes, for building accordions, FAQ sections, expandable cards, and other disclosure patterns.

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

## Accordion

For an accordion, hold a single open id in the parent so opening one panel closes the others.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { fn } from '@ember/helper';
import { Collapsible, Button } from 'frontile';

export default class FaqAccordion extends Component {
  @tracked openItem: string | null = null;

  faqs = [
    {
      id: 'shipping',
      question: 'What are the shipping options?',
      answer:
        'Standard shipping takes 5-7 business days and express shipping 2-3. Free standard shipping on orders over $50.'
    },
    {
      id: 'returns',
      question: 'What is your return policy?',
      answer:
        'Returns are accepted within 30 days of purchase, unused and in original packaging. Refunds are processed within 5-10 business days.'
    },
    {
      id: 'warranty',
      question: 'Do you offer a warranty?',
      answer:
        'All products come with a 1-year manufacturer warranty covering defects in materials and workmanship.'
    }
  ];

  toggleItem = (id: string) => {
    this.openItem = this.openItem === id ? null : id;
  };

  isOpen = (id: string) => {
    return this.openItem === id;
  };

  <template>
    <div class='max-w-2xl space-y-2'>
      {{#each this.faqs as |faq|}}
        <div class='border border-neutral-subtle rounded-lg overflow-hidden'>
          <h3>
            <Button
              @appearance='minimal'
              @class='w-full text-left px-6 py-4 hover:bg-neutral-subtle'
              @onPress={{fn this.toggleItem faq.id}}
              aria-expanded='{{this.isOpen faq.id}}'
              aria-controls='faq-panel-{{faq.id}}'
            >
              <div class='flex items-center justify-between'>
                <span class='font-semibold'>{{faq.question}}</span>
                <span class='text-neutral-soft'>
                  {{if (this.isOpen faq.id) '−' '+'}}
                </span>
              </div>
            </Button>
          </h3>

          <Collapsible
            @isOpen={{this.isOpen faq.id}}
            id='faq-panel-{{faq.id}}'
            role='region'
          >
            <div class='px-6 pb-4 text-neutral'>
              {{faq.answer}}
            </div>
          </Collapsible>
        </div>
      {{/each}}
    </div>
  </template>
}
```

## Independent Panels

Track one flag per panel instead of a single id and any number of them can be open at once.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { fn } from '@ember/helper';
import { Collapsible, Button } from 'frontile';

export default class IndependentPanels extends Component {
  @tracked openPanels: Record<string, boolean> = {};

  panels = [
    {
      id: 'features',
      title: 'Features',
      body: 'Smooth animations, fully customizable markup, and no styling to fight.'
    },
    {
      id: 'pricing',
      title: 'Pricing',
      body: 'Starting at $9.99/month with a 14-day free trial.'
    },
    {
      id: 'support',
      title: 'Support',
      body: '24/7 email support with an average response time of 2 hours.'
    }
  ];

  toggle = (id: string) => {
    this.openPanels = { ...this.openPanels, [id]: !this.openPanels[id] };
  };

  isOpen = (id: string) => {
    return !!this.openPanels[id];
  };

  <template>
    <div class='max-w-md space-y-4'>
      {{#each this.panels as |panel|}}
        <div class='border border-neutral-subtle rounded-lg overflow-hidden'>
          <div class='p-4 bg-neutral-subtle border-b border-neutral-subtle'>
            <Button
              @appearance='minimal'
              @class='w-full text-left font-semibold'
              @onPress={{fn this.toggle panel.id}}
              aria-expanded='{{this.isOpen panel.id}}'
            >
              {{panel.title}}
              <span class='float-right'>
                {{if (this.isOpen panel.id) '▲' '▼'}}
              </span>
            </Button>
          </div>

          <Collapsible @isOpen={{this.isOpen panel.id}}>
            <p class='p-4 text-neutral'>{{panel.body}}</p>
          </Collapsible>
        </div>
      {{/each}}
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
- In an accordion, wrap each trigger in a heading (`<h3>` and so on) at the right level for the surrounding page.
- Collapsed content stays in the DOM and remains focusable, so avoid interactive elements inside a panel that is expected to read as hidden.

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
