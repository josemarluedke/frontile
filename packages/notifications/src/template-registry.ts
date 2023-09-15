import type NotificationCard from './components/notification-card';
import type NotificationsContainer from './components/notifications-container';

export default interface Registry {
  NotificationCard: typeof NotificationCard;
  NotificationsContainer: typeof NotificationsContainer;
}
