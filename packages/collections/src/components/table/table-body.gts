import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import { getSafeValue } from './utils';
import { TableRow } from './table-row';
import { TableCell } from './table-cell';
import type { ColumnDefinition } from './types';

interface TableBodySignature<T> {
  Args: {
    /** Array of column definitions for automatic row generation */
    columns?: ColumnDefinition<T>[];
    /** Array of data items to display as rows */
    items?: T[];
    /** Additional CSS class to apply to the body section */
    class?: string;
    /**
     * @internal Style function passed from parent Table component
     * @ignore
     */
    tbodyStyles?: (options?: { class?: string }) => string;
    /**
     * @internal Style function passed from parent Table component
     * @ignore
     */
    trStyles?: (options?: { class?: string }) => string;
    /**
     * @internal Style function passed from parent Table component
     * @ignore
     */
    tdStyles?: (options?: { class?: string }) => string;
  };
  Element: HTMLTableSectionElement;
  Blocks: {
    default: [
      {
        Row: typeof TableRow;
        Cell: typeof TableCell;
      }
    ];
    row: [
      {
        item: T;
        Row: typeof TableRow;
        Cell: typeof TableCell;
      }
    ];
  };
}

class TableBody<T = unknown> extends Component<TableBodySignature<T>> {
  get classNames() {
    const { table } = useStyles();
    return (
      this.args.tbodyStyles?.({ class: this.args.class }) ||
      table().tbody({ class: this.args.class })
    );
  }

  getValue = (item: T, column: ColumnDefinition<T>) =>
    getSafeValue(item, column);

  <template>
    <tbody
      class={{this.classNames}}
      data-test-id="table-body"
      data-component="table-body"
      ...attributes
    >
      {{#if (has-block "default")}}
        {{yield (hash Row=TableRow Cell=TableCell) to="default"}}
      {{else}}
        {{#each @items as |item|}}
          {{#if (has-block "row")}}
            {{yield (hash item=item Row=TableRow Cell=TableCell) to="row"}}
          {{else}}
            <TableRow
              @item={{item}}
              @columns={{@columns}}
              @trStyles={{@trStyles}}
              @tdStyles={{@tdStyles}}
            >
              {{#each @columns as |column|}}
                {{#let (this.getValue item column) as |value|}}
                  <TableCell
                    @item={{item}}
                    @column={{column}}
                    @tdStyles={{@tdStyles}}
                  >
                    {{value}}
                  </TableCell>
                {{/let}}
              {{/each}}
            </TableRow>
          {{/if}}
        {{/each}}
      {{/if}}
    </tbody>
  </template>
}

export { TableBody, type TableBodySignature };
export default TableBody;
