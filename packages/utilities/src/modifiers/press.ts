import { modifier } from 'ember-modifier';
import { assert } from '@ember/debug';

export type PressType = 'pressstart' | 'pressend' | 'pressup' | 'press';
export type PointerType = 'mouse' | 'pen' | 'touch' | 'keyboard' | 'virtual';

export class PressEvent {
  /** The type of press event. */
  type: PressType;
  /** The pointer type that triggered the press event. */
  pointerType: PointerType;
  /** The target element of the press event. */
  target: Element;
  /** Whether the shift keyboard modifier was held during the press event. */
  shiftKey: boolean;
  /** Whether the ctrl keyboard modifier was held during the press event. */
  ctrlKey: boolean;
  /** Whether the meta keyboard modifier was held during the press event. */
  metaKey: boolean;
  /** Whether the alt keyboard modifier was held during the press event. */
  altKey: boolean;
  /** The x position of the event relative to the target element. */
  x: number;
  /** The y position of the event relative to the target element. */
  y: number;
  private shouldContinuePropagation = false;
  private originalEvent: Event;

  constructor(
    type: PressType,
    pointerType: PointerType,
    originalEvent: Event,
    target: Element
  ) {
    this.type = type;
    this.pointerType = pointerType;
    this.target = target;
    this.originalEvent = originalEvent;
    this.shiftKey = this.getModifierState(originalEvent, 'shiftKey');
    this.ctrlKey = this.getModifierState(originalEvent, 'ctrlKey');
    this.metaKey = this.getModifierState(originalEvent, 'metaKey');
    this.altKey = this.getModifierState(originalEvent, 'altKey');

    const coords = this.getCoordinates(originalEvent, target);
    this.x = coords.x;
    this.y = coords.y;
  }

  /** By default, press events stop propagation to parent elements. */
  continuePropagation(): void {
    this.shouldContinuePropagation = true;
  }

  /** Prevents the default browser behavior for this event. */
  preventDefault(): void {
    this.originalEvent.preventDefault();
  }

  get shouldPropagate(): boolean {
    return this.shouldContinuePropagation;
  }

  private getModifierState(
    event: Event,
    key: 'shiftKey' | 'ctrlKey' | 'metaKey' | 'altKey'
  ): boolean {
    if (
      event instanceof KeyboardEvent ||
      event instanceof MouseEvent ||
      event instanceof PointerEvent
    ) {
      return event[key];
    }
    return false;
  }

  private getCoordinates(
    event: Event,
    target: Element
  ): { x: number; y: number } {
    if (event instanceof MouseEvent || event instanceof PointerEvent) {
      const rect = target.getBoundingClientRect();
      return {
        x: event.clientX - rect.left,
        y: event.clientY - rect.top
      };
    }
    return { x: 0, y: 0 };
  }
}

function getPointerType(event: Event): PointerType {
  if (event instanceof PointerEvent) {
    return event.pointerType as PointerType;
  }
  if (event instanceof KeyboardEvent) {
    return 'keyboard';
  }
  if (event instanceof MouseEvent) {
    return 'mouse';
  }
  return 'virtual';
}

function isHTMLAnchorLink(element: Element): boolean {
  return element instanceof HTMLAnchorElement && element.hasAttribute('href');
}

function shouldPreventDefaultUp(target: Element): boolean {
  if (target instanceof HTMLInputElement) {
    return false;
  }

  if (target instanceof HTMLButtonElement) {
    return target.type !== 'submit' && target.type !== 'reset';
  }

  if (isHTMLAnchorLink(target)) {
    return false;
  }

  return true;
}

function isValidInputKey(target: HTMLInputElement, key: string): boolean {
  const nonTextInputTypes = new Set([
    'checkbox',
    'radio',
    'range',
    'color',
    'file',
    'image',
    'button',
    'submit',
    'reset'
  ]);

  return target.type === 'checkbox' || target.type === 'radio'
    ? key === ' '
    : nonTextInputTypes.has(target.type);
}

function shouldPreventDefaultKeyboard(target: Element, key: string): boolean {
  if (target instanceof HTMLInputElement) {
    return !isValidInputKey(target, key);
  }
  return shouldPreventDefaultUp(target);
}

export interface PressOptions {
  onPressStart?: (event: PressEvent) => void;
  onPressEnd?: (event: PressEvent) => void;
  onPress?: (event: PressEvent) => void;
  onPressUp?: (event: PressEvent) => void;
  onPressChange?: (isPressed: boolean) => void;
}

export interface PressSignature {
  Element: HTMLElement;
  Args: {
    Positional: [(event: PressEvent) => void] | [];
    Named: PressOptions;
  };
}

const press = modifier<PressSignature>(
  (
    element: HTMLElement,
    positional: PressSignature['Args']['Positional'],
    named: PressOptions = {}
  ) => {
    let isPressed = false;
    const cleanupFunctions: (() => void)[] = [];
    let documentListenersActive = false;
    let currentPointerType: PointerType | null = null;

    // Handle positional onPress argument
    const positionalOnPress = positional[0];

    assert(
      'You cannot provide both a positional onPress function and the onPress named argument to the press modifier. Choose one approach.',
      !(positionalOnPress && named.onPress)
    );

    // Use positional or named onPress
    const onPress = positionalOnPress || named.onPress;

    // Check if any callbacks are provided
    const hasAnyCallback =
      named.onPressStart ||
      named.onPressEnd ||
      onPress ||
      named.onPressUp ||
      named.onPressChange;

    if (!hasAnyCallback) {
      return () => {};
    }

    // Determine which types of events we need based on callbacks
    // We need start events if we have onPressStart OR if we have any end events (to track state) OR onPressChange
    const needsStartEvents =
      named.onPressStart ||
      named.onPressEnd ||
      onPress ||
      named.onPressUp ||
      named.onPressChange;
    const needsEndEvents =
      named.onPressEnd || onPress || named.onPressUp || named.onPressChange;

    // Check if we should ignore this event due to pointer event deduplication
    const shouldIgnoreEvent = (event: Event): boolean => {
      const eventPointerType = getPointerType(event);

      // If this is a mouse event but we already have a pointer/touch interaction active, ignore it
      if (
        eventPointerType === 'mouse' &&
        currentPointerType &&
        currentPointerType !== 'mouse'
      ) {
        return true;
      }

      // In mobile Safari, both pointer and mouse events can fire for the same touch.
      // If we have pointer event support, ignore mouse events entirely on touch devices
      if (
        eventPointerType === 'mouse' &&
        'PointerEvent' in window &&
        'ontouchstart' in window
      ) {
        return true;
      }

      return false;
    };

    const addDocumentListeners = (): void => {
      if (documentListenersActive || !needsEndEvents) {
        return;
      }
      documentListenersActive = true;
      document.addEventListener('pointerup', end, true);
      document.addEventListener('mouseup', end, true);
      document.addEventListener('pointercancel', cancel, true);
    };

    const removeDocumentListeners = (): void => {
      if (!documentListenersActive) {
        return;
      }
      documentListenersActive = false;
      document.removeEventListener('pointerup', end, true);
      document.removeEventListener('mouseup', end, true);
      document.removeEventListener('pointercancel', cancel, true);
    };

    const start = (event: Event): void => {
      if (shouldIgnoreEvent(event)) {
        return;
      }

      if (!isPressed) {
        isPressed = true;
        currentPointerType = getPointerType(event);
        addDocumentListeners();
        named.onPressChange?.(true);
        const pressEvent = new PressEvent(
          'pressstart',
          getPointerType(event),
          event,
          element
        );
        named.onPressStart?.(pressEvent);
        if (!pressEvent.shouldPropagate) {
          event.stopPropagation();
        }
      }
    };

    const end = (event: Event): void => {
      if (shouldIgnoreEvent(event) || !isPressed) {
        return;
      }

      isPressed = false;
      currentPointerType = null;
      removeDocumentListeners();
      named.onPressChange?.(false);

      const pressEndEvent = new PressEvent(
        'pressend',
        getPointerType(event),
        event,
        element
      );
      named.onPressEnd?.(pressEndEvent);

      if (element.contains(event.target as Node)) {
        const pressEvent = new PressEvent(
          'press',
          getPointerType(event),
          event,
          element
        );
        onPress?.(pressEvent);
        if (!pressEvent.shouldPropagate) {
          event.stopPropagation();
        }
      }

      const pressUpEvent = new PressEvent(
        'pressup',
        getPointerType(event),
        event,
        element
      );
      named.onPressUp?.(pressUpEvent);

      if (!pressEndEvent.shouldPropagate) {
        event.stopPropagation();
      }
    };

    const cancel = (event: PointerEvent): void => {
      if (!isPressed) {
        return;
      }
      isPressed = false;
      currentPointerType = null;
      removeDocumentListeners();
      named.onPressChange?.(false);
      const pressEvent = new PressEvent(
        'pressend',
        getPointerType(event),
        event,
        element
      );
      named.onPressEnd?.(pressEvent);
      if (!pressEvent.shouldPropagate) {
        event.stopPropagation();
      }
    };

    const handleKeyDown = (event: KeyboardEvent): void => {
      if (event.key === 'Enter' || event.key === ' ') {
        if (shouldPreventDefaultKeyboard(element, event.key)) {
          event.preventDefault();
        }
        start(event);
      }
    };

    const handleKeyUp = (event: KeyboardEvent): void => {
      if (event.key === 'Enter' || event.key === ' ') {
        if (shouldPreventDefaultKeyboard(element, event.key)) {
          event.preventDefault();
        }
        end(event);
      }
    };

    // Add pointer/mouse down events only if we need start events
    if (needsStartEvents) {
      element.addEventListener('pointerdown', start);
      element.addEventListener('mousedown', start);

      cleanupFunctions.push(() => {
        element.removeEventListener('pointerdown', start);
        element.removeEventListener('mousedown', start);
      });
    }

    // Add pointer/mouse up events only if we need end events
    if (needsEndEvents) {
      element.addEventListener('pointerup', end);
      element.addEventListener('mouseup', end);

      cleanupFunctions.push(() => {
        element.removeEventListener('pointerup', end);
        element.removeEventListener('mouseup', end);
      });
    }

    // Add pointer cancel only if we have onPressEnd (since cancel triggers onPressEnd)
    if (named.onPressEnd) {
      element.addEventListener('pointercancel', cancel);

      cleanupFunctions.push(() => {
        element.removeEventListener('pointercancel', cancel);
      });
    }

    // Add keyboard events - both start and end events if we have any callbacks that need them
    if (needsStartEvents) {
      element.addEventListener('keydown', handleKeyDown);
      cleanupFunctions.push(() => {
        element.removeEventListener('keydown', handleKeyDown);
      });
    }

    if (needsEndEvents) {
      element.addEventListener('keyup', handleKeyUp);
      cleanupFunctions.push(() => {
        element.removeEventListener('keyup', handleKeyUp);
      });
    }

    return (): void => {
      cleanupFunctions.forEach((cleanup) => cleanup());
      removeDocumentListeners();
      currentPointerType = null;
      isPressed = false;
    };
  }
);

export { press };
export default press;
