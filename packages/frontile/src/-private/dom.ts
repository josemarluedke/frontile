import { getOwner } from '@ember/owner';

export function getDOM(context: object): Document | null {
  if (typeof document !== 'undefined') {
    return document;
  }

  const container = getOwner(context);
  if (!container) {
    return null;
  }
  const documentService = container.lookup('service:-document');

  if (documentService) {
    return documentService as Document;
  }
  return null;
}

function childNodesOfElement(
  element: Node | Element | null | undefined
): (Node | Element)[] {
  if (!element) {
    return [];
  }

  const children = [];
  let child = element.firstChild;
  while (child) {
    children.push(child);
    child = child.nextSibling;
  }
  return children;
}

/**
 * Escapes a value for use inside a *quoted* attribute selector.
 *
 * Values reaching here come from consumers — `Portal @target="#some-id"`, a
 * portal target name — and an id is only required to be non-empty and free of
 * whitespace, so plenty of legal ids (`1foo`, `user.email`, `a:b`) are not
 * valid CSS identifiers. Interpolating them raw either throws a `SyntaxError`
 * and takes the render down, or, for a crafted value like
 * `x], [data-portal-target`, closes the predicate and matches something else
 * entirely.
 *
 * `CSS.escape` is the right tool, but it is a browser global and this module
 * also runs against the `-document` service when the app is prerendered. In a
 * quoted string only the quote itself, a backslash, and raw newlines actually
 * need escaping, so the fallback is both small and complete.
 */
function escapeAttributeValue(value: string): string {
  if (typeof CSS !== 'undefined' && typeof CSS.escape === 'function') {
    return CSS.escape(value);
  }

  return value.replace(/["\\]/g, '\\$&').replace(/[\n\r\f]/g, ' ');
}

export function getElementById(
  doc: Document | Element,
  id: string
): null | Element {
  // `Document` (and the `-document` service standing in for it) can answer
  // this without a selector at all, which sidesteps escaping entirely.
  // `Element` has no `getElementById`, so those callers keep the selector and
  // node-walking paths below.
  if (typeof (doc as Document).getElementById === 'function') {
    return id ? (doc as Document).getElementById(id) : null;
  }

  return getElementByAttribute(doc, 'id', id);
}

export function getElementByAttribute(
  doc: Document | Element,
  attribute: string,
  value: string | undefined = undefined
): null | Element {
  // Only an omitted value means "any element carrying this attribute". An
  // empty string is a value like any other and is matched literally —
  // otherwise `@target="#"` would portal into whatever element happens to
  // carry an `id` first.
  const hasValue = typeof value !== 'undefined';

  if (doc.querySelector) {
    if (hasValue) {
      return doc.querySelector(
        `[${attribute}="${escapeAttributeValue(value as string)}"]`
      );
    } else {
      return doc.querySelector(`[${attribute}]`);
    }
  }

  let nodes = childNodesOfElement(doc);
  let node;

  while (nodes.length) {
    node = nodes.shift();

    if (node && isElement(node)) {
      if (hasValue && node.getAttribute(attribute) === value) {
        return node as Element;
      } else if (!hasValue && node.getAttribute(attribute)) {
        return node as Element;
      }
    }

    nodes = childNodesOfElement(node).concat(nodes);
  }

  return null;
}

function isElement(el: Node | Element): el is Element {
  // @ts-expect-error checking if is an element
  return typeof el.getAttribute == 'function';
}
