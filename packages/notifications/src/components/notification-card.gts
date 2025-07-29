/* eslint-disable ember/no-runloop */
import Component from '@glimmer/component';
import { modifier } from 'ember-modifier';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import { htmlSafe } from '@ember/template';
import { later } from '@ember/runloop';
import { on } from '@ember/modifier';
import { fn, concat } from '@ember/helper';
import { CloseButton } from '@frontile/buttons';
import { cssTransition } from 'ember-css-transitions';
import { useStyles } from '@frontile/theme';

import type NotificationsService from '../services/notifications';
import type Notification from '../-private/notification';
import type { CustomAction, containerPlacement } from '../-private/types';

interface NotificationCardSignature {
  Args: {
    notification: Notification;
    placement: containerPlacement;

    /**
     * Spacing for each notification, in px.
     *
     * @defaultValue 16
     */
    spacing?: number;
  };
  Element: HTMLDivElement;
}

class NotificationCard extends Component<NotificationCardSignature> {
  @service notifications!: NotificationsService;
  @tracked hasEntered = false;

  get styles(): unknown {
    const styles = [
      `transition-duration: ${this.args.notification.transitionDuration}ms`
    ];

    if (!this.hasEntered) {
      styles.push(
        `transition-delay: ${this.args.notification.transitionDuration}ms`
      );
    }

    return htmlSafe(styles.join('; '));
  }

  transitionIn = modifier((element: HTMLElement) => {
    const spacing =
      typeof this.args.spacing === 'undefined' ? 16 : this.args.spacing;
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
  });

  transitionOut = modifier(
    (element: HTMLElement, [isExiting, ..._]: boolean[]) => {
      if (isExiting) {
        element.style.height = '0';
      }
    }
  );

  remove = () => {
    this.notifications.remove(this.args.notification);
  };

  pause = () => {
    if (this.args.notification.timer) {
      this.args.notification.timer.pause();
    }
  };

  resume = () => {
    if (this.args.notification.timer) {
      this.args.notification.timer.resume();
    }
  };

  handleClickCustomAction = (customAction: CustomAction) => {
    customAction.onClick();
    this.remove();
  };

  get classes() {
    const { notificationCard } = useStyles();

    let { base, message, customActions, customActionButton, closeButton } =
      notificationCard({
        appearance: this.args.notification.appearance
      });

    return {
      base: base(),
      message: message(),
      customActions: customActions(),
      customActionButton: customActionButton(),
      closeButton: closeButton()
    };
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    {{! template-lint-disable no-unnecessary-concat }}
    {{! template-lint-disable no-inline-styles }}
    {{! template-lint-disable style-concatenation  }}
    <div {{this.transitionIn}} {{this.transitionOut @notification.isRemoving}}>
      {{#unless @notification.isRemoving}}
        <div
          {{on "mouseenter" this.pause}}
          {{on "mouseleave" this.resume}}
          {{cssTransition
            (concat "notification-transition--slide-from-" @placement)
            isEnabled=true
          }}
          class={{this.classes.base}}
          style="{{this.styles}}"
          ...attributes
        >
          <div class={{this.classes.message}}>
            {{@notification.message}}
          </div>

          {{#if @notification.customActions}}
            <div class={{this.classes.customActions}}>
              {{#each @notification.customActions as |customAction|}}
                <button
                  type="button"
                  class={{this.classes.customActionButton}}
                  {{on "click" (fn this.handleClickCustomAction customAction)}}
                >
                  {{customAction.label}}
                </button>
              {{/each}}
            </div>
          {{/if}}

          {{#if @notification.allowClosing}}
            <CloseButton
              @onClick={{this.remove}}
              @size="sm"
              @class={{this.classes.closeButton}}
            />
          {{/if}}
        </div>
      {{/unless}}
    </div>
  </template>
}

export { NotificationCard, type NotificationCardSignature };
export default NotificationCard;
