import Component from '@glimmer/component';
import { useStyles, twMerge } from '@frontile/theme';
import type { SlotsToClasses, TableSlots } from '../table/types';

interface SimpleTableCellSignature {
  Args: {
    /** Additional CSS class to apply to the cell */
    class?: string;
    /** Whether this cell should be sticky during horizontal scrolling */
    isSticky?: boolean;
    /** Position where the sticky cell should stick. @default 'left' */
    stickyPosition?: 'left' | 'right';
    /** Whether this cell is part of a sticky row (used for intersection styling) */
    isInStickyRow?: boolean;
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
  Element: HTMLTableCellElement;
  Blocks: {
    default: [];
  };
}

class SimpleTableCell extends Component<SimpleTableCellSignature> {
  get styles() {
    return this.args.styleFns || useStyles().table();
  }

  get classNames() {
    const options = {
      isSticky: this.args.isSticky || false,
      stickyPosition: this.args.isSticky
        ? (this.args.stickyPosition as 'left' | 'right') || 'left'
        : undefined,
      isInStickyRow: this.args.isInStickyRow || false,
      class: twMerge(this.args.class || '', this.args.classes?.td || '')
    };

    return this.styles.td(options);
  }

  <template>
    <td
      class={{this.classNames}}
      data-test-id="table-cell"
      data-component="table-cell"
      ...attributes
    >
      {{yield}}
    </td>
  </template>
}

export { SimpleTableCell, type SimpleTableCellSignature };
export default SimpleTableCell;
