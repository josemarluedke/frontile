import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles, twMerge } from '@frontile/theme';
import { SimpleTableCell } from './cell';
import type { SlotsToClasses, TableSlots } from '../table/types';

interface SimpleTableRowSignature {
  Args: {
    /** Additional CSS class to apply to the row */
    class?: string;
    /** Whether this row should be sticky during vertical scrolling */
    isSticky?: boolean;
    /** Whether the table has a sticky header (affects positioning of sticky rows) */
    hasStickyHeader?: boolean;
    /**
     * @internal Style functions object from SimpleTable component
     * @ignore
     */
    styleFns?: ReturnType<ReturnType<typeof useStyles>['table']>;
    /**
     * @internal Classes object from SimpleTable component
     * @ignore
     */
    classes?: SlotsToClasses<TableSlots>;
  };
  Element: HTMLTableRowElement;
  Blocks: {
    default: [
      {
        Cell: typeof SimpleTableCell;
      }
    ];
  };
}

class SimpleTableRow extends Component<SimpleTableRowSignature> {
  get styles() {
    return this.args.styleFns || useStyles().table();
  }

  get classNames() {
    const options = {
      isSticky: this.args.isSticky || false,
      stickyPosition: this.args.isSticky ? ('top' as const) : undefined,
      hasStickyHeader: this.args.hasStickyHeader || false,
      class: twMerge(this.args.class || '', this.args.classes?.tr || '')
    };

    return this.styles.tr(options);
  }

  <template>
    <tr
      class={{this.classNames}}
      data-test-id="table-row"
      data-component="table-row"
      ...attributes
    >
      {{yield (hash Cell=SimpleTableCell)}}
    </tr>
  </template>
}

export { SimpleTableRow, type SimpleTableRowSignature };
export default SimpleTableRow;
