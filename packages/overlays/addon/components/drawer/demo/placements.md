---
order: 3
---
# Placements

Use the `placement` argument to set the desired Drawer placement.

```hbs template
{{#each this.placements as |placement|}}
  <Button
    {{on "click" (fn this.toggle placement)}}
  >
    Open {{placement}}
  </Button>
{{/each}}

<Drawer
  @isOpen={{this.isOpen}}
  @placement={{this.placement}}
  @onClose={{this.toggle}}
  as |m|
>
  <m.Header>Title</m.Header>
  <m.Body>
    <p>
      Sit nulla est ex deserunt exercitation anim occaecat. Nostrud ullamco deserunt aute id consequat veniam incididunt duis in sint irure nisi. Mollit officia cillum Lorem ullamco minim nostrud elit officia tempor esse quis.
    </p>
    <p>
      Sunt ad dolore quis aute consequat. Magna exercitation reprehenderit magna aute tempor cupidatat consequat elit dolor adipisicing. Mollit dolor eiusmod sunt ex incididunt cillum quis. Velit duis sit officia eiusmod Lorem aliqua enim laboris do dolor eiusmod. Et mollit incididunt nisi consectetur esse laborum eiusmod pariatur proident Lorem eiusmod et. Culpa deserunt nostrud ad veniam.
    </p>
  </m.Body>
  <m.Footer>
    <Button
      class="mr-4"
      {{on "click" this.toggle}}
    >
      Close
    </Button>
  </m.Footer>
</Drawer>
```

```js component
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';

export default class Demo extends Component {
  placements = ['top', 'bottom', 'left', 'right'];

  @tracked isOpen = false;
  @tracked placement;

  @action toggle(placement) {
    this.isOpen = !this.isOpen;
    this.placement = placement;
  }
}
```
