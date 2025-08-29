import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';
import type { TableColumnSignature } from './types';

class TableColumn extends Component<TableColumnSignature> {
  get classNames() {
    // TODO: Add table styles to theme
    const classes = ['table-column'];
    if (this.args.class) {
      classes.push(this.args.class);
    }
    return classes.join(' ');
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