```hbs template
<div class="max-w-md">
  <button
    type="button"
    class="px-4 py-2 text-teal-600 border border-teal-600 rounded hover:bg-teal-700 hover:text-white"
    {{on "click" this.toggle}}
  >
    Collapse
  </button>

  <Collapsible
    @isOpen={{this.isOpen}}
  >
    <div
      class="p-8 mt-4 text-white bg-teal-800 rounded"
    >
      Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse malesuada lacus ex, sit amet blandit leo lobortis eget. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse malesuada lacus ex, sit amet blandit leo lobortis eget.
    </div>
  </Collapsible>
</div>
```

```js component
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';

export default class CollapsibleDemo extends Component {
  @tracked isOpen = false;

  @action toggle() {
    this.isOpen = !this.isOpen;
  }
}
```
