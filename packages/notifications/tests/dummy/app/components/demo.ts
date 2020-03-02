import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { inject as service } from '@ember/service';
import { action } from '@ember/object';
import {
  NotificationOptions,
  NotificationsService
} from '@frontile/notifications';

interface DemoArgs {}

export default class Demo extends Component<DemoArgs> {
  @service notifications!: NotificationsService;
  @tracked appearance: NotificationOptions['appearance'] = 'info';

  @action setAppearance(value: NotificationOptions['appearance']): void {
    this.appearance = value;
  }

  @action addSimple() {
    this.notifications.add(
      'sed diam nonumy eirmod tempor invidunt ut labore et dolore magna',
      { appearance: this.appearance }
    );
  }

  @action addPreserve() {
    this.notifications.add(
      'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua',
      { appearance: this.appearance, preserve: true }
    );
  }

  @action addWithAction() {
    this.notifications.add('Conversation arquived.', {
      appearance: this.appearance,
      preserve: true,
      allowClosing: true,
      customActions: [
        {
          label: 'Undo',
          onClick: () => {
            // empty
          }
        }
      ]
    });
  }
}
