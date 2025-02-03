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

  @tracked isSelected: boolean;
  @tracked isDisabled: boolean;
  @tracked isActive: boolean;

  constructor(
    el: HTMLLIElement | HTMLOptionElement,
    args: Required<ListItemArgs>
  ) {
    this.el = el;
    this.key = args.key;
    this.textValue = args.textValue;
    this.isSelected = args.isSelected;
    this.isDisabled = args.isDisabled;
    this.isActive = args.isActive;
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
  onActiveItemChange?: (key?: string) => void;
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

  register(
    el: HTMLLIElement | HTMLOptionElement,
    args: Required<ListItemArgs>
  ): void {
    if (
      this.args.autoActivateMode == 'first' &&
      this.#items.length === 0 &&
      !args.isDisabled
    ) {
      args.isActive = true;
      this.args.onActiveItemChange?.(args.key);
    }
    const newItem = new ListItem(el, args);
    this.#items.push(newItem);
    this.#syncItemsOrderWithDOM();

    if (typeof this.args.onListItemsChange === 'function') {
      this.args.onListItemsChange(this.#items, 'add');
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

    if (this.args.autoActivateMode == 'first' && this.#items.length >= 1) {
      this.activateItem(this.#items[0]);
    }

    if (typeof this.args.onListItemsChange === 'function') {
      this.args.onListItemsChange(this.#items, 'remove');
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
    if (item && !item.isActive) {
      this.#clearActive();
      item.isActive = true;
      this.args.onActiveItemChange?.(item.key);

      // Ensure the item is scrolled into view
      requestAnimationFrame(() => {
        item.el.scrollIntoView({ block: 'nearest', inline: 'nearest' });
      });
    }
  }

  setNextOptionActive(): void {
    for (let i = this.#indexofActiveItem + 1; i < this.#items.length; i++) {
      const item = this.#items[i];
      if (item && !item.isDisabled && !item.isActive) {
        this.activateItem(item);
        break;
      }
    }
  }

  setPreviousOptionActive(): void {
    for (let i = this.#indexofActiveItem - 1; i >= 0; i--) {
      const item = this.#items[i];
      if (item && !item.isDisabled && !item.isActive) {
        this.activateItem(item);
        break;
      }
    }
  }

  setFirstOptionActive(): void {
    for (let i = 0; i < this.#items.length; i++) {
      const item = this.#items[i];
      if (item && !item.isDisabled) {
        this.activateItem(item);
        break;
      }
    }
  }

  setSelectedOptionActive(): void {
    let activated = false;

    for (let i = 0; i < this.#items.length; i++) {
      const item = this.#items[i];
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
    for (let i = this.#items.length - 1; i >= 0; i--) {
      const item = this.#items[i];
      if (item && !item.isDisabled) {
        this.activateItem(item);
        break;
      }
    }
  }

  search(key: string): void {
    debounce(this, this.#clearSeaerch, 500);
    this.searchKeys += key.toLowerCase();

    for (let i = 0; i < this.#items.length; i++) {
      const item = this.#items[i] as ListItem;

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

  get #indexofActiveItem(): number {
    let item = this.#activeItem;

    if (!item) {
      for (let i = 0; i < this.#items.length; i++) {
        const n = this.#items[i] as ListItem;
        if (n.isSelected) {
          item = n;
          break;
        }
      }
    }
    if (!item) {
      return -1;
    }
    return this.#items.indexOf(item);
  }

  // Ensure #items is always in sync with DOM order
  #syncItemsOrderWithDOM(): void {
    if (!this.#items.length) return;

    // Sort items based on their position in the DOM
    this.#items.sort((a, b) => {
      const position = a.el.compareDocumentPosition(b.el);
      if (position & Node.DOCUMENT_POSITION_FOLLOWING) return -1;
      if (position & Node.DOCUMENT_POSITION_PRECEDING) return 1;
      return 0;
    });
  }

  #toggleSelectedItem(item: ListItem): string[] {
    let selectedKeys: string[] = [];

    for (let i = 0; i < this.#items.length; i++) {
      const _item = this.#items[i] as ListItem;
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
    for (let i = 0; i < this.#items.length; i++) {
      const item = this.#items[i] as ListItem;
      if (item.isActive) {
        return item;
      }
    }
  }

  #clearSeaerch(): void {
    this.searchKeys = '';
  }

  #clearActive(): void {
    for (let i = 0; i < this.#items.length; i++) {
      const item = this.#items[i] as ListItem;
      if (item.isActive) {
        item.isActive = false;
      }
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

      if (!args.disableEvents) {
        el.addEventListener('mouseenter', mouseEnter);
        el.addEventListener('mouseleave', mouseLeave);

        el.addEventListener('focusin', mouseEnter);
        el.addEventListener('focusout', mouseLeave);
      }

      return (): void => {
        this.unregister(el);

        if (!args.disableEvents) {
          el.removeEventListener('mouseenter', mouseEnter);
          el.removeEventListener('mouseleave', mouseLeave);

          el.removeEventListener('focusin', mouseEnter);
          el.removeEventListener('focusout', mouseLeave);
        }
      };
    }
  );
}
function keyAndLabelForItem(item: unknown): {
  key: string;
  label: string;
} {
  if (typeof item === 'string' || typeof item === 'number') {
    return { key: item.toString(), label: item.toString() };
  } else if (typeof item === 'object' && item !== null) {
    const typedItem = item as { key: string; label: string };
    if ('key' in typedItem && 'label' in typedItem) {
      return { key: typedItem.key, label: typedItem.label };
    } else {
      return { key: item.toString(), label: item.toString() };
    }
  }
  return { key: '', label: '' };
}

export type { ListItem, ListItemArgs, SelectionMode, AutoActivateMode };
export { ListManager, keyAndLabelForItem };
