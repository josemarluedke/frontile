import { tracked } from '@glimmer/tracking';
import { later, cancel } from '@ember/runloop';
import type { Timer as EmberTimer } from '@ember/runloop';
import { action } from '@ember/object';

export default class Timer {
  @tracked remaining: number;
  @tracked isRunning = true;

  readonly onFinish: () => void;
  private timer?: EmberTimer;
  private start!: number;

  constructor(duration: number, onFinish: () => void) {
    this.remaining = duration;
    this.onFinish = onFinish;
    this.setup();
  }

  @action clear(): void {
    this.isRunning = false;

    if (this.timer) {
      cancel(this.timer);
    }
  }

  @action pause(): void {
    this.clear();
    this.remaining -= Date.now() - this.start;
  }

  @action resume(): void {
    this.clear();
    this.setup();
  }

  private setup(): void {
    this.start = Date.now();
    this.isRunning = true;

    this.timer = later(
      this,
      () => {
        this.onFinish();
        this.isRunning = false;
      },
      this.remaining
    );
  }
}
