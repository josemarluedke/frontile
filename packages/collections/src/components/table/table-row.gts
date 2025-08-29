import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import { keyAndLabelForItem } from '../../utils/listManager';
import { getSafeValue } from './utils';
import { TableCell } from './table-cell';
import type { TableRowSignature, ColumnDefinition } from './types';

class TableRow<T = unknown> extends Component<TableRowSignature<T>> {
  get classNames() {
    const { table } = useStyles();
    return this.args.trStyles?.({ class: this.args.class }) || table().tr({ class: this.args.class });
  }

  get rowKey(): string {
    if (this.args.item) {
      const { key } = keyAndLabelForItem(this.args.item);
      return key;
    }
    return '';
  }

  getValue = (item: T, column: ColumnDefinition<T>) => getSafeValue(item, column);

  <template>
    <tr
      class={{this.classNames}}
      data-test-id="table-row"
      data-component="table-row"
      data-key={{this.rowKey}}
      ...attributes
    >
      {{#if (has-block "default")}}
        {{yield (hash Cell=TableCell) to="default"}}
      {{else}}
        {{#each @columns as |column|}}
          {{#if @item}}
            {{#let (this.getValue @item column) as |value|}}
              <TableCell
                @item={{@item}}
                @column={{column}}
                @value={{value}}
                @tdStyles={{@tdStyles}}
              >
                {{value}}
              </TableCell>
            {{/let}}
          {{/if}}
        {{/each}}
      {{/if}}
    </tr>
  </template>
}

export { TableRow, type TableRowSignature };
export default TableRow;