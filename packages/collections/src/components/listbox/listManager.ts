/* eslint-disable ember/no-runloop */
import { tracked } from '@glimmer/tracking';
import { debounce } from '@ember/runloop';
import { modifier } from 'ember-modifier';

type SelectionMode = 'none' | 'single' | 'multiple';

class Node {
  el: HTMLLIElement | HTMLOptionElement;
  key: string;
  textValue: string;

  @tracked isSelected: boolean;
  @tracked isDisabled: boolean;
  @tracked isActive: boolean;

  constructor(el: HTMLLIElement | HTMLOptionElement, args: Required<NodeArgs>) {
    this.el = el;
    this.key = args.key;
    this.textValue = args.textValue;
    this.isSelected = args.isSelected;
    this.isDisabled = args.isDisabled;
    this.isActive = args.isActive;
  }
}

interface NodeArgs {
  key: string;
  textValue?: string;
  isSelected?: boolean;
  isDisabled?: boolean;
  isActive?: boolean;
}

interface ListManagerOptions {
  selectionMode?: SelectionMode;
  selectedKeys?: string[];
  disabledKeys?: string[];
  allowEmpty?: boolean;
  onAction?: (key: string) => void;
  onSelectionChange?: (key: string[]) => void;
  onNodesChange?: (nodes: Node[], action: 'add' | 'remove') => void;
}

class ListManager {
  searchKeys: string = '';

  #selectionMode: SelectionMode = 'none';
  #nodes: Node[] = [];
  #selectedKeys: string[] = [];
  #disabledKeys: string[] = [];
  #allowEmpty: boolean = false;
  #onAction?: (key: string) => void;
  #onSelectionChange?: (key: string[]) => void;
  #onNodesChange?: (nodes: Node[], action: 'add' | 'remove') => void;

  constructor(options: ListManagerOptions = {}) {
    this.update(options);
  }

  register(
    el: HTMLLIElement | HTMLOptionElement,
    args: Required<NodeArgs>
  ): void {
    this.#nodes.push(new Node(el, args));

    if (typeof this.#onNodesChange === 'function') {
      this.#onNodesChange(this.#nodes, 'add');
    }
  }

  unregister(el: HTMLLIElement | HTMLOptionElement): void {
    this.#nodes = this.#nodes.filter((node) => node.el !== el);

    if (typeof this.#onNodesChange === 'function') {
      this.#onNodesChange(this.#nodes, 'remove');
    }
  }

  at(el?: HTMLLIElement | HTMLOptionElement): Node | undefined {
    return this.#nodes.find((node) => node.el === el);
  }

  atKey(key: string): Node | undefined {
    return this.#nodes.find((node) => node.key === key);
  }

  update(options: ListManagerOptions): void {
    this.#selectionMode = options.selectionMode || 'none';
    this.#selectedKeys = options.selectedKeys || [];
    this.#disabledKeys = options.disabledKeys || [];
    this.#allowEmpty = options.allowEmpty || false;

    for (let i = 0; i < this.#nodes.length; i++) {
      const node = this.#nodes[i] as Node;
      node.isSelected = this.isKeySelected(node.key);
      node.isDisabled = this.isKeyDisabled(node.key);
    }

    if (options.onAction) {
      this.#onAction = options.onAction;
    }

    if (options.onSelectionChange) {
      this.#onSelectionChange = options.onSelectionChange;
    }

    if (options.onNodesChange) {
      this.#onNodesChange = options.onNodesChange;
    }
  }

  selectActiveNode(): void {
    const node = this.#activeNode;
    if (node) {
      node.el.click();
    }
  }

  selectNode(node?: Node): void {
    if (node) {
      if (this.#selectionMode !== 'none') {
        this.activateNode(node);
      }
      if (typeof this.#onAction === 'function') {
        this.#onAction(node.key);
      }

      if (
        typeof this.#onSelectionChange === 'function' &&
        this.#selectionMode !== 'none'
      ) {
        this.#onSelectionChange(this.#toggleSelectedKey(node));
      }
    }
  }

  activateNode(node?: Node): void {
    if (node) {
      this.#clearActive();
      node.isActive = true;
      node.el.focus();
    }
  }

  setNextOptionActive(): void {
    for (let i = this.#indexOfActiveNode + 1; i < this.#nodes.length; i++) {
      const node = this.#nodes[i];
      if (node && !node.isDisabled) {
        this.activateNode(node);
        break;
      }
    }
  }

  setPreviousOptionActive(): void {
    for (let i = this.#indexOfActiveNode - 1; i >= 0; i--) {
      const node = this.#nodes[i];
      if (node && !node.isDisabled) {
        this.activateNode(node);
        break;
      }
    }
  }

  setFirstOptionActive(): void {
    for (let i = 0; i < this.#nodes.length; i++) {
      const node = this.#nodes[i];
      if (node && !node.isDisabled) {
        this.activateNode(node);
        break;
      }
    }
  }

  setLastOptionActive(): void {
    for (let i = this.#nodes.length - 1; i >= 0; i--) {
      const node = this.#nodes[i];
      if (node && !node.isDisabled) {
        this.activateNode(node);
        break;
      }
    }
  }

  search(key: string): void {
    debounce(this, this.#clearSeaerch, 500);
    this.searchKeys += key.toLowerCase();

    for (let i = 0; i < this.#nodes.length; i++) {
      const node = this.#nodes[i] as Node;

      if (
        !node.isDisabled &&
        this.searchKeys &&
        node.textValue.trim().toLowerCase().startsWith(this.searchKeys)
      ) {
        this.activateNode(node);
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

  get #indexOfActiveNode(): number {
    let node = this.#activeNode;

    if (!node) {
      for (let i = 0; i < this.#nodes.length; i++) {
        const n = this.#nodes[i] as Node;
        if (n.isSelected) {
          node = n;
          break;
        }
      }
    }
    if (!node) {
      return -1;
    }
    return this.#nodes.indexOf(node);
  }

  #toggleSelectedKey(node: Node): string[] {
    let selectedKeys: string[] = [];

    for (let i = 0; i < this.#nodes.length; i++) {
      const node = this.#nodes[i] as Node;
      if (node.isSelected) {
        selectedKeys.push(node.key);
      }
    }

    if (
      selectedKeys.includes(node.key) &&
      ((this.#allowEmpty && selectedKeys.length == 1) ||
        selectedKeys.length > 1)
    ) {
      const indexToRemove = selectedKeys.indexOf(node.key);
      selectedKeys.splice(indexToRemove, 1);
    } else {
      if (this.#selectionMode === 'single') {
        selectedKeys = [node.key];
      } else if (!selectedKeys.includes(node.key)) {
        selectedKeys.push(node.key);
      }
    }

    return selectedKeys;
  }

  get #activeNode(): Node | undefined {
    for (let i = 0; i < this.#nodes.length; i++) {
      const node = this.#nodes[i] as Node;
      if (node.isActive) {
        return node;
      }
    }
  }

  #clearSeaerch(): void {
    this.searchKeys = '';
  }

  #clearActive(): void {
    for (let i = 0; i < this.#nodes.length; i++) {
      const node = this.#nodes[i] as Node;
      if (node.isActive) {
        node.isActive = false;
      }
    }
  }

  onUpdate = modifier(
    (
      _el: HTMLUListElement | HTMLSelectElement,
      _: unknown[],
      args: ListManagerOptions
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
      args: Pick<NodeArgs, 'key' | 'textValue'> & {
        onRegister?: (node: Node) => void;
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
      const node = this.at(el);
      if (node && typeof args.onRegister === 'function') {
        args.onRegister(node);
      }

      const mouseEnter = (): void => {
        this.activateNode(node);
      };

      const mouseLeave = (): void => {
        if (node) {
          node.isActive = false;
        }
      };

      el.addEventListener('mouseenter', mouseEnter);
      el.addEventListener('mouseleave', mouseLeave);

      return (): void => {
        this.unregister(el);

        el.removeEventListener('mouseenter', mouseEnter);
        el.removeEventListener('mouseleave', mouseLeave);
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

export type { Node, NodeArgs, SelectionMode };
export { ListManager, keyAndLabelForItem };
