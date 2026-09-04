import Service from '@ember/service';
import Notification from '../-private/notification';
import NotificationsManager from '../-private/manager';
import type {
  NotificationOptions,
  NotificationContent,
  PromiseNotificationOptions
} from '../-private/types';

export default class NotificationsService extends Service {
  onRemoveCallback?: (
    notification: Notification<Record<string, unknown>>
  ) => void;

  manager = new NotificationsManager(this, (notification) => {
    if (this.onRemoveCallback) {
      this.onRemoveCallback(notification);
    }
  });

  get notifications(): Notification<Record<string, unknown>>[] {
    return this.manager.notifications;
  }

  add = <TMetadata extends Record<string, unknown> = Record<string, unknown>>(
    content: string | NotificationContent,
    options?: NotificationOptions<TMetadata>
  ): Notification<TMetadata> => {
    return this.manager.add<TMetadata>(content, options);
  };

  promise = <
    T,
    TMetadata extends Record<string, unknown> = Record<string, unknown>
  >(
    promise: Promise<T>,
    options: PromiseNotificationOptions<T, TMetadata>
  ): Promise<T> => {
    return this.manager.promise<T, TMetadata>(promise, options);
  };

  remove = (notification?: Notification<Record<string, unknown>>): void => {
    this.manager.remove(notification);
  };

  removeAll = (): void => {
    this.manager.removeAll();
  };

  setOnRemoveCallback = (
    callback?: (notification: Notification<Record<string, unknown>>) => void
  ): void => {
    this.onRemoveCallback = callback;
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
