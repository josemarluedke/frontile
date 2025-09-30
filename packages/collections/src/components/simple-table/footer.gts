import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles, twMerge } from '@frontile/theme';
import { SimpleTableColumn } from './column';
import type { SlotsToClasses, TableSlots } from '../table/types';

interface SimpleTableFooterSignature {
  Args: {
    /** Additional CSS class to apply to the footer element */
    class?: string;
    /** Whether this footer should be sticky during vertical scrolling */
    isSticky?: boolean;
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
        Column: typeof SimpleTableColumn;
      }
    ];
  };
}

class SimpleTableFooter extends Component<SimpleTableFooterSignature> {
  get styles() {
    return this.args.styleFns || useStyles().table();
  }

  get classNames() {
    const options = {
      isSticky: this.args.isSticky || false,
      stickyPosition: this.args.isSticky ? ('bottom' as const) : undefined,
      class: twMerge(this.args.class, this.args.classes?.tfoot)
    };

    return this.styles.tfoot(options);
  }

  get rowClassNames() {
    const options = {
      class: twMerge('', this.args.classes?.tr || ''),
      isSticky: false
    };
    return this.styles.tr(options);
  }

  get separatorClassNames() {
    return this.styles.separator({
      class: this.args.classes?.separator
    });
  }

  <template>
    <tfoot
      class={{this.classNames}}
      data-test-id="table-footer"
      data-component="table-footer"
      ...attributes
    >
      <tr class={{this.separatorClassNames}} />
      <tr class={{this.rowClassNames}}>
        {{yield (hash Column=SimpleTableColumn)}}
      </tr>
    </tfoot>
  </template>
}

export { SimpleTableFooter, type SimpleTableFooterSignature };
export default SimpleTableFooter;

