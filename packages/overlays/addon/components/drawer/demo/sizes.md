---
order: 2
---
# Sizes

Use the `size` argument to set the desired Drawer size.

```hbs template
{{#each this.sizes as |size|}}
  <Button
    {{on "click" (fn this.toggle size)}}
  >
    Open {{size}}
  </Button>
{{/each}}

<Drawer
  @isOpen={{this.isOpen}}
  @size={{this.size}}
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
  sizes = ['xs', 'sm', 'md', 'lg', 'xl', 'full'];

  @tracked isOpen = false;
  @tracked size;

  @action toggle(size) {
    this.isOpen = !this.isOpen;
    this.size = size;
  }
}
```
