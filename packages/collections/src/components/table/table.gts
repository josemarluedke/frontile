import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import { getSafeValue } from './utils';
import { TableHeader } from './table-header';
import { TableBody } from './table-body';
import { TableColumn } from './table-column';
import { TableRow } from './table-row';
import { TableCell } from './table-cell';
import type {
  ColumnDefinition,
  TableVariants,
  TableSlots,
  SlotsToClasses
} from './types';
import type { ContentValue, WithBoundArgs } from '@glint/template';

interface TableSignature<T> {
  Args: {
    columns?: ColumnDefinition<T>[];
    items?: T[];
    classes?: SlotsToClasses<TableSlots>;
    size?: TableVariants['size'];
    layout?: TableVariants['layout'];
    striped?: TableVariants['striped'];
    emptyContent?: ContentValue;
  };
  Element: HTMLTableElement;
  Blocks: {
    default: [
      {
        Column: WithBoundArgs<typeof TableColumn, 'thStyles'>;
        Header: WithBoundArgs<
          typeof TableHeader,
          'columns' | 'theadStyles' | 'trStyles'
        >;
        Body: WithBoundArgs<
          typeof TableBody<T>,
          | 'columns'
          | 'items'
          | 'tbodyStyles'
          | 'trStyles'
          | 'thStyles'
          | 'tdStyles'
        >;
        Row: WithBoundArgs<
          typeof TableRow<T>,
          'columns' | 'trStyles' | 'tdStyles'
        >;
        Cell: WithBoundArgs<typeof TableCell, 'tdStyles'>;
      }
    ];
  };
}

class Table<T = unknown> extends Component<TableSignature<T>> {
  // Needed to make glint happy with generic components
  TableBody = TableBody<T>;
  TableRow = TableRow<T>;

  get styles() {
    const { table } = useStyles();
    return table({
      size: this.args.size,
      layout: this.args.layout,
      striped: this.args.striped,
      class: this.args.classes?.base
    });
  }

  get wrapperClassNames() {
    return this.styles.wrapper({ class: this.args.classes?.wrapper });
  }

  get tableClassNames() {
    return this.styles.table({ class: this.args.classes?.table });
  }

  get columns(): ColumnDefinition<T>[] {
    return this.args.columns || [];
  }

  get items(): T[] {
    return this.args.items || [];
  }

  getValue = (item: T, column: ColumnDefinition<T>) =>
    getSafeValue(item, column);

  <template>
    <div class={{this.wrapperClassNames}} data-component="table-wrapper">
      <table
        class={{this.tableClassNames}}
        data-test-id="table"
        data-component="table"
        ...attributes
      >
        {{#if (has-block "default")}}
          {{yield
            (hash
              Column=(component TableColumn thStyles=this.styles.th)
              Header=(component
                TableHeader
                columns=this.columns
                theadStyles=this.styles.thead
                trStyles=this.styles.tr
              )
              Body=(component
                this.TableBody
                columns=this.columns
                items=this.items
                tbodyStyles=this.styles.tbody
                trStyles=this.styles.tr
                thStyles=this.styles.th
                tdStyles=this.styles.td
              )
              Row=(component
                this.TableRow
                columns=this.columns
                trStyles=this.styles.tr
                tdStyles=this.styles.td
              )
              Cell=(component TableCell tdStyles=this.styles.td)
            )
            to="default"
          }}
        {{else}}
          <TableHeader
            @columns={{this.columns}}
            @theadStyles={{this.styles.thead}}
            @trStyles={{this.styles.tr}}
          >
            {{#each this.columns as |column|}}
              <TableColumn @column={{column}} @thStyles={{this.styles.th}}>
                {{column.label}}
              </TableColumn>
            {{/each}}
          </TableHeader>

          <TableBody
            @columns={{this.columns}}
            @items={{this.items}}
            @tbodyStyles={{this.styles.tbody}}
            @trStyles={{this.styles.tr}}
            @thStyles={{this.styles.th}}
            @tdStyles={{this.styles.td}}
          >

            {{#each this.items as |item|}}
              <TableRow
                @item={{item}}
                @columns={{this.columns}}
                @trStyles={{this.styles.tr}}
                @tdStyles={{this.styles.td}}
              >
                {{#each this.columns as |column|}}
                  {{#let (this.getValue item column) as |value|}}
                    <TableCell
                      @item={{item}}
                      @column={{column}}
                      @value={{value}}
                      @tdStyles={{this.styles.td}}
                    >
                      {{value}}
                    </TableCell>
                  {{/let}}
                {{/each}}
              </TableRow>
            {{else}}
              {{#if @emptyContent}}
                <TableRow
                  @trStyles={{this.styles.tr}}
                  data-test-id="table-empty-row"
                >
                  <TableCell
                    colspan={{this.columns.length}}
                    @tdStyles={{this.styles.td}}
                    @class={{(this.styles.emptyCell)}}
                    data-test-id="table-empty-cell"
                  >
                    {{@emptyContent}}
                  </TableCell>
                </TableRow>
              {{/if}}
            {{/each}}
          </TableBody>
        {{/if}}
      </table>
    </div>
  </template>
}

export { Table, type TableSignature };
export default Table;
