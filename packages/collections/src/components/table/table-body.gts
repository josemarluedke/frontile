import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles, twMerge } from '@frontile/theme';
import { TableRow } from './table-row';
import { TableCell } from './table-cell';
import type { SlotsToClasses, TableSlots, Row, Column } from './types';

interface TableBodySignature<T> {
  Args: {
    /** Array of columns for automatic row generation */
    columns?: Column<T>[];
    /** Array of data rows to display as rows */
    rows?: Row<T>[];
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
        rows: Row<T>[];
        columns: Column<T>[];
      }
    ];
    row: [
      {
        row: Row<T>;
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

  get rows(): Row<T>[] {
    return this.args.rows || [];
  }

  get columns(): Column<T>[] {
    return this.args.columns || [];
  }

  <template>
    <tbody
      class={{this.classNames}}
      data-test-id="table-body"
      data-component="table-body"
      ...attributes
    >
      {{#if (has-block)}}
        {{yield
          (hash Row=TableRow Cell=TableCell rows=this.rows columns=this.columns)
        }}
      {{else}}
        {{#each @rows as |row|}}
          {{#if (has-block "row")}}
            {{yield (hash row=row Row=TableRow Cell=TableCell) to="row"}}
          {{else}}
            <TableRow
              @row={{row}}
              @columns={{@columns}}
              @styleFns={{@styleFns}}
              @classes={{@classes}}
            >
              {{#each @columns as |column|}}
                {{#let (column.getValueForRow row) as |value|}}
                  <TableCell
                    @row={{row}}
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
