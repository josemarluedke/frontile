import type { NotificationCard, NotificationsContainer } from './index';

export default interface Registry {
  NotificationCard: typeof NotificationCard;
  NotificationsContainer: typeof NotificationsContainer;
}
