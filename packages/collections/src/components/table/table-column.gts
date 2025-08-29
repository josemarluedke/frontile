import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';
import type { ColumnDefinition } from './types';

interface TableColumnSignature {
  Args: {
    /** Column definition for automatic header generation */
    column?: ColumnDefinition<any>;
    /** Additional CSS class to apply to the header cell */
    class?: string;
    /** Whether this column should be frozen (sticky) during horizontal scrolling */
    isFrozen?: boolean;
    /** Position where the frozen column should stick. @default 'left' */
    frozenPosition?: 'left' | 'right';
    /**
     * @internal Style function passed from parent Table component
     * @ignore
     */
    thStyles?: (options?: { class?: string }) => string;
  };
  Element: HTMLTableCellElement;
  Blocks: {
    default: [];
  };
}

class TableColumn extends Component<TableColumnSignature> {
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
      class: this.args.class
    };

    return this.args.thStyles?.(options) || table().th(options);
  }

  <template>
    <th
      class={{this.classNames}}
      data-test-id="table-column"
      data-component="table-column"
      data-key={{@column.key}}
      ...attributes
    >
      {{yield}}
    </th>
  </template>
}

export { TableColumn, type TableColumnSignature };
export default TableColumn;
