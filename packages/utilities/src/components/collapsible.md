---
imports:
  - import Signature from 'site/components/signature';
---

# Collapsible

An unstyled component that provides smooth expand and collapse animations for content. Perfect for building accordions, FAQ sections, expandable cards, and other disclosure patterns.

## Import

```js
import { Collapsible } from 'frontile';
```

## Key Features

- **Smooth Animations**: Built-in height and opacity transitions with cubic-bezier easing
- **Initial Height Support**: Show a preview of content when collapsed
- **Fully Controlled**: Manage open/close state from parent component
- **Unstyled**: Complete styling freedom
- **Accessible**: Works with any accessible disclosure pattern
- **Test-Friendly**: Built-in test waiters for reliable async testing

## Usage

### Basic Collapsible

A simple collapsible panel with toggle button.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Collapsible, Button } from 'frontile';

export default class BasicCollapsible extends Component {
  @tracked isOpen = false;

  @action toggle() {
    this.isOpen = !this.isOpen;
  }

  <template>
    <div class='max-w-md'>
      <Button @intent='primary' @onPress={{this.toggle}}>
        {{if this.isOpen 'Hide' 'Show'}}
        Content
      </Button>

      <Collapsible @isOpen={{this.isOpen}}>
        <div
          class='p-8 mt-4 bg-primary-100 rounded-lg border border-primary-200'
        >
          <p class='text-default-900'>
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse
            malesuada lacus ex, sit amet blandit leo lobortis eget. Lorem ipsum
            dolor sit amet, consectetur adipiscing elit.
          </p>
        </div>
      </Collapsible>
    </div>
  </template>
}
```

### With Initial Height

Show a preview of content when collapsed using `@initialHeight`.

> **Note:** Always include the unit (e.g., `px`, `rem`, `em`) in the height value.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Collapsible, Button } from 'frontile';

export default class PreviewCollapsible extends Component {
  @tracked isOpen = false;

  @action toggle() {
    this.isOpen = !this.isOpen;
  }

  <template>
    <div class='max-w-md'>
      <div class='border border-default-200 rounded-lg overflow-hidden'>
        <Collapsible @isOpen={{this.isOpen}} @initialHeight='80px'>
          <div class='p-6 bg-default-50'>
            <h3 class='text-lg font-semibold mb-2'>Article Title</h3>
            <p class='text-default-700'>
              Lorem ipsum dolor sit amet, consectetur adipiscing elit.
              Suspendisse malesuada lacus ex, sit amet blandit leo lobortis
              eget. Lorem ipsum dolor sit amet, consectetur adipiscing elit.
              Suspendisse malesuada lacus ex, sit amet blandit leo lobortis
              eget. Sed hendrerit turpis nec dolor maximus, vitae facilisis
              lectus scelerisque.
            </p>
          </div>
        </Collapsible>

        <div class='px-6 py-3 bg-default-100 border-t border-default-200'>
          <Button @size='sm' @appearance='minimal' @onPress={{this.toggle}}>
            {{if this.isOpen 'Read Less' 'Read More'}}
          </Button>
        </div>
      </div>
    </div>
  </template>
}
```

### FAQ Accordion

Build an FAQ section with multiple collapsible items.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { Collapsible, Button } from 'frontile';

export default class FaqAccordion extends Component {
  @tracked openItem = null;

  faqs = [
    {
      id: 'shipping',
      question: 'What are the shipping options?',
      answer:
        'We offer standard shipping (5-7 business days) and express shipping (2-3 business days). Free standard shipping is available on orders over $50.'
    },
    {
      id: 'returns',
      question: 'What is your return policy?',
      answer:
        'We accept returns within 30 days of purchase. Items must be unused and in original packaging. Refunds are processed within 5-10 business days.'
    },
    {
      id: 'warranty',
      question: 'Do you offer a warranty?',
      answer:
        'Yes, all products come with a 1-year manufacturer warranty covering defects in materials and workmanship. Extended warranties are available for purchase.'
    }
  ];

  @action toggleItem(id: string) {
    this.openItem = this.openItem === id ? null : id;
  }

  isOpen = (id: string) => {
    return this.openItem === id;
  };

  <template>
    <div class='max-w-2xl space-y-2'>
      {{#each this.faqs as |faq|}}
        <div class='border border-default-200 rounded-lg overflow-hidden'>
          <Button
            @appearance='minimal'
            @class='w-full text-left px-6 py-4 hover:bg-default-50'
            @onPress={{fn this.toggleItem faq.id}}
          >
            <div class='flex items-center justify-between'>
              <span class='font-semibold'>{{faq.question}}</span>
              <span class='text-default-500'>
                {{if (this.isOpen faq.id) '−' '+'}}
              </span>
            </div>
          </Button>

          <Collapsible @isOpen={{this.isOpen faq.id}}>
            <div class='px-6 pb-4 text-default-700'>
              {{faq.answer}}
            </div>
          </Collapsible>
        </div>
      {{/each}}
    </div>
  </template>
}
```

### Expandable Card

Create an expandable card with additional details.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Collapsible, Button } from 'frontile';

export default class ExpandableCard extends Component {
  @tracked isExpanded = false;

  @action toggleExpand() {
    this.isExpanded = !this.isExpanded;
  }

  <template>
    <div class='max-w-md border border-default-200 rounded-lg overflow-hidden'>
      <div class='p-6'>
        <div class='flex items-start gap-4'>
          <div
            class='w-12 h-12 rounded-full bg-primary-100 flex items-center justify-center'
          >
            <span class='text-primary-600 font-semibold text-lg'>JD</span>
          </div>
          <div class='flex-1'>
            <h3 class='font-semibold text-lg'>John Doe</h3>
            <p class='text-default-500 text-sm'>Software Engineer</p>
          </div>
        </div>

        <Collapsible @isOpen={{this.isExpanded}}>
          <div class='mt-4 pt-4 border-t border-default-200'>
            <dl class='space-y-2 text-sm'>
              <div class='flex'>
                <dt class='font-medium w-24'>Email:</dt>
                <dd class='text-default-700'>john.doe@example.com</dd>
              </div>
              <div class='flex'>
                <dt class='font-medium w-24'>Phone:</dt>
                <dd class='text-default-700'>+1 (555) 123-4567</dd>
              </div>
              <div class='flex'>
                <dt class='font-medium w-24'>Location:</dt>
                <dd class='text-default-700'>San Francisco, CA</dd>
              </div>
            </dl>
          </div>
        </Collapsible>
      </div>

      <div class='px-6 py-3 bg-default-50 border-t border-default-200'>
        <Button @size='sm' @appearance='minimal' @onPress={{this.toggleExpand}}>
          {{if this.isExpanded 'Show Less' 'Show More'}}
        </Button>
      </div>
    </div>
  </template>
}
```

### Multiple Independent Panels

Each panel can be controlled independently.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Collapsible, Button } from 'frontile';

export default class MultiplePanels extends Component {
  @tracked isPanelOneOpen = false;
  @tracked isPanelTwoOpen = false;
  @tracked isPanelThreeOpen = false;

  @action togglePanelOne() {
    this.isPanelOneOpen = !this.isPanelOneOpen;
  }

  @action togglePanelTwo() {
    this.isPanelTwoOpen = !this.isPanelTwoOpen;
  }

  @action togglePanelThree() {
    this.isPanelThreeOpen = !this.isPanelThreeOpen;
  }

  <template>
    <div class='max-w-md space-y-4'>
      <div class='border border-default-200 rounded-lg overflow-hidden'>
        <div class='p-4 bg-primary-50 border-b border-default-200'>
          <Button
            @appearance='minimal'
            @class='w-full text-left font-semibold'
            @onPress={{this.togglePanelOne}}
          >
            Features
            <span class='float-right'>{{if this.isPanelOneOpen '▲' '▼'}}</span>
          </Button>
        </div>
        <Collapsible @isOpen={{this.isPanelOneOpen}}>
          <div class='p-4'>
            <ul class='space-y-2 text-default-700'>
              <li>✓ Smooth animations</li>
              <li>✓ Fully customizable</li>
              <li>✓ Accessible by default</li>
            </ul>
          </div>
        </Collapsible>
      </div>

      <div class='border border-default-200 rounded-lg overflow-hidden'>
        <div class='p-4 bg-success-50 border-b border-default-200'>
          <Button
            @appearance='minimal'
            @class='w-full text-left font-semibold'
            @onPress={{this.togglePanelTwo}}
          >
            Pricing
            <span class='float-right'>{{if this.isPanelTwoOpen '▲' '▼'}}</span>
          </Button>
        </div>
        <Collapsible @isOpen={{this.isPanelTwoOpen}}>
          <div class='p-4'>
            <p class='text-default-700'>
              Starting at $9.99/month with a 14-day free trial.
            </p>
          </div>
        </Collapsible>
      </div>

      <div class='border border-default-200 rounded-lg overflow-hidden'>
        <div class='p-4 bg-warning-50 border-b border-default-200'>
          <Button
            @appearance='minimal'
            @class='w-full text-left font-semibold'
            @onPress={{this.togglePanelThree}}
          >
            Support
            <span class='float-right'>{{if
                this.isPanelThreeOpen
                '▲'
                '▼'
              }}</span>
          </Button>
        </div>
        <Collapsible @isOpen={{this.isPanelThreeOpen}}>
          <div class='p-4'>
            <p class='text-default-700'>
              24/7 email support with average response time of 2 hours.
            </p>
          </div>
        </Collapsible>
      </div>
    </div>
  </template>
}
```

### Initially Open

Start with content expanded.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Collapsible, Button } from 'frontile';

export default class InitiallyOpen extends Component {
  @tracked isOpen = true;

  @action toggle() {
    this.isOpen = !this.isOpen;
  }

  <template>
    <div class='max-w-md'>
      <div class='border border-primary-200 rounded-lg overflow-hidden'>
        <div class='p-4 bg-primary-50 border-b border-primary-200'>
          <h3 class='font-semibold'>Welcome Message</h3>
        </div>

        <Collapsible @isOpen={{this.isOpen}}>
          <div class='p-4'>
            <p class='text-default-700 mb-4'>
              Thank you for signing up! Here are some quick tips to get started
              with our platform.
            </p>
            <ul class='space-y-2 text-default-700'>
              <li>→ Complete your profile</li>
              <li>→ Connect your accounts</li>
              <li>→ Explore the dashboard</li>
            </ul>
          </div>
        </Collapsible>

        <div class='px-4 py-3 bg-default-50 border-t border-default-200'>
          <Button @size='sm' @appearance='minimal' @onPress={{this.toggle}}>
            {{if this.isOpen 'Dismiss' 'Show Again'}}
          </Button>
        </div>
      </div>
    </div>
  </template>
}
```

### Nested Collapsibles

Collapsibles can be nested within each other.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Collapsible, Button } from 'frontile';

export default class NestedCollapsibles extends Component {
  @tracked isParentOpen = false;
  @tracked isChildOneOpen = false;
  @tracked isChildTwoOpen = false;

  @action toggleParent() {
    this.isParentOpen = !this.isParentOpen;
  }

  @action toggleChildOne() {
    this.isChildOneOpen = !this.isChildOneOpen;
  }

  @action toggleChildTwo() {
    this.isChildTwoOpen = !this.isChildTwoOpen;
  }

  <template>
    <div class='max-w-md'>
      <div class='border border-default-200 rounded-lg overflow-hidden'>
        <div class='p-4 bg-default-100'>
          <Button
            @appearance='minimal'
            @class='w-full text-left font-semibold'
            @onPress={{this.toggleParent}}
          >
            Category
            <span class='float-right'>{{if this.isParentOpen '▲' '▼'}}</span>
          </Button>
        </div>

        <Collapsible @isOpen={{this.isParentOpen}}>
          <div class='p-4 space-y-2'>
            <div class='border border-default-200 rounded overflow-hidden'>
              <div class='p-3 bg-default-50'>
                <Button
                  @appearance='minimal'
                  @size='sm'
                  @class='w-full text-left'
                  @onPress={{this.toggleChildOne}}
                >
                  Subcategory 1
                  <span class='float-right'>{{if
                      this.isChildOneOpen
                      '−'
                      '+'
                    }}</span>
                </Button>
              </div>
              <Collapsible @isOpen={{this.isChildOneOpen}}>
                <div class='p-3 text-sm text-default-700'>
                  Details for subcategory 1
                </div>
              </Collapsible>
            </div>

            <div class='border border-default-200 rounded overflow-hidden'>
              <div class='p-3 bg-default-50'>
                <Button
                  @appearance='minimal'
                  @size='sm'
                  @class='w-full text-left'
                  @onPress={{this.toggleChildTwo}}
                >
                  Subcategory 2
                  <span class='float-right'>{{if
                      this.isChildTwoOpen
                      '−'
                      '+'
                    }}</span>
                </Button>
              </div>
              <Collapsible @isOpen={{this.isChildTwoOpen}}>
                <div class='p-3 text-sm text-default-700'>
                  Details for subcategory 2
                </div>
              </Collapsible>
            </div>
          </div>
        </Collapsible>
      </div>
    </div>
  </template>
}
```

## Important Notes

### Animation Behavior

The Collapsible component animates both height and opacity:

- **Expanding**: Height and opacity transition smoothly to full size over 0.4s
- **Collapsing**: Height and opacity transition to collapsed state over 0.2-0.3s
- **Easing**: Uses cubic-bezier easing for smooth, natural motion

After expansion completes, the height is set to `auto` and overflow is reset to allow dynamic content changes.

### Initial Height

When using `@initialHeight`:

- Content is always visible up to the specified height, even when collapsed
- Opacity remains at `1` when collapsed (instead of fading to `0`)
- Useful for "Read More" patterns and content previews
- Remember to include units (`px`, `rem`, `em`, etc.)

### State Management

The component is **fully controlled**:

- You must manage the `@isOpen` state in your parent component
- Toggle the state with your own button or trigger
- This gives you complete control over when and how the collapsible opens

### Styling

The component is **unstyled** by default:

- Apply your own classes and styles to the content wrapper
- Style the trigger button however you need
- Works with any CSS framework or custom styles
- The component only manages height and opacity transitions

### Accessibility

When building collapsible UIs, remember to:

- Use semantic HTML (buttons for triggers)
- Add `aria-expanded` to toggle buttons
- Add `aria-controls` linking trigger to content
- Consider `aria-labelledby` for the content region
- Use proper heading hierarchy for accordion items

Example accessible pattern:

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

### Testing

The component includes built-in test waiters:

- Transitions are properly tracked for test stability
- Use `await settled()` in tests to wait for animations
- The component waits for height and opacity transitions to complete

## API

<Signature @package="utilities" @component="Collapsible" />
