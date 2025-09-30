import Component from '@glimmer/component';
import { action } from '@ember/object';
import { Dropdown } from '../dropdown';
import {
  hide,
  show,
  isVisible
} from '@universal-ember/table/plugins/column-visibility';
import type { Table, Column } from './types';

interface ColumnVisibilitySignature<T> {
  Args: {
    /** Universal-ember table instance */
    tableInstance?: Table<T>;
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
  get columns() {
    return this.args.tableInstance?.columns.values() || [];
  }

  get selectedKeys() {
    return this.columns
      .filter((column: Column<T>) => isVisible(column))
      .map((column: Column<T>) => column.key);
  }

  get allColumnKeys() {
    return this.columns.map((column: any) => column.key);
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
        <d.Trigger @intent="default" @size="sm">

          {{#if (has-block "icon")}}
            {{yield to="icon"}}
          {{else}}
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke-width="1.5"
              stroke="currentColor"
              class="size-6"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M9 4.5v15m6-15v15m-10.875 0h15.75c.621 0 1.125-.504 1.125-1.125V5.625c0-.621-.504-1.125-1.125-1.125H4.125C3.504 4.5 3 5.004 3 5.625v12.75c0 .621.504 1.125 1.125 1.125Z"
              />
            </svg>
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
