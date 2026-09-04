import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { service } from '@ember/service';
import { DocfyService } from '@docfy/ember';
import { CommandDialog } from 'frontile';
import type RouterService from '@ember/routing/router-service';
import type { PageMetadata } from '@docfy/core/lib/types';

interface DocfyJumpToArgs {}

/** One searchable documentation page. */
interface PageRecord {
  key: string;
  label: string;
  section: string;
  url: string;
}

const RECENTS_KEY = 'frontile:docs:recent-pages';
const MAX_RECENTS = 5;

/**
 * Recently visited pages, so an empty palette is useful rather than a wall of
 * every page in the docs.
 *
 * Persistence is deliberately the app's concern rather than the component's:
 * what counts as "recent", and whether to remember it at all, is a product
 * decision, and `Command` supports it by simply receiving a different list
 * while the query is blank.
 */
function readRecents(): string[] {
  try {
    const raw = window.localStorage.getItem(RECENTS_KEY);
    return raw ? (JSON.parse(raw) as string[]) : [];
  } catch {
    // Private browsing, disabled storage, or corrupt JSON — recents are a
    // convenience, never a requirement.
    return [];
  }
}

function writeRecents(urls: string[]): void {
  try {
    window.localStorage.setItem(RECENTS_KEY, JSON.stringify(urls));
  } catch {
    // Ignore: see readRecents.
  }
}

export default class DocfyJumpTo extends Component<DocfyJumpToArgs> {
  @service declare docfy: DocfyService;
  @service declare router: RouterService;

  @tracked isOpen = false;
  @tracked query = '';
  @tracked recentUrls: string[] = readRecents();

  get pages(): PageRecord[] {
    return this.docfy.flat.map((page: PageMetadata) => ({
      key: page.url,
      label: page.title,
      section: page.parentLabel || 'Documentation',
      url: page.url,
    }));
  }

  /**
   * With no query, show recents (falling back to everything on a first visit).
   * Once the user types, search the whole corpus.
   */
  get items(): PageRecord[] {
    if (this.query.trim() || this.recentUrls.length === 0) {
      return this.pages;
    }

    const byUrl = new Map(this.pages.map((page) => [page.url, page]));

    return this.recentUrls
      .map((url) => byUrl.get(url))
      .filter((page): page is PageRecord => Boolean(page));
  }

  get groupBy(): string | undefined {
    // Recents are already in the order that matters; grouping them by section
    // would scatter a list of five.
    return this.query.trim() ? 'section' : undefined;
  }

  open = () => {
    this.isOpen = true;
  };

  close = () => {
    this.isOpen = false;
    this.query = '';
  };

  updateQuery = (query: string) => {
    this.query = query;
  };

  select = (_key: string, item?: PageRecord) => {
    if (!item) {
      return;
    }

    this.recentUrls = [
      item.url,
      ...this.recentUrls.filter((url) => url !== item.url),
    ].slice(0, MAX_RECENTS);
    writeRecents(this.recentUrls);

    this.close();
    this.router.transitionTo(item.url);
  };

  <template>
    <button
      type="button"
      class="transition flex items-center rounded focus-visible:ring outline-none hover:text-neutral-strong"
      {{on "click" this.open}}
    >
      <svg
        class="w-4 h-4 mr-2"
        fill="none"
        stroke="currentColor"
        viewBox="0 0 24 24"
        xmlns="http://www.w3.org/2000/svg"
        aria-hidden="true"
      ><path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
        ></path></svg>

      Search
      <code
        class="hidden sm:block ml-3 rounded border font-bold border-neutral-soft px-2 py-1 text-xs leading-none"
      >
        /
      </code>
    </button>

    <CommandDialog
      @isOpen={{this.isOpen}}
      @onOpen={{this.open}}
      @onClose={{this.close}}
      @onSelect={{this.select}}
      @shortcut="/"
      @items={{this.items}}
      @groupBy={{this.groupBy}}
      @query={{this.query}}
      @onQueryChange={{this.updateQuery}}
      @label="Search documentation"
      @placeholder="Search documentation…"
      as |c|
    >
      <c.Input />
      <c.List>
        <:item as |ctx|>
          <ctx.Item @key={{ctx.key}} @description={{ctx.item.section}}>
            {{ctx.label}}
          </ctx.Item>
        </:item>
        <:empty>
          No results for "{{c.query}}"
        </:empty>
      </c.List>
    </CommandDialog>
  </template>
}
