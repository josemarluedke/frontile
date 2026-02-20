import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import { SimpleTableHeader, type SimpleTableHeaderSignature } from './header';
import { SimpleTableBody, type SimpleTableBodySignature } from './body';
import { SimpleTableFooter, type SimpleTableFooterSignature } from './footer';
import { SimpleTableColumn, type SimpleTableColumnSignature } from './column';
import { SimpleTableRow, type SimpleTableRowSignature } from './row';
import { SimpleTableCell, type SimpleTableCellSignature } from './cell';

import type { TableVariants, TableSlots, SlotsToClasses } from '../table/types';
import type { ComponentLike, WithBoundArgs } from '@glint/template';

interface SimpleTableSignature {
  Args: {
    /** Custom CSS classes for different table elements (wrapper, table, th, td, etc.) */
    classes?: SlotsToClasses<TableSlots>;
    /** Size variant for table cells and headers. @defaultValue 'md' */
    size?: TableVariants['size'];
    /** Table layout algorithm - 'auto' sizes columns by content, 'fixed' uses first row for sizing. @defaultValue 'auto' */
    layout?: TableVariants['layout'];
    /** Enable striped rows (alternating background colors) */
    isStriped?: TableVariants['striped'];
    /** Enable scrolling for the table container */
    isScrollable?: boolean;
    /** Whether to render the wrapper div. @defaultValue true */
    hasWrapper?: boolean;
    /** Enable loading state styling and behavior */
    isLoading?: boolean;
    /** Color variant for loading animation. @defaultValue 'default' */
    loadingColor?: TableVariants['loadingColor'];
    /** Color variant for selection highlight. @defaultValue 'primary' */
    selectionColor?: TableVariants['selectionColor'];
    /** Whether a custom loading block is provided (disables CSS loading indicator) */
    hasCustomLoading?: boolean;
  };
  Element: HTMLTableElement;
  Blocks: {
    default: [
      {
        Header: WithBoundArgs<
          ComponentLike<SimpleTableHeaderSignature>,
          'styleFns' | 'classes'
        >;
        Body: WithBoundArgs<
          ComponentLike<SimpleTableBodySignature>,
          'styleFns' | 'classes'
        >;
        Footer: WithBoundArgs<
          ComponentLike<SimpleTableFooterSignature>,
          'styleFns' | 'classes'
        >;
        Column: WithBoundArgs<
          ComponentLike<SimpleTableColumnSignature>,
          'styleFns'
        >;
        Row: WithBoundArgs<
          ComponentLike<SimpleTableRowSignature>,
          'styleFns' | 'classes'
        >;
        Cell: WithBoundArgs<
          ComponentLike<SimpleTableCellSignature>,
          'styleFns' | 'classes'
        >;
      }
    ];
  };
}

class SimpleTable extends Component<SimpleTableSignature> {
  get hasWrapper() {
    return this.args.hasWrapper ?? true;
  }

  get styles() {
    const { table } = useStyles();
    return table({
      size: this.args.size,
      layout: this.args.layout,
      striped: this.args.isStriped,
      isScrollable: this.args.isScrollable || false,
      hasStickyHeader: false, // Will be determined by header component
      isLoading: this.args.hasCustomLoading
        ? false
        : this.args.isLoading || false,
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

  <template>
    {{#if this.hasWrapper}}
      <div class={{this.wrapperClassNames}} data-component="table-wrapper">
        <table
          class={{this.tableClassNames}}
          data-test-id="table"
          data-component="table"
          data-loading={{if this.args.isLoading "true" "false"}}
          ...attributes
        >
          {{yield
            (hash
              Header=(component
                SimpleTableHeader styleFns=this.styles classes=this.args.classes
              )
              Body=(component
                SimpleTableBody styleFns=this.styles classes=this.args.classes
              )
              Footer=(component
                SimpleTableFooter styleFns=this.styles classes=this.args.classes
              )
              Column=(component SimpleTableColumn styleFns=this.styles)
              Row=(component
                SimpleTableRow styleFns=this.styles classes=this.args.classes
              )
              Cell=(component
                SimpleTableCell styleFns=this.styles classes=this.args.classes
              )
            )
          }}
        </table>
      </div>
    {{else}}
      <table
        class={{this.tableClassNames}}
        data-test-id="table"
        data-component="table"
        data-loading={{if this.args.isLoading "true" "false"}}
        ...attributes
      >
        {{yield
          (hash
            Header=(component
              SimpleTableHeader styleFns=this.styles classes=this.args.classes
            )
            Body=(component
              SimpleTableBody styleFns=this.styles classes=this.args.classes
            )
            Footer=(component
              SimpleTableFooter styleFns=this.styles classes=this.args.classes
            )
            Column=(component SimpleTableColumn styleFns=this.styles)
            Row=(component
              SimpleTableRow styleFns=this.styles classes=this.args.classes
            )
            Cell=(component
              SimpleTableCell styleFns=this.styles classes=this.args.classes
            )
          )
        }}
      </table>
    {{/if}}
  </template>
}

export { SimpleTable, type SimpleTableSignature };
export default SimpleTable;
