import Component from '@glimmer/component';
import { action } from '@ember/object';
import { inject as service } from '@ember/service';
import { NotificationsService, Notification, CustomAction } from '../.';

interface NotificationCardArgs {
  notification: Notification;
}

export default class NotificationCard extends Component<NotificationCardArgs> {
  @service notifications!: NotificationsService;

  @action remove(): void {
    this.notifications.remove(this.args.notification);
  }

  @action pause(): void {
    if (this.args.notification.timer) {
      this.args.notification.timer.pause();
    }
  }

  @action resume(): void {
    if (this.args.notification.timer) {
      this.args.notification.timer.resume();
    }
  }

  @action handleClickCustomAction(customAction: CustomAction): void {
    customAction.onClick();
    this.remove();
  }
}
