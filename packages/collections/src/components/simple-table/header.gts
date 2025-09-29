import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { useStyles, twMerge } from '@frontile/theme';
import { SimpleTableColumn } from './column';
import type { SlotsToClasses, TableSlots } from '../table/types';

interface SimpleTableHeaderSignature {
  Args: {
    /** Additional CSS class to apply to the header section */
    class?: string;
    /** Whether the header should be sticky during vertical scrolling */
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

class SimpleTableHeader extends Component<SimpleTableHeaderSignature> {
  get styles() {
    return this.args.styleFns || useStyles().table();
  }

  get classNames() {
    const options = {
      isSticky: this.args.isSticky || false,
      stickyPosition: this.args.isSticky ? ('top' as const) : undefined,
      class: twMerge(this.args.class, this.args.classes?.thead)
    };

    return this.styles.thead(options);
  }

  get rowClassNames() {
    const options = {
      class: twMerge('', this.args.classes?.tr || ''),
      isSticky: false
    };
    return this.styles.tr(options);
  }

  <template>
    <thead
      class={{this.classNames}}
      data-test-id="table-header"
      data-component="table-header"
      ...attributes
    >
      <tr class={{this.rowClassNames}}>
        {{yield (hash Column=SimpleTableColumn)}}
      </tr>
    </thead>
  </template>
}

export { SimpleTableHeader, type SimpleTableHeaderSignature };
export default SimpleTableHeader;