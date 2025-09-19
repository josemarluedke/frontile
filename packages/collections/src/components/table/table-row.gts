import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles, twMerge } from '@frontile/theme';
import { keyAndLabelForItem } from '../../utils/listManager';
import { TableCell } from './table-cell';
import type { SlotsToClasses, TableSlots, Row, Column, Table } from './types';
import type Owner from '@ember/owner';
import { assert } from '@ember/debug';
import { modifier } from 'ember-modifier';
import type { FunctionBasedModifier } from 'ember-modifier';

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
     * @internal Universal-ember table instance for accessing modifiers and behaviors
     * @ignore
     */
    tableInstance?: Table<T>;
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
  get isSticky(): boolean {
    if (this.args.isSticky) return true;

    if (this.args.stickyKeys && this.args.row) {
      // Universal-ember Row objects have structure: { data, table, index }
      // Extract the actual data from the row wrapper
      const row = this.args.row as Row<T>;
      const actualData = row.data || row;

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
      const row = this.args.row as Row<T>;
      const actualData = row.data || row;

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

  getRowModifier = (): FunctionBasedModifier<{
    Args: {
      Positional: [Row<T> | undefined];
      Named: {};
    };
    Element: HTMLElement;
  }> => {
    if (this.args.tableInstance && this.args.row) {
      return this.args.tableInstance.modifiers.row as FunctionBasedModifier<{
        Args: {
          Positional: [Row<T> | undefined];
          Named: {};
        };
        Element: HTMLElement;
      }>;
    } else {
      // noop modifier
      return modifier(
        (_element: HTMLElement, _positional: [Row<T> | undefined]) => {}
      );
    }
  };

  <template>
    <tr
      class={{this.classNames}}
      data-test-id="table-row"
      data-component="table-row"
      data-key={{this.rowKey}}
      {{(this.getRowModifier) @row}}
      ...attributes
    >
      {{#if (has-block)}}
        {{yield (hash Cell=TableCell columns=this.columns)}}
      {{else}}
        {{#each @columns as |column|}}
          {{#if @row}}
            {{#let (column.getValueForRow @row) as |value|}}
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
