import Component from '@glimmer/component';
import { cached, tracked } from '@glimmer/tracking';
import { fn } from '@ember/helper';
import { modifier } from 'ember-modifier';
import { useStyles, type SlotsToClasses } from '@frontile/theme';
import type Owner from '@ember/owner';
import { press } from '../../../modifiers/press';
import { VisuallyHidden } from '../../utilities/visually-hidden';
import { paginationRange } from './range';
import {
  ChevronLeftIcon,
  ChevronRightIcon,
  ChevronDoubleLeftIcon,
  ChevronDoubleRightIcon
} from './icons';
import type { PaginationSlots, PaginationVariants } from '@frontile/theme';
import type { ModifierLike } from '@glint/template';

/** What the `summary` block receives. */
interface PaginationSummary {
  /** 1-based index of the first item on the current page; 0 when empty. */
  from: number;
  /** 1-based index of the last item on the current page; 0 when empty. */
  to: number;
  total: number;
  page: number;
  totalPages: number;
}

/** What the `item` block receives, once per page chip. */
interface PaginationItemContext {
  page: number;
  isActive: boolean;
  classNames: string;
  setupItem: ModifierLike<{
    Element: HTMLElement;
    Args: { Positional: [boolean] };
  }>;
}

/**
 * One rendered slot. `isEllipsis` is a precomputed boolean rather than a
 * `type` string compared in the template: `eq` is not available to `.gts`
 * templates in this codebase, so every comparison is done here.
 */
interface RenderedItem {
  key: string;
  isEllipsis: boolean;
  value: number;
  isActive: boolean;
  label: string;
  /**
   * Prebuilt so the template can `{{yield item.context to="item"}}` rather
   * than calling a function in a sub-expression position.
   */
  context: PaginationItemContext;
}

interface PaginationArgs {
  /**
   * Total number of items across all pages -- an *item* count, not a page
   * count. `@pageSize` divides it. This is what lets the `summary` block be
   * handed a real item range instead of making the caller compute one.
   *
   * @defaultValue 0
   */
  total?: number;

  /**
   * Items shown per page. Values below 1 are treated as 1.
   *
   * @defaultValue 10
   */
  pageSize?: number;

  /**
   * The current page, 1-based.
   *
   * *Passing* this argument at all puts the component in controlled mode: the
   * rendered page then only ever reflects what you pass, so pair it with
   * `@onChange` and update your own state. Omit it entirely to let the
   * component track the page itself, seeded by `@defaultPage`.
   */
  page?: number;

  /**
   * The page to start on when uncontrolled. Ignored in controlled mode.
   *
   * @defaultValue 1
   */
  defaultPage?: number;

  /**
   * Called with the new page on every navigation, in both modes. Never called
   * with an out-of-range page, and never called when the page would not
   * change.
   */
  onChange?: (page: number) => void;

  /**
   * How many page chips to show either side of the current one. The first and
   * last pages are always shown; that boundary is not configurable.
   *
   * @defaultValue 1
   */
  siblingCount?: number;

  /**
   * Adds jump-to-first and jump-to-last controls at the ends of the row.
   *
   * @defaultValue false
   */
  showEdges?: boolean;

  /**
   * Set to false for compact page-number navigation with previous and next
   * controls but no page chips. `@total` and `@pageSize` still determine the
   * first and last pages.
   *
   * @defaultValue true
   */
  showPages?: boolean;

  /** @defaultValue 'md' */
  size?: PaginationVariants['size'];

  /**
   * The colour of the active page chip.
   *
   * @defaultValue 'default'
   */
  intent?: PaginationVariants['intent'];

  /**
   * Disables every control.
   *
   * @defaultValue false
   */
  isDisabled?: boolean;

  /**
   * Accessible name for the nav landmark. Worth setting when a page has more
   * than one pagination on it.
   *
   * @defaultValue 'pagination'
   */
  label?: string;

  /** Class names for each slot of the component, merged with the theme's. */
  classes?: SlotsToClasses<PaginationSlots>;
}

interface PaginationSignature {
  Args: PaginationArgs;
  Blocks: {
    summary?: [PaginationSummary];
    item?: [PaginationItemContext];
  };
  Element: HTMLElement;
}

function clamp(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max);
}

/**
 * A row of controls for moving through a paged list.
 *
 * It deliberately does **not** use `rovingFocus`: these are navigation
 * targets, not a composite widget, so every control stays individually
 * reachable by Tab. The ARIA tabs pattern does not apply, and applying it
 * would remove destinations from the tab order for no gain -- the same
 * reasoning `TabNav` documents.
 */
class Pagination extends Component<PaginationSignature> {
  /**
   * Uncontrolled mode's own page, seeded from `@defaultPage`. Written on every
   * navigation regardless of mode -- see `goTo` -- so the two modes stay on one
   * code path, the way `SegmentedControl` does it. In controlled mode nothing
   * reads it.
   */
  @tracked _page: number;

  constructor(owner: Owner, args: PaginationSignature['Args']) {
    super(owner, args);
    this._page = this.args.defaultPage ?? 1;
  }

  get pageSize(): number {
    return Math.max(1, Math.floor(this.args.pageSize ?? 10));
  }

  get total(): number {
    return Math.max(0, this.args.total ?? 0);
  }

  /** Never below 1: an empty list still has one (empty) page to sit on. */
  get totalPages(): number {
    return Math.max(1, Math.ceil(this.total / this.pageSize));
  }

  get siblingCount(): number {
    return Math.max(0, Math.floor(this.args.siblingCount ?? 1));
  }

  get showPages(): boolean {
    return this.args.showPages ?? true;
  }

  get label(): string {
    return this.args.label ?? 'pagination';
  }

  /**
   * Whether `@page` was *passed* decides the mode, not what it holds -- the
   * same rule as `SegmentedControl`. Glimmer's named-args object carries a key
   * for every argument written in the invoking template, so `in` distinguishes
   * an omitted `@page` from one that happens to be `undefined`.
   */
  get isControlled(): boolean {
    return 'page' in this.args;
  }

  /**
   * Clamped, so a caller who passes `@page={{99}}` for a three-page list gets
   * page 3 rather than a row with nothing marked current.
   */
  get currentPage(): number {
    const raw = this.isControlled ? (this.args.page ?? 1) : this._page;

    return clamp(Math.floor(raw) || 1, 1, this.totalPages);
  }

  get isFirstPage(): boolean {
    return this.currentPage <= 1;
  }

  get isLastPage(): boolean {
    return this.currentPage >= this.totalPages;
  }

  get isDisabled(): boolean {
    return this.args.isDisabled ?? false;
  }

  get isPrevDisabled(): boolean {
    return this.isDisabled || this.isFirstPage;
  }

  get isNextDisabled(): boolean {
    return this.isDisabled || this.isLastPage;
  }

  @cached
  get renderedItems(): RenderedItem[] {
    const items = paginationRange({
      page: this.currentPage,
      totalPages: this.totalPages,
      siblingCount: this.siblingCount
    });

    const classNames = this.pageClass;
    const setupItem = this
      .setupItem as unknown as PaginationItemContext['setupItem'];

    // The ellipsis key is positional because a row can hold two of them and
    // neither has a page number to key on.
    return items.map((item, index) => {
      if (item.type === 'ellipsis') {
        return {
          key: `ellipsis-${index}`,
          isEllipsis: true,
          value: 0,
          isActive: false,
          label: '',
          context: { page: 0, isActive: false, classNames, setupItem }
        };
      }

      const isActive = item.value === this.currentPage;

      return {
        key: `page-${item.value}`,
        isEllipsis: false,
        value: item.value,
        isActive,
        label: `Go to page ${item.value}`,
        context: { page: item.value, isActive, classNames, setupItem }
      };
    });
  }

  @cached
  get summary(): PaginationSummary {
    const empty = this.total === 0;

    return {
      from: empty ? 0 : (this.currentPage - 1) * this.pageSize + 1,
      to: empty ? 0 : Math.min(this.currentPage * this.pageSize, this.total),
      total: this.total,
      page: this.currentPage,
      totalPages: this.totalPages
    };
  }

  @cached
  get styles() {
    const { pagination } = useStyles();

    return pagination({
      size: this.args.size,
      intent: this.args.intent,
      isDisabled: this.isDisabled
    });
  }

  @cached
  get pageClass(): string {
    return this.styles.page({ class: this.args.classes?.page });
  }

  /**
   * Writes the active state onto whatever element the `item` block rendered,
   * so a consumer bringing their own `<a>` or `LinkTo` gets the same ARIA the
   * built-in chip does without having to know the contract. Same pattern as
   * `TabNav`'s yielded `setupItem`.
   */
  setupItem = modifier((element: HTMLElement, [isActive]: [boolean]) => {
    element.setAttribute('data-active', String(Boolean(isActive)));

    if (isActive) {
      element.setAttribute('aria-current', 'page');
    } else {
      element.removeAttribute('aria-current');
    }
  });

  goTo = (page: number): void => {
    const next = clamp(page, 1, this.totalPages);

    if (next === this.currentPage) {
      return;
    }

    this._page = next;
    this.args.onChange?.(next);
  };

  goToPrevious = (): void => {
    this.goTo(this.currentPage - 1);
  };

  goToNext = (): void => {
    this.goTo(this.currentPage + 1);
  };

  <template>
    <nav
      data-component="pagination"
      data-part="base"
      aria-label={{this.label}}
      class={{this.styles.base class=@classes.base}}
      ...attributes
    >
      {{#if (has-block "summary")}}
        <div
          data-part="summary"
          class={{this.styles.summary class=@classes.summary}}
          data-pagination-summary
        >
          {{yield this.summary to="summary"}}
        </div>
      {{/if}}

      <ul data-part="list" class={{this.styles.list class=@classes.list}}>
        {{#if @showEdges}}
          <li data-part="item" class={{this.styles.item class=@classes.item}}>
            <button
              type="button"
              data-part="prev"
              class={{this.styles.prev class=@classes.prev}}
              aria-label="Go to first page"
              disabled={{this.isPrevDisabled}}
              data-test-first
              {{press (fn this.goTo 1)}}
            >
              <ChevronDoubleLeftIcon />
            </button>
          </li>
        {{/if}}

        <li data-part="item" class={{this.styles.item class=@classes.item}}>
          <button
            type="button"
            data-part="prev"
            class={{this.styles.prev class=@classes.prev}}
            aria-label="Go to previous page"
            disabled={{this.isPrevDisabled}}
            data-test-prev
            {{press this.goToPrevious}}
          >
            <ChevronLeftIcon />
            Previous
          </button>
        </li>

        {{#if this.showPages}}
          {{#each this.renderedItems key="key" as |item|}}
            <li data-part="item" class={{this.styles.item class=@classes.item}}>
              {{#if item.isEllipsis}}
                <span
                  data-part="ellipsis"
                  class={{this.styles.ellipsis class=@classes.ellipsis}}
                  aria-hidden="true"
                  data-test-ellipsis
                >&hellip;</span>
                <VisuallyHidden>More pages</VisuallyHidden>
              {{else if (has-block "item")}}
                {{yield item.context to="item"}}
              {{else}}
                <button
                  type="button"
                  data-part="page"
                  class={{this.pageClass}}
                  aria-label={{item.label}}
                  aria-current={{if item.isActive "page"}}
                  data-active={{if item.isActive "true" "false"}}
                  disabled={{this.isDisabled}}
                  data-test-page={{item.value}}
                  {{press (fn this.goTo item.value)}}
                >{{item.value}}</button>
              {{/if}}
            </li>
          {{/each}}
        {{/if}}

        <li data-part="item" class={{this.styles.item class=@classes.item}}>
          <button
            type="button"
            data-part="next"
            class={{this.styles.next class=@classes.next}}
            aria-label="Go to next page"
            disabled={{this.isNextDisabled}}
            data-test-next
            {{press this.goToNext}}
          >
            Next
            <ChevronRightIcon />
          </button>
        </li>

        {{#if @showEdges}}
          <li data-part="item" class={{this.styles.item class=@classes.item}}>
            <button
              type="button"
              data-part="next"
              class={{this.styles.next class=@classes.next}}
              aria-label="Go to last page"
              disabled={{this.isNextDisabled}}
              data-test-last
              {{press (fn this.goTo this.totalPages)}}
            >
              <ChevronDoubleRightIcon />
            </button>
          </li>
        {{/if}}
      </ul>
    </nav>
  </template>
}

export {
  Pagination,
  type PaginationSignature,
  type PaginationArgs,
  type PaginationSummary,
  type PaginationItemContext
};
export default Pagination;
