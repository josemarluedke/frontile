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
import type {
  DefaultConfig,
  NotificationOptions,
  NotificationContent,
  NotificationIntent,
  PromiseMessage,
  PromiseNotificationOptions
} from './types';

function resolveMessage<T>(
  message: PromiseMessage<T>,
  value: T
): NotificationContent {
  const resolved = typeof message === 'function' ? message(value) : message;
  return typeof resolved === 'string' ? { title: resolved } : resolved;
}

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
    content: string | NotificationContent,
    options: NotificationOptions<TMetadata> = {}
  ): Notification<TMetadata> {
    const notification = new Notification<TMetadata>(
      this.config,
      content,
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

  /**
   * Show a notification driven by a promise: a spinner while pending, then
   * the same notification mutated in place once it settles.
   *
   * Returns the original promise, so callers can still await it — and are
   * still responsible for handling its rejection.
   */
  promise<
    T,
    TMetadata extends Record<string, unknown> = Record<string, unknown>
  >(
    promise: Promise<T>,
    options: PromiseNotificationOptions<T, TMetadata>
  ): Promise<T> {
    const { loading, success, error, ...rest } = options;

    const notification = this.add<TMetadata>(loading, {
      ...(rest as NotificationOptions<TMetadata>),
      preserve: true,
      allowClosing: false,
      isLoading: true
    });

    const settle = (
      content: NotificationContent,
      intent: NotificationIntent
    ) => {
      // The user may have dismissed the toast before the promise settled; in
      // that case there is nothing left to update.
      if (notification.isRemoving) {
        return;
      }

      notification.update({
        ...content,
        intent,
        allowClosing: true,
        isLoading: false
      });

      // `preserve: true` forces the loading phase to skip auto-dismissal
      // (there's nothing useful to time out on a spinner), but the docs
      // promise every option except `isLoading` carries through to the
      // settled notification — so a caller's own `preserve` must still be
      // honored here, not silently overridden by the loading phase's.
      const preserve =
        typeof rest.preserve === 'undefined'
          ? getConfigOption(this.config, 'preserve', false)
          : rest.preserve;

      if (
        preserve !== true &&
        getConfigOption(this.config, 'skipTimer', false) !== true
      ) {
        this.setupAutoRemoval(notification, notification.duration);
      }
    };

    promise.then(
      (value) => settle(resolveMessage(success, value), 'success'),
      (reason) => settle(resolveMessage(error, reason), 'danger')
    );

    return promise;
  }

  remove(notification?: Notification<Record<string, unknown>>): void {
    // Removal is single-shot: a notification already on its way out must not
    // schedule a second removal, otherwise `onRemove` is called twice for it.
    if (!notification || notification.isRemoving) {
      return;
    }

    notification.remove();

    // The unmount is timed to `transitionDuration` (default 200ms), which
    // governs the card's exit *opacity* fade. The exit *slide/scale*
    // transform, however, runs at a fixed 400ms (see notificationCard's
    // theme slots) independent of `transitionDuration`. At the defaults this
    // is invisible only because the opacity reaches 0 at the same moment the
    // card unmounts, hiding the fact that the slide is truncated mid-flight.
    // If the opacity duration is ever decoupled from this unmount timer (or
    // `transitionDuration` is changed without also revisiting the transform
    // duration), cards will visibly disappear mid-slide instead of fading
    // out cleanly. Keep the two in sync, or make the unmount wait for the
    // longer of the two durations.
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
