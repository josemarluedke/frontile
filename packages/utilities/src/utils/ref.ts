import { tracked } from '@glimmer/tracking';
import { modifier } from 'ember-modifier';

class Ref<T extends Element = Element> {
  @tracked current: T | undefined;
  #onChange?: (el: T | undefined) => void;

  constructor(onChange?: (el: T | undefined) => void) {
    this.#onChange = onChange;
  }

  setup = modifier((el: T) => {
    this.current = el;
    if (this.#onChange) {
      this.#onChange(el);
    }

    return (): void => {
      this.current = undefined;
      if (this.#onChange) {
        this.#onChange(undefined);
      }
    };
  });
}

function ref<T extends Element = Element>(
  onChange?: (el: T | undefined) => void
): Ref<T> {
  return new Ref(onChange);
}

export { ref };
