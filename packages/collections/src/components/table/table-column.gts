import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';
import type { ColumnDefinition } from './types';

interface TableColumnSignature {
  Args: {
    column?: ColumnDefinition<any>;
    class?: string;
    /** @internal Style function passed from parent Table component */
    thStyles?: (options?: { class?: string }) => string;
  };
  Element: HTMLTableCellElement;
  Blocks: {
    default: [];
  };
}

class TableColumn extends Component<TableColumnSignature> {
  get classNames() {
    const { table } = useStyles();
    return (
      this.args.thStyles?.({ class: this.args.class }) ||
      table().th({ class: this.args.class })
    );
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

