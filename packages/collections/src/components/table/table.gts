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
  get styles() {
    const { table } = useStyles();
    return table({
      size: this.args.size,
      layout: this.args.layout,
      striped: this.args.striped,
      class: this.args.classes?.base
    });
  }

  get wrapperClassNames() {
    return this.styles.wrapper({ class: this.args.classes?.wrapper });
  }

  get tableClassNames() {
    return this.styles.table({ class: this.args.classes?.table });
  }

  get columns(): ColumnDefinition<T>[] {
    return this.args.columns || [];
  }

  get items(): T[] {
    return this.args.items || [];
  }

  getValue = (item: T, column: ColumnDefinition<T>) =>
    getSafeValue(item, column);

  <template>
    <div class={{this.wrapperClassNames}} data-component="table-wrapper">
      <table
        class={{this.tableClassNames}}
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
          <TableHeader
            @columns={{this.columns}}
            @theadStyles={{this.styles.thead}}
            @trStyles={{this.styles.tr}}
          >
            {{#each this.columns as |column|}}
              <TableColumn @column={{column}} @thStyles={{this.styles.th}}>
                {{column.label}}
              </TableColumn>
            {{/each}}
          </TableHeader>

          <TableBody
            @columns={{this.columns}}
            @items={{this.items}}
            @tbodyStyles={{this.styles.tbody}}
            @trStyles={{this.styles.tr}}
            @thStyles={{this.styles.th}}
            @tdStyles={{this.styles.td}}
          >
            {{#each this.items as |item|}}
              <TableRow
                @item={{item}}
                @columns={{this.columns}}
                @trStyles={{this.styles.tr}}
                @tdStyles={{this.styles.td}}
              >
                {{#each this.columns as |column|}}
                  {{#let (this.getValue item column) as |value|}}
                    <TableCell
                      @item={{item}}
                      @column={{column}}
                      @value={{value}}
                      @tdStyles={{this.styles.td}}
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
    </div>
  </template>
}

export { Table, type TableSignature };
export default Table;
