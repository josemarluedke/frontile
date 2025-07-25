import Component from '@glimmer/component';
import { service } from '@ember/service';
import { modifier } from 'ember-modifier';
import NotificationCard from './notification-card';
import type NotificationsService from '../services/notifications';
import type Notification from '../-private/notification';
import { type containerPlacement } from '../-private/types';
import { useStyles } from '@frontile/theme';

interface NotificationsContainerSignature {
  Args: {
    /**
     * The placement of the notifications
     *
     * @defaultValue 'bottom-right'
     */
    placement?: containerPlacement;
    /**
     * Spacing for each notification, in px.
     *
     * @defaultValue 16
     */
    spacing?: number;

    /**
     * Custom class name, it will override the default ones using Tailwind Merge library.
     */
    class?: string;
  };
  Element: HTMLDivElement;
}

class NotificationsContainer extends Component<NotificationsContainerSignature> {
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

  get classes() {
    const { notificationsContainer } = useStyles();

    return notificationsContainer({
      placement: this.args.placement,
      class: this.args.class
    });
  }

  setupSpacing = modifier((element: HTMLElement) => {
    const spacing =
      typeof this.args.spacing === 'undefined' ? 16 : this.args.spacing;
    if (this.isTopPlacement) {
      element.style.marginTop = `${spacing}px`;
    }
  });

  <template>
    {{#if this.sortedNotifications}}
      <div
        {{this.setupSpacing @spacing @placement}}
        class={{this.classes}}
        role="alert"
        aria-live="assertive"
        aria-atomic="true"
        ...attributes
      >
        {{#each this.sortedNotifications as |notification|}}
          <NotificationCard
            @spacing={{@spacing}}
            @placement={{if @placement @placement "bottom-right"}}
            @notification={{notification}}
          />
        {{/each}}
      </div>
    {{/if}}
  </template>
}

export { NotificationsContainer, type NotificationsContainerSignature };
export default NotificationsContainer;
