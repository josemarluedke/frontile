import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import NotificationsService from '../services/notifications';
import { action } from '@ember/object';
import { Notification } from '../';

export interface NotificationsContainerArgs {
  /**
   * The placement of the notifications
   *
   * @defaultValue 'bottom-right'
   */
  placement?:
    | 'top-left'
    | 'top-center'
    | 'top-right'
    | 'bottom-left'
    | 'bottom-center'
    | 'bottom-right';

  /**
   * Spacing for each notification, in px.
   *
   * @defaultValue 16
   */
  spacing?: number;
}

export default class NotificationsContainer extends Component<NotificationsContainerArgs> {
  @service notifications!: NotificationsService;

  get isTopPlacement(): boolean {
    return !!(this.args.placement && this.args.placement.includes('top'));
  }

  get sortedNotifications(): Notification[] {
    if (this.isTopPlacement) {
      return this.notifications.notifications.slice().reverse();
    } else {
      return this.notifications.notifications;
    }
  }

  @action addSpacing(element: HTMLElement): void {
    const spacing =
      typeof this.args.spacing === 'undefined' ? 16 : this.args.spacing;
    if (this.isTopPlacement) {
      element.style.marginTop = `${spacing}px`;
    }
  }
}
