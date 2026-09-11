import { Rule } from 'ember-template-lint';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { readSlotlessConfigNames } from '../../scripts/check-anatomy.mjs';

const kebab = (s) => s.replace(/([a-z0-9])([A-Z])/g, '$1-$2').toLowerCase();

const __dirname = dirname(fileURLToPath(import.meta.url));

/**
 * The set of top-level tv() config names (raw JS identifiers, e.g.
 * `skeleton`, `spinner`, `divider` -- not kebab-cased) that are
 * "slotless": no `slots:` key of their own, and nothing slot-shaped
 * inherited through `extend` either. See `readSlotlessConfigNames`'s doc in
 * `scripts/check-anatomy.mjs` for the full explanation of why this rule
 * needs to know this and how it's computed; computed once at module load
 * since the theme package doesn't change while linting runs.
 */
const SLOTLESS_CONFIG_NAMES = readSlotlessConfigNames(
  join(__dirname, '../../packages/theme/src/components')
);

/**
 * Does `expr` (a MustacheStatement or SubExpression) invoke its path with
 * more than just a single `class=` hash pair? Every genuine *slot*
 * invocation in this codebase follows one of two shapes: a bare property
 * read (`{{this.classes.base}}`, zero args) or a single `class=` hash pair
 * (`{{this.classes.base class=@classes.base}}`) -- because a slot function
 * only ever needs the caller's own class override.
 *
 * A config invoked *directly* (the whole tv() config, not one of its slots)
 * instead passes its own variant props, either as multiple hash pairs
 * (`{{styles.skeleton class=@class shape=@shape size=@size ...}}`) or as a
 * single positional argument built with `(hash ...)`
 * (`{{divider (hash class=@class orientation=@orientation)}}`). Either
 * shape is a reliable, purely-syntactic tell that this call is not the
 * single-hash-pair slot convention, which is what makes it safe to treat
 * `last` below as a config name rather than a slot name -- see
 * `slotFromExpr`.
 */
function isWholeConfigCall(expr) {
  const hash = expr.hash?.pairs ?? [];
  const params = expr.params ?? [];
  if (params.length > 0) return true;
  if (hash.length > 1) return true;
  if (hash.length === 1 && hash[0].key !== 'class') return true;
  return false;
}

/** `{{this.styles.trigger}}` / `{{(this.styles.sortButton)}}` / bare `{{divider …}}` → the slot name, or `null`. */
function slotFromExpr(expr) {
  // `{{(this.styles.sortButton)}}` wraps the real call in a SubExpression
  // sitting in the mustache's path position; unwrap it so both the accessed
  // path and (for isWholeConfigCall) the argument list come from the real
  // call, not the (argument-less) outer mustache.
  const call =
    expr.path && expr.path.type === 'SubExpression' ? expr.path : expr;
  const path = call.path;
  if (!path || path.type !== 'PathExpression') return null;
  const parts = path.parts ?? [];
  const last = parts.at(-1);
  if (!last) return null;

  if (parts.length === 1) {
    // A bare identifier, e.g. `const { divider } = useStyles(); …
    // class={{divider (hash …)}}`. useStyles() only ever destructures
    // whole top-level configs -- never an individual slot function -- so
    // this sole segment is always a config name, never a slot. It is
    // exactly this rule's blind spot when the destructured config happens
    // to be multi-slot (nothing in this codebase does that today; if it
    // ever does, this returns `null` -- no false report, but no coverage
    // either. See the require-data-part tests and Task 12's report for the
    // residual-risk note.)
    return SLOTLESS_CONFIG_NAMES.has(last) ? 'base' : null;
  }

  const owner = parts.at(-2);
  if (!['styles', 'classNames', 'classes'].includes(owner)) return null;

  if (SLOTLESS_CONFIG_NAMES.has(last) && isWholeConfigCall(call)) {
    // `{{styles.skeleton class=@class shape=@shape size=@size ...}}`:
    // `styles` is useStyles()'s raw return (the whole config namespace) and
    // `skeleton` names the entire slotless config being invoked directly
    // with its own variant args -- not a slot of some other config that
    // happens to share the "styles" owner name. The correct, already-used
    // convention for a slotless config's one element is `data-part="base"`
    // (matching `readThemeSlots`'s modeling in check-anatomy.mjs), not the
    // literal config name.
    return 'base';
  }

  return last;
}

/** `{{this.styles.trigger …}}` / `{{classNames.startContent}}` → the slot name. */
function slotFromClassAttr(node) {
  const attr = node.attributes.find((a) => a.name === 'class');
  if (!attr) return null;
  const value = attr.value;

  if (value.type === 'MustacheStatement') {
    return slotFromExpr(value);
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
      const slot = slotFromExpr(part);
      if (slot) return slot;
    }
  }

  return null;
}

const attrValue = (node, name) => {
  const a = node.attributes.find((x) => x.name === name);
  return a && a.value.type === 'TextNode' ? a.value.chars : undefined;
};

/**
 * Is `tag` a component invocation (`<Overlay>`, `<@PopoverContent>`,
 * `<this.Checkbox>`) rather than a plain HTML element (`<div>`,
 * `<button>`)? Same convention `frontile/require-root-data-component` uses
 * (leading `@`/`.`, or an uppercase first character) -- duplicated here
 * (rather than shared through a module) because it's a three-line, unlikely-
 * to-drift piece of Glimmer trivia, and this rule has no existing shared-utils
 * module to hang it on.
 */
function isComponentInvocation(tag) {
  if (tag.startsWith('@') || tag.includes('.')) return true;
  const first = tag[0] ?? '';
  return first !== first.toLowerCase() && first === first.toUpperCase();
}

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
              node
            });
          } else if (part !== expected) {
            this.log({
              message: `data-part="${part}" does not match the rendered slot; expected "${expected}"`,
              node
            });
          }
        }

        // Forward check: an element carrying a literal data-part or
        // data-component whose `class` attribute is provably NOT a slot
        // accessor -- a plain static string, e.g.
        // `class="not-a-real-slot-class"` -- is a hand-copied attribute pair
        // rather than a genuine anatomy element. The rest of this rule (and
        // `check-anatomy.mjs`) only ever check the *reverse* direction ("a
        // detected slot must have a matching data-part"); nothing previously
        // caught the case where data-part/data-component names a real slot
        // of a real config, but the element they're written on isn't
        // actually rendering that slot at all.
        //
        // Deliberately narrow to "class is a bare TextNode (no `{{...}}`
        // anywhere)" rather than "slotFromClassAttr returned null": several
        // real components compute their whole class string behind an opaque
        // getter (`class={{this.classes}}`, `class={{this.classNames}}`,
        // `class={{this.baseClass}}`, ...) that this rule's static analysis
        // cannot see through to confirm it's slot-backed -- see
        // `slotFromExpr`'s single-part-PathExpression branch and its doc
        // comment for the same, already-accepted blind spot. Every one of
        // those still contains a real `{{mustache}}`, so gating on "zero
        // mustaches at all" catches the copy-pasted-hardcoded-string shape
        // the reviewer's counter-example demonstrates without flagging any
        // of those legitimate opaque-getter components. A `class` attribute
        // that's entirely absent (e.g. `progress-bar.gts`'s root, which
        // deliberately renders no slot and carries no data-part) is exempt
        // for the same reason: there is no class value here to contradict.
        //
        // Also exempt: component invocations (`<Overlay data-component=...>`,
        // `<@PopoverContent data-component="tooltip">`,
        // `<Collapsible data-part="content">`,
        // `<m.CloseButton data-part="close-button" />`). These forward
        // data-part/data-component onto some other template's own root
        // element via `...attributes`; they carry no `class` of their own
        // for *this* template to render a slot through, so there's nothing
        // here to check.
        if (
          (part !== undefined || component !== undefined) &&
          !isComponentInvocation(node.tag)
        ) {
          const classAttr = node.attributes.find((a) => a.name === 'class');
          if (classAttr && classAttr.value.type === 'TextNode') {
            const attrName =
              part !== undefined ? 'data-part' : 'data-component';
            const attrVal = part !== undefined ? part : component;
            this.log({
              message: `${attrName}="${attrVal}" is written on an element whose class is a plain string, not a rendered slot; derive both from the same tv() slot accessor (or remove the attribute if this element isn't part of the component's anatomy)`,
              node
            });
          }
        }

        if (testId !== undefined && (testId === part || testId === component)) {
          this.log({
            message: `data-test-id="${testId}" duplicates data-${
              testId === part ? 'part' : 'component'
            }="${testId}"; remove it`,
            node
          });
        }

        const splat = node.attributes.findIndex(
          (a) => a.name === '...attributes'
        );
        if (splat !== -1) {
          for (const name of ['data-part', 'data-component']) {
            const i = node.attributes.findIndex((a) => a.name === name);
            if (i > splat) {
              this.log({
                message: `${name} must be written before ...attributes so a caller value can override it`,
                node
              });
            }
          }
        }
      }
    };
  }
}
