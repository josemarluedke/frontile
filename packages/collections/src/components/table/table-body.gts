import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles, twMerge } from '@frontile/theme';
import { getSafeValue } from './utils';
import { TableRow } from './table-row';
import { TableCell } from './table-cell';
import type { ColumnDefinition, SlotsToClasses, TableSlots } from './types';

interface TableBodySignature<T> {
  Args: {
    /** Array of column definitions for automatic row generation */
    columns?: ColumnDefinition<T>[];
    /** Array of data items to display as rows */
    items?: T[];
    /** Additional CSS class to apply to the body section */
    class?: string;
    /**
     * @internal Style functions object from Table component
     * @ignore
     */
    styleFns?: ReturnType<ReturnType<typeof useStyles>['table']>;
    /**
     * @internal Classes object from Table component
     * @ignore
     */
    classes?: SlotsToClasses<TableSlots>;
  };
  Element: HTMLTableSectionElement;
  Blocks: {
    default: [
      {
        Row: typeof TableRow;
        Cell: typeof TableCell;
        items: T[];
        columns: ColumnDefinition<T>[];
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
  get styles() {
    return this.args.styleFns || useStyles().table();
  }

  get classNames() {
    const mergedClass = twMerge(this.args.class, this.args.classes?.tbody);
    return this.styles.tbody({ class: mergedClass });
  }

  get items(): T[] {
    return this.args.items || [];
  }

  get columns(): ColumnDefinition<T>[] {
    return this.args.columns || [];
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
      {{#if (has-block)}}
        {{yield (hash Row=TableRow Cell=TableCell items=this.items columns=this.columns)}}
      {{else}}
        {{#each @items as |item|}}
          {{#if (has-block "row")}}
            {{yield (hash item=item Row=TableRow Cell=TableCell) to="row"}}
          {{else}}
            <TableRow
              @item={{item}}
              @columns={{@columns}}
              @styleFns={{@styleFns}}
              @classes={{@classes}}
            >
              {{#each @columns as |column|}}
                {{#let (this.getValue item column) as |value|}}
                  <TableCell
                    @item={{item}}
                    @column={{column}}
                    @styleFns={{@styleFns}}
                    @classes={{@classes}}
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
