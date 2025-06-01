import { modifier } from 'ember-modifier';

export interface PressOptions {
  onPressStart?: (event: PointerEvent | KeyboardEvent) => void;
  onPressEnd?: (event: PointerEvent | KeyboardEvent) => void;
  onPress?: (event: PointerEvent | KeyboardEvent) => void;
  onPressUp?: (event: PointerEvent | KeyboardEvent) => void;
  disabled?: boolean;
}

const press = modifier((element: HTMLElement, _positional: unknown[], named: PressOptions = {}) => {
  let isPressed = false;

  const start = (event: PointerEvent | KeyboardEvent) => {
    if (named.disabled) {
      return;
    }
    if (!isPressed) {
      isPressed = true;
      named.onPressStart?.(event);
    }
  };

  const end = (event: PointerEvent | KeyboardEvent) => {
    if (!isPressed) {
      return;
    }
    isPressed = false;
    named.onPressEnd?.(event);
    if (element.contains(event.target as Node)) {
      named.onPress?.(event);
    }
    named.onPressUp?.(event);
  };

  const cancel = (event: PointerEvent) => {
    if (!isPressed) {
      return;
    }
    isPressed = false;
    named.onPressEnd?.(event);
  };

  const handleKeyDown = (event: KeyboardEvent) => {
    if (event.key === 'Enter' || event.key === ' ') {
      start(event);
    }
  };

  const handleKeyUp = (event: KeyboardEvent) => {
    if (event.key === 'Enter' || event.key === ' ') {
      end(event);
    }
  };

  element.addEventListener('pointerdown', start);
  element.addEventListener('pointerup', end);
  element.addEventListener('pointercancel', cancel);
  element.addEventListener('mousedown', start);
  element.addEventListener('mouseup', end);
  element.addEventListener('keydown', handleKeyDown);
  element.addEventListener('keyup', handleKeyUp);

  return () => {
    element.removeEventListener('pointerdown', start);
    element.removeEventListener('pointerup', end);
    element.removeEventListener('pointercancel', cancel);
    element.removeEventListener('mousedown', start);
    element.removeEventListener('mouseup', end);
    element.removeEventListener('keydown', handleKeyDown);
    element.removeEventListener('keyup', handleKeyUp);
  };
});

export { press };
export default press;
