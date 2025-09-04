import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles, twMerge } from '@frontile/theme';
import { modifier } from 'ember-modifier';
import { keyAndLabelForItem } from '../../utils/listManager';
import { getSafeValue } from './utils';
import { TableCell } from './table-cell';
import type { ColumnDefinition, SlotsToClasses, TableSlots } from './types';

interface TableRowSignature<T> {
  Args: {
    /** The data item for this row */
    item?: T;
    /** Array of column definitions for automatic cell generation */
    columns?: ColumnDefinition<T>[];
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
        columns: ColumnDefinition<T>[];
      }
    ];
  };
}

class TableRow<T = unknown> extends Component<TableRowSignature<T>> {
  // No longer needed - using render functions instead of registration

  get isSticky(): boolean {
    if (this.args.isSticky) return true;

    if (this.args.stickyKeys && this.args.item) {
      const { key } = keyAndLabelForItem(this.args.item);
      return this.args.stickyKeys.includes(key);
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
    if (this.args.item) {
      const { key } = keyAndLabelForItem(this.args.item);
      return key;
    }
    return '';
  }

  get columns(): ColumnDefinition<T>[] {
    return this.args.columns || [];
  }

  getValue = (item: T, column: ColumnDefinition<T>) =>
    getSafeValue(item, column);

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
          {{#if @item}}
            {{#let (this.getValue @item column) as |value|}}
              <TableCell
                @item={{@item}}
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
