import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { useStyles } from '@frontile/theme';
import didUpdate from '@ember/render-modifiers/modifiers/did-update';
import { ListManager, type SelectionMode } from './listManager';
import { ListboxItem } from './item';

export interface ListboxSignature {
  Args: {
    selectionMode: SelectionMode;
    selectedKeys: string[];
    disabledKeys: string[];
    allowEmpty: boolean;
    items: unknown[];
    class?: string;
    isKeyboardEventsEnabled?: boolean;

    onAction: (key: string) => void;
    onSelectionChange: (key: string[]) => void;
  };
  Element: HTMLUListElement;
  Blocks: {
    item: [unknown];
    default: [unknown];
  };
}

export default class Listbox extends Component<ListboxSignature> {
  listManager = new ListManager({
    selectionMode: this.args.selectionMode,
    selectedKeys: this.args.selectedKeys,
    disabledKeys: this.args.disabledKeys,
    allowEmpty: this.args.allowEmpty,
    onSelectionChange: this.args.onSelectionChange,
    onAction: this.args.onAction
  });

  @action
  handleKeyPress(event: KeyboardEvent) {
    if (this.args.isKeyboardEventsEnabled) {
      if (
        event.key === 'Enter' ||
        ((event.key === 'Space' || event.key === ' ') &&
          this.listManager.searchKeys == '')
      ) {
        this.listManager.selectActiveNode();
        event.preventDefault();
        event.stopPropagation();
      } else if (event.key.length === 1) {
        this.listManager.search(event.key);
      }
    }
  }

  @action
  handleKeyDown(event: KeyboardEvent) {
    if (!this.args.isKeyboardEventsEnabled) {
      return;
    }
    if (
      [
        'ArrowUp',
        'ArrowDown',
        'ArrowLeft',
        'ArrowRight',
        'PageUp',
        'PageDown',
        'Home',
        'End'
      ].includes(event.key)
    ) {
      event.preventDefault();
    }
  }

  @action
  handleKeyUp(event: KeyboardEvent) {
    if (!this.args.isKeyboardEventsEnabled) {
      return;
    }
    if (event.key === 'ArrowDown') {
      this.listManager.setNextOptionActive();
    } else if (event.key === 'ArrowRight') {
      this.listManager.setNextOptionActive();
    } else if (event.key === 'ArrowUp') {
      this.listManager.setPreviousOptionActive();
    } else if (event.key === 'ArrowLeft') {
      this.listManager.setPreviousOptionActive();
    } else if (event.key === 'Home' || event.key === 'PageUp') {
      this.listManager.setFirstOptionActive();
    } else if (event.key === 'End' || event.key === 'PageDown') {
      this.listManager.setLastOptionActive();
    }
  }

  get classNames() {
    const { listbox } = useStyles();
    const { base, list } = listbox();
    return { base: base({ class: this.args.class }), list: list() };
  }

  @action
  updateListManager() {
    this.listManager.update({
      selectionMode: this.args.selectionMode,
      disabledKeys: this.args.disabledKeys,
      selectedKeys: this.args.selectedKeys,
      allowEmpty: this.args.allowEmpty
    });
  }

  <template>
    <div class={{this.classNames.base}}>
      <ul
        tabindex='0'
        role='listbox'
        {{didUpdate this.updateListManager @selectedKeys @disabledKeys @selectionMode @allowEmpty}}
        {{on 'keypress' this.handleKeyPress}}
        {{on 'keydown' this.handleKeyDown}}
        {{on 'keyup' this.handleKeyUp}}
        data-test-id="listbox"
        class={{this.classNames.list}}
        ...attributes
      >
        {{#each @items as |item|}}
          {{#if (has-block "item")}}
            {{yield (hash
                      item=item
                      Item=(component ListboxItem manager=this.listManager)
            ) to="item"}}
          {{else}}
            {{! @glint-expect-error: if we get to this option, we are assuming the option is primitive value}}
            <ListboxItem @manager={{this.listManager}} @key={{item}}>{{item}}</ListboxItem>
          {{/if}}
        {{/each}}

        {{yield (hash Item=(component ListboxItem manager=this.listManager)) to="default"}}
      </ul>
    </div>
  </template>
}
