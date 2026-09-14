import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { modifier } from 'ember-modifier';
import { service } from '@ember/service';
import { htmlSafe } from '@ember/template';
import { fn } from '@ember/helper';
import { CloseButton } from '../buttons/close-button';
import { Button } from '../buttons/button';
import { Spinner } from '../utilities/spinner';
import {
  IconInfo,
  IconSuccess,
  IconWarning,
  IconDanger
} from '../../-private/icons';
import { useStyles } from '@frontile/theme';

import type NotificationsService from '../../services/notifications';
import type Notification from '../../-private/notification';
import { isTopPlacement } from '../../-private/notification-stack';
import type { CardGeometry } from '../../-private/notification-stack';
import type {
  CustomAction,
  containerPlacement,
  NotificationStatus
} from '../../-private/types';
import type { SafeString } from '@ember/template';

/**
 * Everything that varies by `NotificationStatus`, keyed in one place so
 * adding a status means adding one row here instead of remembering to
 * touch an icon map, an action-colour map, and the `role` getter's cascade
 * separately.
 */
const STATUS_CONFIG = {
  neutral: {
    icon: IconInfo,
    // Button colour for the primary custom action. Also reused as the
    // loading <Spinner>'s `@color` (its colour union has the same
    // neutral/primary/success/warning/danger shape), so the spinner's arc
    // matches the same accent the card's custom action button would use.
    actionColor: 'neutral',
    // `alert` interrupts a screen reader, so it is reserved for the
    // statuses that warrant interrupting. This coupling is why the prop is
    // `@status` and not `@color`.
    role: 'status'
  },
  // Formerly `info`, which already painted `primary`'s classes. The info
  // glyph stays attached to `primary`.
  primary: {
    icon: IconInfo,
    actionColor: 'primary',
    role: 'status'
  },
  success: {
    icon: IconSuccess,
    actionColor: 'success',
    role: 'status'
  },
  warning: {
    icon: IconWarning,
    actionColor: 'warning',
    role: 'alert'
  },
  danger: {
    icon: IconDanger,
    actionColor: 'danger',
    role: 'alert'
  }
} as const satisfies Record<
  NotificationStatus,
  {
    icon: unknown;
    actionColor: 'neutral' | 'primary' | 'success' | 'warning' | 'danger';
    role: 'status' | 'alert';
  }
>;

interface NotificationCardSignature {
  Args: {
    notification: Notification<Record<string, unknown>>;
    placement: containerPlacement;

    /**
     * The visual style of the card.
     *
     * @defaultValue 'surface'
     */
    variant?: 'surface' | 'soft' | 'solid';

    /**
     * Position, scale, and stacking supplied by the container. When omitted
     * the card renders in place with no stack transform.
     *
     * Part of the container/card plumbing, not a consumer-facing argument.
     *
     * @internal
     */
    geometry?: CardGeometry;

    /**
     * Called with the card's measured height whenever it changes.
     *
     * Part of the container/card plumbing, not a consumer-facing argument.
     *
     * @internal
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
    return isTopPlacement(this.args.placement || 'bottom-right');
  }

  get status(): NotificationStatus {
    return this.args.notification.status;
  }

  get icon() {
    return STATUS_CONFIG[this.status].icon;
  }

  get actionColor() {
    return STATUS_CONFIG[this.status].actionColor;
  }

  get role(): 'status' | 'alert' {
    return STATUS_CONFIG[this.status].role;
  }

  get style(): SafeString {
    const { geometry, notification } = this.args;
    // The theme owns the whole `transition-duration` shorthand (and its
    // `motion-reduce:` override) so the per-property duration order can
    // never drift out of sync with `transition-[transform,opacity,height]`
    // across the component boundary — see notification-card.ts. This card
    // only supplies the one value `@transitionDuration` actually governs
    // (the enter/exit fade), as a custom property the theme's `var()` reads.
    const declarations = [
      `--frontile-toast-fade: ${notification.transitionDuration}ms`
    ];

    // The static edge-pinning (`position: absolute` + `left/right/top` or
    // `bottom`) lives in the `stackPlacement` theme variant (see
    // `this.classes`) rather than here, since it never varies frame to
    // frame — only the geometry-driven parts below (transform, opacity,
    // height, z-index, transform-origin) need to be inline, because a
    // `style` attribute passed through `...attributes` replaces the
    // element's own `style` outright and would drop them.

    if (!this.hasEntered || notification.isRemoving) {
      // Enter from, and exit to, the placement edge.
      const offset = this.isTopPlacement ? '-100%' : '100%';
      declarations.push(
        `opacity: 0`,
        `transform: translateY(${offset}) scale(0.95)`,
        // A card can be transparent-and-collapsed the instant it starts
        // exiting; keep it out of the click path either way.
        `pointer-events: none`
      );

      if (geometry) {
        declarations.push(
          `z-index: ${geometry.zIndex}`,
          `transform-origin: ${geometry.transformOrigin}`,
          // Preserve the collapsed height clamp through the exit
          // transition — otherwise a non-front collapsed card snaps from
          // its clamped height to `auto` for the slide-out.
          geometry.height === null
            ? `height: auto`
            : `height: ${geometry.height}px`
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
        `pointer-events: ${geometry.pointerEvents}`,
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
   *
   * `element` is the inner element (never height-constrained, so its
   * `offsetHeight` is always the content's true natural height). The border
   * lives on the outer element (`element.parentElement`), so it isn't part
   * of that number — we add it back via `outer.offsetHeight -
   * outer.clientHeight`, the outer element's vertical border width. That
   * difference is constant whether or not the outer element's height is
   * currently clamped by the collapsed-stack height, so it's safe to read
   * off the outer element even while it's clamped, and it stays correct if
   * the theme's border width ever changes.
   */
  measure = modifier((element: HTMLElement) => {
    const { onMeasure } = this.args;

    if (!onMeasure) {
      return;
    }

    const outer = element.parentElement as HTMLElement;

    const report = () => {
      const outerBorder = outer.offsetHeight - outer.clientHeight;
      onMeasure(element.offsetHeight + outerBorder);
    };

    const observer = new ResizeObserver(report);

    report();
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
      spinner,
      content,
      title,
      description,
      customActions,
      customActionButton,
      closeButton
    } = notificationCard({
      status: this.status,
      variant: this.args.variant || 'surface',
      hasDescription: !!this.args.notification.description,
      // Only pin the card to the placement edge once the container has
      // supplied stack geometry — see the `stackPlacement` variant's
      // comment in the theme.
      stackPlacement: this.args.geometry
        ? this.isTopPlacement
          ? 'top'
          : 'bottom'
        : 'none'
    });

    return {
      base: base(),
      inner: inner(),
      icon: icon(),
      spinner: spinner(),
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
      data-component="notification-card"
      data-part="base"
      class={{this.classes.base}}
      style={{this.style}}
      role={{this.role}}
      data-test-notification-card
      data-test-status={{this.status}}
      {{this.enter}}
      ...attributes
    >
      {{! measure reads offsetHeight off this inner element, not the outer one above, since the outer carries the collapsed-stack height clamp. See notification-stack.ts. }}
      <div data-part="inner" class={{this.classes.inner}} {{this.measure}}>
        {{#unless @notification.hideIcon}}
          {{#if @notification.isLoading}}
            <Spinner
              data-part="spinner"
              @class={{this.classes.spinner}}
              @color={{this.actionColor}}
              @size="sm"
              data-test-icon="loading"
            />
          {{else}}
            {{#let this.icon as |Icon|}}
              <Icon data-part="icon" class={{this.classes.icon}} />
            {{/let}}
          {{/if}}
        {{/unless}}

        <div data-part="content" class={{this.classes.content}}>
          <div
            data-part="title"
            class={{this.classes.title}}
          >{{@notification.title}}</div>

          {{#if @notification.description}}
            <div data-part="description" class={{this.classes.description}}>
              {{@notification.description}}
            </div>
          {{/if}}
        </div>

        {{#if @notification.customActions}}
          <div data-part="custom-actions" class={{this.classes.customActions}}>
            {{#each @notification.customActions as |customAction index|}}
              <Button
                data-part="custom-action-button"
                @size="xs"
                @color={{if index "neutral" this.actionColor}}
                @variant={{if index "plain" "solid"}}
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
            data-part="close-button"
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
