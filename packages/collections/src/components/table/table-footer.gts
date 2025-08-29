import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles, twMerge } from '@frontile/theme';
import { TableColumn } from './table-column';
import type { ColumnDefinition, SlotsToClasses, TableSlots } from './types';
import type { WithBoundArgs } from '@glint/template';

interface TableFooterSignature<T = unknown> {
  Args: {
    /** Array of column definitions for automatic footer generation */
    columns?: ColumnDefinition<T>[];
    /** Additional CSS class to apply to the footer element */
    class?: string;
    /** Whether this footer should be frozen (sticky) during vertical scrolling */
    isFrozen?: boolean;
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
        Column: WithBoundArgs<typeof TableColumn<T>, 'styleFns'>;
      }
    ];
  };
}

class TableFooter<T = unknown> extends Component<TableFooterSignature<T>> {
  get styles() {
    return this.args.styleFns || useStyles().table();
  }

  get classNames() {
    const options = {
      isFrozen: this.args.isFrozen ?? false,
      frozenPosition: this.args.isFrozen ? ('bottom' as const) : undefined,
      class: twMerge(this.args.class, this.args.classes?.tfoot)
    };

    return this.styles.tfoot(options);
  }

  get rowClassNames() {
    const options = {
      class: twMerge('', this.args.classes?.tr || ''),
      isFrozen: false
    };
    return this.styles.tr(options);
  }

  <template>
    <tfoot
      class={{this.classNames}}
      data-test-id="table-footer"
      data-component="table-footer"
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
    </tfoot>
  </template>
}

export { TableFooter, type TableFooterSignature };
export default TableFooter;
