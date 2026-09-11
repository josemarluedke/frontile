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

    /**
     * The appearance of the keycap rendered for each item's `@shortcut`.
     *
     * @defaultValue 'inherit'
     */
    shortcutAppearance?: ListboxItemSignature['Args']['shortcutAppearance'];
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

const NAVIGATION_KEYS = [
  'ArrowUp',
  'ArrowDown',
  'PageUp',
  'PageDown',
  'Home',
  'End'
];

/**
 * Whether a command-style modifier is held.
 *
 * Enter, Space and type-ahead moved here from the deprecated `keypress`,
 * which largely did not deliver modifier combinations at all. `keydown` does,
 * and it reports an unchanged `key`: Cmd+K arrives as `key === 'k'`, Cmd+Space
 * (Spotlight) as `key === ' '`. Acting on those would swallow the user's and
 * the OS's shortcuts -- typing them into the search buffer, or selecting an
 * option nobody asked for -- so a modifier combo is not ours to handle.
 *
 * Shift is deliberately absent: a capital letter is legitimate type-ahead.
 * `Popover`'s open-on-letter handler makes the same check for the same
 * reason.
 *
 * Arrow and Home/End navigation is exempt, because it always lived on
 * `keydown` and so already had to tolerate these combinations.
 */
const hasCommandModifier = (event: KeyboardEvent): boolean => {
  return event.metaKey || event.ctrlKey || event.altKey;
};

/**
 * Whether a keystroke should extend the type-ahead search buffer.
 *
 * Any single printable character qualifies. Unlike `Popover`'s letter check
 * this deliberately does not require `event.code === 'Key' + key`, which
 * restricts matching to A-Z: a listbox types ahead with digits and
 * punctuation too, and the WAI-ARIA APG requires Space to extend an active
 * search.
 *
 * Autorepeat is dropped. `search()` accumulates a prefix rather than cycling
 * between same-initial items, so a leaned-on 'a' would build "aaaa" and match
 * nothing -- a hazard `keypress` never surfaced here. Keystrokes mid-IME
 * composition belong to the input method, not to type-ahead.
 */
const isTypeAheadKey = (event: KeyboardEvent): boolean => {
  return event.key.length === 1 && !event.repeat && !event.isComposing;
};

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

  /**
   * All keyboard behaviour lands on `keydown`.
   *
   * Selection and type-ahead used to live on a separate `keypress` listener.
   * A browser fires `keypress` only when the preceding `keydown` was not
   * canceled, so any co-located `keydown` handler calling `preventDefault()`
   * -- `Dropdown`'s submenu keys, a consuming app's shortcut handler --
   * silently deleted the event this component depended on, and Enter
   * selection stopped working with no error at all. `keypress` is also absent
   * from current spec guidance and inconsistent for non-printable keys.
   */
  handleKeyDown = (event: KeyboardEvent) => {
    if (NAVIGATION_KEYS.includes(event.key)) {
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

      return;
    }

    if (hasCommandModifier(event)) {
      return;
    }

    // Navigation above applies wherever the keystroke came from, but text
    // entry does not: when the events are forwarded from a real input (an
    // Autocomplete or Select trigger), the input owns the typing and only
    // Enter is ours to act on.
    if (isInputElement(event.target)) {
      if (event.key === 'Enter') {
        this.listManager.selectActiveItem();
      }
      return;
    }

    if (event.key === 'Enter') {
      // Enter always selects the active item, even mid-search — unlike
      // Space, Enter is never itself a type-ahead character (its length is
      // 5, not 1), so gating it on an empty search buffer just drops the
      // keystroke while `search()`'s 500ms debounce is still pending. Do
      // not fold this back into the Space branch below.
      this.listManager.selectActiveItem();
      this.listManager.clearSearch();
      event.preventDefault();
      event.stopPropagation();
      return;
    }

    if (event.key === ' ' && this.listManager.searchKeys == '') {
      this.listManager.selectActiveItem();
      event.preventDefault();
      event.stopPropagation();
      return;
    }

    if (isTypeAheadKey(event)) {
      if (event.key === ' ') {
        // Space extends an active search rather than selecting, but it must
        // still not scroll the page. Only `keydown` can prevent that; the
        // old `keypress` listener fired too late to stop it.
        event.preventDefault();
      }

      this.listManager.search(event.key);
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
      }

      return () => {
        if (args.elementToAddKeyboardEvents) {
          args.elementToAddKeyboardEvents.removeEventListener(
            'keydown',
            this.handleKeyDown
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
      {{on "keydown" this.onKeyDown}}
      {{this.setupEvents
        elementToAddKeyboardEvents=@elementToAddKeyboardEvents
      }}
      data-test-id="listbox"
      data-component="listbox"
      data-part="base"
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
                  shortcutAppearance=@shortcutAppearance
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
              @shortcutAppearance={{@shortcutAppearance}}
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
            shortcutAppearance=@shortcutAppearance
            type=this.role
          )
          Group=(component
            ListboxGroup
            manager=this.listManager
            appearance=@appearance
            intent=@intent
            shortcutAppearance=@shortcutAppearance
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
