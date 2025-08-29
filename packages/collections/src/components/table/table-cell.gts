import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';
import type { TableCellSignature } from './types';

class TableCell extends Component<TableCellSignature> {
  get classNames() {
    const { table } = useStyles();
    return this.args.tdStyles?.({ class: this.args.class }) || table().td({ class: this.args.class });
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