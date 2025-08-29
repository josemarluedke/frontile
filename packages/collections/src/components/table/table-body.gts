import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import { getSafeValue } from './utils';
import { TableRow } from './table-row';
import { TableCell } from './table-cell';
import type { TableBodySignature, ColumnDefinition } from './types';

class TableBody<T = unknown> extends Component<TableBodySignature<T>> {
  get classNames() {
    const { table } = useStyles();
    return this.args.tbodyStyles?.({ class: this.args.class }) || table().tbody({ class: this.args.class });
  }

  getValue = (item: T, column: ColumnDefinition<T>) => getSafeValue(item, column);

  <template>
    <tbody
      class={{this.classNames}}
      data-test-id="table-body"
      data-component="table-body"
      ...attributes
    >
      {{#if (has-block "default")}}
        {{yield (hash Row=TableRow Cell=TableCell) to="default"}}
      {{else}}
        {{#each @items as |item|}}
          {{#if (has-block "row")}}
            {{yield (hash item=item Row=TableRow Cell=TableCell) to="row"}}
          {{else}}
            <TableRow @item={{item}} @columns={{@columns}} @trStyles={{@trStyles}} @tdStyles={{@tdStyles}}>
              {{#each @columns as |column|}}
                {{#let (this.getValue item column) as |value|}}
                  <TableCell
                    @item={{item}}
                    @column={{column}}
                    @value={{value}}
                    @tdStyles={{@tdStyles}}
                  >
                    {{value}}
                  </TableCell>
                {{/let}}
              {{/each}}
            </TableRow>
          {{/if}}
        {{/each}}
      {{/if}}
    </tbody>
  </template>
}

export { TableBody, type TableBodySignature };
export default TableBody;