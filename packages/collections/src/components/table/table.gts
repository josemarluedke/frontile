import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import { modifier } from 'ember-modifier';
import { getSafeValue } from './utils';
import { TableHeader } from './table-header';
import { TableBody } from './table-body';
import { TableFooter } from './table-footer';
import { TableColumn } from './table-column';
import { TableRow } from './table-row';
import { TableCell } from './table-cell';
import type {
  ColumnDefinition,
  TableVariants,
  TableSlots,
  SlotsToClasses,
  ClassValue
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
    /** Array of item keys that should be sticky during vertical scrolling */
    stickyKeys?: string[];
    /** Make the table header sticky during vertical scrolling */
    isStickyHeader?: boolean;
    /** Array of column definitions for automatic footer generation */
    footerColumns?: ColumnDefinition<T>[];
    /** Make the table footer sticky during vertical scrolling */
    isStickyFooter?: boolean;
  };
  Element: HTMLTableElement;
  Blocks: {
    default: [
      {
        Column: WithBoundArgs<typeof TableColumn<T>, 'styleFns'>;
        Header: WithBoundArgs<typeof TableHeader<T>, 'columns' | 'styleFns'>;
        Body: WithBoundArgs<
          typeof TableBody<T>,
          'columns' | 'items' | 'styleFns'
        >;
        Footer: WithBoundArgs<typeof TableFooter<T>, 'columns' | 'styleFns'>;
        Row: WithBoundArgs<
          typeof TableRow<T>,
          'columns' | 'styleFns' | 'stickyKeys' | 'isStickyHeader'
        >;
        Cell: WithBoundArgs<typeof TableCell<T>, 'styleFns'>;
      }
    ];
  };
}

class Table<T = unknown> extends Component<TableSignature<T>> {
  // Needed to make glint happy with generic components
  TableBody = TableBody<T>;
  TableFooter = TableFooter<T>;
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
      hasStickyHeader: this.args.isStickyHeader || false,
      class: this.args.classes?.base
    });
  }

  get wrapperClassNames() {
    return this.styles.wrapper({
      class: this.args.classes?.wrapper
    });
  }

  calculateHeaderHeight = modifier((el: HTMLDivElement) => {
    if (this.args.isStickyHeader) {
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

  get footerColumns(): ColumnDefinition<T>[] {
    return this.args.footerColumns || [];
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
        {{#if (has-block)}}
          {{yield
            (hash
              Column=(component this.TableColumn styleFns=this.styles)
              Header=(component
                this.TableHeader
                columns=this.columns
                styleFns=this.styles
                classes=this.args.classes
              )
              Body=(component
                this.TableBody
                columns=this.columns
                items=this.items
                styleFns=this.styles
                classes=this.args.classes
              )
              Footer=(component
                this.TableFooter
                columns=this.footerColumns
                styleFns=this.styles
                classes=this.args.classes
              )
              Row=(component
                this.TableRow
                columns=this.columns
                stickyKeys=@stickyKeys
                isStickyHeader=@isStickyHeader
                styleFns=this.styles
                classes=this.args.classes
              )
              Cell=(component
                this.TableCell styleFns=this.styles classes=this.args.classes
              )
            )
          }}
        {{else}}
          <this.TableHeader
            @columns={{this.columns}}
            @isSticky={{@isStickyHeader}}
            @styleFns={{this.styles}}
            @classes={{this.args.classes}}
          >
            {{#each this.columns as |column|}}
              <this.TableColumn @column={{column}} @styleFns={{this.styles}}>
                {{column.label}}
              </this.TableColumn>
            {{/each}}
          </this.TableHeader>

          <this.TableBody
            @columns={{this.columns}}
            @items={{this.items}}
            @styleFns={{this.styles}}
            @classes={{this.args.classes}}
          >

            {{#each this.items as |item|}}
              <this.TableRow
                @item={{item}}
                @columns={{this.columns}}
                @stickyKeys={{@stickyKeys}}
                @isStickyHeader={{@isStickyHeader}}
                @styleFns={{this.styles}}
                @classes={{this.args.classes}}
              >
                {{#each this.columns as |column|}}
                  {{#let (this.getValue item column) as |value|}}
                    <this.TableCell
                      @item={{item}}
                      @column={{column}}
                      @styleFns={{this.styles}}
                      @classes={{this.args.classes}}
                    >
                      {{value}}
                    </this.TableCell>
                  {{/let}}
                {{/each}}
              </this.TableRow>
            {{else}}
              {{#if @emptyContent}}
                <this.TableRow
                  @styleFns={{this.styles}}
                  @classes={{this.args.classes}}
                  data-test-id="table-empty-row"
                >
                  <this.TableCell
                    colspan={{this.columns.length}}
                    @styleFns={{this.styles}}
                    @classes={{this.args.classes}}
                    @class={{(this.styles.emptyCell)}}
                    data-test-id="table-empty-cell"
                  >
                    {{@emptyContent}}
                  </this.TableCell>
                </this.TableRow>
              {{/if}}
            {{/each}}
          </this.TableBody>

          {{#if this.footerColumns.length}}
            <this.TableFooter
              @columns={{this.footerColumns}}
              @isSticky={{@isStickyFooter}}
              @styleFns={{this.styles}}
              @classes={{this.args.classes}}
            >
              {{#each this.footerColumns as |column|}}
                <this.TableColumn @column={{column}} @styleFns={{this.styles}}>
                  {{column.label}}
                </this.TableColumn>
              {{/each}}
            </this.TableFooter>
          {{/if}}
        {{/if}}
      </table>
    </div>
  </template>
}

export { Table, type TableSignature };
export default Table;
