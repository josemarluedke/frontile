import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { assert } from '@ember/debug';
import { on } from '@ember/modifier';
import { useStyles } from '@frontile/theme';
import { Divider } from '../../utilities/divider';
import { Kbd } from '../../utilities/kbd';
import type { KbdSignature } from '../../utilities/kbd';
import { guidFor } from '@ember/object/internals';
import type { TOC } from '@ember/component/template-only';
import type { ListManager, ListItem } from '../../../utils/listManager';

export interface ListboxItemSignature {
  Args: {
    manager: ListManager;
    key: string;
    textValue?: string;

    /**
     * The entry of `@items` this option renders, remembered on the registered
     * list item so a selection can hand it back. Bound for you on the Item
     * yielded from the `:item` block; block-form options have no such entry.
     */
    item?: unknown;

    description?: string;

    /**
     * A keyboard shortcut shown at the end of the option, rendered by `Kbd`.
     * Accepts named keys (`"mod+k"`) or a literal string (`"⌘K"`).
     */
    shortcut?: string;

    /**
     * The appearance of the rendered shortcut. Defaults to `inherit`, so the
     * keycap follows the option's own colour on active and filled rows.
     *
     * @defaultValue 'inherit'
     */
    shortcutAppearance?: KbdSignature['Args']['appearance'];
    onClick?: () => void;
    class?: string;
    withDivider?: boolean;

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

    type?: 'menu' | 'listbox';
  };
  Element: HTMLLIElement;
  Blocks: {
    default: [];
    selectedIcon: [];
    start: [];
    end: [];
  };
}

class ListboxItem extends Component<ListboxItemSignature> {
  // Stable element id so consumers (e.g. Autocomplete) can reference the
  // option via aria-activedescendant.
  itemId = `${guidFor(this)}-option`;
  labelId = guidFor(this);
  @tracked listItem?: ListItem;

  get manager(): ListManager {
    assert(
      `ListboxItem does not have a listManager; Missing argument @manager`,
      this.args.manager
    );

    return this.args.manager;
  }

  get key(): string {
    assert(
      `Argument @key is undefined or null, @key must be provided in Listbox.Item component`,
      this.args.key
    );

    return this.args.key;
  }

  @action
  onRegister(item: ListItem) {
    this.listItem = item;
  }

  @action
  onClick(): void {
    if (this.listItem?.isDisabled) {
      return;
    }

    this.manager.selectItem(this.listItem);

    if (typeof this.args.onClick === 'function') {
      this.args.onClick();
    }
  }

  /**
   * A roving tabindex: the manager nominates one option as the composite's tab
   * stop and every other option stays out of the tab order, as the ARIA
   * listbox pattern requires. Giving a `0` to each active *or selected* option
   * turned a multi-select with eight selections into eight tab stops.
   */
  get tabindex() {
    return this.manager.isTabStop(this.key) ? 0 : -1;
  }

  get classNames() {
    const { listboxItem } = useStyles();

    const { base, descriptionWrapper, label, description, selectedIcon } =
      listboxItem({
        appearance: this.args.appearance || 'default',
        intent: this.args.intent || 'default',
        isDisabled: this.listItem?.isDisabled,
        isSelected: this.listItem?.isSelected,
        isActive: this.listItem?.isActive,
        withDivider: this.args.withDivider
      });

    return {
      base: base({ class: this.args.class }),
      descriptionWrapper: descriptionWrapper(),
      label: label(),
      description: description(),
      selectedIcon: selectedIcon()
    };
  }

  /**
   * `inherit` by default so the keycap picks up the option's own colour rather
   * than the theme having to repaint it for every intent on an active row.
   */
  get shortcutAppearance() {
    return this.args.shortcutAppearance ?? 'inherit';
  }

  get role() {
    if (this.args.type === 'menu') {
      return 'menuitem';
    }
    return 'option';
  }

  /**
   * `aria-selected` belongs on `option`, and only there — a plain `menuitem`
   * that carries it is invalid ARIA, since menu items convey state through
   * `aria-checked` and only as `menuitemcheckbox`/`menuitemradio`. Returning
   * undefined omits the attribute rather than rendering an empty one.
   */
  get ariaSelected(): 'true' | 'false' | undefined {
    if (this.role !== 'option') {
      return undefined;
    }
    return this.listItem?.isSelected ? 'true' : 'false';
  }

  <template>
    <li
      {{this.manager.setupItem
        key=this.key
        textValue=@textValue
        item=@item
        onRegister=this.onRegister
      }}
      {{on "click" this.onClick}}
      id={{this.itemId}}
      role={{this.role}}
      aria-labelledby={{this.labelId}}
      aria-selected={{this.ariaSelected}}
      tabindex={{this.tabindex}}
      data-active="{{this.listItem.isActive}}"
      data-selected="{{this.listItem.isSelected}}"
      data-test-id="listbox-item"
      data-component="listbox-item"
      data-key={{this.key}}
      aria-disabled={{if this.listItem.isDisabled "true"}}
      class={{this.classNames.base}}
      ...attributes
    >
      {{yield to="start"}}

      {{#if @description}}
        <div class={{this.classNames.descriptionWrapper}}>
          <span
            data-test-id="listbox-item-label"
            class={{this.classNames.label}}
            id={{this.labelId}}
          >{{yield}}</span>
          <span
            data-test-id="listbox-item-description"
            class={{this.classNames.description}}
          >{{@description}}</span>
        </div>
      {{else}}
        <span
          data-test-id="listbox-item-label"
          class={{this.classNames.label}}
          id={{this.labelId}}
        >{{yield}}</span>
      {{/if}}

      {{#if @shortcut}}
        <Kbd
          @keys={{@shortcut}}
          @size="sm"
          @appearance={{this.shortcutAppearance}}
          data-test-id="listbox-item-shortcut"
        />
      {{/if}}

      {{#if this.listItem.isSelected}}
        <span
          data-test-id="listbox-item-selected-icon"
          class={{this.classNames.selectedIcon}}
        >
          {{#if (has-block "selectedIcon")}}
            {{yield to="selectedIcon"}}
          {{else}}
            <CheckIcon class="h-full w-full" />
          {{/if}}
        </span>
      {{/if}}

      {{yield to="end"}}
    </li>
    {{#if @withDivider}}
      <Divider @as="li" />
    {{/if}}
  </template>
}

const CheckIcon: TOC<{
  Element: SVGElement;
}> = <template>
  <svg
    xmlns="http://www.w3.org/2000/svg"
    fill="none"
    viewBox="0 0 24 24"
    stroke-width="1.5"
    stroke="currentColor"
    ...attributes
  >
    <path
      stroke-linecap="round"
      stroke-linejoin="round"
      d="m4.5 12.75 6 6 9-13.5"
    />
  </svg>
</template>;

export { ListboxItem };
