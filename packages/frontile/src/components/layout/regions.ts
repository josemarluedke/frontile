import { escapeAttributeValue, getDOM } from '../../-private/dom';

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
 * Nothing here is tracked and nothing is scheduled. The element exists before
 * either side renders, so it does not matter which renders first, and it can
 * be displayed somewhere else later (the aside moving into a drawer) without
 * the content being rebuilt.
 */
export class LayoutRegions {
  #doc: Document | null;
  #layoutId: string;
  #className: () => string;
  #onEmpty: (name: string) => void;
  #elements = new Map<string, Element>();
  #sources = new Map<string, number>();

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

  /**
   * A plain count of the sources rendered for `name`, for behaviour that
   * cannot be CSS (closing the aside when it empties). Not tracked: nothing
   * renders from it. Returns the function that takes the source out again.
   */
  addSource(name: string): () => void {
    this.#sources.set(name, (this.#sources.get(name) ?? 0) + 1);
    return () => {
      const left = (this.#sources.get(name) ?? 1) - 1;
      this.#sources.set(name, left);
      if (left === 0) {
        this.#onEmpty(name);
      }
    };
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
