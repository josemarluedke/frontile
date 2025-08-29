import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';
import type { ContentValue } from '@glint/template';
import type { ColumnDefinition } from './types';

interface TableCellSignature<T = unknown> {
  Args: {
    /** The data item for this row (used for context) */
    item?: T;
    /** Column definition associated with this cell */
    column?: ColumnDefinition<T>;
    /** Additional CSS class to apply to the cell */
    class?: string;
    /** Whether this cell should be frozen (sticky) during horizontal scrolling */
    isFrozen?: boolean;
    /** Position where the frozen cell should stick. @default 'left' */
    frozenPosition?: 'left' | 'right';
    /** Whether this cell is part of a frozen row (used for intersection styling) */
    isInFrozenRow?: boolean;
    /**
     * @internal Style function passed from parent Table component
     * @ignore
     */
    tdStyles?: (options?: { class?: string }) => string;
  };
  Element: HTMLTableCellElement;
  Blocks: {
    default: [];
  };
}

class TableCell<T = unknown> extends Component<TableCellSignature<T>> {
  get isFrozen(): boolean {
    return this.args.isFrozen ?? this.args.column?.isFrozen ?? false;
  }

  get frozenPosition(): 'left' | 'right' {
    return (
      this.args.frozenPosition ?? this.args.column?.frozenPosition ?? 'left'
    );
  }

  get classNames() {
    const { table } = useStyles();
    const options = {
      isFrozen: this.isFrozen,
      frozenPosition: this.isFrozen
        ? (this.frozenPosition as 'left' | 'right')
        : undefined,
      isInFrozenRow: this.args.isInFrozenRow || false,
      class: this.args.class
    };

    return this.args.tdStyles?.(options) || table().td(options);
  }

  <template>
    <td
      class={{this.classNames}}
      data-test-id="table-cell"
      data-component="table-cell"
      data-column={{if @column @column.key}}
      ...attributes
    >
      {{yield}}
    </td>
  </template>
}

export { TableCell, type TableCellSignature };
export default TableCell;
