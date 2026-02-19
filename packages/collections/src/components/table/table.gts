import Component from '@glimmer/component';
import { hash, fn } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import { modifier } from 'ember-modifier';
import { tracked } from '@glimmer/tracking';
import { cached } from '@glimmer/tracking';
import { SimpleTable } from '../simple-table';
import { extractFrontileOptions } from './utils';
import { keyAndLabelForItem } from '../../utils/listManager';
import ColumnVisibilityComponent from './column-visibility';
import CellForComponent from './cell-for';
import CellDefaultComponent from './cell-default';
import SortButtonComponent from './sort-button';
import CheckboxComponent from './checkbox';
import { CellRenderingContext } from './cell-rendering-context';
import { headlessTable as createHeadlessTable } from '@universal-ember/table';
import { columns } from '@universal-ember/table/plugins';
import { ColumnVisibility } from '@universal-ember/table/plugins/column-visibility';
import { DataSorting } from '@universal-ember/table/plugins/data-sorting';
import {
  sort as sortColumn,
  isSortable as isColumnSortable,
  sortDirection as getColumnSortDirection
} from '@universal-ember/table/plugins/data-sorting';
import { RowSelection } from '@universal-ember/table/plugins/row-selection';

import type {
  ColumnConfig,
  FrontilePluginOption,
  TableVariants,
  TableSlots,
  SlotsToClasses,
  Column,
  Row,
  SortItem,
  SelectionMode
} from './types';
import type { ColumnConfig as UniversalColumnConfig } from '@universal-ember/table';
import type { ContentValue, WithBoundArgs } from '@glint/template';
import type Owner from '@ember/owner';

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
    /** Color variant for loading animation. @defaultValue 'default' */
    loadingColor?: TableVariants['loadingColor'];
    /** Function to sort items when sorting is triggered. Receives the items array and sort descriptor. Returns sorted items. */
    onSort?: (items: T[], sortDescriptor: SortItem<T>) => T[];
    /** Initial sort descriptor to apply on mount. Only used for initial render, subsequent changes are ignored. */
    initialSort?: SortItem<T>;
    /** Selection mode - 'none' (default), 'single' (row clicks only), or 'multiple' (with checkboxes). @defaultValue 'none' */
    selectionMode?: SelectionMode;
    /** Color variant for selection highlight. @defaultValue 'primary' */
    selectionColor?: TableVariants['selectionColor'];
    /** Set of selected item keys */
    selectedKeys?: Set<string> | string[];
    /** Callback when selection changes */
    onSelectionChange?: (selectedKeys: Set<string>) => void;
    /** Function to extract unique key from an item. Defaults to using keyAndLabelForItem helper. */
    getKey?: (item: T) => string;
    /** Array of keys that should be disabled from selection */
    disabledKeys?: string[];
    /** Show "select all" checkbox in header (only for multiple selection mode). @defaultValue true */
    showSelectAll?: boolean;
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
    empty: [];
    header: [
      {
        column: Column<T>;
        isSortable: boolean;
        sortDirection: string;
        isSorted: boolean;
        onSort: () => void;
      }
    ];
    loading: [];
    bodyTop: [];
    bodyBottom: [];
  };
}

const and = (a: unknown, b: unknown) => {
  return a && b;
};

// Standalone helper functions that don't depend on component state

function columnIsSticky<T>(column: Column<T>): boolean {
  const frontileOptions = extractFrontileOptions(column);
  return frontileOptions?.isSticky ?? false;
}

function columnStickyPosition<T>(
  column: Column<T>
): 'left' | 'right' | undefined {
  const frontileOptions = extractFrontileOptions(column);
  return frontileOptions?.stickyPosition;
}

function createCellContext<T>(column: Column<T>, row: Row<T>) {
  const registry = new CellRenderingContext();
  return {
    column,
    row,
    value: column.getValueForRow(row),
    registry
  };
}

function columnIsSorted<T>(column: Column<T>): boolean {
  return getColumnSortDirection(column) !== 'none';
}

function isSelectionColumn<T>(column: Column<T>): boolean {
  return column.key === '__selection__';
}

const calculateHeaderHeight = modifier(
  (el: HTMLDivElement, [isStickyHeader]: [boolean | undefined]) => {
    if (isStickyHeader) {
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
  }
);

class Table<
  T = unknown,
  TColumns extends ColumnConfig<T>[] = ColumnConfig<T>[]
> extends Component<TableSignature<T, TColumns>> {
  ColumnVisibility = ColumnVisibilityComponent<T>;
  CellFor = CellForComponent<T, TColumns>;
  CellDefault = CellDefaultComponent<T>;
  SortButton = SortButtonComponent<T>;
  Checkbox = CheckboxComponent;

  // Tracked state for sorting
  @tracked sorts: SortItem<T>[] = [];

  // Tracked state for uncontrolled selection
  @tracked private internalSelectedKeys = new Set<string>();

  constructor(owner: Owner, args: TableSignature<T, TColumns>['Args']) {
    super(owner, args);
    // Initialize sorts from initialSort if provided (only on mount)
    if (args.initialSort) {
      this.sorts = [args.initialSort];
    }
  }

  // Selection helpers
  get selectionMode(): SelectionMode {
    return this.args.selectionMode ?? 'none';
  }

  get hasSelection(): boolean {
    return this.selectionMode !== 'none';
  }

  @cached
  get selectedKeysSet(): Set<string> {
    // Use controlled state if provided, otherwise use internal state
    const isControlled = this.args.selectedKeys !== undefined;
    const sourceKeys = isControlled
      ? this.args.selectedKeys
      : this.internalSelectedKeys;

    if (!sourceKeys) {
      return new Set();
    }
    return sourceKeys instanceof Set ? sourceKeys : new Set(sourceKeys);
  }

  @cached
  get disabledKeysSet(): Set<string> {
    const keys = this.args.disabledKeys;
    return keys ? new Set(keys) : new Set();
  }

  // Extract actual data from row (handles both row.data and direct row)
  getRowData = (row: Row<T>): T => {
    if (row.data && row.table) {
      return row.data;
    }
    return row as T;
  };

  // Get key from item or row - unified method
  getKey = (itemOrRow: T | Row<T>): string => {
    // Extract the actual item from row if needed
    const item = (itemOrRow as Row<T>).data
      ? this.getRowData(itemOrRow as Row<T>)
      : (itemOrRow as T);

    // Use provided getKey function if available
    if (this.args.getKey) {
      return this.args.getKey(item);
    }

    // Try keyAndLabelForItem helper
    try {
      const { key } = keyAndLabelForItem(item);
      return key;
    } catch {
      // Final fallback
      return String(item);
    }
  };

  // Check if a key is disabled
  isKeyDisabled = (key: string): boolean => {
    return this.disabledKeysSet.has(key);
  };

  // Selection handlers
  handleSelect = (key: string): void => {
    if (this.isKeyDisabled(key)) return;

    const newSelection = new Set(this.selectedKeysSet);

    if (this.selectionMode === 'single') {
      // Single selection: clear all and add only the new one
      newSelection.clear();
      newSelection.add(key);
    } else {
      // Multiple selection: add to existing
      newSelection.add(key);
    }

    // Update internal state if uncontrolled
    const isControlled = this.args.selectedKeys !== undefined;
    if (!isControlled) {
      this.internalSelectedKeys = newSelection;
    }

    // Always call onChange callback if provided
    this.args.onSelectionChange?.(newSelection);
  };

  handleDeselect = (key: string): void => {
    if (this.isKeyDisabled(key)) return;

    const newSelection = new Set(this.selectedKeysSet);
    newSelection.delete(key);

    // Update internal state if uncontrolled
    const isControlled = this.args.selectedKeys !== undefined;
    if (!isControlled) {
      this.internalSelectedKeys = newSelection;
    }

    // Always call onChange callback if provided
    this.args.onSelectionChange?.(newSelection);
  };

  // Check if a row is selected
  isRowSelected = (row: Row<T>): boolean => {
    return this.selectedKeysSet.has(this.getKey(row.data));
  };

  // Check if a row is disabled
  isRowDisabled = (row: Row<T>): boolean => {
    return this.isKeyDisabled(this.getKey(row.data));
  };

  // Handler for row checkbox change
  handleRowSelectionChange = (row: Row<T>, checked: boolean): void => {
    const key = this.getKey(row.data);
    if (checked) {
      this.handleSelect(key);
    } else {
      this.handleDeselect(key);
    }
  };

  // Handler for keyboard row selection and navigation
  handleRowKeydown = (row: Row<T>, event: KeyboardEvent): void => {
    if (!this.hasSelection) return;

    // Handle arrow key navigation
    if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
      event.preventDefault();

      const currentElement = event.target as HTMLElement;
      const allRows = Array.from(
        currentElement
          .closest('tbody')
          ?.querySelectorAll('[data-selectable="true"]') || []
      ) as HTMLElement[];

      const currentIndex = allRows.indexOf(currentElement);

      if (event.key === 'ArrowDown' && currentIndex < allRows.length - 1) {
        allRows[currentIndex + 1]?.focus();
      } else if (event.key === 'ArrowUp' && currentIndex > 0) {
        allRows[currentIndex - 1]?.focus();
      }

      return;
    }

    // Handle selection (Space/Enter)
    if (this.isRowDisabled(row)) return;

    // Only handle Space and Enter keys
    if (event.key !== ' ' && event.key !== 'Enter') return;

    // Prevent default behavior (scroll for Space, form submission for Enter)
    event.preventDefault();

    const key = this.getKey(row.data);
    const isSelected = this.isRowSelected(row);

    if (this.selectionMode === 'single') {
      // Single selection: always select the row
      this.handleSelect(key);
    } else {
      // Multiple selection: toggle
      if (isSelected) {
        this.handleDeselect(key);
      } else {
        this.handleSelect(key);
      }
    }
  };

  // Modifier for row keyboard navigation
  rowKeyboardHandler = modifier((element: HTMLElement, [row]: [Row<T>]) => {
    const handler = (event: KeyboardEvent) => {
      this.handleRowKeydown(row, event);
    };

    element.addEventListener('keydown', handler);

    return () => {
      element.removeEventListener('keydown', handler);
    };
  });

  // Get all selectable (non-disabled) item keys
  get selectableKeys(): string[] {
    const items = this.args.items || [];
    return items
      .map((item) => this.getKey(item))
      .filter((key) => !this.isKeyDisabled(key));
  }

  // Check if all selectable rows are selected
  get isAllSelected(): boolean {
    if (this.selectableKeys.length === 0) return false;
    return this.selectableKeys.every((key) => this.selectedKeysSet.has(key));
  }

  // Check if some (but not all) selectable rows are selected
  get isSomeSelected(): boolean {
    if (this.selectedKeysSet.size === 0) return false;
    if (this.isAllSelected) return false;
    return this.selectableKeys.some((key) => this.selectedKeysSet.has(key));
  }

  // Handler for select all checkbox change
  handleSelectAllChange = (checked: boolean): void => {
    const newSelection = new Set(this.selectedKeysSet);

    if (checked) {
      // Select all selectable rows
      this.selectableKeys.forEach((key) => {
        newSelection.add(key);
      });
    } else {
      // Deselect all selectable rows
      this.selectableKeys.forEach((key) => {
        newSelection.delete(key);
      });
    }

    // Update internal state if uncontrolled
    const isControlled = this.args.selectedKeys !== undefined;
    if (!isControlled) {
      this.internalSelectedKeys = newSelection;
    }

    // Always call onChange callback if provided
    this.args.onSelectionChange?.(newSelection);
  };

  // Add checkbox column for multiple selection
  get columnsWithSelection(): readonly ColumnConfig<T>[] {
    if (this.selectionMode !== 'multiple') {
      return this.args.columns;
    }

    // Add checkbox column as the first column
    const checkboxColumn: ColumnConfig<T> = {
      key: '__selection__',
      name: '', // Empty name, we'll render checkbox in header
      isSticky: this.args.isScrollable || false,
      stickyPosition: 'left'
    };

    return [checkboxColumn, ...this.args.columns];
  }

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
        isSortable,
        sortProperty,
        Cell,
        value,
        ...baseColumn
      } = column;

      const pluginOptions: unknown[] = [];

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

      // Add DataSorting plugin option - always add it to override the default (true) with our default (false)
      pluginOptions.push(
        DataSorting.forColumn(() => ({
          isSortable: isSortable ?? false, // Default to false (override universal-ember's default of true)
          sortProperty
        }))
      );

      // Create the universal-ember column configuration
      const universalColumn: UniversalColumnConfig<T> = {
        key: baseColumn.key,
        name: baseColumn.name,
        pluginOptions:
          pluginOptions.length > 0
            ? (pluginOptions as UniversalColumnConfig<T>['pluginOptions'])
            : undefined
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

  // Handler for sort state changes from the DataSorting plugin
  handleSortChange = (newSorts: SortItem<T>[]) => {
    this.sorts = newSorts;
  };

  tableInstance = createHeadlessTable<T>(this, {
    data: () => this.sortedItems,
    columns: () => this.processColumns(this.columnsWithSelection),
    plugins: [
      ColumnVisibility,
      DataSorting.with(() => ({
        sorts: this.sorts,
        onSort: this.handleSortChange
      })),
      ...(this.hasSelection
        ? [
            RowSelection.with(() => ({
              selection: this.selectedKeysSet,
              key: this.getKey,
              onSelect: this.handleSelect,
              onDeselect: this.handleDeselect
            }))
          ]
        : [])
    ]
  });

  // Computed property that returns sorted items based on current sort state
  get sortedItems(): T[] {
    const items = this.args.items || [];

    // If no onSort handler or no active sorts, return items as-is
    if (!this.args.onSort || this.sorts.length === 0) {
      return items;
    }

    // Only use the first sort item (single column sorting)
    const sortDescriptor = this.sorts[0];
    if (!sortDescriptor) {
      return items;
    }

    return this.args.onSort(items, sortDescriptor);
  }

  get styles() {
    const { table } = useStyles();
    return table({
      size: this.args.size,
      layout: this.args.layout,
      striped: this.args.isStriped,
      isScrollable: this.args.isScrollable || false,
      hasStickyHeader: this.args.isStickyHeader || false,
      isLoading: this.args.isLoading || false,
      loadingColor: this.args.loadingColor,
      selectionColor: this.args.selectionColor,
      class: this.args.classes?.base
    });
  }

  get wrapperClassNames() {
    return this.styles.wrapper({
      class: this.args.classes?.wrapper
    });
  }

  get tableClassNames() {
    return this.styles.table({ class: this.args.classes?.table });
  }

  get headlessColumns() {
    return columns.for(this.tableInstance);
  }

  get headlessRows() {
    return this.tableInstance.rows.values();
  }

  // Helper to check if a row is sticky
  isRowSticky = (row: Row<T>): boolean => {
    return !!this.args.stickyKeys?.includes(this.getKey(row));
  };

  <template>
    <div
      class={{this.wrapperClassNames}}
      {{calculateHeaderHeight @isStickyHeader}}
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
        @loadingColor={{@loadingColor}}
        @selectionColor={{@selectionColor}}
        @hasCustomLoading={{has-block "loading"}}
        as |t|
      >
        <t.Header @isSticky={{@isStickyHeader}}>
          {{#each this.headlessColumns as |column|}}
            <t.Column
              {{this.tableInstance.modifiers.columnHeader column}}
              @isSticky={{columnIsSticky column}}
              @stickyPosition={{columnStickyPosition column}}
              data-key={{column.key}}
              data-sortable="{{isColumnSortable column}}"
            >
              {{#if (isSelectionColumn column)}}
                {{! Selection column header - render select all checkbox if enabled (default true) }}
                {{#if (if @showSelectAll @showSelectAll true)}}
                  <this.Checkbox
                    @checked={{this.isAllSelected}}
                    @indeterminate={{this.isSomeSelected}}
                    @onChange={{this.handleSelectAllChange}}
                    @size={{@size}}
                    @ariaLabel="Select all rows"
                  />
                {{/if}}
              {{else if (has-block "header")}}
                {{yield
                  (hash
                    column=column
                    isSortable=(isColumnSortable column)
                    sortDirection=(getColumnSortDirection column)
                    isSorted=(columnIsSorted column)
                    onSort=(fn sortColumn column)
                  )
                  to="header"
                }}
              {{else if (isColumnSortable column)}}
                <this.SortButton
                  @column={{column}}
                  @sortDirection={{getColumnSortDirection column}}
                  @isSorted={{columnIsSorted column}}
                  @onSort={{fn sortColumn column}}
                />
              {{else}}
                {{column.name}}
              {{/if}}
            </t.Column>
          {{/each}}
        </t.Header>

        <t.Body>
          {{#if (has-block "bodyTop")}}
            {{yield to="bodyTop"}}
          {{/if}}

          {{#each this.headlessRows as |row|}}
            <t.Row
              {{this.tableInstance.modifiers.row row}}
              {{this.rowKeyboardHandler row}}
              @isSticky={{this.isRowSticky row}}
              @hasStickyHeader={{@isStickyHeader}}
              data-key={{this.getKey row}}
              data-selected={{if (this.isRowSelected row) "true" "false"}}
              data-disabled={{if (this.isRowDisabled row) "true"}}
              data-selectable={{if this.hasSelection "true"}}
              tabindex={{if this.hasSelection "0" "-1"}}
            >
              {{#each this.headlessColumns as |column|}}
                <t.Cell
                  @isSticky={{columnIsSticky column}}
                  @stickyPosition={{columnStickyPosition column}}
                  @isInStickyRow={{this.isRowSticky row}}
                  data-column={{column.key}}
                >
                  {{#if (isSelectionColumn column)}}
                    {{! Selection column cell - render checkbox }}
                    <this.Checkbox
                      @checked={{this.isRowSelected row}}
                      @disabled={{this.isRowDisabled row}}
                      @onChange={{fn this.handleRowSelectionChange row}}
                      @size={{@size}}
                      @ariaLabel="Select row"
                    />
                  {{else if (has-block "cell")}}
                    {{#let (createCellContext column row) as |cellContext|}}
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
            {{#unless @isLoading}}
              {{#if (has-block "empty")}}
                <t.Row data-test-id="table-empty-row">
                  <t.Cell
                    @class={{(this.styles.empty)}}
                    colspan={{this.headlessColumns.length}}
                    data-test-id="table-empty-cell"
                  >
                    {{yield to="empty"}}
                  </t.Cell>
                </t.Row>
              {{else if @emptyContent}}
                <t.Row data-test-id="table-empty-row">
                  <t.Cell
                    @class={{(this.styles.empty)}}
                    colspan={{this.headlessColumns.length}}
                    data-test-id="table-empty-cell"
                  >
                    {{@emptyContent}}
                  </t.Cell>
                </t.Row>
              {{/if}}
            {{/unless}}
          {{/each}}

          {{#if (and @isLoading (has-block "loading"))}}
            <t.Row data-test-id="table-loading-row">
              <t.Cell
                colspan={{this.headlessColumns.length}}
                data-test-id="table-loading-cell"
              >
                {{yield to="loading"}}
              </t.Cell>
            </t.Row>
          {{/if}}

          {{#if (has-block "bodyBottom")}}
            {{yield to="bodyBottom"}}
          {{/if}}
        </t.Body>

        {{#if @footerColumns}}
          <t.Footer @isSticky={{@isStickyFooter}}>
            {{#each @footerColumns as |column|}}
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
