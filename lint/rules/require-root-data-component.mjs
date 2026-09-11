import { Rule } from 'ember-template-lint';

const hasAttr = (node, name) => node.attributes.some((a) => a.name === name);

/**
 * Is `tag` a component invocation (`<Overlay>`, `<@PopoverContent>`,
 * `<this.Checkbox>`, `<Tag>` for a dynamic `element` helper result) rather
 * than a plain HTML element (`<div>`, `<button>`)? Glimmer's own convention:
 * a block-param/path reference (leading `@` or containing `.`), or a tag
 * whose first character is uppercase.
 */
function isComponentInvocation(tag) {
  if (tag.startsWith('@') || tag.includes('.')) return true;
  const first = tag[0] ?? '';
  return first !== first.toLowerCase() && first === first.toUpperCase();
}

/**
 * Files with one deliberate, already-tested exception to "data-component
 * goes on the outermost element": `SimpleTable`'s standalone rendering
 * (`@hasWrapper` true, the default) wraps its `<table>` in a `<div
 * data-part="wrapper">`, but `data-component="table"` still goes on the
 * inner `<table>`, not the wrapper div -- because `<table>`, not the
 * wrapper, is what `...attributes` targets and what `Element:
 * HTMLTableElement` promises callers (refs, `{{on}}`, etc. all need to land
 * on the real `<table>`). This is spelled out and pinned by
 * `test-app/tests/integration/components/collections/simple-table-test.gts`
 * ("it renders the anatomy attributes with the wrapper (default)": "its
 * `<table>` element -- not the wrapper div -- is the anatomy root").
 *
 * `Table` (`table/table.gts`), which always renders `SimpleTable` with
 * `@hasWrapper={{false}}`, puts `data-component="table"` on ITS OWN wrapper
 * div instead -- that one is not exempted here, and correctly passes this
 * rule unexempted, since in that file the wrapper div genuinely is the
 * template's outermost element.
 *
 * Whether "the anatomy root is whichever element the Element type points
 * `...attributes` at" should be a *general* rule (rather than a one-off
 * exception) is a real open question -- flagged here rather than resolved,
 * since generalizing it is a bigger design call than this task should make
 * unilaterally. See Task 12's report.
 */
const ROOT_PLACEMENT_EXEMPT_FILES = [
  'packages/frontile/src/components/collections/simple-table/index.gts'
];

function isExemptFile(filePath) {
  if (!filePath) return false;
  const normalized = filePath.replace(/\\/g, '/');
  return ROOT_PLACEMENT_EXEMPT_FILES.some((suffix) =>
    normalized.endsWith(suffix)
  );
}

/**
 * Enforces the other half of the anatomy invariant that
 * `frontile/require-data-part` doesn't cover: `data-component` may only be
 * written on a `<template>` block's own outermost element -- never on an
 * element nested inside another element/component invocation within the
 * *same* template block.
 *
 * This is the enforcement gap Task 12's brief calls out directly: Tasks 5
 * and 7a both shipped `data-component` on a non-root element, and neither
 * `frontile/require-data-part` (which only checks slot/part *naming*, not
 * placement) nor `scripts/check-anatomy.mjs` (which only checks that every
 * slot has *some* renderer, not where on the element tree) noticed --
 * caught only by human code review both times.
 *
 * Deliberately scoped to *placement*, not *value*: this rule says nothing
 * about whether a `data-component` value is the "right" one, or whether the
 * same value appears more than once across the codebase -- both of those
 * are legitimate:
 *
 * - `CloseButton` inside `Alert` (`alert.gts`): Alert's own template passes
 *   `<CloseButton data-part="close-button" ... />` with no `data-component`
 *   at all -- that attribute exists only in `close-button.gts`'s own
 *   template, on `close-button.gts`'s own outermost `<button>`. Each file's
 *   template independently satisfies "root only"; nothing here reasons
 *   about the composed cross-file DOM, so a nested component's root
 *   legitimately carries its own `data-component` while also receiving a
 *   `data-part` that belongs to its *parent*'s slot naming.
 * - `tab-nav.gts` and `navigation/tabs/tabs.gts` both render
 *   `data-component="tabs"` -- two *different* templates, each on its own
 *   outermost element. This rule checks one template at a time, so the
 *   repeated value across files never comes up.
 * - `tooltip.gts` writes `data-component="tooltip"` on `<@PopoverContent>`,
 *   which is tooltip.gts's own template's sole top-level node (no wrapping
 *   element around it in that file) -- even though the value ultimately
 *   overrides Overlay's own default of `data-component="overlay"` once it
 *   flows through Popover.Content's `...attributes` forwarding. From this
 *   rule's perspective it's simply "the one root node, carrying the
 *   attribute" -- exactly the same shape as every other component.
 *
 * Implementation: only *plain HTML elements* (`<div>`, `<button>`, ...) --
 * not component invocations like `<Overlay>`, `<@PopoverContent>`, or
 * `<this.Checkbox>` -- increment the "nested inside another element in this
 * template" depth counter tracked via enter/exit on `ElementNode`. This is
 * what makes `modal.gts` pass: its real root, `<div data-component="modal"
 * ...>`, sits directly inside `<Overlay>...</Overlay>` in that file's own
 * template, but `Overlay` is a component invocation, not a plain wrapping
 * element that modal.gts itself renders -- `Overlay`/`Portal`/`Backdrop`
 * are explicitly out-of-scope overlay/portal machinery (see
 * `scripts/check-anatomy.mjs`'s `NEVER_RENDERED_CONFIGS` doc), so being
 * nested inside one of *those* isn't "this component put data-component in
 * the wrong place" -- it's the established, sanctioned overlay-wrapping
 * shape every portaled component uses. A *plain* element interposed
 * anywhere in the tree -- whether or not there's also component-invocation
 * wrapping above it -- still increments the counter and is still caught;
 * only component-invocation ancestors are transparent to it. The violation
 * check itself still runs for every `ElementNode` regardless of whether the
 * node itself is a plain element or a component invocation, since a
 * misplaced `data-component` on either shape is equally a bug.
 *
 * Non-element wrappers -- `{{#if}}`, `{{#let}}`, `{{#each}}`, and so on --
 * are a different AST node type entirely and never increment the depth
 * either, so they don't count as "nesting" (matching how, e.g.,
 * `button.gts`'s `{{#if @isRenderless}}...{{else}}<button ...>...{{/if}}`
 * still has exactly one root element for this rule's purposes).
 */
export default class RequireRootDataComponent extends Rule {
  visitor() {
    if (isExemptFile(this.filePath)) return {};

    let plainElementDepth = 0;

    return {
      ElementNode: {
        enter(node) {
          if (hasAttr(node, 'data-component') && plainElementDepth > 0) {
            this.log({
              message:
                "data-component must be written on this template's outermost element, not on an element nested inside another element",
              node
            });
          }
          if (!isComponentInvocation(node.tag)) plainElementDepth++;
        },
        exit(node) {
          if (!isComponentInvocation(node.tag)) plainElementDepth--;
        }
      }
    };
  }
}
