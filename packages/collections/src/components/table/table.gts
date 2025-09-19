import Component from '@glimmer/component';
import { hash, get } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import { modifier } from 'ember-modifier';
import { TableHeader } from './table-header';
import { TableBody } from './table-body';
import { TableFooter } from './table-footer';
import { TableColumn } from './table-column';
import { TableRow } from './table-row';
import { TableCell } from './table-cell';
import { headlessTable as createHeadlessTable } from '@universal-ember/table';
import { columns } from '@universal-ember/table/plugins';

import type {
  ColumnConfig,
  TableVariants,
  TableSlots,
  SlotsToClasses
} from './types';
import type { ContentValue, WithBoundArgs } from '@glint/template';

interface TableSignature<T> {
  Args: {
    /** Array of column configurations for automatic table generation */
    columns?: ColumnConfig<T>[];
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
    /** Array of column configurations for automatic footer generation */
    footerColumns?: ColumnConfig<T>[];
    /** Make the table footer sticky during vertical scrolling */
    isStickyFooter?: boolean;
  };
  Element: HTMLTableElement;
  Blocks: {
    default: [
      {
        Header: WithBoundArgs<
          typeof TableHeader<T>,
          'styleFns' | 'classes' | 'columns'
        >;
        Body: WithBoundArgs<
          typeof TableBody<T>,
          'styleFns' | 'classes' | 'rows' | 'columns'
        >;
        Footer: WithBoundArgs<
          typeof TableFooter<T>,
          'styleFns' | 'classes' | 'columns'
        >;
        Column: WithBoundArgs<
          typeof TableColumn<T>,
          'styleFns' | 'tableInstance'
        >;
        Row: WithBoundArgs<typeof TableRow<T>, 'styleFns'>;
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

  tableInstance = createHeadlessTable<T>(this, {
    data: () => this.args.items || [],
    columns: () => this.args.columns || [],
    plugins: [
      // ColumnResizing,
      // ColumnVisibility
    ]
  });

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

  get columns(): ColumnConfig<T>[] {
    return this.args.columns || [];
  }

  get footerColumns(): ColumnConfig<T>[] {
    return this.args.footerColumns || [];
  }

  get items(): T[] {
    // Universal-ember rows are the original data
    return this.tableInstance.rows.values() as T[];
  }

  // Keep access to the raw universal-ember data for modifiers and rendering
  get headlessColumns() {
    return columns.for(this.tableInstance);
  }

  get headlessRows() {
    return this.tableInstance.rows.values();
  }

  <template>
    <div
      class={{this.wrapperClassNames}}
      {{this.calculateHeaderHeight}}
      {{this.tableInstance.modifiers.container}}
      data-component="table-wrapper"
    >
      {{#if (has-block)}}
        {{! Block usage }}
        <table
          class={{this.tableClassNames}}
          data-test-id="table"
          data-component="table"
          ...attributes
        >
          {{yield
            (hash
              Header=(component
                this.TableHeader
                styleFns=this.styles
                classes=this.args.classes
                columns=this.headlessColumns
              )
              Body=(component
                this.TableBody
                styleFns=this.styles
                classes=this.args.classes
                rows=this.headlessRows
                columns=this.headlessColumns
              )
              Footer=(component
                this.TableFooter
                styleFns=this.styles
                classes=this.args.classes
                columns=this.footerColumns
              )
              Column=(component
                this.TableColumn
                styleFns=this.styles
                classes=this.args.classes
                tableInstance=this.tableInstance
              )
              Row=(component
                this.TableRow
                styleFns=this.styles
                classes=this.args.classes
                columns=this.headlessColumns
                stickyKeys=@stickyKeys
                isStickyHeader=@isStickyHeader
                tableInstance=this.tableInstance
              )
              Cell=(component
                this.TableCell styleFns=this.styles classes=this.args.classes
              )
            )
          }}
        </table>
      {{else}}
        {{! Automatic rendering }}
        <table
          class={{this.tableClassNames}}
          data-test-id="table"
          data-component="table"
          ...attributes
        >
          <this.TableHeader
            @columns={{this.headlessColumns}}
            @isSticky={{@isStickyHeader}}
            @styleFns={{this.styles}}
            @classes={{this.args.classes}}
          >
            {{#each this.headlessColumns as |column|}}
              <this.TableColumn
                @column={{column}}
                @styleFns={{this.styles}}
                @tableInstance={{this.tableInstance}}
              >
                {{column.name}}
              </this.TableColumn>
            {{/each}}
          </this.TableHeader>

          <this.TableBody
            @columns={{this.headlessColumns}}
            @rows={{this.headlessRows}}
            @styleFns={{this.styles}}
            @classes={{this.args.classes}}
          >
            {{#each this.headlessRows as |row|}}
              <this.TableRow
                @row={{row}}
                @columns={{this.headlessColumns}}
                @stickyKeys={{@stickyKeys}}
                @isStickyHeader={{@isStickyHeader}}
                @styleFns={{this.styles}}
                @classes={{this.args.classes}}
                @tableInstance={{this.tableInstance}}
              >
                {{#each this.headlessColumns as |column|}}
                  <this.TableCell
                    @row={{row}}
                    @column={{column}}
                    @styleFns={{this.styles}}
                    @classes={{this.args.classes}}
                  >
                    {{column.getValueForRow row}}
                  </this.TableCell>
                {{/each}}
              </this.TableRow>
            {{else}}
              {{#if @emptyContent}}
                <this.TableRow
                  @styleFns={{this.styles}}
                  @classes={{this.args.classes}}
                  @tableInstance={{this.tableInstance}}
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
                <this.TableColumn
                  @key={{column.key}}
                  @styleFns={{this.styles}}
                  @tableInstance={{this.tableInstance}}
                >
                  {{column.name}}
                </this.TableColumn>
              {{/each}}
            </this.TableFooter>
          {{/if}}
        </table>
      {{/if}}
    </div>
  </template>
}

export { Table, type TableSignature };
export default Table;
