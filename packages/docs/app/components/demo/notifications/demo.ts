// BEGIN-SNIPPET demo-notifications.ts
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

  @tracked placement = 'bottom-right';

  @tracked customActions: NotificationOptions['customActions'] = [
    {
      label: 'Ok',
      onClick: (): void => {
        // empty
      }
    },
    {
      label: 'Undo',
      onClick: (): void => {
        // empty
      }
    },
    {
      label: 'Cancel',
      onClick: (): void => {
        // empty
      }
    }
  ];

  @action setPlacement(placement: string): void {
    this.placement = placement;
  }

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

  @action addNotification(): void {
    this.notifications.add(
      'Sed diam nonumy eirmod tempor invidunt ut labore et dolore magna.',
      this.options
    );
  }
}
// END-SNIPPET
