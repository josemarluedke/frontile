import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import { TableColumn } from './table-column';
import type { TableHeaderSignature } from './types';

class TableHeader extends Component<TableHeaderSignature> {
  get styles() {
    const { table } = useStyles();
    return table();
  }

  get classNames() {
    return this.args.theadStyles?.({ class: this.args.class }) || this.styles.thead({ class: this.args.class });
  }

  get rowClassNames() {
    return this.args.trStyles?.() || this.styles.tr();
  }

  <template>
    <thead
      class={{this.classNames}}
      data-test-id="table-header"
      data-component="table-header"
      ...attributes
    >
      <tr class={{this.rowClassNames}}>
        {{#if (has-block "default")}}
          {{yield (hash Column=TableColumn) to="default"}}
        {{else}}
          {{#each @columns as |column|}}
            <TableColumn @column={{column}}>
              {{column.label}}
            </TableColumn>
          {{/each}}
        {{/if}}
      </tr>
    </thead>
  </template>
}

export { TableHeader, type TableHeaderSignature };
export default TableHeader;