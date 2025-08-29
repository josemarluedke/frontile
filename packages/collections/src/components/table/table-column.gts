import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';
import type { ColumnDefinition } from './types';

interface TableColumnSignature<T = unknown> {
  Args: {
    /** Column definition for automatic header generation */
    column?: ColumnDefinition<T>;
    /** Additional CSS class to apply to the header cell */
    class?: string;
    /** Whether this column should be sticky during horizontal scrolling */
    isSticky?: boolean;
    /** Position where the sticky column should stick. @default 'left' */
    stickyPosition?: 'left' | 'right';
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
  get isSticky(): boolean {
    return this.args.isSticky ?? this.args.column?.isSticky ?? false;
  }

  get stickyPosition(): 'left' | 'right' {
    return (
      this.args.stickyPosition ?? this.args.column?.stickyPosition ?? 'left'
    );
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
