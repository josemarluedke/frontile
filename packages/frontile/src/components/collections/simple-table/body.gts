import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles, twMerge } from '@frontile/theme';
import { SimpleTableRow } from './row';
import { SimpleTableCell } from './cell';
import type { SlotsToClasses, TableSlots } from '../table/types';

interface SimpleTableBodySignature {
  Args: {
    /** Additional CSS class to apply to the body section */
    class?: string;
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
  Element: HTMLTableSectionElement;
  Blocks: {
    default: [
      {
        Row: typeof SimpleTableRow;
        Cell: typeof SimpleTableCell;
      }
    ];
  };
}

class SimpleTableBody extends Component<SimpleTableBodySignature> {
  get styles() {
    return this.args.styleFns || useStyles().table();
  }

  get classNames() {
    const mergedClass = twMerge(this.args.class, this.args.classes?.tbody);
    return this.styles.tbody({ class: mergedClass });
  }

  <template>
    <tbody
      class={{this.classNames}}
      data-test-id="table-body"
      data-component="table-body"
      ...attributes
    >
      {{yield (hash Row=SimpleTableRow Cell=SimpleTableCell)}}
    </tbody>
  </template>
}

export { SimpleTableBody, type SimpleTableBodySignature };
export default SimpleTableBody;
