import { tracked } from '@glimmer/tracking';
import { debounce } from '@ember/runloop';

type SelectionMode = 'none' | 'single' | 'multiple';

class Node {
  el: HTMLLIElement;
  key: string;
  textValue: string;

  @tracked isSelected: boolean;
  @tracked isDisabled: boolean;
  @tracked isActive: boolean;

  constructor(el: HTMLLIElement, args: Required<NodeArgs>) {
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

  constructor(options: ListManagerOptions = {}) {
    this.update(options);
  }

  register(el: HTMLLIElement, args: Required<NodeArgs>): void {
    this.#nodes.push(new Node(el, args));
  }

  unregister(el: HTMLLIElement): void {
    this.#nodes = this.#nodes.filter((node) => node.el !== el);
  }

  at(el?: HTMLLIElement): Node | undefined {
    return this.#nodes.find((node) => node.el === el);
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
}

export type { Node, NodeArgs, SelectionMode };
export { ListManager };
