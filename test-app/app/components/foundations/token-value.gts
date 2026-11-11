import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { schedule } from '@ember/runloop';
import { isDestroying } from '@ember/destroyable';
import { modifier } from 'ember-modifier';
import { readVar } from 'test-app/utils/workbench/css';
import { subscribe } from 'test-app/utils/workbench/root-theme-observer';

export interface TokenValueSignature {
  Args: {
    /** A CSS custom property, e.g. `--radius-md`. Read from the enclosing pane. */
    name: string;
    /**
     * A computed property of the sibling `[data-token-shape]` to show instead
     * of the raw variable, for tokens defined as `calc()` or `var()`. The
     * raw value then moves to the tooltip, as `--name: raw`.
     */
    property?: string;
  };
  Element: HTMLElement;
}

/**
 * Prints a token's live value. Re-reads when the root's theme class changes,
 * through the shared observer.
 */
export default class TokenValue extends Component<TokenValueSignature> {
  @tracked value = '';

  /** The variable's own value; shown in the tooltip when `@property` is set. */
  @tracked raw = '';

  get title(): string {
    return this.args.property && this.raw
      ? `${this.args.name}: ${this.raw}`
      : this.args.name;
  }

  read(el: HTMLElement): void {
    if (isDestroying(this)) {
      return;
    }
    const raw = readVar(el, this.args.name);
    const shape = this.args.property
      ? el.closest('[data-token-item]')?.querySelector('[data-token-shape]')
      : null;
    this.raw = raw;
    this.value =
      shape && this.args.property
        ? getComputedStyle(shape).getPropertyValue(this.args.property).trim()
        : raw;
  }

  measure = modifier((el: HTMLElement, [name, property]: [string, unknown]) => {
    void name;
    void property;
    const run = (): void => {
      schedule('afterRender', this, this.read, el);
    };
    run();
    return subscribe(run);
  });

  <template>
    <code
      data-token-value={{@name}}
      title={{this.title}}
      class="text-neutral-firm font-mono text-xs break-all"
      {{this.measure @name @property}}
      ...attributes
    >{{this.value}}</code>
  </template>
}
