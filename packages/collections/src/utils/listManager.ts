/* eslint-disable ember/no-runloop */
import { tracked } from '@glimmer/tracking';
import { debounce } from '@ember/runloop';
import { modifier } from 'ember-modifier';

type SelectionMode = 'none' | 'single' | 'multiple';

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

interface ListManagerOptions {
  selectionMode?: SelectionMode;
  selectedKeys?: string[];
  disabledKeys?: string[];
  allowEmpty?: boolean;
  onAction?: (key: string) => void;
  onSelectionChange?: (key: string[]) => void;
  onListItemsChange?: (items: ListItem[], action: 'add' | 'remove') => void;
}

class ListManager {
  searchKeys: string = '';

  #selectionMode: SelectionMode = 'none';
  #items: ListItem[] = [];
  #selectedKeys: string[] = [];
  #disabledKeys: string[] = [];
  #allowEmpty: boolean = false;
  #onAction?: (key: string) => void;
  #onSelectionChange?: (key: string[]) => void;
  #onListItemsChange?: (items: ListItem[], action: 'add' | 'remove') => void;

  constructor(options: ListManagerOptions = {}) {
    this.update(options);
  }

  register(
    el: HTMLLIElement | HTMLOptionElement,
    args: Required<ListItemArgs>
  ): void {
    this.#items.push(new ListItem(el, args));

    if (typeof this.#onListItemsChange === 'function') {
      this.#onListItemsChange(this.#items, 'add');
    }
  }

  unregister(el: HTMLLIElement | HTMLOptionElement): void {
    this.#items = this.#items.filter((item) => item.el !== el);

    if (typeof this.#onListItemsChange === 'function') {
      this.#onListItemsChange(this.#items, 'remove');
    }
  }

  at(el?: HTMLLIElement | HTMLOptionElement): ListItem | undefined {
    return this.#items.find((item) => item.el === el);
  }

  atKey(key: string): ListItem | undefined {
    return this.#items.find((item) => item.key === key);
  }

  update(options: ListManagerOptions): void {
    this.#selectionMode = options.selectionMode || 'none';
    this.#selectedKeys = options.selectedKeys || [];
    this.#disabledKeys = options.disabledKeys || [];
    this.#allowEmpty = options.allowEmpty || false;

    for (let i = 0; i < this.#items.length; i++) {
      const item = this.#items[i] as ListItem;
      item.isSelected = this.isKeySelected(item.key);
      item.isDisabled = this.isKeyDisabled(item.key);
    }

    if (options.onAction) {
      this.#onAction = options.onAction;
    }

    if (options.onSelectionChange) {
      this.#onSelectionChange = options.onSelectionChange;
    }

    if (options.onListItemsChange) {
      this.#onListItemsChange = options.onListItemsChange;
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
      if (this.#selectionMode !== 'none') {
        this.activateItem(item);
      }
      if (typeof this.#onAction === 'function') {
        this.#onAction(item.key);
      }

      if (
        typeof this.#onSelectionChange === 'function' &&
        this.#selectionMode !== 'none'
      ) {
        this.#onSelectionChange(this.#toggleSelectedItem(item));
      }
    }
  }

  activateItem(item?: ListItem): void {
    if (item) {
      this.#clearActive();
      item.isActive = true;
      item.el.focus();
    }
  }

  setNextOptionActive(): void {
    for (let i = this.#indexofActiveItem + 1; i < this.#items.length; i++) {
      const item = this.#items[i];
      if (item && !item.isDisabled) {
        this.activateItem(item);
        break;
      }
    }
  }

  setPreviousOptionActive(): void {
    for (let i = this.#indexofActiveItem - 1; i >= 0; i--) {
      const item = this.#items[i];
      if (item && !item.isDisabled) {
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
    return this.#disabledKeys.includes(key);
  }

  isKeySelected(key: string): boolean {
    return this.#selectedKeys.includes(key);
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
      ((this.#allowEmpty && selectedKeys.length == 1) ||
        selectedKeys.length > 1)
    ) {
      const indexToRemove = selectedKeys.indexOf(item.key);
      selectedKeys.splice(indexToRemove, 1);
    } else {
      if (this.#selectionMode === 'single') {
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
      args: ListManagerOptions & { isKeyboardEventsEnabled?: boolean }
    ) => {
      this.update({
        selectionMode: args.selectionMode,
        disabledKeys: args.disabledKeys,
        selectedKeys: args.selectedKeys,
        allowEmpty: args.allowEmpty
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

export type { ListItem, ListItemArgs, SelectionMode };
export { ListManager, keyAndLabelForItem };
