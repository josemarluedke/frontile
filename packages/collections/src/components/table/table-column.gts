import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';
import { modifier } from 'ember-modifier';
import { extractFrontileOptions } from './utils';
import type { Column, Table } from './types';
import type { FunctionBasedModifier } from 'ember-modifier';

interface TableColumnSignature<T = unknown> {
  Args: {
    /** Column definition */
    column?: Column<T>;
    /** Additional CSS class to apply to the header cell */
    class?: string;
    /** Whether this column should be sticky during horizontal scrolling */
    isSticky?: boolean;
    /** Position where the sticky column should stick. @default 'left' */
    stickyPosition?: 'left' | 'right';
    /** Column key for registration when used in block form */
    key?: string;
    /** Column label for registration when used in block form */
    label?: string;
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
  };
  Element: HTMLTableCellElement;
  Blocks: {
    default: [];
  };
}

class TableColumn<T = unknown> extends Component<TableColumnSignature<T>> {
  get isSticky(): boolean {
    const frontileOptions = extractFrontileOptions(this.args.column);
    return frontileOptions?.isSticky ?? this.args.isSticky ?? false;
  }

  get stickyPosition(): 'left' | 'right' {
    const frontileOptions = extractFrontileOptions(this.args.column);
    return (
      frontileOptions?.stickyPosition ?? this.args.stickyPosition ?? 'left'
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

  getColumnModifier = (): FunctionBasedModifier<{
    Args: {
      Positional: [Column<T> | undefined];
      Named: {};
    };
    Element: HTMLElement;
  }> => {
    if (this.args.tableInstance && this.args.column) {
      return this.args.tableInstance.modifiers
        .columnHeader as FunctionBasedModifier<{
        Args: {
          Positional: [Column<T> | undefined];
          Named: {};
        };
        Element: HTMLElement;
      }>;
    } else {
      // noop modifier
      return modifier(
        (_element: HTMLElement, _positional: [Column<T> | undefined]) => {}
      );
    }
  };

  <template>
    <th
      class={{this.classNames}}
      data-test-id="table-column"
      data-component="table-column"
      data-key={{if @column @column.key @key}}
      {{(this.getColumnModifier) @column}}
      ...attributes
    >
      {{yield}}
    </th>
  </template>
}

export { TableColumn, type TableColumnSignature };
export default TableColumn;
