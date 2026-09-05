import Component from '@glimmer/component';
import { tracked, cached } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { guidFor } from '@ember/object/internals';
import { debounce, cancel } from '@ember/runloop';
import { modifier } from 'ember-modifier';
import { useStyles } from '@frontile/theme';
import { VisuallyHidden } from '../../utilities/visually-hidden';
import { keyAndLabelForItem, type ListItem } from '../../../utils/listManager';
import { ref } from '../../../utils/ref';
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
    | 'hasResults'
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
    | 'isSearchPrompt'
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
     * The text searched for each item. Defaults to its label.
     *
     * Return several fields to search more than the label — a category, say, or
     * keywords. The first is primary; the rest are down-weighted and combined
     * by max, so a weak hit on a secondary field never outranks a strong hit on
     * the label.
     */
    searchFields?: (item: T) => string | string[];

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
     *
     * The resolved items **replace** `@items` — this is for a wholly remote
     * list. To combine static entries (navigation, recents) with remote ones,
     * do not use `@onSearch`: merge them yourself into `@items`, set
     * `@disableFiltering`, and rank the static half with `filterAndRankItems`
     * from `frontile/utils/filter`. See "Mixing static and remote results" in
     * the docs.
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
  /**
   * The search field, which `CommandList` hands to `Listbox` as the element to
   * attach keyboard events to. `ref` rather than a hand-rolled modifier so the
   * reference is cleared on teardown.
   */
  inputRef = ref<HTMLInputElement>();

  /** Discards out-of-order `@onSearch` resolutions; latest query wins. */
  #searchToken = 0;
  #pendingSearch?: ReturnType<typeof debounce>;

  get query(): string {
    return this.args.query ?? this.internalQuery;
  }

  get isLoading(): boolean {
    return this.args.isLoading === true || this.isSearchPending;
  }

  handleInput = (value: string) => {
    if (this.args.query === undefined) {
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
      this.args.searchDebounce ?? 250
    );
  }

  async runSearch(query: string): Promise<void> {
    const token = ++this.#searchToken;

    try {
      const result = await this.args.onSearch!(query);

      // A slower earlier request must not overwrite a newer one's results, and
      // a resolution after teardown must not write to a destroyed component.
      if (
        token !== this.#searchToken ||
        this.isDestroying ||
        this.isDestroyed
      ) {
        return;
      }

      this.asyncItems = result;
    } finally {
      if (
        token === this.#searchToken &&
        !this.isDestroying &&
        !this.isDestroyed
      ) {
        this.isSearchPending = false;
      }
    }
  }

  willDestroy(): void {
    super.willDestroy();

    // The copy of Autocomplete's async machinery dropped these; a pending
    // debounce that fires after teardown writes to a destroyed component.
    if (this.#pendingSearch) {
      cancel(this.#pendingSearch);
    }

    if (this.#pendingAnnouncement) {
      cancel(this.#pendingAnnouncement);
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
        (item) =>
          this.args.searchFields?.(item) ?? keyAndLabelForItem(item).label,
        this.args.filter
      ) ?? []
    );
  }

  get resultCount(): number {
    return this.results.length;
  }

  /**
   * Whether the listbox is currently rendered. `CommandList` shows the empty or
   * loading state in its place when there is nothing to list, so the combobox
   * must report itself collapsed — and must not point `aria-controls` at an
   * element that is no longer in the document.
   */
  get hasResults(): boolean {
    return this.resultCount > 0;
  }

  /**
   * An async palette with nothing typed has nothing to show and no results to
   * report — the moment to ask for a query rather than claim emptiness.
   */
  get isSearchPrompt(): boolean {
    return (
      typeof this.args.onSearch === 'function' &&
      !this.query.trim() &&
      !this.isLoading &&
      this.resultCount === 0
    );
  }

  @tracked announcement = '';

  #pendingAnnouncement?: ReturnType<typeof debounce>;

  setAnnouncement = (count: number) => {
    this.announcement =
      count === 0
        ? 'No results found'
        : `${count} result${count === 1 ? '' : 's'} available`;
  };

  /**
   * Debounced so a burst of keystrokes announces once, at rest, rather than
   * interrupting the screen reader on every character.
   */
  announceResults = modifier(
    (_element: HTMLElement, [count, isLoading]: [number, boolean]) => {
      if (isLoading) {
        return;
      }

      this.#pendingAnnouncement = debounce(
        this,
        this.setAnnouncement,
        count,
        250
      );

      return () => {
        if (this.#pendingAnnouncement) {
          cancel(this.#pendingAnnouncement);
        }
      };
    }
  );

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
    if (!this.args.groupBy) {
      return this.resultCount ? [{ items: this.results }] : [];
    }

    const byTitle = new Map<string, T[]>();
    const ungrouped: T[] = [];

    for (const item of this.results) {
      const title = this.groupTitleFor(item);

      if (!title) {
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

  get baseClass(): string {
    const { command } = useStyles();
    // No size fallback: the theme's `defaultVariants` owns the default.
    const { base } = command({
      size: this.args.size,
      isBordered: this.args.isBordered
    });

    return base({ class: [this.args.class, this.args.classes?.base] });
  }

  <template>
    <div
      data-test-id="command"
      data-component="command"
      class={{this.baseClass}}
      ...attributes
    >
      <VisuallyHidden>
        <div
          role="status"
          aria-live="polite"
          data-test-id="command-announcer"
          {{this.announceResults this.resultCount this.isLoading}}
        >{{this.announcement}}</div>
      </VisuallyHidden>

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
            hasResults=this.hasResults
            activeDescendant=this.activeDescendant
            setup=this.inputRef.setup
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
            isSearchPrompt=this.isSearchPrompt
            inputElement=this.inputRef.current
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
