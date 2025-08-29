import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import { keyAndLabelForItem } from '../../utils/listManager';
import { getSafeValue } from './utils';
import { TableHeader } from './table-header';
import { TableBody } from './table-body';
import { TableColumn } from './table-column';
import { TableRow } from './table-row';
import { TableCell } from './table-cell';
import type { TableSignature, ColumnDefinition } from './types';

class Table<T = unknown> extends Component<TableSignature<T>> {
  get classNames() {
    // TODO: Add table styles to theme
    const classes = ['table'];
    if (this.args.class) {
      classes.push(this.args.class);
    }
    return classes.join(' ');
  }

  get columns(): ColumnDefinition<T>[] {
    return this.args.columns || [];
  }

  get items(): T[] {
    return this.args.items || [];
  }

  getValue = (item: T, column: ColumnDefinition<T>) => getSafeValue(item, column);

  <template>
    <table
      class={{this.classNames}}
      data-test-id="table"
      data-component="table"
      ...attributes
    >
      {{#if (has-block "default")}}
        {{yield
          (hash
            Column=TableColumn
            Header=TableHeader
            Body=TableBody
            Row=TableRow
            Cell=TableCell
          )
          to="default"
        }}
      {{else}}
        <TableHeader @columns={{this.columns}}>
          {{#each this.columns as |column|}}
            <TableColumn @column={{column}}>
              {{column.label}}
            </TableColumn>
          {{/each}}
        </TableHeader>

        <TableBody @columns={{this.columns}} @items={{this.items}}>
          {{#each this.items as |item|}}
            <TableRow @item={{item}} @columns={{this.columns}}>
              {{#each this.columns as |column|}}
                {{#let (this.getValue item column) as |value|}}
                  <TableCell
                    @item={{item}}
                    @column={{column}}
                    @value={{value}}
                  >
                    {{value}}
                  </TableCell>
                {{/let}}
              {{/each}}
            </TableRow>
          {{/each}}
        </TableBody>
      {{/if}}
    </table>
  </template>
}

export { Table, type TableSignature };
export default Table;