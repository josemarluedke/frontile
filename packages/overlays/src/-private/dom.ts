import { getOwner } from '@ember/owner';

export function getDOM(context: object): Document | null {
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

export function getElementById(
  doc: Document | Element,
  id: string
): null | Element {
  return getElementByAttribute(doc, 'id', id);
}

export function getElementByAttribute(
  doc: Document | Element,
  attribute: string,
  value: string | undefined = undefined
): null | Element {
  if (doc.querySelector) {
    if (value) {
      return doc.querySelector(`[${attribute}=${value}]`);
    } else {
      return doc.querySelector(`[${attribute}]`);
    }
  }

  let nodes = childNodesOfElement(doc);
  let node;

  while (nodes.length) {
    node = nodes.shift();

    if (node && isElement(node)) {
      if (value && node.getAttribute(attribute) === value) {
        return node as Element;
      } else if (node.getAttribute(attribute)) {
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
