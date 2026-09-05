import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { modifier } from 'ember-modifier';
import { service } from '@ember/service';
import { htmlSafe } from '@ember/template';
import { fn } from '@ember/helper';
import { CloseButton } from '../buttons/close-button';
import { Button } from '../buttons/button';
import { Spinner } from '../utilities/spinner';
import { IconInfo, IconSuccess, IconWarning, IconDanger } from './icons';
import { useStyles } from '@frontile/theme';

import type NotificationsService from '../../services/notifications';
import type Notification from '../../-private/notification';
import type { CardGeometry } from '../../-private/notification-stack';
import type {
  CustomAction,
  containerPlacement,
  NotificationIntent
} from '../../-private/types';
import type { SafeString } from '@ember/template';

const ICONS = {
  info: IconInfo,
  success: IconSuccess,
  warning: IconWarning,
  danger: IconDanger
};

/**
 * Button intent for the primary custom action, per notification intent.
 */
const ACTION_INTENT = {
  info: 'primary',
  success: 'success',
  warning: 'warning',
  danger: 'danger'
} as const;

interface NotificationCardSignature {
  Args: {
    notification: Notification<Record<string, unknown>>;
    placement: containerPlacement;

    /**
     * The visual style of the card.
     *
     * @defaultValue 'default'
     */
    variant?: 'default' | 'tonal' | 'solid';

    /**
     * Position, scale, and stacking supplied by the container. When omitted
     * the card renders in place with no stack transform.
     */
    geometry?: CardGeometry;

    /**
     * Called with the card's measured height whenever it changes.
     */
    onMeasure?: (height: number) => void;
  };
  Element: HTMLDivElement;
}

class NotificationCard extends Component<NotificationCardSignature> {
  @service notifications!: NotificationsService;

  /**
   * False for the first frame so the card can transition in from the
   * placement edge rather than appearing at its resting position.
   */
  @tracked hasEntered = false;

  get isTopPlacement(): boolean {
    return (this.args.placement || 'bottom-right').startsWith('top');
  }

  get intent(): NotificationIntent {
    return this.args.notification.intent;
  }

  get icon() {
    return ICONS[this.intent];
  }

  get actionIntent() {
    return ACTION_INTENT[this.intent];
  }

  /**
   * `alert` interrupts a screen reader, so it is reserved for the intents
   * that warrant interrupting.
   */
  get role(): 'status' | 'alert' {
    return this.intent === 'warning' || this.intent === 'danger'
      ? 'alert'
      : 'status';
  }

  get style(): SafeString {
    const { geometry, notification } = this.args;
    const declarations = [
      `transition-duration: ${notification.transitionDuration}ms, ${notification.transitionDuration}ms, 400ms`
    ];

    // Cards are pinned to the placement edge so the stack grows away from it.
    // This lives here rather than on the container, because a `style`
    // attribute passed through `...attributes` replaces the element's own
    // `style` outright and would drop the transform below.
    if (geometry) {
      declarations.push(
        'position: absolute',
        'left: 0',
        'right: 0',
        this.isTopPlacement ? 'top: 0' : 'bottom: 0'
      );
    }

    if (!this.hasEntered || notification.isRemoving) {
      // Enter from, and exit to, the placement edge.
      const offset = this.isTopPlacement ? '-100%' : '100%';
      declarations.push(
        `opacity: 0`,
        `transform: translateY(${offset}) scale(0.95)`
      );

      if (geometry) {
        declarations.push(
          `z-index: ${geometry.zIndex}`,
          `transform-origin: ${geometry.transformOrigin}`
        );
      }

      return htmlSafe(declarations.join('; '));
    }

    if (geometry) {
      declarations.push(
        `transform: ${geometry.transform}`,
        `transform-origin: ${geometry.transformOrigin}`,
        `z-index: ${geometry.zIndex}`,
        `opacity: ${geometry.opacity}`,
        geometry.height === null
          ? `height: auto`
          : `height: ${geometry.height}px`
      );
    }

    return htmlSafe(declarations.join('; '));
  }

  /**
   * Flip to the resting position on the frame after insertion, so the browser
   * has a start value to transition from.
   */
  enter = modifier(() => {
    const frame = requestAnimationFrame(() => {
      this.hasEntered = true;
    });

    return () => cancelAnimationFrame(frame);
  });

  /**
   * Report the card's height to the container so the stack can lay itself
   * out. Also fires when promise content swaps change the height.
   */
  measure = modifier((element: HTMLElement) => {
    const { onMeasure } = this.args;

    if (!onMeasure) {
      return;
    }

    const observer = new ResizeObserver(() => {
      onMeasure(element.offsetHeight);
    });

    onMeasure(element.offsetHeight);
    observer.observe(element);

    return () => observer.disconnect();
  });

  remove = () => {
    this.notifications.remove(this.args.notification);
  };

  handleClickCustomAction = (customAction: CustomAction) => {
    customAction.onClick();
    this.notifications.remove(this.args.notification);
  };

  get classes() {
    const { notificationCard } = useStyles();

    const {
      base,
      inner,
      icon,
      content,
      title,
      description,
      customActions,
      customActionButton,
      closeButton
    } = notificationCard({
      intent: this.intent,
      variant: this.args.variant || 'default',
      hasDescription: !!this.args.notification.description
    });

    return {
      base: base(),
      inner: inner(),
      icon: icon(),
      content: content(),
      title: title(),
      description: description(),
      customActions: customActions(),
      customActionButton: customActionButton(),
      closeButton: closeButton()
    };
  }

  <template>
    {{! template-lint-disable no-inline-styles style-concatenation }}
    <div
      class={{this.classes.base}}
      style={{this.style}}
      role={{this.role}}
      data-test-notification-card
      {{this.enter}}
      ...attributes
    >
      {{! measure reads offsetHeight off this inner element, not the outer one above, since the outer carries the collapsed-stack height clamp. See notification-stack.ts. }}
      <div class={{this.classes.inner}} {{this.measure}}>
        {{#unless @notification.hideIcon}}
          {{#if @notification.isLoading}}
            <Spinner
              @class={{this.classes.icon}}
              @size="sm"
              data-test-icon="loading"
            />
          {{else}}
            {{#let this.icon as |Icon|}}
              <Icon class={{this.classes.icon}} />
            {{/let}}
          {{/if}}
        {{/unless}}

        <div class={{this.classes.content}}>
          <div class={{this.classes.title}}>{{@notification.title}}</div>

          {{#if @notification.description}}
            <div class={{this.classes.description}}>
              {{@notification.description}}
            </div>
          {{/if}}
        </div>

        {{#if @notification.customActions}}
          <div class={{this.classes.customActions}}>
            {{#each @notification.customActions as |customAction index|}}
              <Button
                @size="xs"
                @intent={{if index "default" this.actionIntent}}
                @appearance={{if index "minimal" "default"}}
                @class={{this.classes.customActionButton}}
                @onPress={{fn this.handleClickCustomAction customAction}}
              >
                {{customAction.label}}
              </Button>
            {{/each}}
          </div>
        {{/if}}

        {{#if @notification.allowClosing}}
          <CloseButton
            @onPress={{this.remove}}
            @size="sm"
            @class={{this.classes.closeButton}}
          />
        {{/if}}
      </div>
    </div>
  </template>
}

export { NotificationCard, type NotificationCardSignature };
export default NotificationCard;
