---
order: 1
---
# Usage

Basic Modal usage.

```hbs template
<Button
  {{on "click" this.toggle}}
>
  Open Modal
</Button>

<Modal
  @isOpen={{this.isOpen}}
  @onClose={{this.toggle}}
  as |m|
>
  <m.Header>Title</m.Header>
  <m.Body>
    <p>Some contents...</p>
    <p>Some contents...</p>
    <p>Some contents...</p>
  </m.Body>
  <m.Footer>
    <Button
      @appearance="minimal"
      class="mr-4"
      {{on "click" this.toggle}}
    >
      Cancel
    </Button>
    <Button
      @intent="primary"
      disabled={{this.isLoading}}
      {{on "click" this.save}}
    >
      {{if this.isLoading "Loading..." "Save"}}
    </Button>
  </m.Footer>
</Modal>
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

  @action save() {
    this.isLoading = true;

    later(
      this,
      () => {
        this.isLoading = false;
        this.isOpen = false;
      },
      1000
    );
  }
}
```
