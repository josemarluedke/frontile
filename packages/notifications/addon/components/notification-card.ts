import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { inject as service } from '@ember/service';
import { htmlSafe } from '@ember/string';
import { NotificationsService, Notification, CustomAction } from '../.';
import { later } from '@ember/runloop';
import { NotificationsContainerArgs } from './notifications-container';

interface NotificationCardArgs {
  notification: Notification;
  placement: NotificationsContainerArgs['placement'];

  /*
   * Spacing for each notification, in px.
   * Only applied in bottom placement
   * @defaultValue 16
   */
  spacing?: number;
}

export default class NotificationCard extends Component<NotificationCardArgs> {
  @service notifications!: NotificationsService;
  @tracked hasEntered = false;

  get styles(): unknown {
    return htmlSafe(
      `transition-duration: ${this.args.notification.transitionDuration}ms`
    );
  }

  @action transitionIn(element: HTMLElement): void {
    let spacing =
      typeof this.args.spacing === 'undefined' ? 16 : this.args.spacing;

    if ((this.args.placement || '').includes('top')) {
      spacing = 0;
    }

    const expectedHeight = element.offsetHeight + spacing;
    const duration = this.args.notification.transitionDuration / 2;

    requestAnimationFrame(() => {
      element.style.height = '0';
      const transition = `height ${duration}ms ease-in ${duration}ms`;
      element.style.transition = transition;

      requestAnimationFrame(() => {
        element.style.height = `${expectedHeight}px`;
      });
    });

    later(
      this,
      () => {
        this.hasEntered = true;
      },
      this.args.notification.transitionDuration
    );
  }

  @action transitionOut(
    element: HTMLElement,
    [isExiting, ..._]: boolean[]
  ): void {
    if (isExiting) {
      element.style.height = '0';
    }
  }

  @action remove(): void {
    this.notifications.remove(this.args.notification);
  }

  @action pause(): void {
    if (this.args.notification.timer) {
      this.args.notification.timer.pause();
    }
  }

  @action resume(): void {
    if (this.args.notification.timer) {
      this.args.notification.timer.resume();
    }
  }

  @action handleClickCustomAction(customAction: CustomAction): void {
    customAction.onClick();
    this.remove();
  }
}
