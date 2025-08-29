import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';
import type { TableColumnSignature } from './types';

class TableColumn extends Component<TableColumnSignature> {
  get classNames() {
    const { table } = useStyles();
    return this.args.thStyles?.({ class: this.args.class }) || table().th({ class: this.args.class });
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