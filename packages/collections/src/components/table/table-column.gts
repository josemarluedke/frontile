import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';
import type { ColumnDefinition } from './types';

interface TableColumnSignature<T = unknown> {
  Args: {
    /** Column definition for automatic header generation */
    column?: ColumnDefinition<T>;
    /** Additional CSS class to apply to the header cell */
    class?: string;
    /** Whether this column should be frozen (sticky) during horizontal scrolling */
    isFrozen?: boolean;
    /** Position where the frozen column should stick. @default 'left' */
    frozenPosition?: 'left' | 'right';
    /**
     * @internal Style functions object from Table component
     * @ignore
     */
    styleFns?: ReturnType<ReturnType<typeof useStyles>['table']>;
  };
  Element: HTMLTableCellElement;
  Blocks: {
    default: [];
  };
}

class TableColumn<T = unknown> extends Component<TableColumnSignature<T>> {
  get isFrozen(): boolean {
    return this.args.isFrozen ?? this.args.column?.isFrozen ?? false;
  }

  get frozenPosition(): 'left' | 'right' {
    return (
      this.args.frozenPosition ?? this.args.column?.frozenPosition ?? 'left'
    );
  }

  get styles() {
    return this.args.styleFns || useStyles().table();
  }

  get classNames() {
    const options = {
      isFrozen: this.isFrozen,
      frozenPosition: this.isFrozen
        ? (this.frozenPosition as 'left' | 'right')
        : undefined,
      class: this.args.class
    };

    return this.styles.th(options);
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
