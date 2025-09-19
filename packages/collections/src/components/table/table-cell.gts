import Component from '@glimmer/component';
import { useStyles, twMerge } from '@frontile/theme';
import type { SlotsToClasses, TableSlots, Row, Column } from './types';

interface TableCellSignature<T = unknown> {
  Args: {
    /** The data row for this row (used for context) */
    row?: Row<T>;
    /** Universal-ember column definition associated with this cell */
    column?: Column<T>;
    /** Additional CSS class to apply to the cell */
    class?: string;
    /** Whether this cell should be sticky during horizontal scrolling */
    isSticky?: boolean;
    /** Position where the sticky cell should stick. @default 'left' */
    stickyPosition?: 'left' | 'right';
    /** Whether this cell is part of a sticky row (used for intersection styling) */
    isInStickyRow?: boolean;
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
  Element: HTMLTableCellElement;
  Blocks: {
    default: [];
  };
}

class TableCell<T = unknown> extends Component<TableCellSignature<T>> {
  get isSticky(): boolean {
    return this.args.isSticky ?? false;
  }

  get stickyPosition(): 'left' | 'right' {
    return this.args.stickyPosition ?? 'left';
  }

  get styles() {
    return this.args.styleFns || useStyles().table();
  }

  get classNames() {
    const options = {
      isSticky: this.isSticky,
      stickyPosition: this.isSticky
        ? (this.stickyPosition as 'left' | 'right')
        : undefined,
      isInStickyRow: this.args.isInStickyRow || false,
      class: twMerge(this.args.class || '', this.args.classes?.td || '')
    };

    return this.styles.td(options);
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
