import Service from '@ember/service';
import Notification from '../-private/notification';
import NotificationsManager from '../-private/manager';
import type { NotificationOptions } from '../-private/types';

export default class NotificationsService extends Service {
  manager = new NotificationsManager();

  get notifications(): Notification[] {
    return this.manager.notifications;
  }

  add = (message: string, options?: NotificationOptions): Notification => {
    return this.manager.add(message, options);
  };

  remove = (notification?: Notification): void => {
    this.manager.remove(notification);
  };

  removeAll = (): void => {
    this.manager.removeAll();
  };

  willDestroy(): void {
    this.removeAll();
    super.willDestroy();
  }
}

// DO NOT DELETE: this is how TypeScript knows how to look up your services.
declare module '@ember/service' {
  interface Registry {
    notifications: NotificationsService;
  }
}
