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

// eslint-disable-next-line no-control-regex
const CONTROL_CHARACTERS = /[\u0000-\u001f\u007f]/g;

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
 * `CSS.escape` would also work here, but it escapes for the *identifier*
 * grammar while every call site interpolates into a *quoted string*
 * (`[attr="…"]`). Two escapers for two grammars in one function is a trap
 * even though both happen to round-trip, and `CSS.escape` is a browser global
 * this module cannot rely on — it also runs against the `-document` service
 * when the app is prerendered. So there is one hand-rolled escaper, complete
 * for the quoted-string position and exercised by every caller on every
 * platform:
 *
 * - `"` and `\` are escaped with a backslash; they are the only characters a
 *   quoted string cannot carry literally.
 * - Control characters — newline (`\a`), carriage return (`\d`), form feed
 *   (`\c`) among them — cannot appear literally in a CSS string either, and
 *   get the hex escape the grammar defines, always with the terminating space
 *   so the following character is never absorbed into the escape. Substituting
 *   a different character for them (a space, say) would silently query for a
 *   *different* value and match the wrong element, or none, with no error.
 */
function escapeAttributeValue(value: string): string {
  return value
    .replace(/["\\]/g, '\\$&')
    .replace(
      CONTROL_CHARACTERS,
      (char) => `\\${char.charCodeAt(0).toString(16)} `
    );
}

export function getElementById(
  doc: Document | Element,
  id: string
): null | Element {
  // `Document` (and the `-document` service standing in for it) can answer
  // this without a selector at all, which sidesteps escaping entirely.
  // `Element` has no `getElementById`, so those callers keep the selector and
  // node-walking paths below.
  //
  // Intentional asymmetry with `getElementByAttribute`: an empty id is *no id*
  // here (`@target="#"` must resolve to nothing rather than to whichever
  // element happens to carry an `id` first), while an empty value passed to
  // `getElementByAttribute` is a value like any other and is matched
  // literally. Both receivers are reachable, so the two exports disagree by
  // design, not by oversight.
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
