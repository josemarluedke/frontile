import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles, twMerge } from '@frontile/theme';
import { modifier } from 'ember-modifier';
import { keyAndLabelForItem } from '../../utils/listManager';
import { getSafeValue } from './utils';
import { TableCell } from './table-cell';
import type { SlotsToClasses, TableSlots, Row, Column } from './types';
import type { ContentValue } from '@glint/template';

interface TableRowSignature<T> {
  Args: {
    /** The data row for this row */
    row?: Row<T>;
    /** Array of universal-ember columns for automatic cell generation */
    columns?: Column<T>[];
    /** Additional CSS class to apply to the row */
    class?: string;
    /** Whether this row should be sticky during vertical scrolling */
    isSticky?: boolean;
    /** Array of item keys that should be sticky (used to determine if this row is sticky) */
    stickyKeys?: string[];
    /** Whether the table has a sticky header (affects positioning of sticky rows) */
    isStickyHeader?: boolean;
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
  Element: HTMLTableRowElement;
  Blocks: {
    default: [
      {
        Cell: typeof TableCell;
        columns: Column<T>[];
      }
    ];
  };
}

class TableRow<T = unknown> extends Component<TableRowSignature<T>> {
  // No longer needed - using render functions instead of registration

  get isSticky(): boolean {
    if (this.args.isSticky) return true;

    if (this.args.stickyKeys && this.args.row) {
      // Universal-ember Row objects have structure: { data, table, index }
      // Extract the actual data from the row wrapper
      const row = this.args.row as any;
      const actualData = row.data || row.original || row;
      
      try {
        const { key } = keyAndLabelForItem(actualData);
        return this.args.stickyKeys.includes(key);
      } catch (error) {
        // Fallback: use the row index if key extraction fails
        const fallbackKey = row.index?.toString() || '';
        return this.args.stickyKeys.includes(fallbackKey);
      }
    }

    return false;
  }

  get styles() {
    return this.args.styleFns || useStyles().table();
  }

  get classNames() {
    const options = {
      isSticky: this.isSticky,
      stickyPosition: this.isSticky ? ('top' as const) : undefined,
      hasStickyHeader: this.args.isStickyHeader || false,
      class: twMerge(this.args.class || '', this.args.classes?.tr || '')
    };

    return this.styles.tr(options);
  }

  get rowKey(): string {
    if (this.args.row) {
      // Universal-ember Row objects have structure: { data, table, index }
      // Extract the actual data from the row wrapper
      const row = this.args.row as any;
      const actualData = row.data || row.original || row;

      try {
        const { key } = keyAndLabelForItem(actualData);
        return key;
      } catch (error) {
        // Fallback: use the row index if key extraction fails
        return row.index?.toString() || '';
      }
    }
    return '';
  }

  get columns(): Column<T>[] {
    return this.args.columns || [];
  }

  getValue = (row: Row<T>, column: Column<T>): ContentValue =>
    column.getValueForRow
      ? column.getValueForRow(row)
      : getSafeValue(row.data, { key: column.key, label: column.name || '' });

  <template>
    <tr
      class={{this.classNames}}
      data-test-id="table-row"
      data-component="table-row"
      data-key={{this.rowKey}}
      ...attributes
    >
      {{#if (has-block)}}
        {{yield (hash Cell=TableCell columns=this.columns)}}
      {{else}}
        {{#each @columns as |column|}}
          {{#if @row}}
            {{#let (this.getValue @row column) as |value|}}
              <TableCell
                @row={{@row}}
                @column={{column}}
                @isInStickyRow={{this.isSticky}}
                @styleFns={{@styleFns}}
                @classes={{@classes}}
              >
                {{value}}
              </TableCell>
            {{/let}}
          {{/if}}
        {{/each}}
      {{/if}}
    </tr>
  </template>
}

export { TableRow, type TableRowSignature };
export default TableRow;
