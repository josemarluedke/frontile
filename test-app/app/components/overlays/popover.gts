import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { Popover, Portal } from '@frontile/overlays';
import { Divider } from '@frontile/utilities';
import { Button } from '@frontile/buttons';

export default class Example extends Component {
  @tracked isOpen = false;

  onOpenChange = (isOpen: boolean) => {
    this.isOpen = isOpen;
  };

  open = () => {
    this.isOpen = true;
  };

  close = () => {
    this.isOpen = false;
  };

  <template>
    <Button {{on "click" this.open}}>Open</Button>
    <Divider class="my-4" />

    <Popover
      @isOpen={{this.isOpen}}
      @onOpenChange={{this.onOpenChange}}
      as |pop|
    >
      <Button {{pop.trigger}} {{pop.anchor}}>
        Toggle Popover
      </Button>

      <pop.Content @class="p-4">
        This is some example content for the popover. Check the nested popover
        by clicking the button below.

        <Button {{on "click" this.close}}>Close Popover</Button>
      </pop.Content>
    </Popover>

    <Portal class="absolute w-content bg-default left-10">
      First portal
      <Portal class="absolute w-content bg-primary left-12">
        Second portal
        <Portal class="absolute w-content bg-danger left-14">
          Last portal
        </Portal>
      </Portal>
    </Portal>
  </template>
}
