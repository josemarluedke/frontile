---
imports:
  - import Signature from 'site/components/signature';
---
# Collapsible

This component provides unstyled collapsible ability.

## Import 
```js
import { Collapsible } from 'frontile';
```
## Usage


```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { Collapsible } from 'frontile';

export default class CollapsibleDemo extends Component {
  @tracked isOpen = false;

  @action toggle() {
    this.isOpen = !this.isOpen;
  }

  <template>
    <div class="max-w-md">
      <button
        type="button"
        class="px-4 py-2 text-teal-600 border border-teal-600 rounded hover:bg-teal-700 hover:text-white"
        {{on "click" this.toggle}}
      >
        Collapse
      </button>

      <Collapsible @isOpen={{this.isOpen}}>
        <div class="p-8 mt-4 text-white bg-teal-800 rounded">
          Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse
          malesuada lacus ex, sit amet blandit leo lobortis eget. Lorem ipsum
          dolor sit amet, consectetur adipiscing elit. Suspendisse malesuada
          lacus ex, sit amet blandit leo lobortis eget.
        </div>
      </Collapsible>
    </div>
  </template>
}
```

## Specifying Initial Height

You can use the `initialHeight` argument to set the initial height of the content.
The content will be displayed up to the specified height even when Collapsible is closed.

> Include unit of the value. For example, `px`, `rem`, etc.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { Collapsible } from 'frontile';

export default class CollapsibleDemo extends Component {
  @tracked isOpen = false;

  @action toggle() {
    this.isOpen = !this.isOpen;
  }

  <template>
    <div class="max-w-md">
      <Collapsible @isOpen={{this.isOpen}} @initialHeight="22px">
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse
        malesuada lacus ex, sit amet blandit leo lobortis eget. Lorem ipsum
        dolor sit amet, consectetur adipiscing elit. Suspendisse malesuada lacus
        ex, sit amet blandit leo lobortis eget.
      </Collapsible>
      <button
        type="button"
        class="mt-2 px-2 py-1 text-sm text-teal-600 border border-teal-600 rounded hover:bg-teal-700 hover:text-white"
        {{on "click" this.toggle}}
      >
        See more
      </button>
    </div>
  </template>
}
```

## API

<Signature @package="utilities" @component="Collapsible" />
