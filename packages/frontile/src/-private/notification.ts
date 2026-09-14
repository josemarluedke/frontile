import { tracked } from '@glimmer/tracking';
import { deprecate } from '@ember/debug';
import Timer from './timer';
import { getConfigOption } from './get-config';
import type {
  NotificationOptions,
  NotificationContent,
  NotificationStatus,
  NotificationAppearance,
  NotificationUpdate,
  CustomAction,
  DefaultConfig
} from './types';

/**
 * Normalise the two content forms into `{ title, description }`.
 */
function toContent(content: string | NotificationContent): NotificationContent {
  return typeof content === 'string' ? { title: content } : content;
}

/**
 * Emit the shared deprecation notice and remap `error` onto `danger`. Used
 * for both the option-level and config-level `appearance` fallbacks in
 * `resolveStatus`, which must apply the same remap.
 */
function mapAppearance(appearance: NotificationAppearance): NotificationStatus {
  deprecate(
    'The `appearance` option for notifications is deprecated. Use `status` instead, and `danger` in place of `error`.',
    false,
    {
      id: 'frontile.notification-appearance',
      until: '0.19.0',
      for: 'frontile',
      since: { available: '0.18.0', enabled: '0.18.0' }
    }
  );

  if (appearance === 'error') return 'danger';
  // `info` folded into `primary` when the axis became `status`.
  if (appearance === 'info') return 'primary';

  return appearance;
}

/**
 * Resolve the notification status from the current option, the deprecated
 * `appearance` option, and the app config, in that order.
 */
function resolveStatus(
  config: DefaultConfig,
  options: NotificationOptions
): NotificationStatus {
  if (options.status) {
    return options.status;
  }

  if (options.appearance) {
    return mapAppearance(options.appearance);
  }

  if (config.status) {
    return config.status;
  }

  if (config.appearance) {
    return mapAppearance(config.appearance);
  }

  // `config.status`/`config.appearance` were already read directly above, so
  // there is no distinct config lookup left to fall back to.
  return 'neutral';
}

export default class Notification<
  TMetadata extends Record<string, unknown> = Record<string, unknown>
> {
  /**
   * The title of the notification. Named `message` for backwards
   * compatibility with the original single-string API.
   */
  @tracked message: string;
  @tracked description?: string;
  @tracked status: NotificationStatus;
  @tracked allowClosing: boolean;
  @tracked isLoading: boolean;
  @tracked customActions?: CustomAction[];
  @tracked timer?: Timer;
  @tracked isRemoving = false;

  readonly transitionDuration: number;
  readonly duration: number;
  readonly hideIcon: boolean;
  readonly metadata?: TMetadata;

  constructor(
    config: DefaultConfig,
    content: string | NotificationContent,
    options: NotificationOptions<TMetadata> = {}
  ) {
    const { title, description } = toContent(content);

    this.message = title;
    // An object content form owns the description outright; the option is only
    // a convenience for the string form.
    this.description =
      typeof content === 'string' ? options.description : description;
    this.status = resolveStatus(config, options);
    this.isLoading = options.isLoading === true;
    this.hideIcon = options.hideIcon === true;
    this.customActions = options.customActions;
    this.duration =
      options.duration || getConfigOption(config, 'duration', 5000);
    this.transitionDuration =
      typeof options.transitionDuration !== 'undefined'
        ? options.transitionDuration
        : getConfigOption(config, 'transitionDuration', 200);
    this.metadata = options.metadata;
    this.allowClosing = options.allowClosing !== false;
  }

  /** Read-only alias of `message` — do not add a setter. */
  get title(): string {
    return this.message;
  }

  /**
   * @deprecated Read `status` instead.
   *
   * The return type is widened to include `'default'` because `default` is
   * new vocabulary introduced alongside this getter's deprecation — it has
   * no equivalent in the old `NotificationAppearance` names, so mapping it
   * onto `'info'` here would silently lie about the notification's status.
   * Everything else keeps the old four-value shape.
   */
  get appearance(): 'default' | 'info' | 'success' | 'warning' | 'error' {
    if (this.status === 'danger') return 'error';
    if (this.status === 'neutral') return 'default';
    if (this.status === 'primary') return 'info';

    return this.status;
  }

  /**
   * Mutate the notification in place. Used by `promise()` so a settling
   * promise swaps the content of the toast already on screen rather than
   * replacing it with a new one.
   */
  update(changes: NotificationUpdate): void {
    if (typeof changes.title !== 'undefined') {
      this.message = changes.title;
    }

    if (typeof changes.description !== 'undefined') {
      this.description = changes.description;
    }

    if (typeof changes.status !== 'undefined') {
      this.status = changes.status;
    }

    if (typeof changes.allowClosing !== 'undefined') {
      this.allowClosing = changes.allowClosing;
    }

    if (typeof changes.isLoading !== 'undefined') {
      this.isLoading = changes.isLoading;
    }
  }

  remove(): void {
    this.isRemoving = true;

    if (this.timer) {
      this.timer.clear();
    }
  }
}
