import { deprecate } from '@ember/debug';

deprecate(
  'Importing from "@frontile/notifications" is deprecated. ' +
  'Import from "frontile" or "frontile/notifications" instead. ' +
  'See https://frontile.dev/docs/migrations/v0.18/package-consolidation',
  false,
  {
    id: 'frontile.import-from-notifications',
    until: '0.19.0',
    for: 'frontile',
    since: { available: '0.18.0', enabled: '0.18.0' },
    url: 'https://frontile.dev/docs/migrations/v0.18/package-consolidation'
  }
);

export {
  NotificationsContainer,
  NotificationCard,
  type NotificationsContainerSignature,
  type NotificationCardSignature,
  type NotificationsService,
  Notification,
  Timer,
  type NotificationOptions,
  type DefaultConfig,
  type CustomAction
} from 'frontile/notifications';
