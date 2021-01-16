---
order: 1
---
# Usage

```hbs template
<Button
  {{on "click" this.toggle}}
>
  Open Overlay
</Button>

<Overlay
  @isOpen={{this.isOpen}}
  @onClose={{this.toggle}}
  as |m|
>
  <div class="bg-white p-8">
    <p>Some contents...</p>
    <p>Some contents...</p>
    <p>Some contents...</p>
    <Button {{on "click" this.toggle}}>Close</Button>
  </div>
</Overlay>
```

```js component
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { later } from '@ember/runloop';

export default class DemoModal extends Component {
  @tracked isOpen = false;
  @tracked isLoading = false;

  @action toggle() {
    this.isOpen = !this.isOpen;
  }
}
```
