---
order: 4
---
# Combining Placement and Size

As an composition example, you can set the Drawer to a given placement and size at the same time.

```hbs template
<FormRadioGroup
  @isInline={{true}}
  @label="Placement"
  @value={{this.placement}}
  @onChange={{this.setPlacement}}
  as |Radio|
>
  {{#each this.placements as |placement|}}
    <Radio @value={{placement}} @label={{placement}} />
  {{/each}}
</FormRadioGroup>

<FormRadioGroup
  @containerClass="mt-2"
  @isInline={{true}}
  @label="Size"
  @value={{this.size}}
  @onChange={{this.setSize}}
  as |Radio|
>
  {{#each this.sizes as |size|}}
    <Radio @value={{size}} @label={{size}} />
  {{/each}}
</FormRadioGroup>

<Button
  class="mt-6"
  {{on "click" this.toggle}}
>
  Open Drawer
</Button>

<Drawer
  @isOpen={{this.isOpen}}
  @placement={{this.placement}}
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
  placements = ['top', 'bottom', 'left', 'right'];
  sizes = ['xs', 'sm', 'md', 'lg', 'xl', 'full'];

  @tracked isOpen = false;
  @tracked placement = 'right';
  @tracked size = 'md';

  @action toggle() {
    this.isOpen = !this.isOpen;
  }

  @action setPlacement(placement) {
    this.placement = placement;
  }

  @action setSize(size) {
    this.size = size;
  }
}
```
