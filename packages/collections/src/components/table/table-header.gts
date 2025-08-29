import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import { TableColumn } from './table-column';
import type { ColumnDefinition } from './types';

interface TableHeaderSignature {
  Args: {
    /** Array of column definitions for automatic header generation */
    columns?: ColumnDefinition<any>[];
    /** Additional CSS class to apply to the header section */
    class?: string;
    /** Whether the header should be frozen (sticky) during vertical scrolling */
    isFrozen?: boolean;
    /**
     * @internal Style function passed from parent Table component
     * @ignore
     */
    theadStyles?: (options?: { class?: string }) => string;
    /**
     * @internal Style function passed from parent Table component
     * @ignore
     */
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
    const options = {
      isFrozen: this.args.isFrozen,
      frozenPosition: this.args.isFrozen ? ('top' as const) : undefined,
      class: this.args.class
    };

    return this.args.theadStyles?.(options) || this.styles.thead(options);
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
