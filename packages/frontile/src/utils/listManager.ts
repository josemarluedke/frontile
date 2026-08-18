/* eslint-disable ember/no-runloop */
import { tracked } from '@glimmer/tracking';
import { debounce } from '@ember/runloop';
import { modifier } from 'ember-modifier';
import { later } from '@ember/runloop';

type SelectionMode = 'none' | 'single' | 'multiple';
type AutoActivateMode = 'none' | 'first' | 'selected';

interface ListItemArgs {
  key: string;
  textValue?: string;
  isSelected?: boolean;
  isDisabled?: boolean;
  isActive?: boolean;
}

class ListItem {
  el: HTMLLIElement | HTMLOptionElement;
  key: string;
  textValue: string;

  // Ember's tracked setter dirties a tag unconditionally — it never compares
  // against the current value. That makes a redundant write more than wasted
  // work here: Glimmer reads an attribute and writes it to the DOM inside a
  // single autotracking frame, and writing `tabindex` onto the focused item
  // blurs it, so the browser dispatches `focusout` synchronously and this
  // item's own listeners run *inside* the frame that just consumed `isActive`.
  // Dirtying a tag that frame already consumed trips a backtracking-rerender
  // assertion, so every field below only writes on a real change.
  //
  // Each comparison reads a plain mirror rather than the tracked field itself.
  // Reading the tracked field would *consume* its tag, so the write that
  // followed would dirty a tag the current frame had just consumed — precisely
  // the failure these guards exist to prevent. For the same reason, code that
  // reads a field only to decide whether to write it should read the mirror;
  // `isActiveUntracked` exposes that for the one caller outside this class.
  @tracked private _isSelected: boolean;
  @tracked private _isDisabled: boolean;
  @tracked private _isActive: boolean;

  private isSelectedMirror: boolean;
  private isDisabledMirror: boolean;
  private isActiveMirror: boolean;

  get isSelected(): boolean {
    return this._isSelected;
  }

  set isSelected(value: boolean) {
    if (this.isSelectedMirror !== value) {
      this.isSelectedMirror = value;
      this._isSelected = value;
    }
  }

  get isDisabled(): boolean {
    return this._isDisabled;
  }

  set isDisabled(value: boolean) {
    if (this.isDisabledMirror !== value) {
      this.isDisabledMirror = value;
      this._isDisabled = value;
    }
  }

  get isActive(): boolean {
    return this._isActive;
  }

  set isActive(value: boolean) {
    if (this.isActiveMirror !== value) {
      this.isActiveMirror = value;
      this._isActive = value;
    }
  }

  /** `isActive` read without consuming its tag, for write decisions. */
  get isActiveUntracked(): boolean {
    return this.isActiveMirror;
  }

  constructor(
    el: HTMLLIElement | HTMLOptionElement,
    args: Required<ListItemArgs>
  ) {
    this.el = el;
    this.key = args.key;
    this.textValue = args.textValue;
    this._isSelected = this.isSelectedMirror = args.isSelected;
    this._isDisabled = this.isDisabledMirror = args.isDisabled;
    this._isActive = this.isActiveMirror = args.isActive;
  }
}

interface ListManagerArgs {
  selectionMode?: SelectionMode;
  selectedKeys?: string[];
  disabledKeys?: string[];
  allowEmpty?: boolean;
  autoActivateMode?: AutoActivateMode;
  onAction?: (key: string) => void;
  onSelectionChange?: (key: string[]) => void;
  onListItemsChange?: (items: ListItem[], action: 'add' | 'remove') => void;
  onActiveItemChange?: (key?: string, item?: ListItem) => void;
}

class ListManager {
  #items: ListItem[] = [];

  searchKeys: string = '';
  args: ListManagerArgs = {
    selectionMode: 'none',
    selectedKeys: [],
    disabledKeys: [],
    allowEmpty: false,
    autoActivateMode: 'none'
  };

  constructor(args: ListManagerArgs = {}) {
    this.updateArgs(args);
  }

  /**
   * Registered items that are still in the document, in DOM order.
   *
   * The order cannot be maintained eagerly as items register: Glimmer moves
   * the element of an item that persists across an update instead of
   * re-creating it (no registration to react to), and it installs the
   * modifiers of newly rendered items before tearing down the ones they
   * replace — so a sort at registration time both misses later moves and
   * compares against detached elements, which `compareDocumentPosition`
   * orders arbitrarily. Deriving the order from the document when it is
   * needed keeps navigation in step with what the user sees.
   */
  get #orderedItems(): ListItem[] {
    return this.#items
      .filter((item) => item.el.isConnected)
      .sort((a, b) => {
        const position = a.el.compareDocumentPosition(b.el);
        if (position & Node.DOCUMENT_POSITION_FOLLOWING) return -1;
        if (position & Node.DOCUMENT_POSITION_PRECEDING) return 1;
        return 0;
      });
  }

  /** Whether any registered item is still in the document. */
  get #hasVisibleItems(): boolean {
    return this.#items.some((item) => item.el.isConnected);
  }

  /**
   * The registered item that comes first in the document, found in a single
   * pass so callers that need only one item do not pay to order the whole
   * list.
   */
  get #firstVisibleItem(): ListItem | undefined {
    let first: ListItem | undefined;
    for (const item of this.#items) {
      if (!item.el.isConnected) continue;
      if (
        !first ||
        item.el.compareDocumentPosition(first.el) &
          Node.DOCUMENT_POSITION_FOLLOWING
      ) {
        first = item;
      }
    }
    return first;
  }

  register(
    el: HTMLLIElement | HTMLOptionElement,
    args: Required<ListItemArgs>
  ): void {
    const newItem = new ListItem(el, args);
    if (
      this.args.autoActivateMode == 'first' &&
      !this.#hasVisibleItems &&
      !args.isDisabled
    ) {
      newItem.isActive = true;
      this.args.onActiveItemChange?.(newItem.key, newItem);
    }
    this.#items.push(newItem);

    if (typeof this.args.onListItemsChange === 'function') {
      this.args.onListItemsChange(this.#orderedItems, 'add');
    }

    if (this.args.autoActivateMode != 'none' && this.#items.length > 1) {
      later(() => {
        if (this.args.autoActivateMode == 'first') {
          this.setFirstOptionActive();
        } else {
          this.setSelectedOptionActive();
        }
      }, 1);
    }
  }

  unregister(el: HTMLLIElement | HTMLOptionElement): void {
    this.#items = this.#items.filter((item) => item.el !== el);

    if (this.args.autoActivateMode == 'first') {
      // Deferred for the same reason as the activation in `register`: unregister
      // runs while Glimmer tears down the elements it is replacing, which is the
      // same render pass in which item templates have already consumed
      // `isActive`. Activating synchronously here would write to that tracked
      // state after it was read, tripping a backtracking-rerender assertion.
      later(() => {
        this.activateItem(this.#firstVisibleItem);
      }, 1);
    }

    if (typeof this.args.onListItemsChange === 'function') {
      this.args.onListItemsChange(this.#orderedItems, 'remove');
    }
  }

  at(el?: HTMLLIElement | HTMLOptionElement): ListItem | undefined {
    return this.#items.find((item) => item.el === el);
  }

  atKey(key: string): ListItem | undefined {
    return this.#items.find((item) => item.key === key);
  }

  updateArgs(args: ListManagerArgs): void {
    this.args.selectedKeys = args.selectedKeys || [];
    this.args.disabledKeys = args.disabledKeys || [];
    this.args.allowEmpty = args.allowEmpty || false;
    this.args.autoActivateMode = args.autoActivateMode || 'none';

    for (let i = 0; i < this.#items.length; i++) {
      const item = this.#items[i] as ListItem;
      item.isSelected = this.isKeySelected(item.key);
      item.isDisabled = this.isKeyDisabled(item.key);
    }

    if (args.selectionMode) {
      this.args.selectionMode = args.selectionMode;
    }

    if (args.onAction) {
      this.args.onAction = args.onAction;
    }

    if (args.onSelectionChange) {
      this.args.onSelectionChange = args.onSelectionChange;
    }

    if (args.onListItemsChange) {
      this.args.onListItemsChange = args.onListItemsChange;
    }

    if (args.onActiveItemChange) {
      this.args.onActiveItemChange = args.onActiveItemChange;
    }
  }

  selectActiveItem(): void {
    const item = this.#activeItem;
    if (item) {
      item.el.click();
    }
  }

  selectItem(item?: ListItem): void {
    if (item) {
      if (this.args.selectionMode !== 'none') {
        this.activateItem(item);
      }
      if (typeof this.args.onAction === 'function') {
        this.args.onAction(item.key);
      }

      if (
        typeof this.args.onSelectionChange === 'function' &&
        this.args.selectionMode !== 'none'
      ) {
        this.args.onSelectionChange(this.#toggleSelectedItem(item));
      }
    }
  }

  activateItem(item?: ListItem): void {
    // `isActiveUntracked`, not `isActive`: this read only decides whether to
    // write, and consuming the tag here would put the write below in the same
    // frame as a read of it — the hazard `ListItem` documents.
    if (item && !item.isActiveUntracked) {
      this.#clearActive();
      item.isActive = true;
      this.args.onActiveItemChange?.(item.key, item);

      // Ensure the item is scrolled into view
      requestAnimationFrame(() => {
        item.el.scrollIntoView({ block: 'nearest', inline: 'nearest' });
      });
    }
  }

  setNextOptionActive(): void {
    const items = this.#orderedItems;
    for (let i = this.#indexOfActiveItem(items) + 1; i < items.length; i++) {
      const item = items[i];
      if (item && !item.isDisabled && !item.isActive) {
        this.activateItem(item);
        break;
      }
    }
  }

  setPreviousOptionActive(): void {
    const items = this.#orderedItems;
    for (let i = this.#indexOfActiveItem(items) - 1; i >= 0; i--) {
      const item = items[i];
      if (item && !item.isDisabled && !item.isActive) {
        this.activateItem(item);
        break;
      }
    }
  }

  setFirstOptionActive(): void {
    const items = this.#orderedItems;
    for (let i = 0; i < items.length; i++) {
      const item = items[i];
      if (item && !item.isDisabled) {
        this.activateItem(item);
        break;
      }
    }
  }

  setSelectedOptionActive(): void {
    const items = this.#orderedItems;
    let activated = false;

    for (let i = 0; i < items.length; i++) {
      const item = items[i];
      if (item && !item.isDisabled && item.isSelected) {
        this.activateItem(item);
        activated = true;
        break;
      }
    }

    if (!activated) {
      this.setFirstOptionActive();
    }
  }

  setLastOptionActive(): void {
    const items = this.#orderedItems;
    for (let i = items.length - 1; i >= 0; i--) {
      const item = items[i];
      if (item && !item.isDisabled) {
        this.activateItem(item);
        break;
      }
    }
  }

  search(key: string): void {
    debounce(this, this.#clearSeaerch, 500);
    this.searchKeys += key.toLowerCase();

    const items = this.#orderedItems;
    for (let i = 0; i < items.length; i++) {
      const item = items[i] as ListItem;

      if (
        !item.isDisabled &&
        this.searchKeys &&
        item.textValue.trim().toLowerCase().startsWith(this.searchKeys)
      ) {
        this.activateItem(item);
        break;
      }
    }
  }

  isKeyDisabled(key: string): boolean {
    return this.args.disabledKeys?.includes(key) || false;
  }

  isKeySelected(key: string): boolean {
    return this.args.selectedKeys?.includes(key) || false;
  }

  #indexOfActiveItem(items: ListItem[]): number {
    let item = items.find((i) => i.isActive);

    if (!item) {
      item = items.find((i) => i.isSelected);
    }
    if (!item) {
      return -1;
    }
    return items.indexOf(item);
  }

  #toggleSelectedItem(item: ListItem): string[] {
    let selectedKeys: string[] = [];

    const items = this.#orderedItems;
    for (let i = 0; i < items.length; i++) {
      const _item = items[i] as ListItem;
      if (_item.isSelected) {
        selectedKeys.push(_item.key);
      }
    }

    if (
      selectedKeys.includes(item.key) &&
      ((this.args.allowEmpty && selectedKeys.length == 1) ||
        selectedKeys.length > 1)
    ) {
      const indexToRemove = selectedKeys.indexOf(item.key);
      selectedKeys.splice(indexToRemove, 1);
    } else {
      if (this.args.selectionMode === 'single') {
        selectedKeys = [item.key];
      } else if (!selectedKeys.includes(item.key)) {
        selectedKeys.push(item.key);
      }
    }

    return selectedKeys;
  }

  get #activeItem(): ListItem | undefined {
    return this.#orderedItems.find((item) => item.isActive);
  }

  #clearSeaerch(): void {
    this.searchKeys = '';
  }

  #clearActive(): void {
    for (let i = 0; i < this.#items.length; i++) {
      // No `isActive` check: the setter already skips unchanged values, and
      // reading it here would consume every item's tag on a path that can run
      // mid-render.
      (this.#items[i] as ListItem).isActive = false;
    }
  }

  setup = modifier(
    (
      _el: HTMLUListElement | HTMLSelectElement,
      _: unknown[],
      args: ListManagerArgs
    ) => {
      this.updateArgs({
        selectionMode: args.selectionMode,
        disabledKeys: args.disabledKeys,
        selectedKeys: args.selectedKeys,
        allowEmpty: args.allowEmpty,
        autoActivateMode: args.autoActivateMode
      });
    }
  );

  setupItem = modifier(
    (
      el: HTMLLIElement | HTMLOptionElement,
      _: unknown[],
      args: Pick<ListItemArgs, 'key' | 'textValue'> & {
        onRegister?: (item: ListItem) => void;
        disableEvents?: boolean;
      }
    ) => {
      let textValue = args.textValue;
      if (
        typeof textValue === 'undefined' ||
        textValue === '' ||
        textValue === null
      ) {
        const labelId = el.getAttribute('aria-labelledby');
        if (labelId) {
          const labelElement = el.querySelector(`#${labelId}`);
          if (labelElement) {
            textValue = labelElement.textContent?.trim() || '';
          }
        } else {
          textValue = el.textContent?.trim() || '';
        }
      }

      this.register(el as HTMLLIElement, {
        key: args.key,
        textValue: textValue || '',
        isActive: false,
        isDisabled: this.isKeyDisabled(args.key),
        isSelected: this.isKeySelected(args.key)
      });
      const item = this.at(el);
      if (item && typeof args.onRegister === 'function') {
        args.onRegister(item);
      }

      const mouseEnter = (): void => {
        this.activateItem(item);
      };

      const mouseLeave = (): void => {
        if (item) {
          item.isActive = false;
        }
      };

      // Glimmer mutates this item's DOM during a render — rewriting `tabindex`
      // on the focused item, or clearing the block that contains it — and the
      // browser reacts by blurring the element and dispatching `focusout`
      // synchronously, inside the frame that just consumed `isActive` (see
      // `ListItem` above). Those blurs carry no `relatedTarget`.
      //
      // Neither do some genuine ones: clicking a non-focusable region,
      // switching tab or window, or moving focus to browser chrome. Ignoring
      // every targetless blur therefore trades a possibly-stale highlight for
      // never writing tracked state mid-render. That is a good trade here —
      // for a roving-tabindex widget, keeping the active item across a blur is
      // closer to the ARIA pattern than clearing it.
      const focusOut = (event: Event): void => {
        if ((event as FocusEvent).relatedTarget === null) {
          return;
        }
        mouseLeave();
      };

      if (!args.disableEvents) {
        el.addEventListener('mouseenter', mouseEnter);
        el.addEventListener('mouseleave', mouseLeave);

        el.addEventListener('focusin', mouseEnter);
        el.addEventListener('focusout', focusOut);
      }

      return (): void => {
        this.unregister(el);

        if (!args.disableEvents) {
          el.removeEventListener('mouseenter', mouseEnter);
          el.removeEventListener('mouseleave', mouseLeave);

          el.removeEventListener('focusin', mouseEnter);
          el.removeEventListener('focusout', focusOut);
        }
      };
    }
  );
}

function keyAndLabelForItem(item: unknown): { key: string; label: string } {
  // Handle primitive types directly
  if (typeof item === 'string' || typeof item === 'number') {
    const value = item.toString();
    return { key: value, label: value };
  }

  // If the item is an object, try to extract key and label using common property names
  if (typeof item === 'object' && item !== null) {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const typedItem = item as any;

    // Try to use the 'key' property first; if not available, use 'id'
    let keyProp = typedItem.key || typedItem.id;
    if (keyProp === undefined) {
      keyProp = item.toString();
    }

    // Determine the label by checking multiple possible properties
    let labelProp =
      typedItem.label || typedItem.value || typedItem.name || typedItem.title;
    if (labelProp === undefined) {
      labelProp = item.toString();
    }

    return { key: keyProp.toString(), label: labelProp.toString() };
  }

  // Fallback if item does not match expected types
  return { key: '', label: '' };
}

/**
 * Default option-matching used by Select and Autocomplete:
 * case-insensitive "contains".
 */
function defaultFilter(itemValue: string, filterValue: string): boolean {
  return itemValue.toLowerCase().includes(filterValue.toLowerCase());
}

export type { ListItem, ListItemArgs, SelectionMode, AutoActivateMode };
export { ListManager, keyAndLabelForItem, defaultFilter };
