import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import { next } from '@ember/runloop';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import { modifier } from 'ember-modifier';
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
    // Prune immediately rather than waiting for the next `measure` call —
    // if the dismissed notification was the last one, nothing would ever
    // trigger a rebuild otherwise, and its height entry (with its strong
    // reference to the `Notification` and its `metadata`) would linger
    // forever.
    if (this.heights.has(notification)) {
      const nextHeights = new Map(this.heights);
      nextHeights.delete(notification);
      this.heights = nextHeights;
    }

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
   * `data-expanded` as a string, computed here rather than with an inline
   * `{{if}}`: the template-side form needs quoted string literals, and
   * prettier and ember-template-lint disagree about which quotes those may
   * be, so neither linter can be satisfied inside the template.
   */
  get expandedAttribute(): 'true' | 'false' {
    return this.isExpanded ? 'true' : 'false';
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
    // Skip scheduling entirely when the height hasn't actually changed, so a
    // redundant ResizeObserver tick doesn't cost a runloop turn.
    if (this.heights.get(notification) === height) {
      return;
    }

    // The card's measure modifier calls this synchronously while installing,
    // i.e. mid-render, while other cards' geometry is still being read from
    // `this.heights` in the same computation. Deferring the write to the next
    // runloop turn avoids the "updated after being used" assertion. Note that
    // `next()` schedules via a 1ms `_backburner.later(...)` timer, which lands
    // *after* the current frame paints — so the first painted frame still
    // renders with `heights` empty (`containerHeight: 0px`, every collapsed
    // card at `height: 0px`), corrected one macrotask later. Since the stack
    // carries `transition-[height] duration-400`, that correction is a
    // visible height animation from 0 on first appearance.
    next(() => {
      if (this.isDestroying || this.isDestroyed) {
        return;
      }

      if (this.heights.get(notification) === height) {
        return;
      }

      // Rebuild rather than mutate in place (`Map` mutation isn't tracked),
      // and prune any notification no longer live while we're at it — a
      // dismissed notification is never measured again, so without this the
      // map (and its strong reference to every past `Notification` and its
      // `metadata`) would grow for the container's entire lifetime, and
      // every future rebuild would keep copying all of that dead weight.
      const live = new Set(this.notifications.notifications);
      const nextHeights = new Map(
        Array.from(this.heights).filter(([n]) => live.has(n))
      );
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

  /**
   * `focusout` bubbles from every element inside the container, and fires
   * before the next element's `focusin` — so tabbing from one card's close
   * button to the next card's close button collapses the stack for one
   * tick and re-expands it immediately after, right in the middle of the
   * exact keyboard journey the focus-expand behavior exists to support.
   *
   * A containment check fixes it: only collapse when focus is actually
   * leaving the container, i.e. `relatedTarget` (the element about to
   * receive focus) is not inside it. `relatedTarget` is `null` when focus
   * moves somewhere that isn't focus-trackable (e.g. the browser chrome),
   * which is also a real "focus left the container" case.
   */
  handleFocusOut = (event: FocusEvent) => {
    const container = event.currentTarget as HTMLElement;
    const related = event.relatedTarget as Node | null;

    if (related && container.contains(related)) {
      return;
    }

    this.collapse();
  };

  /**
   * `expand()`/`collapse()` only touch the timers that exist at the moment
   * the pointer enters or leaves the stack. That leaves two gaps: a toast
   * added (or a `promise()` settling into its own timer via
   * `setupAutoRemoval`) while the stack is already expanded starts
   * *running*, and can auto-dismiss under the cursor; and with `@expand=
   * {{true}}` `isExpanded` is permanently true but `expand()` never runs at
   * all, so none of its timers are ever paused.
   *
   * This modifier is the durable fix. It's invoked with `stackOrder` and
   * `isExpanded` as *positional arguments* (see the template) rather than
   * only reading them off `this` inside the callback — a function-based
   * modifier only re-runs when Glimmer sees its own args change; reading
   * other tracked state from inside the callback without also passing it
   * as an arg does not reliably trigger a re-invocation. Passing them as
   * args guarantees this runs again the instant a new notification (and
   * thus a new timer) appears, or the moment `isExpanded` flips.
   *
   * The pause itself is deferred via `next()`, for the same reason
   * `measure()` below defers its write: `Timer#pause()` reads `isRunning`
   * (to no-op if already paused) before writing it, and doing that
   * read-then-write on a tracked property from *within* a modifier's
   * update — which Glimmer treats as still "rendering" — trips the
   * "attempted to update a value after using it in this computation"
   * assertion. Deferring one runloop turn moves the mutation safely
   * outside that render transaction. `Timer#pause()` is a no-op on an
   * already-paused timer, so this is safe to run redundantly alongside
   * `expand()`.
   */
  syncTimers = modifier(
    (
      _element: Element,
      [stackOrder, isExpanded]: [
        Notification<Record<string, unknown>>[],
        boolean
      ]
    ) => {
      if (!isExpanded) {
        return;
      }

      next(() => {
        if (this.isDestroying || this.isDestroyed) {
          return;
        }

        stackOrder.forEach((notification) => {
          notification.timer?.pause();
        });
      });
    }
  );

  /**
   * The number of entries in the `heights` map. Not used for rendering —
   * exposed (via a `data-*` attribute below) purely so tests can assert the
   * map is actually pruned on dismiss/measure, rather than only checking
   * that pruning doesn't throw.
   *
   * @internal
   */
  get heightsSize(): number {
    return this.heights.size;
  }

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
      data-test-heights-size={{this.heightsSize}}
      {{on "mouseenter" this.expand}}
      {{on "mouseleave" this.collapse}}
      {{on "focusin" this.expand}}
      {{on "focusout" this.handleFocusOut}}
      ...attributes
    >
      <div
        class={{this.classes.stack}}
        style={{this.stackStyle}}
        data-expanded={{this.expandedAttribute}}
        {{this.syncTimers this.stackOrder this.isExpanded}}
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
