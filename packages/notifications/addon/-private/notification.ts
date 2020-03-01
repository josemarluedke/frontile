import { tracked } from '@glimmer/tracking';
import Timer from './timer';
import { NotificationOptions, CustomAction } from './types';

export default class Notification {
  readonly message: string;
  readonly transitionDuration: number;
  readonly appearance: NonNullable<NotificationOptions['appearance']>;
  readonly customActions?: CustomAction[];
  readonly allowClosing: boolean;
  readonly duration: number;

  @tracked timer?: Timer;
  @tracked isRemoving = false;

  constructor(message: string, options: NotificationOptions = {}) {
    this.message = message;
    this.appearance = options.appearance || 'info';
    this.customActions = options.customActions;
    this.duration = options.duration || 5000;
    this.transitionDuration =
      typeof options.transitionDuration !== 'undefined'
        ? options.transitionDuration
        : 200;

    if (options.allowClosing === false) {
      this.allowClosing = false;
    } else {
      this.allowClosing = true;
    }
  }
}
