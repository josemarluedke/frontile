import { tracked } from '@glimmer/tracking';
import { assert } from '@ember/debug';
import Timer from './timer';
import { getConfigOption } from './get-config';
import type {
  NotificationOptions,
  NotificationContent,
  NotificationStatus,
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
 * Fail in development when the `appearance` option, removed in 0.19.0, is
 * still passed, either per notification or in the app config. An explicitly
 * `undefined` value does not fail.
 */
function assertNoAppearance(source: object): void {
  assert(
    'Notifications: the "appearance" option was removed in 0.19.0. Use "status".',
    (source as Record<string, unknown>)['appearance'] === undefined
  );
}

/**
 * Resolve the notification status from the option, then the app config.
 */
function resolveStatus(
  config: DefaultConfig,
  options: NotificationOptions
): NotificationStatus {
  return options.status ?? config.status ?? 'neutral';
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
    assertNoAppearance(config);
    assertNoAppearance(options);

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
