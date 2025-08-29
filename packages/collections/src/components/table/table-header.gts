import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import { TableColumn } from './table-column';
import type { TableHeaderSignature } from './types';

class TableHeader extends Component<TableHeaderSignature> {
  get classNames() {
    // TODO: Add table styles to theme
    const classes = ['table-header'];
    if (this.args.class) {
      classes.push(this.args.class);
    }
    return classes.join(' ');
  }

  <template>
    <thead
      class={{this.classNames}}
      data-test-id="table-header"
      data-component="table-header"
      ...attributes
    >
      <tr>
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