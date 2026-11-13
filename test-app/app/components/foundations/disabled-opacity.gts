import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { schedule } from '@ember/runloop';
import { isDestroying } from '@ember/destroyable';
import { modifier } from 'ember-modifier';
import { Button } from 'frontile';
import { subscribe } from 'test-app/utils/workbench/root-theme-observer';

/** A disabled Button and the opacity it resolves to. */
export default class DisabledOpacity extends Component {
  @tracked value = '';

  read(el: HTMLElement): void {
    if (isDestroying(this)) {
      return;
    }
    const button = el.querySelector('button');
    if (button) {
      this.value = getComputedStyle(button).opacity;
    }
  }

  measure = modifier((el: HTMLElement) => {
    const run = (): void => {
      schedule('afterRender', this, this.read, el);
    };
    run();
    return subscribe(run);
  });

  <template>
    <div data-token-item class="flex items-center gap-3">
      <div {{this.measure}}>
        <Button @color="primary" disabled>Disabled</Button>
      </div>
      <span class="text-neutral-firm text-xs">opacity</span>
      <code
        data-token-value="opacity"
        class="text-neutral-firm font-mono text-xs"
      >{{this.value}}</code>
    </div>
  </template>
}
