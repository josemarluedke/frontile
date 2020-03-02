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
  @tracked options: NotificationOptions = {
    appearance: 'info',
    preserve: false,
    duration: 5000,
    allowClosing: true
  };

  @tracked customActions: NotificationOptions['customActions'] = [
    {
      label: 'Ok',
      onClick: () => {
        // empty
      }
    },
    {
      label: 'Undo',
      onClick: () => {
        // empty
      }
    },
    {
      label: 'Cancel',
      onClick: () => {
        // empty
      }
    }
  ];

  @action setValue<T extends keyof NotificationOptions>(
    key: T,
    value: NotificationOptions[T]
  ): void {
    const options = {
      ...this.options,
      [key]: value
    };
    this.options = options;
  }

  @action addNotification() {
    this.notifications.add(
      'sed diam nonumy eirmod tempor invidunt ut labore et dolore magna',
      this.options
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
