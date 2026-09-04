import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import { next } from '@ember/runloop';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import { htmlSafe } from '@ember/template';
import { registerDestructor } from '@ember/destroyable';
import NotificationCard from './notification-card';
import { NotificationStack } from '../../-private/notification-stack';
import type NotificationsService from '../../services/notifications';
import type Notification from '../../-private/notification';
import { type containerPlacement } from '../../-private/types';
import { useStyles } from '@frontile/theme';
import type Owner from '@ember/owner';
import type { SafeString } from '@ember/template';

interface NotificationsContainerSignature {
  Args: {
    /**
     * The placement of the notifications
     *
     * @defaultValue 'bottom-right'
     */
    placement?: containerPlacement;

    /**
     * The peek offset between collapsed cards, and the gap between expanded
     * cards, in px.
     *
     * @defaultValue 16
     */
    spacing?: number;

    /**
     * The visual style applied to every card.
     *
     * @defaultValue 'default'
     */
    variant?: 'default' | 'tonal' | 'solid';

    /**
     * How many cards stay visible while the stack is collapsed.
     *
     * @defaultValue 3
     */
    visibleToasts?: number;

    /**
     * Keep the stack expanded instead of collapsing it when not hovered.
     *
     * @defaultValue false
     */
    expand?: boolean;

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

  @tracked isHovered = false;

  /**
   * Measured card heights, keyed by notification. Reassigned rather than
   * mutated so reads stay tracked.
   */
  @tracked heights: Map<Notification<Record<string, unknown>>, number> =
    new Map();

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

  get placement(): containerPlacement {
    return this.args.placement || 'bottom-right';
  }

  get spacing(): number {
    return typeof this.args.spacing === 'undefined' ? 16 : this.args.spacing;
  }

  get visibleToasts(): number {
    return typeof this.args.visibleToasts === 'undefined'
      ? 3
      : this.args.visibleToasts;
  }

  get isExpanded(): boolean {
    return this.args.expand === true || this.isHovered;
  }

  /**
   * Newest first, for every placement. The placement only decides which edge
   * the stack is pinned to and which way it grows, never the order.
   */
  get stackOrder(): Notification<Record<string, unknown>>[] {
    return this.notifications.notifications.slice().reverse();
  }

  get stack(): NotificationStack {
    return new NotificationStack({
      heights: this.stackOrder.map(
        (notification) => this.heights.get(notification) ?? 0
      ),
      isExpanded: this.isExpanded,
      gap: this.spacing,
      visibleToasts: this.visibleToasts,
      placement: this.placement
    });
  }

  get stackStyle(): SafeString {
    return htmlSafe(`height: ${this.stack.containerHeight}px`);
  }

  /**
   * Glint rejects calling a class method with an argument directly from the
   * template, so this arrow-function property is the call site instead.
   */
  geometryFor = (index: number) => this.stack.geometryFor(index);

  measure = (
    notification: Notification<Record<string, unknown>>,
    height: number
  ) => {
    // The card's measure modifier calls this synchronously while installing,
    // i.e. mid-render, while other cards' geometry is still being read from
    // `this.heights` in the same computation. Deferring the write to the
    // next runloop turn avoids the "updated after being used" assertion
    // while still updating well before the next paint.
    next(() => {
      if (this.heights.get(notification) === height) {
        return;
      }

      const nextHeights = new Map(this.heights);
      nextHeights.set(notification, height);
      this.heights = nextHeights;
    });
  };

  /**
   * Expanding the stack pauses every timer, not just the hovered card's:
   * the user is reading the whole stack, so none of it should time out.
   */
  expand = () => {
    if (this.isHovered) {
      return;
    }

    this.isHovered = true;
    this.notifications.notifications.forEach((notification) => {
      notification.timer?.pause();
    });
  };

  collapse = () => {
    if (!this.isHovered) {
      return;
    }

    this.isHovered = false;
    this.notifications.notifications.forEach((notification) => {
      notification.timer?.resume();
    });
  };

  get classes() {
    const { notificationsContainer } = useStyles();

    const { base, stack } = notificationsContainer({
      placement: this.placement,
      class: this.args.class
    });

    return { base: base(), stack: stack() };
  }

  <template>
    {{! template-lint-disable no-inline-styles }}
    <div
      class={{this.classes.base}}
      role="region"
      aria-label="Notifications"
      aria-live="polite"
      {{on "mouseenter" this.expand}}
      {{on "mouseleave" this.collapse}}
      {{on "focusin" this.expand}}
      {{on "focusout" this.collapse}}
      ...attributes
    >
      <div
        class={{this.classes.stack}}
        style={{this.stackStyle}}
        data-expanded="{{if this.isExpanded 'true' 'false'}}"
      >
        {{#each this.stackOrder key="@identity" as |notification index|}}
          <NotificationCard
            @notification={{notification}}
            @placement={{this.placement}}
            @variant={{@variant}}
            @geometry={{this.geometryFor index}}
            @onMeasure={{fn this.measure notification}}
          />
        {{/each}}
      </div>
    </div>
  </template>
}

export { NotificationsContainer, type NotificationsContainerSignature };
export default NotificationsContainer;
