import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';
import type { TableCellSignature } from './types';

class TableCell extends Component<TableCellSignature> {
  get classNames() {
    // TODO: Add table styles to theme
    const classes = ['table-cell'];
    if (this.args.class) {
      classes.push(this.args.class);
    }
    return classes.join(' ');
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