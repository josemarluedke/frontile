/* eslint-disable ember/no-runloop */
import Notification from './notification';
import Timer from './timer';
import { tracked } from '@glimmer/tracking';
import { assert } from '@ember/debug';
import { getConfigOption } from './get-config';
import { getOwner } from '@ember/owner';
import { isDestroyed } from '@ember/destroyable';
import { later } from '@ember/runloop';
import type Owner from '@ember/owner';
import type { DefaultConfig } from './types';
import type { NotificationOptions } from './types';

export default class NotificationsManager {
  @tracked notifications: Notification<Record<string, unknown>>[] = [];

  config: DefaultConfig = {};
  onRemove?: (notification: Notification<Record<string, unknown>>) => void;

  constructor(
    context: object,
    onRemove?: (notification: Notification<Record<string, unknown>>) => void
  ) {
    if (isDestroyed(context)) {
      return;
    }
    const owner = getOwner(context) as Owner;
    assert('NotificationsManager context must have an owner', owner);
    const configFactory = owner.factoryFor('config:environment');

    if (configFactory && configFactory.class) {
      this.config =
        (configFactory.class as never)['@frontile/notifications'] || {};
    }

    this.onRemove = onRemove;
  }

  add<TMetadata extends Record<string, unknown> = Record<string, unknown>>(
    message: string,
    options: NotificationOptions<TMetadata> = {}
  ): Notification<TMetadata> {
    const notification = new Notification<TMetadata>(
      this.config,
      message,
      options
    );
    this.notifications = [...this.notifications, notification];

    let preserve =
      typeof options.preserve === 'undefined'
        ? getConfigOption(this.config, 'preserve', false)
        : options.preserve;

    // if default config has set skipTimer to true, we will preserve the
    // notification, therefore skiping the timer
    if (getConfigOption(this.config, 'skipTimer', false) === true) {
      preserve = true;
    }

    if (preserve === false) {
      this.setupAutoRemoval(notification, notification.duration);
    }
    return notification;
  }

  remove(notification?: Notification<Record<string, unknown>>): void {
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

        // Call the onRemove callback after the notification is actually removed
        if (this.onRemove) {
          this.onRemove(notification);
        }
      },
      notification.transitionDuration
    );
  }

  removeAll(): void {
    this.notifications.forEach((notification) => {
      this.remove(notification);
    });
  }

  private setupAutoRemoval(
    notification: Notification<Record<string, unknown>>,
    duration: number
  ): void {
    notification.timer = new Timer(duration, () => {
      this.remove(notification);
    });
  }
}
