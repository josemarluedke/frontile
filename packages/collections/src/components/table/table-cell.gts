import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';
import type { ContentValue } from '@glint/template';
import type { ColumnDefinition } from './types';

interface TableCellSignature {
  Args: {
    item?: unknown;
    column?: ColumnDefinition<any>;
    value?: ContentValue;
    class?: string;
    /** @internal Style function passed from parent Table component */
    tdStyles?: (options?: { class?: string }) => string;
  };
  Element: HTMLTableCellElement;
  Blocks: {
    default: [];
  };
}

class TableCell extends Component<TableCellSignature> {
  get classNames() {
    const { table } = useStyles();
    return (
      this.args.tdStyles?.({ class: this.args.class }) ||
      table().td({ class: this.args.class })
    );
  }

  <template>
    <td
      class={{this.classNames}}
      data-test-id="table-cell"
      data-component="table-cell"
      data-column={{@column.key}}
      ...attributes
    >
      {{yield}}
    </td>
  </template>
}

export { TableCell, type TableCellSignature };
export default TableCell;

