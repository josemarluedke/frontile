import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { inject as service } from '@ember/service';
import { htmlSafe } from '@ember/template';
import { later } from '@ember/runloop';
import { on } from '@ember/modifier';
import { fn, concat } from '@ember/helper';
import didUpdate from '@ember/render-modifiers/modifiers/did-update';
import didInsert from '@ember/render-modifiers/modifiers/did-insert';
import useFrontileClass from '@frontile/core/helpers/use-frontile-class';
import CloseButton from '@frontile/core/components/close-button';
import { cssTransition } from 'ember-css-transitions';

import type NotificationsService from '../services/notifications';
import type Notification from '../-private/notification';
import type { CustomAction, containerPlacement } from '../-private/types';

export interface NotificationCardArgs {
  notification: Notification;
  placement: containerPlacement;

  /**
   * Spacing for each notification, in px.
   *
   * @defaultValue 16
   */
  spacing?: number;
}

export interface NotificationCardSignature {
  Args: NotificationCardArgs;
  Element: HTMLDivElement;
}

export default class NotificationCard extends Component<NotificationCardSignature> {
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

  @action addSpacing(element: HTMLElement): void {
    if (this.args.placement && this.args.placement.includes('top')) {
      element.style.marginTop = `${this.args.spacing || 16}px`;
    }
  }

  @action transitionIn(element: HTMLElement): void {
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

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    {{! template-lint-disable no-unnecessary-concat }}
    {{! template-lint-disable no-inline-styles }}
    {{! template-lint-disable style-concatenation  }}
    <div
      {{didInsert this.transitionIn}}
      {{didUpdate this.transitionOut @notification.isRemoving}}
    >
      {{#unless @notification.isRemoving}}
        <div
          {{on "mouseenter" this.pause}}
          {{on "mouseleave" this.resume}}
          {{cssTransition
            (concat "notification-transition--slide-from-" @placement)
            isEnabled=true
          }}
          class={{useFrontileClass
            "notification-card"
            @notification.appearance
          }}
          style="{{this.styles}}"
          ...attributes
        >
          <div
            class={{useFrontileClass
              "notification-card"
              @notification.appearance
              part="message"
            }}
          >
            {{@notification.message}}
          </div>

          {{#if @notification.customActions}}
            <div
              class={{useFrontileClass
                "notification-card"
                @notification.appearance
                part="custom-actions"
              }}
            >
              {{#each @notification.customActions as |customAction|}}
                <button
                  type="button"
                  class={{useFrontileClass
                    "notification-card"
                    @notification.appearance
                    part="custom-action-btn"
                  }}
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
              class={{useFrontileClass
                "notification-card"
                @notification.appearance
                part="close-btn"
              }}
            />
          {{/if}}
        </div>
      {{/unless}}
    </div>
  </template>
}
