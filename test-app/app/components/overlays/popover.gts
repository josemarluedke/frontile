import Component from '@glimmer/component';
import { Popover } from '@frontile/overlays';
import { Button } from '@frontile/buttons';

export default class Example extends Component {
  <template>
    <Popover as |pop|>
      <Button {{pop.trigger}} {{pop.anchor}}>
        Toggle Popover
      </Button>

      <pop.Content @class="p-4">
        This is some example content for the popover. Check the nested popover
        by clicking the button below.

        <Popover @placement="right" as |p2|>
          <Button {{p2.trigger}} {{p2.anchor}} @class="mt-2">
            Second Popover
          </Button>

          <p2.Content @class="p-4">
            <p>
              More content here, the nested overlay.
            </p>
            <p class="mt-2">
              Clicking outside will close this Popover, and not the root
              Popover.
            </p>
          </p2.Content>
        </Popover>
      </pop.Content>
    </Popover>
  </template>
}
