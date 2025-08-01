import { tracked } from '@glimmer/tracking';
import Timer from './timer';
import { getConfigOption } from './get-config';
import type { NotificationOptions, CustomAction, DefaultConfig } from './types';

export default class Notification<
  TMetadata extends Record<string, unknown> = Record<string, unknown>
> {
  readonly message: string;
  readonly transitionDuration: number;
  readonly appearance: NonNullable<NotificationOptions['appearance']>;
  readonly customActions?: CustomAction[];
  readonly allowClosing: boolean;
  readonly duration: number;
  readonly metadata?: TMetadata;

  @tracked timer?: Timer;
  @tracked isRemoving = false;

  constructor(
    config: DefaultConfig,
    message: string,
    options: NotificationOptions<TMetadata> = {}
  ) {
    this.message = message;
    this.appearance =
      options.appearance || getConfigOption(config, 'appearance', 'info');
    this.customActions = options.customActions;
    this.duration =
      options.duration || getConfigOption(config, 'duration', 5000);
    this.transitionDuration =
      typeof options.transitionDuration !== 'undefined'
        ? options.transitionDuration
        : getConfigOption(config, 'transitionDuration', 200);
    this.metadata = options.metadata;

    if (options.allowClosing === false) {
      this.allowClosing = false;
    } else {
      this.allowClosing = true;
    }
  }

  remove(): void {
    this.isRemoving = true;

    if (this.timer) {
      this.timer.clear();
    }
  }
}
