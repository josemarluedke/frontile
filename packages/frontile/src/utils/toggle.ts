import { tracked } from '@glimmer/tracking';
import type { PressEvent } from '../modifiers/press';

class ToggleState {
  @tracked current = false;
  #onChange?: (val: boolean) => void;

  constructor(initialValue?: boolean, onChange?: (val: boolean) => void) {
    this.#onChange = onChange;
    if (initialValue !== undefined) {
      this.current = initialValue;
    }
  }

  toggle = (input?: boolean | Event | PressEvent): void => {
    if (typeof input === 'boolean') {
      this.#set(input);
      return;
    }

    // Handle checkbox input
    if (
      input instanceof Event &&
      input.currentTarget &&
      input.currentTarget instanceof HTMLInputElement
    ) {
      this.#set(input.currentTarget.checked);
      return;
    }

    this.#set(!this.current);
  };

  #set(val: boolean): void {
    this.current = val;
    this.#callback();
  }

  #callback() {
    if (this.#onChange) {
      this.#onChange(this.current);
    }
  }
}

function toggleState(
  initialValue?: boolean,
  onChange?: (val: boolean) => void
): ToggleState {
  return new ToggleState(initialValue, onChange);
}

export { toggleState };
