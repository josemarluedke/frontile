import Notification from './notification';
import Timer from './timer';
import { NotificationOptions } from './types';
import { getConfigOption } from './get-config';
import { tracked } from '@glimmer/tracking';
import { later } from '@ember/runloop';
import Evented from './evented';

export default class NotificationsManager extends Evented {
  @tracked notifications: Notification[] = [];

  add(message: string, options: NotificationOptions = {}): Notification {
    const notification = new Notification(message, options);
    this.notifications = [...this.notifications, notification];

    let preserve =
      typeof options.preserve === 'undefined'
        ? getConfigOption('preserve', false)
        : options.preserve;

    // if default config has set skipTimer to true, we will preserve the
    // notification, therefore skiping the timer
    if (getConfigOption('skipTimer', false) === true) {
      preserve = true;
    }

    if (preserve === false) {
      this.setupAutoRemoval(notification, notification.duration);
    }

    this.trigger('add', notification);
    return notification;
  }

  remove(notification?: Notification): void {
    if (!notification) {
      return;
    }

    notification.remove();

    later(
      this,
      () => {
        this.notifications = this.notifications.filter((n) => {
          return n !== notification;
        });
      },
      notification.transitionDuration
    );
    this.trigger('remove', notification);
  }

  removeAll(): void {
    this.notifications.forEach((notification) => {
      this.remove(notification);
    });
  }

  private setupAutoRemoval(notification: Notification, duration: number): void {
    notification.timer = new Timer(duration, () => {
      this.remove(notification);
    });
  }
}
