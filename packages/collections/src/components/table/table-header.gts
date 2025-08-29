import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles, twMerge } from '@frontile/theme';
import { TableColumn } from './table-column';
import type { ColumnDefinition, SlotsToClasses, TableSlots } from './types';

interface TableHeaderSignature<T = unknown> {
  Args: {
    /** Array of column definitions for automatic header generation */
    columns?: ColumnDefinition<T>[];
    /** Additional CSS class to apply to the header section */
    class?: string;
    /** Whether the header should be sticky during vertical scrolling */
    isSticky?: boolean;
    /**
     * @internal Style functions object from Table component
     * @ignore
     */
    styleFns?: ReturnType<ReturnType<typeof useStyles>['table']>;
    /**
     * @internal Classes object from Table component
     * @ignore
     */
    classes?: SlotsToClasses<TableSlots>;
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

class TableHeader<T = unknown> extends Component<TableHeaderSignature<T>> {
  get styles() {
    return this.args.styleFns || useStyles().table();
  }

  get classNames() {
    const options = {
      isSticky: this.args.isSticky,
      stickyPosition: this.args.isSticky ? ('top' as const) : undefined,
      class: twMerge(this.args.class, this.args.classes?.thead)
    };

    return this.styles.thead(options);
  }

  get rowClassNames() {
    const options = {
      class: twMerge('', this.args.classes?.tr || ''),
      isSticky: false
    };
    return this.styles.tr(options);
  }

  <template>
    <thead
      class={{this.classNames}}
      data-test-id="table-header"
      data-component="table-header"
      ...attributes
    >
      <tr class={{this.rowClassNames}}>
        {{#if (has-block)}}
          {{yield (hash Column=TableColumn)}}
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
