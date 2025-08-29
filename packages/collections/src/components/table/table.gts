import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import { modifier } from 'ember-modifier';
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
    /** Array of column definitions for automatic table generation */
    columns?: ColumnDefinition<T>[];
    /** Array of data items to display in the table */
    items?: T[];
    /** Custom CSS classes for different table elements (wrapper, table, th, td, etc.) */
    classes?: SlotsToClasses<TableSlots>;
    /** Size variant for table cells and headers. @defaultValue 'md' */
    size?: TableVariants['size'];
    /** Table layout algorithm - 'auto' sizes columns by content, 'fixed' uses first row for sizing. @defaultValue 'auto' */
    layout?: TableVariants['layout'];
    /** Enable striped rows (alternating background colors) */
    isStriped?: TableVariants['striped'];
    /** Content to display when no data items are provided */
    emptyContent?: ContentValue;
    /** Enable scrolling for the table container */
    isScrollable?: boolean;
    /** Array of item keys that should be frozen (sticky) during vertical scrolling */
    frozenKeys?: string[];
    /** Make the table header sticky during vertical scrolling */
    isFrozenHeader?: boolean;
  };
  Element: HTMLTableElement;
  Blocks: {
    default: [
      {
        Column: WithBoundArgs<typeof TableColumn<T>, 'thStyles'>;
        Header: WithBoundArgs<
          typeof TableHeader<T>,
          'columns' | 'theadStyles' | 'trStyles'
        >;
        Body: WithBoundArgs<
          typeof TableBody<T>,
          | 'columns'
          | 'items'
          | 'tbodyStyles'
          | 'trStyles'
          | 'tdStyles'
        >;
        Row: WithBoundArgs<
          typeof TableRow<T>,
          'columns' | 'trStyles' | 'tdStyles' | 'frozenKeys' | 'isFrozenHeader'
        >;
        Cell: WithBoundArgs<typeof TableCell<T>, 'tdStyles'>;
      }
    ];
  };
}

class Table<T = unknown> extends Component<TableSignature<T>> {
  // Needed to make glint happy with generic components
  TableBody = TableBody<T>;
  TableRow = TableRow<T>;
  TableCell = TableCell<T>;
  TableColumn = TableColumn<T>;
  TableHeader = TableHeader<T>;

  get styles() {
    const { table } = useStyles();
    return table({
      size: this.args.size,
      layout: this.args.layout,
      striped: this.args.isStriped,
      isScrollable: this.args.isScrollable || false,
      hasFrozenHeader: this.args.isFrozenHeader || false,
      class: this.args.classes?.base
    });
  }

  get wrapperClassNames() {
    return this.styles.wrapper({
      class: this.args.classes?.wrapper
    });
  }

  calculateHeaderHeight = modifier((el: HTMLDivElement) => {
    if (this.args.isFrozenHeader) {
      const updateHeight = () => {
        const thead = el.querySelector('thead');
        if (thead) {
          const headerHeight = Math.round(thead.offsetHeight);
          el.style.setProperty('--table-header-height', `${headerHeight}px`);
        }
      };

      requestAnimationFrame(updateHeight);

      // Update on resize
      let observer: ResizeObserver;
      observer = new ResizeObserver(updateHeight);
      observer.observe(el);

      return () => {
        if (observer) {
          observer.disconnect();
        }
      };
    }
  });

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
    <div
      class={{this.wrapperClassNames}}
      {{this.calculateHeaderHeight}}
      data-component="table-wrapper"
    >
      <table
        class={{this.tableClassNames}}
        data-test-id="table"
        data-component="table"
        ...attributes
      >
        {{#if (has-block "default")}}
          {{yield
            (hash
              Column=(component this.TableColumn thStyles=this.styles.th)
              Header=(component
                this.TableHeader
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
                tdStyles=this.styles.td
              )
              Row=(component
                this.TableRow
                columns=this.columns
                frozenKeys=@frozenKeys
                isFrozenHeader=@isFrozenHeader
                trStyles=this.styles.tr
                tdStyles=this.styles.td
              )
              Cell=(component this.TableCell tdStyles=this.styles.td)
            )
            to="default"
          }}
        {{else}}
          <this.TableHeader
            @columns={{this.columns}}
            @isFrozen={{@isFrozenHeader}}
            @theadStyles={{this.styles.thead}}
            @trStyles={{this.styles.tr}}
          >
            {{#each this.columns as |column|}}
              <this.TableColumn @column={{column}} @thStyles={{this.styles.th}}>
                {{column.label}}
              </this.TableColumn>
            {{/each}}
          </this.TableHeader>

          <this.TableBody
            @columns={{this.columns}}
            @items={{this.items}}
            @tbodyStyles={{this.styles.tbody}}
            @trStyles={{this.styles.tr}}
            @tdStyles={{this.styles.td}}
          >

            {{#each this.items as |item|}}
              <this.TableRow
                @item={{item}}
                @columns={{this.columns}}
                @frozenKeys={{@frozenKeys}}
                @isFrozenHeader={{@isFrozenHeader}}
                @trStyles={{this.styles.tr}}
                @tdStyles={{this.styles.td}}
              >
                {{#each this.columns as |column|}}
                  {{#let (this.getValue item column) as |value|}}
                    <this.TableCell
                      @item={{item}}
                      @column={{column}}
                      @tdStyles={{this.styles.td}}
                    >
                      {{value}}
                    </this.TableCell>
                  {{/let}}
                {{/each}}
              </this.TableRow>
            {{else}}
              {{#if @emptyContent}}
                <this.TableRow
                  @trStyles={{this.styles.tr}}
                  data-test-id="table-empty-row"
                >
                  <this.TableCell
                    colspan={{this.columns.length}}
                    @tdStyles={{this.styles.td}}
                    @class={{(this.styles.emptyCell)}}
                    data-test-id="table-empty-cell"
                  >
                    {{@emptyContent}}
                  </this.TableCell>
                </this.TableRow>
              {{/if}}
            {{/each}}
          </this.TableBody>
        {{/if}}
      </table>
    </div>
  </template>
}

export { Table, type TableSignature };
export default Table;
