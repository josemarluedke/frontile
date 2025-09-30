import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import { SimpleTableHeader } from './header';
import { SimpleTableBody } from './body';
import { SimpleTableFooter } from './footer';
import { SimpleTableColumn } from './column';
import { SimpleTableRow } from './row';
import { SimpleTableCell } from './cell';

import type { TableVariants, TableSlots, SlotsToClasses } from '../table/types';
import type { WithBoundArgs } from '@glint/template';

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
  };
  Element: HTMLTableElement;
  Blocks: {
    default: [
      {
        Header: WithBoundArgs<typeof SimpleTableHeader, 'styleFns' | 'classes'>;
        Body: WithBoundArgs<typeof SimpleTableBody, 'styleFns' | 'classes'>;
        Footer: WithBoundArgs<typeof SimpleTableFooter, 'styleFns' | 'classes'>;
        Column: WithBoundArgs<typeof SimpleTableColumn, 'styleFns'>;
        Row: WithBoundArgs<typeof SimpleTableRow, 'styleFns' | 'classes'>;
        Cell: WithBoundArgs<typeof SimpleTableCell, 'styleFns' | 'classes'>;
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
      isLoading: this.args.isLoading || false,
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
          data-loading={{this.args.isLoading}}
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
        data-loading={{this.args.isLoading}}
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
