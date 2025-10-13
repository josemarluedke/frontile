import Component from '@glimmer/component';
import { action } from '@ember/object';
import { useStyles } from '@frontile/theme';
import { Dropdown } from '../dropdown';
import {
  hide,
  show,
  isVisible
} from '@universal-ember/table/plugins/column-visibility';
import { ColumnVisibilityIcon } from './icons';
import type { Table, Column } from './types';

interface ColumnVisibilitySignature<T> {
  Args: {
    /** Universal-ember table instance */
    tableInstance?: Table<T>;
    /** Size of the column visibility button. @defaultValue 'xs' */
    size?: 'xs' | 'sm' | 'lg' | 'xl';
  };
  Element: HTMLUListElement;
  Blocks: {
    default: [];
    icon: [];
  };
}

export default class ColumnVisibility<T> extends Component<
  ColumnVisibilitySignature<T>
> {
  get styles() {
    const { table } = useStyles();
    return table();
  }

  get size() {
    return this.args.size ?? 'xs';
  }

  get columns() {
    return this.args.tableInstance?.columns.values() || [];
  }

  get selectedKeys() {
    return this.columns
      .filter((column: Column<T>) => isVisible(column))
      .map((column: Column<T>) => column.key);
  }

  get allColumnKeys() {
    return this.columns.map((column: Column<T>) => column.key);
  }

  @action
  handleSelectionChange(selectedKeys: string[]) {
    this.columns.forEach((column: Column<T>) => {
      if (selectedKeys.includes(column.key)) {
        if (!isVisible(column)) {
          show(column);
        }
      } else {
        if (isVisible(column)) {
          hide(column);
        }
      }
    });
  }

  <template>
    <Dropdown @closeOnItemSelect={{false}} ...attributes>
      <:default as |d|>
        <d.Trigger
          @intent="default"
          @size={{this.size}}
          @class={{(this.styles.columnVisibilityButton)}}
        >

          {{#if (has-block "icon")}}
            {{yield to="icon"}}
          {{else}}
            <ColumnVisibilityIcon
              class={{(this.styles.columnVisibilityIcon)}}
            />
          {{/if}}
          {{yield}}
        </d.Trigger>

        <d.Menu
          @selectionMode="multiple"
          @selectedKeys={{this.selectedKeys}}
          @onSelectionChange={{this.handleSelectionChange}}
          as |Item|
        >
          {{#each @tableInstance.columns as |column|}}
            <Item @key={{column.key}}>
              {{column.name}}
            </Item>
          {{/each}}
        </d.Menu>
      </:default>
    </Dropdown>
  </template>
}
