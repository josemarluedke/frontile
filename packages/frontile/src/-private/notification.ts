import { tracked } from '@glimmer/tracking';
import { deprecate } from '@ember/debug';
import { get } from '@ember/object';
import Timer from './timer';
import { getConfigOption } from './get-config';
import type {
  NotificationOptions,
  NotificationContent,
  NotificationIntent,
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
 * Resolve the notification intent from the current option, the deprecated
 * `appearance` option, and the app config, in that order.
 */
function resolveIntent(
  config: DefaultConfig,
  options: NotificationOptions
): NotificationIntent {
  if (options.intent) {
    return options.intent;
  }

  if (options.appearance) {
    deprecate(
      'The `appearance` option for notifications is deprecated. Use `intent` instead, and `danger` in place of `error`.',
      false,
      {
        id: 'frontile.notification-appearance',
        until: '0.19.0',
        for: 'frontile',
        since: { available: '0.18.0', enabled: '0.18.0' }
      }
    );

    return options.appearance === 'error' ? 'danger' : options.appearance;
  }

  const configIntent = config.intent;
  if (configIntent) {
    return configIntent;
  }

  const configAppearance = config.appearance;
  if (configAppearance) {
    deprecate(
      'The `appearance` config option for notifications is deprecated. Use `intent` instead, and `danger` in place of `error`.',
      false,
      {
        id: 'frontile.notification-appearance',
        until: '0.19.0',
        for: 'frontile',
        since: { available: '0.18.0', enabled: '0.18.0' }
      }
    );

    return configAppearance === 'error' ? 'danger' : configAppearance;
  }

  return getConfigOption(config, 'intent', 'default') as NotificationIntent;
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
  @tracked intent: NotificationIntent;
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
    this.intent = resolveIntent(config, options);
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

  get title(): string {
    return this.message;
  }

  /**
   * @deprecated Read `intent` instead.
   *
   * The return type is widened to include `'default'` because `default` is
   * new vocabulary introduced alongside this getter's deprecation — it has
   * no equivalent in the old `NotificationAppearance` names, so mapping it
   * onto `'info'` here would silently lie about the notification's intent.
   * Everything else keeps the old four-value shape.
   */
  get appearance(): 'default' | 'info' | 'success' | 'warning' | 'error' {
    return this.intent === 'danger' ? 'error' : this.intent;
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

    if (typeof changes.intent !== 'undefined') {
      this.intent = changes.intent;
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
