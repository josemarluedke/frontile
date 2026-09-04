import Component from '@glimmer/component';
import { service } from '@ember/service';
import { modifier } from 'ember-modifier';
import { registerDestructor } from '@ember/destroyable';
import NotificationCard from './notification-card';
import type NotificationsService from '../../services/notifications';
import type Notification from '../../-private/notification';
import { type containerPlacement } from '../../-private/types';
import { useStyles } from '@frontile/theme';
import type Owner from '@ember/owner';

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

    /**
     * Callback called when a notification is dismissed
     */
    onDismiss?: (notification: Notification<Record<string, unknown>>) => void;
  };
  Element: HTMLDivElement;
}

class NotificationsContainer extends Component<NotificationsContainerSignature> {
  @service notifications!: NotificationsService;

  constructor(owner: Owner, args: NotificationsContainerSignature['Args']) {
    super(owner, args);

    // Register a stable callback that delegates to the current `@onDismiss`,
    // so a change to the argument is picked up without re-registering.
    this.notifications.setOnRemoveCallback(this.handleDismiss);

    // Clean up when component is destroyed, but only if we are still the
    // registered owner: the service holds a single callback slot, so another
    // container might have taken it over in the meantime.
    registerDestructor(this, () => {
      if (this.notifications.onRemoveCallback === this.handleDismiss) {
        this.notifications.setOnRemoveCallback(undefined);
      }
    });
  }

  handleDismiss = (notification: Notification<Record<string, unknown>>) => {
    this.args.onDismiss?.(notification);
  };

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

    // Always assign, so switching from a top to a bottom placement does not
    // leave a stale margin behind.
    element.style.marginTop = this.isTopPlacement ? `${spacing}px` : '';

    return () => {
      element.style.marginTop = '';
    };
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
