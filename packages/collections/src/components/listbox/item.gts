import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { assert } from '@ember/debug';
import { on } from '@ember/modifier';
import { useStyles } from '@frontile/theme';
import { Divider } from '@frontile/utilities';
import { guidFor } from '@ember/object/internals';
import type { TOC } from '@ember/component/template-only';
import type { ListManager, ListItem } from '../../utils/listManager';

export interface ListboxItemSignature {
  Args: {
    manager: ListManager;
    key: string;
    textValue?: string;
    description?: string;
    shortcut?: string;
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
    intent?: 'default' | 'primary' | 'success' | 'warning' | 'danger';

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

  get tabindex() {
    if (this.listItem?.isActive || this.listItem?.isSelected) {
      return 0;
    }
    return -1;
  }

  get classNames() {
    const { listboxItem } = useStyles();

    const {
      base,
      descriptionWrapper,
      label,
      description,
      selectedIcon,
      shortcut
    } = listboxItem({
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
      selectedIcon: selectedIcon(),
      shortcut: shortcut()
    };
  }

  get role() {
    if (this.args.type === 'menu') {
      return 'menuitem';
    }
    return 'option';
  }

  <template>
    <li
      {{this.manager.setupItem
        key=this.key
        textValue=@textValue
        onRegister=this.onRegister
      }}
      {{on "click" this.onClick}}
      role={{this.role}}
      aria-labelledby={{this.labelId}}
      tabindex={{this.tabindex}}
      data-active="{{this.listItem.isActive}}"
      data-selected="{{this.listItem.isSelected}}"
      data-test-id="listbox-item"
      data-component="listbox-item"
      data-key={{this.key}}
      disabled={{this.listItem.isDisabled}}
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
          >{{yield to="default"}}</span>
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
        >{{yield to="default"}}</span>
      {{/if}}

      {{#if @shortcut}}
        <kbd
          data-test-id="listbox-item-shortcut"
          class={{this.classNames.shortcut}}
        >{{@shortcut}}</kbd>
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
