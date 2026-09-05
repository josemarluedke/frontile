import Notification from '../../-private/notification';
import Timer from '../../-private/timer';
import NotificationsService from '../../services/notifications';
import type {
  DefaultConfig,
  NotificationOptions,
  NotificationContent,
  NotificationIntent,
  NotificationAppearance,
  NotificationUpdate,
  CustomAction,
  PromiseMessage,
  PromiseNotificationOptions
} from '../../-private/types';
import { NotificationStack } from '../../-private/notification-stack';
import type { NotificationStackInput } from '../../-private/notification-stack';

// `NotificationStack` and its input type are exported for test ergonomics —
// the unit test at test-app/tests/unit/notifications/notification-stack-test.ts
// exercises the stack geometry math directly, and this package's build
// doesn't expose a `-private` subpath for tests to reach around it. Nothing
// consumer-facing needs these; treat them as internal even though they're
// public exports. `CardGeometry` isn't re-exported here — nothing outside
// `-private` needs it, since the card args that carry it (`@geometry`,
// `@onMeasure`) are themselves `@internal`.
export { Notification, Timer, NotificationStack };
export type { NotificationsService };
export type {
  NotificationOptions,
  DefaultConfig,
  CustomAction,
  NotificationContent,
  NotificationIntent,
  NotificationAppearance,
  NotificationUpdate,
  PromiseMessage,
  PromiseNotificationOptions
};
export type { NotificationStackInput };
export * from './notification-card';
export * from './notifications-container';
