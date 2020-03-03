import Notification from './notification';
import Timer from './timer';
import { tracked } from '@glimmer/tracking';
import { later } from '@ember/runloop';
import { NotificationOptions } from './types';

export default class NotificationsManager {
  @tracked notifications: Notification[] = [];

  add(message: string, options: NotificationOptions = {}): Notification {
    const notification = new Notification(message, options);
    this.notifications = [...this.notifications, notification];

    if (options.preserve !== true) {
      this.setupAutoRemoval(notification, notification.duration);
    }
    return notification;
  }

  remove(notification?: Notification): void {
    if (!notification) {
      return;
    }

    notification.isRemoving = true;

    later(
      this,
      () => {
        this.notifications = this.notifications.filter(n => {
          return n !== notification;
        });
      },
      notification.transitionDuration
    );
  }

  removeAll(): void {
    this.notifications.forEach(notification => {
      this.remove(notification);
    });
  }

  private setupAutoRemoval(notification: Notification, duration: number): void {
    notification.timer = new Timer(duration, () => {
      this.remove(notification);
    });
  }
}
