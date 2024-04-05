import { tracked } from '@glimmer/tracking';
import { modifier } from 'ember-modifier';

class State<T> {
  @tracked element: T | undefined;
}

function ref<T extends Element = Element>() {
  const state = new State<T>();
  return {
    get element(): T | undefined {
      return state.element;
    },
    setup: modifier((el: T) => {
      state.element = el;
      return (): void => {
        state.element = undefined;
      };
    })
  };
}

export { ref };
