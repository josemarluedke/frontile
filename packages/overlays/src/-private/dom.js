import { getOwner } from '@ember/application';

// adjusted from https://github.com/yapplabs/ember-wormhole/blob/0.5.4/addon/utils/dom.js#L45-L63
// Copied from https://github.com/ember-intl/ember-intl/blob/a66560d0af9f08af20778a3eb3003045e19fbf16/addon/-private/utils/get-dom.js
//
// Private Ember API usage. Get the dom implementation used by the current
// renderer, be it native browser DOM or Fastboot SimpleDOM
/**
 * @private
 * @hide
 */
export function getDOM(context) {
  let { renderer } = context;
  if (!renderer || !renderer._dom) {
    // pre glimmer2
    const container = getOwner ? getOwner(context) : context.container;
    const documentService = container.lookup('service:-document');

    if (documentService) {
      return documentService;
    }

    renderer = container.lookup('renderer:-dom');
  }

  if (renderer._dom && renderer._dom.document) {
    // pre Ember 2.6
    return renderer._dom.document;
  }

  return null;
}

function childNodesOfElement(element) {
  const children = [];
  let child = element.firstChild;
  while (child) {
    children.push(child);
    child = child.nextSibling;
  }
  return children;
}

export function getElementById(doc, id) {
  if (doc.getElementById) {
    return doc.getElementById(id);
  }

  let nodes = childNodesOfElement(doc);
  let node;

  while (nodes.length) {
    node = nodes.shift();

    if (node.getAttribute && node.getAttribute('id') === id) {
      return node;
    }

    nodes = childNodesOfElement(node).concat(nodes);
  }
}
