import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';
import { press } from '@frontile/utilities';
import { ChevronUpIcon, ChevronDownIcon } from './icons';
import { SortDirection } from './types';
import type { Column } from './types';

interface SortButtonSignature<T> {
  Args: {
    /** The column to render the sort button for */
    column: Column<T>;
    /** Current sort direction for this column */
    sortDirection: SortDirection;
    /** Whether this column is currently sorted */
    isSorted: boolean;
    /** Click handler for sorting */
    onSort: () => void;
  };
  Element: HTMLButtonElement;
}

export default class SortButton<T> extends Component<SortButtonSignature<T>> {
  get styles() {
    const { table } = useStyles();
    return table();
  }

  get showUpIcon() {
    return this.args.sortDirection === SortDirection.Ascending;
  }

  <template>
    <button
      type="button"
      class="{{(this.styles.sortButton)}}"
      data-sort-direction={{@sortDirection}}
      data-sorted="{{@isSorted}}"
      {{press @onSort}}
      ...attributes
    >
      <span>
        {{@column.name}}
      </span>
      {{#if this.showUpIcon}}
        <ChevronUpIcon
          class={{(this.styles.sortIcon)}}
          data-sorted="{{@isSorted}}"
          aria-hidden="true"
        />
      {{else}}
        <ChevronDownIcon
          class={{(this.styles.sortIcon)}}
          data-sorted="{{@isSorted}}"
          aria-hidden="true"
        />
      {{/if}}
    </button>
  </template>
}
