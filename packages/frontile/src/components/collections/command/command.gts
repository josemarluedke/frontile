import Component from '@glimmer/component';
import { tracked, cached } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { guidFor } from '@ember/object/internals';
import { debounce, cancel } from '@ember/runloop';
import { useStyles } from '@frontile/theme';
import { keyAndLabelForItem, type ListItem } from '../../../utils/listManager';
import { filterAndRankItems, type FilterFn } from '../../../utils/filter';
import { CommandInput } from './input';
import { CommandList } from './list';
import { CommandFooter } from './footer';
import type { CommandSlots, SlotsToClasses } from '@frontile/theme';
import type { WithBoundArgs } from '@glint/template';

/** One rendered section of results. A blank `title` renders no heading. */
export interface CommandGroup<T> {
  title?: string;
  items: T[];
}

export interface CommandApi<T> {
  /** The current query text. */
  query: string;
  /** How many items matched. `0` renders the `:empty` block. */
  resultCount: number;
  /** True while an `@onSearch` promise is in flight, or `@isLoading` is set. */
  isLoading: boolean;
  Input: WithBoundArgs<
    typeof CommandInput,
    | 'onInput'
    | 'value'
    | 'controlsId'
    | 'activeDescendant'
    | 'classes'
    | 'setup'
  >;
  Footer: WithBoundArgs<typeof CommandFooter, 'classes'>;
  List: WithBoundArgs<
    typeof CommandList<T>,
    | 'groups'
    | 'id'
    | 'classes'
    | 'size'
    | 'isLoading'
    | 'inputElement'
    | 'disabledKeys'
    | 'onSelect'
    | 'onActiveItemChange'
  >;
}

export interface CommandSignature<T> {
  Args: {
    /**
     * The items to search. Ranked and grouped by the component unless
     * `@disableFiltering` is set or `@onSearch` is provided.
     */
    items?: T[];

    /**
     * Groups results under headings. Either a property name on the item or a
     * function returning the heading. Items with no group render ungrouped,
     * ahead of any groups.
     */
    groupBy?: string | ((item: T) => string | undefined);

    /**
     * Pins these groups to the top, in this order. Any group not listed still
     * renders, after them, ordered by its best-scoring member — so pinning a
     * "Recent" section cannot hide search results.
     *
     * When omitted, every group is ordered by its best-scoring member, so the
     * closest match is always on top.
     */
    groups?: string[];

    /**
     * Scores or matches an item against the query. Defaults to a relevance
     * filter; see {@link FilterFn}.
     */
    filter?: FilterFn;

    /**
     * Render `@items` as given, without filtering or ranking. Use with
     * `@query`/`@onQueryChange` when filtering happens elsewhere.
     *
     * @defaultValue false
     */
    disableFiltering?: boolean;

    /** The query text. Pass with `@onQueryChange` to control it. */
    query?: string;

    onQueryChange?: (query: string) => void;

    /**
     * Async search. Called (debounced) as the user types; the resolved items
     * are rendered and a loading state shows while pending. Stale responses are
     * discarded, so the latest query always wins. Built-in filtering is
     * disabled, and `@items` is the list shown before the first search.
     */
    onSearch?: (query: string) => Promise<T[]> | T[];

    /**
     * Debounce applied to `@onSearch`, in milliseconds.
     *
     * @defaultValue 250
     */
    searchDebounce?: number;

    /** Show the loading state regardless of `@onSearch`. */
    isLoading?: boolean;

    /** Called when an item is chosen, by click or by Enter. */
    onSelect?: (key: string, item?: T) => void;

    disabledKeys?: string[];

    /**
     * Accessible name for the search input.
     *
     * @defaultValue 'Search'
     */
    label?: string;

    placeholder?: string;

    /**
     * @defaultValue 'md'
     */
    size?: 'sm' | 'md' | 'lg';

    /** Draw the palette's own surface, for use outside a dialog. */
    isBordered?: boolean;

    class?: string;
    classes?: SlotsToClasses<CommandSlots>;
  };
  Element: HTMLDivElement;
  Blocks: {
    default: [CommandApi<T>];
  };
}

const isUndefined = (value: unknown) => typeof value === 'undefined';

/**
 * A command palette: a search input over a ranked, optionally grouped list.
 *
 * Composed of the same primitives as `Autocomplete` — an input driving a
 * `Listbox` through `ListManager` — rather than reimplementing keyboard
 * navigation, option roles or active-item tracking.
 */
class Command<T = unknown> extends Component<CommandSignature<T>> {
  listId = `${guidFor(this)}-list`;

  @tracked internalQuery = '';
  @tracked activeDescendant?: string;
  @tracked asyncItems?: T[];
  @tracked isSearchPending = false;
  @tracked inputElement?: HTMLInputElement;

  /** Discards out-of-order `@onSearch` resolutions; latest query wins. */
  #searchToken = 0;
  #pendingSearch?: ReturnType<typeof debounce>;

  get query(): string {
    return isUndefined(this.args.query) ? this.internalQuery : this.args.query!;
  }

  get isLoading(): boolean {
    return this.args.isLoading === true || this.isSearchPending;
  }

  setupInput = (element: HTMLInputElement) => {
    this.inputElement = element;
  };

  handleInput = (value: string) => {
    if (isUndefined(this.args.query)) {
      this.internalQuery = value;
    }

    this.args.onQueryChange?.(value);

    if (typeof this.args.onSearch === 'function') {
      this.scheduleSearch(value);
    }
  };

  scheduleSearch(query: string): void {
    if (this.#pendingSearch) {
      cancel(this.#pendingSearch);
    }

    this.isSearchPending = true;
    this.#pendingSearch = debounce(
      this,
      this.runSearch,
      query,
      isUndefined(this.args.searchDebounce) ? 250 : this.args.searchDebounce!
    );
  }

  async runSearch(query: string): Promise<void> {
    const token = ++this.#searchToken;

    try {
      const result = await this.args.onSearch!(query);

      // A slower earlier request must not overwrite a newer one's results.
      if (token !== this.#searchToken) {
        return;
      }

      this.asyncItems = result;
    } finally {
      if (token === this.#searchToken) {
        this.isSearchPending = false;
      }
    }
  }

  handleActiveItemChange = (_key?: string, item?: ListItem) => {
    this.activeDescendant = item?.el.id;
  };

  handleSelect = (key: string) => {
    const item = this.results.find(
      (candidate) => keyAndLabelForItem(candidate).key === key
    );

    this.args.onSelect?.(key, item);
  };

  /** The matching items, ordered by relevance. */
  @cached
  get results(): T[] {
    if (typeof this.args.onSearch === 'function') {
      return this.asyncItems ?? this.args.items ?? [];
    }

    if (this.args.disableFiltering) {
      return this.args.items ?? [];
    }

    return (
      filterAndRankItems(
        this.args.items,
        this.query,
        (item) => keyAndLabelForItem(item).label,
        this.args.filter
      ) ?? []
    );
  }

  get resultCount(): number {
    return this.results.length;
  }

  groupTitleFor(item: T): string | undefined {
    const { groupBy } = this.args;

    if (typeof groupBy === 'function') {
      return groupBy(item);
    }

    if (typeof groupBy === 'string') {
      return (item as Record<string, unknown>)?.[groupBy] as string | undefined;
    }

    return undefined;
  }

  /**
   * Results partitioned into sections.
   *
   * Groups are built from the ranked results rather than declared as markup, so
   * a group with no surviving items simply never renders — heading, wrapper and
   * separator together — with no visibility tracking needed.
   */
  @cached
  get groups(): CommandGroup<T>[] {
    if (isUndefined(this.args.groupBy)) {
      return this.resultCount ? [{ items: this.results }] : [];
    }

    const byTitle = new Map<string, T[]>();
    const ungrouped: T[] = [];

    for (const item of this.results) {
      const title = this.groupTitleFor(item);

      if (isUndefined(title) || title === '') {
        ungrouped.push(item);
        continue;
      }

      const existing = byTitle.get(title);

      if (existing) {
        existing.push(item);
      } else {
        byTitle.set(title, [item]);
      }
    }

    // Insertion order is best-scoring group first, because `results` is
    // already ranked. Pinned groups are hoisted above that; anything not
    // pinned keeps its ranked position rather than being dropped.
    const ranked = [...byTitle.keys()];
    const pinned = (this.args.groups ?? []).filter((title) =>
      byTitle.has(title)
    );
    const titles = [
      ...pinned,
      ...ranked.filter((title) => !pinned.includes(title))
    ];

    const groups: CommandGroup<T>[] = [];

    if (ungrouped.length) {
      groups.push({ items: ungrouped });
    }

    for (const title of titles) {
      groups.push({ title, items: byTitle.get(title)! });
    }

    return groups;
  }

  get classNames() {
    const { command } = useStyles();

    return command({
      size: this.args.size || 'md',
      isBordered: this.args.isBordered
    });
  }

  <template>
    <div
      data-test-id="command"
      data-component="command"
      class={{this.classNames.base class=@classes.base}}
      ...attributes
    >
      {{yield
        (hash
          query=this.query
          resultCount=this.resultCount
          isLoading=this.isLoading
          Input=(component
            CommandInput
            value=this.query
            onInput=this.handleInput
            controlsId=this.listId
            activeDescendant=this.activeDescendant
            setup=this.setupInput
            label=@label
            placeholder=@placeholder
            classes=@classes
          )
          List=(component
            CommandList
            groups=this.groups
            id=this.listId
            size=@size
            isLoading=this.isLoading
            inputElement=this.inputElement
            disabledKeys=@disabledKeys
            onSelect=this.handleSelect
            onActiveItemChange=this.handleActiveItemChange
            classes=@classes
          )
          Footer=(component CommandFooter classes=@classes)
        )
      }}
    </div>
  </template>
}

export { Command };
export default Command;
