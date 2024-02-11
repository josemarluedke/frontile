import Component from '@glimmer/component';
import { Popover } from '@frontile/overlays';

export default class Example extends Component {
  <template>
    <Popover as |p|>
      <button {{p.trigger}} {{p.anchor}}>
        Trigger
      </button>

      <p.Content>
        Content here
      </p.Content>
    </Popover>
  </template>
}
