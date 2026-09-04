import { modifier } from 'ember-modifier';

type RovingFocusOrientation = 'horizontal' | 'vertical';
type RovingFocusActivationMode = 'automatic' | 'manual';

interface RovingFocusOptions {
  /** @defaultValue 'horizontal' */
  orientation?: RovingFocusOrientation;

  /**
   * `automatic` moves selection with focus, which is what the radiogroup
   * pattern requires. `manual` moves focus only and waits for Enter or Space,
   * which tabs may want when switching panels is expensive.
   *
   * @defaultValue 'automatic'
   */
  activationMode?: RovingFocusActivationMode;

  /**
   * Called when an item becomes the active one: on every focus move when
   * `activationMode` is `automatic`, or on Enter/Space when it is `manual`.
   * Receives the element that was activated.
   */
  onActivate?: (element: HTMLElement) => void;
}

const SELECTED_ATTRIBUTE = 'data-fr-roving-selected';
const DISABLED_ATTRIBUTE = 'data-fr-roving-disabled';

/**
 * Keyboard navigation for a single-tab-stop group: arrow keys by orientation,
 * Home/End, wrapping, disabled items skipped, and exactly one tabbable item.
 *
 * Options are supplied as a thunk rather than a snapshot, so a consumer whose
 * orientation or activation mode is an argument stays reactive without having
 * to push updates in.
 */
class RovingFocus {
  #items: HTMLElement[] = [];
  #readOptions: () => RovingFocusOptions;

  constructor(readOptions: () => RovingFocusOptions = () => ({})) {
    this.#readOptions = readOptions;
  }

  /**
   * Modifier to place on each candidate item, passing whether it is
   * currently selected and whether it is disabled as positional arguments.
   */
  setupItem = modifier(
    (element: HTMLElement, [isSelected, isDisabled]: [boolean, boolean]) => {
      element.setAttribute(SELECTED_ATTRIBUTE, isSelected ? 'true' : 'false');
      element.setAttribute(DISABLED_ATTRIBUTE, isDisabled ? 'true' : 'false');

      this.#register(element);
      element.addEventListener('keydown', this.handleKeydown);
      this.#syncTabStops();

      return (): void => {
        element.removeEventListener('keydown', this.handleKeydown);
        this.#items = this.#items.filter((item) => item !== element);
        this.#syncTabStops();
      };
    }
  );

  handleKeydown = (event: KeyboardEvent): void => {
    const current = event.currentTarget as HTMLElement | null;
    if (!current) {
      return;
    }

    const { activationMode = 'automatic', onActivate } = this.#readOptions();

    if (
      activationMode === 'manual' &&
      (event.key === 'Enter' || event.key === ' ')
    ) {
      event.preventDefault();
      onActivate?.(current);
      return;
    }

    const next = this.#resolve(event.key, current);
    if (!next) {
      return;
    }

    event.preventDefault();
    next.focus();

    if (activationMode === 'automatic') {
      onActivate?.(next);
    }
  };

  #register(element: HTMLElement): void {
    if (!this.#items.includes(element)) {
      this.#items.push(element);
    }
    // Modifier setup order is not guaranteed to match DOM order once items are
    // added or reordered, and navigation has to follow what the user sees.
    this.#items.sort((a, b) =>
      a.compareDocumentPosition(b) & Node.DOCUMENT_POSITION_FOLLOWING ? -1 : 1
    );
  }

  get #enabled(): HTMLElement[] {
    return this.#items.filter(
      (item) => item.getAttribute(DISABLED_ATTRIBUTE) !== 'true'
    );
  }

  #resolve(key: string, current: HTMLElement): HTMLElement | undefined {
    const { orientation = 'horizontal' } = this.#readOptions();

    let forward = orientation === 'horizontal' ? 'ArrowRight' : 'ArrowDown';
    let backward = orientation === 'horizontal' ? 'ArrowLeft' : 'ArrowUp';

    // The one place direction genuinely matters: in RTL the right arrow moves
    // towards the *start* of the group. Vertical order is unaffected.
    if (
      orientation === 'horizontal' &&
      getComputedStyle(current).direction === 'rtl'
    ) {
      [forward, backward] = [backward, forward];
    }

    const enabled = this.#enabled;
    if (enabled.length === 0) {
      return undefined;
    }

    const index = enabled.indexOf(current);
    if (index === -1) {
      return key === 'Home' || key === forward ? enabled[0] : undefined;
    }

    switch (key) {
      case forward:
        return enabled[(index + 1) % enabled.length];
      case backward:
        return enabled[(index - 1 + enabled.length) % enabled.length];
      case 'Home':
        return enabled[0];
      case 'End':
        return enabled[enabled.length - 1];
      default:
        return undefined;
    }
  }

  /**
   * Exactly one item is tabbable. It is the selected one, or -- per the
   * radiogroup pattern, where a group with nothing selected still has to be
   * reachable by Tab -- the first enabled item.
   */
  #syncTabStops(): void {
    const selected = this.#items.find(
      (item) =>
        item.getAttribute(SELECTED_ATTRIBUTE) === 'true' &&
        item.getAttribute(DISABLED_ATTRIBUTE) !== 'true'
    );
    const stop = selected ?? this.#enabled[0];

    for (const item of this.#items) {
      item.tabIndex = item === stop ? 0 : -1;
    }
  }
}

export {
  RovingFocus,
  type RovingFocusOptions,
  type RovingFocusOrientation,
  type RovingFocusActivationMode
};
