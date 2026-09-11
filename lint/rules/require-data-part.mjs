import { Rule } from 'ember-template-lint';

const kebab = (s) => s.replace(/([a-z0-9])([A-Z])/g, '$1-$2').toLowerCase();

/** `this.styles.trigger` / `(this.styles.trigger)` → `"trigger"`, else `null`. */
function slotFromPath(path) {
  // `{{(this.styles.sortButton)}}` wraps the real PathExpression in a
  // SubExpression; unwrap it before reading `.parts`.
  if (path && path.type === 'SubExpression') path = path.path;
  if (!path || path.type !== 'PathExpression') return null;
  const parts = path.parts ?? [];
  const last = parts.at(-1);
  const owner = parts.at(-2);
  if (!last || !owner) return null;
  if (!['styles', 'classNames', 'classes'].includes(owner)) return null;
  return last;
}

/** `{{this.styles.trigger …}}` / `{{classNames.startContent}}` → the slot name. */
function slotFromClassAttr(node) {
  const attr = node.attributes.find((a) => a.name === 'class');
  if (!attr) return null;
  const value = attr.value;

  if (value.type === 'MustacheStatement') {
    return slotFromPath(value.path);
  }

  // A static class token combined with the slot mustache
  // (`class="group/segmented {{this.styles.base}}"`), or a single mustache
  // with no adjoining text (`class="{{(this.styles.sortButton)}}"`), both
  // parse as a ConcatStatement rather than a bare MustacheStatement.
  if (value.type === 'ConcatStatement') {
    // Ruling: if more than one part renders a slot, use the FIRST one in
    // source order and ignore the rest. A single element declaring two
    // slots at once isn't a supported pattern here; taking the first
    // deterministically avoids double-reporting on the same element.
    for (const part of value.parts) {
      if (part.type !== 'MustacheStatement') continue;
      const slot = slotFromPath(part.path);
      if (slot) return slot;
    }
  }

  return null;
}

const attrValue = (node, name) => {
  const a = node.attributes.find((x) => x.name === name);
  return a && a.value.type === 'TextNode' ? a.value.chars : undefined;
};

export default class RequireDataPart extends Rule {
  visitor() {
    return {
      ElementNode: (node) => {
        const slot = slotFromClassAttr(node);
        const part = attrValue(node, 'data-part');
        const component = attrValue(node, 'data-component');
        const testId = attrValue(node, 'data-test-id');

        if (slot) {
          const expected = kebab(slot);
          if (part === undefined) {
            this.log({
              message: `Element renders slot "${slot}" but is missing data-part="${expected}"`,
              node,
            });
          } else if (part !== expected) {
            this.log({
              message: `data-part="${part}" does not match the rendered slot; expected "${expected}"`,
              node,
            });
          }
        }

        if (testId !== undefined && (testId === part || testId === component)) {
          this.log({
            message: `data-test-id="${testId}" duplicates data-${
              testId === part ? 'part' : 'component'
            }="${testId}"; remove it`,
            node,
          });
        }

        const splat = node.attributes.findIndex((a) => a.name === '...attributes');
        if (splat !== -1) {
          for (const name of ['data-part', 'data-component']) {
            const i = node.attributes.findIndex((a) => a.name === name);
            if (i > splat) {
              this.log({
                message: `${name} must be written before ...attributes so a caller value can override it`,
                node,
              });
            }
          }
        }
      },
    };
  }
}
