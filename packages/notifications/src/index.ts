import Notification from './-private/notification';
import Timer from './-private/timer';
import NotificationsService from './services/notifications';
import type {
  DefaultConfig,
  NotificationOptions,
  CustomAction
} from './-private/types';

export { Notification, Timer };
export type { NotificationsService };
export type { NotificationOptions, DefaultConfig, CustomAction };
export * from './components/notification-card';
export * from './components/notifications-container';
