import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { on } from '@ember/modifier';
import { useStyles } from '@frontile/theme';
import {
  ListManager,
  keyAndLabelForItem,
  type SelectionMode,
  type ListItem
} from '../../../utils/listManager';
import { ListboxItem, type ListboxItemSignature } from './item';
import { ListboxGroup, type ListboxGroupSignature } from './group';
import { modifier } from 'ember-modifier';
import type { WithBoundArgs } from '@glint/template';

type ItemCompBounded = WithBoundArgs<typeof ListboxItem, 'manager'>;
type GroupCompBounded = WithBoundArgs<typeof ListboxGroup, 'manager'>;
type ItemCompBoundedWithItem = WithBoundArgs<
  typeof ListboxItem,
  'manager' | 'item'
>;

interface ListboxSignature<T> {
  Args: {
    /**
     * @default 'listbox'
     */
    type?: 'menu' | 'listbox';
    selectionMode?: SelectionMode;
    selectedKeys?: string[];
    disabledKeys?: string[];
    allowEmpty?: boolean;
    items?: T[];
    class?: string;
    isKeyboardEventsEnabled?: boolean;

    /** The element to add keyboard events to.
     *
     * This does not respect the option `iskeyboardEventsEnabled`.
     * @defaultValue null
     */
    elementToAddKeyboardEvents?: HTMLElement;

    /**
     * @defaultValue 'first'
     */
    autoActivateMode?: 'none' | 'first' | 'selected';

    onAction?: (key: string) => void;
    onSelectionChange?: (key: string[]) => void;
    onActiveItemChange?: (key?: string, item?: ListItem) => void;

    /**
     * The appearance of each item
     *
     * @defaultValue 'default'
     */
    appearance?: 'default' | 'outlined' | 'faded';

    /**
     * The intent of each item
     */
    intent?:
      | 'default'
      | 'primary'
      | 'secondary'
      | 'tertiary'
      | 'success'
      | 'warning'
      | 'danger';
  };
  Element: HTMLUListElement;
  Blocks: {
    item: [
      { item: T; key: string; label: string; Item: ItemCompBoundedWithItem }
    ];
    default: [{ Item: ItemCompBounded; Group: GroupCompBounded }];
  };
}

const isInputElement = (
  target: EventTarget | null
): target is HTMLInputElement => {
  return target instanceof HTMLInputElement;
};

const isUndefined = (a: unknown) => typeof a === 'undefined';

class Listbox<T = unknown> extends Component<ListboxSignature<T>> {
  listManager = new ListManager({
    selectionMode: this.args.selectionMode,
    selectedKeys: this.args.selectedKeys,
    disabledKeys: this.args.disabledKeys,
    allowEmpty: this.args.allowEmpty,
    onSelectionChange: this.args.onSelectionChange,
    onAction: this.args.onAction,
    onActiveItemChange: this.args.onActiveItemChange,
    autoActivateMode: isUndefined(this.args.autoActivateMode)
      ? 'first'
      : this.args.autoActivateMode
  });

  handleKeyPress = (event: KeyboardEvent) => {
    if (isInputElement(event.target)) {
      if (event.key === 'Enter') {
        this.listManager.selectActiveItem();
        return;
      }
    } else {
      if (
        ['Enter', ' '].includes(event.key) &&
        this.listManager.searchKeys == ''
      ) {
        this.listManager.selectActiveItem();
        event.preventDefault();
        event.stopPropagation();
        return;
      } else if (event.key.length === 1) {
        this.listManager.search(event.key);
        return;
      }
    }
  };

  handleKeyDown = (event: KeyboardEvent) => {
    if (
      ['ArrowUp', 'ArrowDown', 'PageUp', 'PageDown', 'Home', 'End'].includes(
        event.key
      )
    ) {
      event.preventDefault();

      if (event.key === 'ArrowDown') {
        this.listManager.setNextOptionActive();
      } else if (event.key === 'ArrowUp') {
        this.listManager.setPreviousOptionActive();
      } else if (event.key === 'Home' || event.key === 'PageUp') {
        this.listManager.setFirstOptionActive();
      } else if (event.key === 'End' || event.key === 'PageDown') {
        this.listManager.setLastOptionActive();
      }
    }
  };

  onKeyPress = (event: KeyboardEvent) => {
    if (this.args.isKeyboardEventsEnabled) {
      this.handleKeyPress(event);
    }
  };

  onKeyDown = (event: KeyboardEvent) => {
    if (this.args.isKeyboardEventsEnabled) {
      this.handleKeyDown(event);
    }
  };

  setupEvents = modifier(
    (
      _el: HTMLElement,
      _: unknown[],
      args: { elementToAddKeyboardEvents?: HTMLElement }
    ) => {
      if (args.elementToAddKeyboardEvents) {
        args.elementToAddKeyboardEvents.addEventListener(
          'keydown',
          this.handleKeyDown
        );
        args.elementToAddKeyboardEvents.addEventListener(
          'keypress',
          this.handleKeyPress
        );
      }

      return () => {
        if (args.elementToAddKeyboardEvents) {
          args.elementToAddKeyboardEvents.removeEventListener(
            'keydown',
            this.handleKeyDown
          );
          args.elementToAddKeyboardEvents.removeEventListener(
            'keypress',
            this.handleKeyPress
          );
        }
      };
    }
  );

  get classNames() {
    const { listbox } = useStyles();
    return listbox({ class: this.args.class });
  }

  get role() {
    if (this.args.type === 'menu') {
      return this.args.type;
    }
    return 'listbox';
  }

  /**
   * A listbox that accepts more than one selection has to say so, otherwise a
   * screen reader presents it as a single-choice list. Only meaningful on
   * `role="listbox"`; a `menu` conveys multi-select through its item roles.
   */
  get ariaMultiselectable(): 'true' | undefined {
    if (this.role !== 'listbox') {
      return undefined;
    }
    return this.args.selectionMode === 'multiple' ? 'true' : undefined;
  }

  <template>
    <ul
      tabindex="0"
      role={{this.role}}
      aria-multiselectable={{this.ariaMultiselectable}}
      {{! The callbacks travel through setup, not only through the manager's
      field initializer above: that initializer runs once, so an onAction
      rebuilt on a later render would otherwise never reach the manager. }}
      {{this.listManager.setup
        selectedKeys=@selectedKeys
        disabledKeys=@disabledKeys
        selectionMode=@selectionMode
        allowEmpty=@allowEmpty
        onAction=@onAction
        onSelectionChange=@onSelectionChange
        onActiveItemChange=@onActiveItemChange
        autoActivateMode=(if
          (isUndefined @autoActivateMode) "first" @autoActivateMode
        )
      }}
      {{on "keypress" this.onKeyPress}}
      {{on "keydown" this.onKeyDown}}
      {{this.setupEvents
        elementToAddKeyboardEvents=@elementToAddKeyboardEvents
      }}
      data-test-id="listbox"
      data-component="listbox"
      class={{this.classNames}}
      ...attributes
    >
      {{#each @items as |item|}}
        {{#let (keyAndLabelForItem item) as |keyLabel|}}
          {{#if (has-block "item")}}
            {{yield
              (hash
                item=item
                key=keyLabel.key
                label=keyLabel.label
                Item=(component
                  ListboxItem
                  manager=this.listManager
                  appearance=@appearance
                  intent=@intent
                  type=this.role
                  key=keyLabel.key
                  item=item
                )
              )
              to="item"
            }}
          {{else}}
            <ListboxItem
              @manager={{this.listManager}}
              @key={{keyLabel.key}}
              @item={{item}}
              @appearance={{@appearance}}
              @intent={{@intent}}
              @type={{this.role}}
            >
              {{keyLabel.label}}
            </ListboxItem>
          {{/if}}
        {{/let}}
      {{/each}}

      {{yield
        (hash
          Item=(component
            ListboxItem
            manager=this.listManager
            appearance=@appearance
            intent=@intent
            type=this.role
          )
          Group=(component
            ListboxGroup
            manager=this.listManager
            appearance=@appearance
            intent=@intent
            type=this.role
          )
        )
      }}
    </ul>
  </template>
}

export {
  Listbox,
  ListboxItem,
  ListboxGroup,
  type ListboxSignature,
  type ListboxItemSignature,
  type ListboxGroupSignature,
  type ListItem
};
export default Listbox;
