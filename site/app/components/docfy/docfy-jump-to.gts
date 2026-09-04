import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { service } from '@ember/service';
import { array } from '@ember/helper';
import { DocfyService } from '@docfy/ember';
import { CommandDialog } from 'frontile';
import {
  RocketIcon,
  PaletteIcon,
  ComponentIcon,
  AccessibilityIcon,
  PackageIcon,
  BookIcon,
} from '../icons';
import type RouterService from '@ember/routing/router-service';
import type { PageMetadata, NestedPageMetadata } from '@docfy/core/lib/types';
import type { ComponentLike } from '@glint/template';

type IconComponent = ComponentLike<{ Element: SVGElement }>;

/** One searchable entry: a documentation page or a top-level section. */
interface PaletteRecord {
  key: string;
  label: string;
  section: string;
  url: string;
  Icon: IconComponent;
}

const RECENT = 'Recent';
const NAVIGATION = 'Navigation';

/**
 * An icon per top-level docs section, keyed by the first URL segment after
 * `/docs/`. Pages inherit their section's icon, so a result reads as belonging
 * somewhere even before you read its group heading.
 */
const SECTION_ICONS: Record<string, IconComponent> = {
  'get-started': RocketIcon,
  theming: PaletteIcon,
  components: ComponentIcon,
  accessibility: AccessibilityIcon,
  migrations: PackageIcon,
};

function sectionNameFor(url: string): string | undefined {
  // '/docs/components/buttons/button' -> 'components'
  return url.split('/')[2];
}

function iconFor(url: string): IconComponent {
  return SECTION_ICONS[sectionNameFor(url) ?? ''] ?? BookIcon;
}

const RECENTS_KEY = 'frontile:docs:recent-pages';
const MAX_RECENTS = 5;

/**
 * Recently visited pages, so an empty palette is useful rather than a wall of
 * every page in the docs.
 *
 * Persistence is deliberately the app's concern rather than the component's:
 * what counts as "recent", and whether to remember it at all, is a product
 * decision, and `Command` supports it by receiving a different list while the
 * query is blank.
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

export default class DocfyJumpTo extends Component {
  @service declare docfy: DocfyService;
  @service declare router: RouterService;

  @tracked isOpen = false;
  @tracked query = '';
  @tracked recentUrls: string[] = readRecents();

  /** The first page under a section, which is where its nav entry points. */
  firstPageUrl(section: NestedPageMetadata): string | undefined {
    if (section.pages?.length) {
      return section.pages[0]?.url;
    }

    for (const child of section.children ?? []) {
      const url = this.firstPageUrl(child);
      if (url) {
        return url;
      }
    }

    return undefined;
  }

  /**
   * The top-level sections — Get Started, Components, Theming & Styles, and so
   * on — as jump targets. Same source as the site's own section nav, so the two
   * cannot drift apart.
   */
  get navigation(): PaletteRecord[] {
    const docs = this.docfy.findNestedChildrenByName('docs');

    return (docs?.children ?? []).reduce<PaletteRecord[]>((records, child) => {
      const url = this.firstPageUrl(child);

      if (url) {
        records.push({
          key: `nav:${child.name}`,
          label: child.label,
          section: NAVIGATION,
          url,
          Icon: SECTION_ICONS[child.name] ?? BookIcon,
        });
      }

      return records;
    }, []);
  }

  get pages(): PaletteRecord[] {
    return this.docfy.flat.map((page: PageMetadata) => ({
      key: page.url,
      label: page.title,
      section: page.parentLabel || 'Documentation',
      url: page.url,
      Icon: iconFor(page.url),
    }));
  }

  get recents(): PaletteRecord[] {
    const byUrl = new Map(this.pages.map((page) => [page.url, page]));

    return this.recentUrls.reduce<PaletteRecord[]>((records, url) => {
      const page = byUrl.get(url);

      if (page) {
        records.push({ ...page, section: RECENT });
      }

      return records;
    }, []);
  }

  /**
   * With no query, offer somewhere to go: what you were last reading, then the
   * top-level sections. Once the user types, search every page as well.
   */
  get items(): PaletteRecord[] {
    if (!this.query.trim()) {
      return [...this.recents, ...this.navigation];
    }

    return [...this.navigation, ...this.pages];
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

  select = (_key: string, item?: PaletteRecord) => {
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
      @groupBy="section"
      {{! Recent and Navigation stay on top; matching pages follow by relevance. }}
      @groups={{array RECENT NAVIGATION}}
      @query={{this.query}}
      @onQueryChange={{this.updateQuery}}
      @label="Search documentation"
      @placeholder="Search documentation…"
      {{! lg so the default Recent + Navigation list fits without scrolling }}
      @size="lg"
      as |c|
    >
      <c.Input />
      <c.List>
        <:item as |ctx|>
          <ctx.Item @key={{ctx.key}}>
            <:start><ctx.item.Icon /></:start>
            <:default>{{ctx.label}}</:default>
          </ctx.Item>
        </:item>
        <:empty>
          No results for "{{c.query}}"
        </:empty>
      </c.List>
      <c.Footer as |f|>
        <span class="flex items-center gap-1.5"><f.Kbd>↑</f.Kbd><f.Kbd>↓</f.Kbd>
          Navigate</span>
        <span class="flex items-center gap-1.5"><f.Kbd>↵</f.Kbd>
          Go to page</span>
        <span class="flex items-center gap-1.5"><f.Kbd>Esc</f.Kbd> Close</span>
      </c.Footer>
    </CommandDialog>
  </template>
}
