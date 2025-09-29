import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';

interface SimpleTableColumnSignature {
  Args: {
    /** Additional CSS class to apply to the header cell */
    class?: string;
    /** Whether this column should be sticky during horizontal scrolling */
    isSticky?: boolean;
    /** Position where the sticky column should stick. @default 'left' */
    stickyPosition?: 'left' | 'right';
    /**
     * @internal Style functions object from SimpleTable component
     * @ignore
     */
    styleFns?: ReturnType<ReturnType<typeof useStyles>['table']>;
  };
  Element: HTMLTableCellElement;
  Blocks: {
    default: [];
  };
}

class SimpleTableColumn extends Component<SimpleTableColumnSignature> {
  get styles() {
    return this.args.styleFns || useStyles().table();
  }

  get classNames() {
    const options = {
      isSticky: this.args.isSticky || false,
      stickyPosition: this.args.isSticky
        ? (this.args.stickyPosition as 'left' | 'right') || 'left'
        : undefined,
      class: this.args.class
    };

    return this.styles.th(options);
  }

  <template>
    <th
      class={{this.classNames}}
      data-test-id="table-column"
      data-component="table-column"
      ...attributes
    >
      {{yield}}
    </th>
  </template>
}

export { SimpleTableColumn, type SimpleTableColumnSignature };
export default SimpleTableColumn;