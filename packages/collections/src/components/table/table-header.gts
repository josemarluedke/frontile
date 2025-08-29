import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import { TableColumn } from './table-column';
import type { ColumnDefinition } from './types';

interface TableHeaderSignature {
  Args: {
    columns?: ColumnDefinition<any>[];
    class?: string;
    /** @internal Style function passed from parent Table component */
    theadStyles?: (options?: { class?: string }) => string;
    /** @internal Style function passed from parent Table component */
    trStyles?: (options?: { class?: string }) => string;
  };
  Element: HTMLTableSectionElement;
  Blocks: {
    default: [
      {
        Column: typeof TableColumn;
      }
    ];
  };
}

class TableHeader extends Component<TableHeaderSignature> {
  get styles() {
    const { table } = useStyles();
    return table();
  }

  get classNames() {
    return (
      this.args.theadStyles?.({ class: this.args.class }) ||
      this.styles.thead({ class: this.args.class })
    );
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
