import { tracked } from '@glimmer/tracking';
import { escapeAttributeValue, getDOM } from '../../-private/dom';

/**
 * PROTOTYPE. One `InRegion`, as its region sees it. `covered` is true while
 * another source of the same region comes before it in the document; a
 * covered source does not render its block.
 *
 * `covered` is only ever written by a source that comes *earlier* in the
 * document, arriving or leaving. The source that reads it comes later in
 * render order, so within one render pass the write is before the read.
 */
export class RegionSource {
  readonly marker: Element | null;
  @tracked covered: boolean;
  #covered: boolean;

  constructor(marker: Element | null, covered: boolean) {
    this.marker = marker;
    this.#covered = covered;
    this.covered = covered;
  }

  /** Writes without reading the tracked value, and only on a change. */
  setCovered(covered: boolean): void {
    if (covered !== this.#covered) {
      this.#covered = covered;
      this.covered = covered;
    }
  }
}

class RegionMode {
  @tracked multiple = false;
  #multiple = false;

  set(multiple: boolean): void {
    if (multiple !== this.#multiple) {
      this.#multiple = multiple;
      this.multiple = multiple;
    }
  }
}

/**
 * Whether `a` comes before `b` in the document. A server document has no
 * `compareDocumentPosition`; there everything renders in one pass, so the
 * order the sources arrived in (`fallback`) is the document order.
 */
function precedes(
  a: RegionSource,
  b: RegionSource,
  fallback: boolean
): boolean {
  // A source being replaced is still listed while its replacement renders:
  // its marker has left the document but its destructor has not run. It
  // covers nothing and is covered by nothing.
  if (a.marker?.isConnected === false || b.marker?.isConnected === false) {
    return false;
  }
  if (
    a.marker &&
    b.marker &&
    typeof a.marker.compareDocumentPosition === 'function'
  ) {
    // 4 is Node.DOCUMENT_POSITION_FOLLOWING: `b` follows `a`.
    return (a.marker.compareDocumentPosition(b.marker) & 4) !== 0;
  }
  return fallback;
}

/**
 * PROTOTYPE (layout regions, second attempt).
 *
 * A region is a DOM element the layout owns, one per name, created the first
 * time anyone asks for it. Two things use it and neither knows the other:
 *
 * - a source (`InRegion`) renders its block into it with `{{in-element}}`;
 * - a display site (`layout.Region`, or a blockless `layout.Aside`) puts the
 *   element in the page by rendering it as content: `{{element}}`.
 *
 * Nothing is scheduled. The element exists before either side renders, so it
 * does not matter which renders first, and it can be displayed somewhere
 * else later (the aside moving into a drawer) without the content being
 * rebuilt. The only tracked state is each source's `covered` flag (see
 * `RegionSource`) and a region's `multiple` mode.
 */
export class LayoutRegions {
  #doc: Document | null;
  #layoutId: string;
  #className: () => string;
  #onEmpty: (name: string) => void;
  #elements = new Map<string, Element>();
  #sources = new Map<string, RegionSource[]>();
  #modes = new Map<string, RegionMode>();

  constructor(
    context: object,
    layoutId: string,
    className: () => string,
    onEmpty: (name: string) => void
  ) {
    this.#doc = getDOM(context);
    this.#layoutId = layoutId;
    this.#className = className;
    this.#onEmpty = onEmpty;
  }

  /** The region's element, made on first use. `null` without a document. */
  element(name: string): Element | null {
    let element = this.#elements.get(name);
    if (!element && this.#doc) {
      element = this.#fromServer(name) ?? this.#doc.createElement('div');
      element.setAttribute('data-part', 'region');
      element.setAttribute('data-region', name);
      element.setAttribute('class', this.#className());
      this.#elements.set(name, element);
    }
    return element ?? null;
  }

  /**
   * When the page was rendered on a server and is being rehydrated, the
   * region's element is already in the document, with its content. It has to
   * be that element the sources render into: Glimmer keeps the server's node
   * where `{{element}}` is displayed, so a new one would never be attached
   * and the visible content would be dead HTML. Nothing matches on a normal
   * boot, and a server document has no `querySelector`.
   */
  #fromServer(name: string): Element | null {
    const doc = this.#doc;
    if (!doc || typeof doc.querySelector !== 'function') {
      return null;
    }
    return doc.querySelector(
      `[data-app-layout-id="${this.#layoutId}"] [data-region="${escapeAttributeValue(name)}"]`
    );
  }

  #mode(name: string): RegionMode {
    let mode = this.#modes.get(name);
    if (!mode) {
      mode = new RegionMode();
      this.#modes.set(name, mode);
    }
    return mode;
  }

  /** Whether the region shows every source (tracked). */
  isMultiple(name: string): boolean {
    return this.#mode(name).multiple;
  }

  /**
   * Set by the display site. Only a change to `true` (or back) is a write,
   * so a plain region never writes. A `@multiple` region has to render
   * before its sources read this.
   */
  setMultiple(name: string, multiple: boolean): void {
    this.#mode(name).set(multiple);
  }

  /**
   * Adds a source, identified by the marker it left in the document. It
   * starts covered if a source already known comes before it, and it covers
   * every known source that comes after it. Returns the source and the
   * function that takes it out again.
   */
  addSource(
    name: string,
    marker: Element | null
  ): { source: RegionSource; remove: () => void } {
    let list = this.#sources.get(name);
    if (!list) {
      list = [];
      this.#sources.set(name, list);
    }
    const sources = list;
    const source = new RegionSource(marker, false);
    const covered = sources.some((other) => precedes(other, source, true));
    source.setCovered(covered);
    for (const other of sources) {
      if (precedes(source, other, false)) {
        other.setCovered(true);
      }
    }
    sources.push(source);

    const remove = (): void => {
      sources.splice(sources.indexOf(source), 1);
      sources.forEach((other, index) => {
        other.setCovered(
          sources.some(
            (earlier, earlierIndex) =>
              earlier !== other &&
              precedes(earlier, other, earlierIndex < index)
          )
        );
      });
      if (sources.length === 0) {
        this.#onEmpty(name);
      }
    };
    return { source, remove };
  }
}

/**
 * Layouts by the id on their root's `data-app-layout-id`. A source finds its
 * layout by walking up from its own marker, the way `Portal` finds a portal
 * target, so it needs no service and no context argument.
 */
const layouts = new Map<string, LayoutRegions>();

export function registerLayoutRegions(
  id: string,
  regions: LayoutRegions
): () => void {
  layouts.set(id, regions);
  return () => {
    layouts.delete(id);
  };
}

export function findLayoutRegions(from: Element | null): LayoutRegions | null {
  let parent = from?.parentNode as Element | null | undefined;
  while (parent) {
    const id =
      typeof parent.getAttribute === 'function'
        ? parent.getAttribute('data-app-layout-id')
        : null;
    if (id) {
      return layouts.get(id) ?? null;
    }
    parent = parent.parentNode as Element | null;
  }
  return null;
}
