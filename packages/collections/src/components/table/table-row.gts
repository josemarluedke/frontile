import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles, twMerge } from '@frontile/theme';
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
    /** Whether this row should be frozen (sticky) during vertical scrolling */
    isFrozen?: boolean;
    /** Array of item keys that should be frozen (used to determine if this row is frozen) */
    frozenKeys?: string[];
    /** Whether the table has a frozen header (affects positioning of frozen rows) */
    isFrozenHeader?: boolean;
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
      }
    ];
  };
}

class TableRow<T = unknown> extends Component<TableRowSignature<T>> {
  get isFrozen(): boolean {
    if (this.args.isFrozen) return true;

    if (this.args.frozenKeys && this.args.item) {
      const { key } = keyAndLabelForItem(this.args.item);
      return this.args.frozenKeys.includes(key);
    }

    return false;
  }

  get styles() {
    return this.args.styleFns || useStyles().table();
  }

  get classNames() {
    const options = {
      isFrozen: this.isFrozen,
      frozenPosition: this.isFrozen ? ('top' as const) : undefined,
      hasFrozenHeader: this.args.isFrozenHeader || false,
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
        {{yield (hash Cell=TableCell)}}
      {{else}}
        {{#each @columns as |column|}}
          {{#if @item}}
            {{#let (this.getValue @item column) as |value|}}
              <TableCell
                @item={{@item}}
                @column={{column}}
                @isInFrozenRow={{this.isFrozen}}
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
