import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import { modifier } from 'ember-modifier';
import { SimpleTable } from '../simple-table';
import { extractFrontileOptions } from './utils';
import { keyAndLabelForItem } from '../../utils/listManager';
import ColumnVisibilityComponent from './column-visibility';
import CellForComponent from './cell-for';
import CellDefaultComponent from './cell-default';
import { CellRenderingContext } from './cell-rendering-context';
import { headlessTable as createHeadlessTable } from '@universal-ember/table';
import { columns } from '@universal-ember/table/plugins';
import { ColumnVisibility } from '@universal-ember/table/plugins/column-visibility';

import type {
  ColumnConfig,
  FrontilePluginOption,
  TableVariants,
  TableSlots,
  SlotsToClasses,
  Column,
  Row
} from './types';
import type { ColumnConfig as UniversalColumnConfig } from '@universal-ember/table';
import type { ContentValue, WithBoundArgs } from '@glint/template';

interface TableSignature<
  T,
  TColumns extends ColumnConfig<T>[] = ColumnConfig<T>[]
> {
  Args: {
    /** Array of column configurations for automatic table generation */
    columns: TColumns;
    /** Array of data items to display in the table */
    items: T[];
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
    /** Enable loading state styling and behavior */
    isLoading?: boolean;
  };
  Element: HTMLTableElement;
  Blocks: {
    default: never;
    toolbar: [
      {
        ColumnVisibility: WithBoundArgs<
          typeof ColumnVisibilityComponent<T>,
          'tableInstance'
        >;
      }
    ];
    cell: [
      {
        column: Column<T>;
        value: ContentValue;
        row: Row<T>;
        For: WithBoundArgs<
          typeof CellForComponent<T, TColumns>,
          'column' | 'registry'
        >;
        Default: WithBoundArgs<
          typeof CellDefaultComponent<T>,
          'column' | 'registry'
        >;
      }
    ];
  };
}

class Table<
  T = unknown,
  TColumns extends ColumnConfig<T>[] = ColumnConfig<T>[]
> extends Component<TableSignature<T, TColumns>> {
  ColumnVisibility = ColumnVisibilityComponent<T>;
  CellFor = CellForComponent<T, TColumns>;
  CellDefault = CellDefaultComponent<T>;

  // Transform Frontile ColumnConfig to universal-ember ColumnConfig with pluginOptions
  processColumns(
    columns: readonly ColumnConfig<T>[]
  ): UniversalColumnConfig<T>[] {
    if (!columns) return [];
    return columns.map((column) => {
      const {
        isSticky,
        stickyPosition,
        isVisible,
        Cell,
        value,
        ...baseColumn
      } = column;

      const pluginOptions: any[] = [];

      // Add Frontile sticky options if present
      if (isSticky !== undefined || stickyPosition !== undefined) {
        const frontileOption: FrontilePluginOption = [
          'frontile',
          () => ({ isSticky, stickyPosition })
        ];
        pluginOptions.push(frontileOption);
      }

      // Add ColumnVisibility plugin option if isVisible is explicitly set
      if (isVisible !== undefined) {
        pluginOptions.push(ColumnVisibility.forColumn(() => ({ isVisible })));
      }

      // Create the universal-ember column configuration
      const universalColumn: UniversalColumnConfig<T> = {
        key: baseColumn.key,
        name: baseColumn.name,
        pluginOptions: pluginOptions.length > 0 ? pluginOptions : undefined
      };

      // Add value function if provided
      if (value) {
        universalColumn.value = value;
      }

      // Add Cell component if provided
      if (Cell) {
        universalColumn.Cell = Cell;
      }

      return universalColumn;
    });
  }

  tableInstance = createHeadlessTable<T>(this, {
    data: () => this.args.items,
    columns: () => this.processColumns(this.args.columns),
    plugins: [
      ColumnVisibility
      // ColumnResizing,
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
      isLoading: this.args.isLoading || false,
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

  get columns(): readonly ColumnConfig<T>[] {
    return this.args.columns || [];
  }

  get footerColumns(): ColumnConfig<T>[] {
    return this.args.footerColumns || [];
  }

  get items(): T[] {
    return this.tableInstance.rows.values() as T[];
  }

  get headlessColumns() {
    return columns.for(this.tableInstance);
  }

  get headlessRows() {
    return this.tableInstance.rows.values();
  }

  // Helper to check if a column is sticky
  columnIsSticky = (column: Column<T>): boolean => {
    const frontileOptions = extractFrontileOptions(column);
    return frontileOptions?.isSticky ?? false;
  };

  // Helper to get column sticky position
  columnStickyPosition = (column: Column<T>): 'left' | 'right' | undefined => {
    const frontileOptions = extractFrontileOptions(column);
    return frontileOptions?.stickyPosition;
  };

  // Helper to check if a row is sticky
  rowIsSticky = (row: Row<T>): boolean => {
    if (!this.args.stickyKeys) return false;
    const rowKey = this.getRowKey(row);
    return this.args.stickyKeys.includes(rowKey);
  };

  // Helper to get row key (from existing TableRow logic)
  getRowKey = (row: any): string => {
    if (row) {
      const actualData = row.data || row;
      try {
        const { key } = keyAndLabelForItem(actualData);
        return key;
      } catch (error) {
        return row.index?.toString() || '';
      }
    }
    return '';
  };

  // Create cell context with registry for custom cell rendering
  createCellContext = (column: Column<T>, row: Row<T>) => {
    const registry = new CellRenderingContext();
    return {
      column,
      row,
      value: column.getValueForRow(row),
      registry
    };
  };

  <template>
    <div
      class={{this.wrapperClassNames}}
      {{this.calculateHeaderHeight}}
      {{this.tableInstance.modifiers.container}}
      data-component="table-wrapper"
    >
      {{#if (has-block "toolbar")}}
        <div class="table-toolbar" data-component="table-toolbar">
          {{yield
            (hash
              ColumnVisibility=(component
                this.ColumnVisibility tableInstance=this.tableInstance
              )
            )
            to="toolbar"
          }}
        </div>
      {{/if}}

      <SimpleTable
        @classes={{this.args.classes}}
        @size={{@size}}
        @layout={{@layout}}
        @isStriped={{@isStriped}}
        @isScrollable={{@isScrollable}}
        @hasWrapper={{false}}
        @isLoading={{@isLoading}}
        as |t|
      >
        <t.Header @isSticky={{@isStickyHeader}}>
          {{#each this.headlessColumns as |column|}}
            <t.Column
              {{this.tableInstance.modifiers.columnHeader column}}
              @isSticky={{this.columnIsSticky column}}
              @stickyPosition={{this.columnStickyPosition column}}
              data-key={{column.key}}
            >
              {{column.name}}
            </t.Column>
          {{/each}}
        </t.Header>

        <t.Body>
          {{#each this.headlessRows as |row|}}
            <t.Row
              {{this.tableInstance.modifiers.row row}}
              @isSticky={{this.rowIsSticky row}}
              @hasStickyHeader={{@isStickyHeader}}
              data-key={{this.getRowKey row}}
            >
              {{#each this.headlessColumns as |column|}}
                <t.Cell
                  @isSticky={{this.columnIsSticky column}}
                  @stickyPosition={{this.columnStickyPosition column}}
                  @isInStickyRow={{this.rowIsSticky row}}
                  data-column={{column.key}}
                >
                  {{#if (has-block "cell")}}
                    {{#let
                      (this.createCellContext column row)
                      as |cellContext|
                    }}
                      {{yield
                        (hash
                          column=cellContext.column
                          value=cellContext.value
                          row=cellContext.row
                          For=(component
                            this.CellFor
                            column=column
                            registry=cellContext.registry
                          )
                          Default=(component
                            this.CellDefault
                            column=column
                            registry=cellContext.registry
                          )
                        )
                        to="cell"
                      }}
                    {{/let}}
                  {{else}}
                    {{#if column.Cell}}
                      <column.Cell @row={{row}} @column={{column}} />
                    {{else}}
                      {{column.getValueForRow row}}
                    {{/if}}
                  {{/if}}
                </t.Cell>
              {{/each}}
            </t.Row>
          {{else}}
            {{#if @emptyContent}}
              <t.Row data-test-id="table-empty-row">
                <t.Cell
                  @class={{(this.styles.emptyCell)}}
                  colspan={{this.headlessColumns.length}}
                  data-test-id="table-empty-cell"
                >
                  {{@emptyContent}}
                </t.Cell>
              </t.Row>
            {{/if}}
          {{/each}}
        </t.Body>

        {{#if this.footerColumns.length}}
          <t.Footer @isSticky={{@isStickyFooter}}>
            {{#each this.footerColumns as |column|}}
              <t.Column data-key={{column.key}}>
                {{column.name}}
              </t.Column>
            {{/each}}
          </t.Footer>
        {{/if}}
      </SimpleTable>
    </div>
  </template>
}

export { Table, type TableSignature };
export default Table;
