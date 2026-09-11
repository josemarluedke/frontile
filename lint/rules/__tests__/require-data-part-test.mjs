import { test } from 'node:test';
import assert from 'node:assert/strict';
import Linter from 'ember-template-lint';
import plugin from '../../frontile-template-lint-plugin.mjs';

async function lint(template) {
  const linter = new Linter({
    config: {
      plugins: [plugin],
      rules: { 'frontile/require-data-part': true }
    }
  });
  const results = await linter.verify({
    source: template,
    filePath: 'a.hbs',
    moduleId: 'a'
  });
  return results.map((r) => r.message);
}

test('accepts an element whose data-part matches its slot', async () => {
  assert.deepEqual(
    await lint('<div data-part="trigger" class={{this.styles.trigger}}></div>'),
    []
  );
});

test('accepts a kebab-cased part for a camelCase slot', async () => {
  assert.deepEqual(
    await lint(
      '<div data-part="start-content" class={{this.styles.startContent}}></div>'
    ),
    []
  );
});

test('accepts a root carrying both attributes before ...attributes', async () => {
  assert.deepEqual(
    await lint(
      '<div data-component="accordion" data-part="base" class={{this.styles.base}} ...attributes></div>'
    ),
    []
  );
});

test('ignores elements that render no slot', async () => {
  assert.deepEqual(await lint('<div class="plain"></div>'), []);
});

test('accepts classNames as well as styles', async () => {
  assert.deepEqual(
    await lint('<div data-part="td" class={{this.classNames.td}}></div>'),
    []
  );
});

test('flags a missing data-part', async () => {
  assert.deepEqual(await lint('<div class={{this.styles.trigger}}></div>'), [
    'Element renders slot "trigger" but is missing data-part="trigger"'
  ]);
});

test('flags a misspelled data-part', async () => {
  assert.deepEqual(
    await lint('<div data-part="triger" class={{this.styles.trigger}}></div>'),
    ['data-part="triger" does not match the rendered slot; expected "trigger"']
  );
});

test('flags a camelCase data-part', async () => {
  assert.deepEqual(
    await lint(
      '<div data-part="startContent" class={{this.styles.startContent}}></div>'
    ),
    [
      'data-part="startContent" does not match the rendered slot; expected "start-content"'
    ]
  );
});

test('flags data-part written after ...attributes', async () => {
  assert.deepEqual(
    await lint(
      '<div ...attributes data-part="base" class={{this.styles.base}}></div>'
    ),
    [
      'data-part must be written before ...attributes so a caller value can override it'
    ]
  );
});

test('flags a data-test-id duplicating data-part', async () => {
  assert.deepEqual(
    await lint(
      '<div data-part="trigger" data-test-id="trigger" class={{this.styles.trigger}}></div>'
    ),
    ['data-test-id="trigger" duplicates data-part="trigger"; remove it']
  );
});

// ConcatStatement class attributes: a static class token combined with the slot
// mustache (`class="group/segmented {{this.styles.base}}"`) parses as a
// ConcatStatement, not a MustacheStatement. These cases previously fell through
// `slotFromClassAttr`'s type check and were silently skipped.

test('flags a concat class attribute missing data-part', async () => {
  assert.deepEqual(
    await lint('<div class="group/segmented {{this.styles.base}}"></div>'),
    ['Element renders slot "base" but is missing data-part="base"']
  );
});

test('accepts a concat class attribute with the correct data-part', async () => {
  assert.deepEqual(
    await lint(
      '<div data-part="base" class="group/segmented {{this.styles.base}}"></div>'
    ),
    []
  );
});

test('flags a concat class attribute with a hash-argument mustache missing data-part', async () => {
  assert.deepEqual(
    await lint(
      '<div class="group/segmented {{this.styles.base class=@classes.base}}"></div>'
    ),
    ['Element renders slot "base" but is missing data-part="base"']
  );
});

// SubExpression form: `class="{{(this.styles.sortButton)}}"` still parses as a
// ConcatStatement (with a single MustacheStatement part) whose mustache path is
// a SubExpression wrapping the real PathExpression, rather than a PathExpression
// directly.

test('flags a SubExpression-wrapped class attribute missing data-part', async () => {
  assert.deepEqual(
    await lint('<div class="{{(this.styles.sortButton)}}"></div>'),
    ['Element renders slot "sortButton" but is missing data-part="sort-button"']
  );
});

test('accepts a SubExpression-wrapped class attribute with the correct data-part', async () => {
  assert.deepEqual(
    await lint(
      '<div data-part="sort-button" class="{{(this.styles.sortButton)}}"></div>'
    ),
    []
  );
});

// Ruling: when a concat contains more than one slot mustache, the rule uses the
// FIRST one in source order and ignores the rest. A single element declaring two
// slots at once is not a supported pattern in this codebase; picking the first
// deterministically avoids double-reporting and matches "the primary style call
// comes first" convention seen in existing templates.

test('uses the first slot mustache when a concat contains more than one', async () => {
  assert.deepEqual(
    await lint('<div class="{{this.styles.base}} {{this.styles.icon}}"></div>'),
    ['Element renders slot "base" but is missing data-part="base"']
  );
});

// Config accessor vs. slot accessor: `useStyles()` returns the theme's whole
// components namespace, so `{{styles.skeleton class=@class shape=@shape}}`
// invokes the entire slotless `skeleton` config directly (with its own
// variant args), not a slot literally named "skeleton". `skeleton` is a real,
// currently-slotless top-level theme config, so this exercises the actual
// production case (see packages/frontile/src/components/utilities/skeleton.gts).
// The distinguishing signal is the argument shape: a genuine slot call only
// ever passes zero args or a single `class=` hash pair; a whole-config call
// passes its own variant props too.

test('treats a multi-arg call of a slotless config as the implicit "base" part, not a slot named after the config', async () => {
  assert.deepEqual(
    await lint(
      '<div data-part="base" class={{styles.skeleton class=@class shape=@shape}}></div>'
    ),
    []
  );
});

test('flags a whole-config accessor call using the config name as data-part instead of "base"', async () => {
  assert.deepEqual(
    await lint(
      '<div data-part="skeleton" class={{styles.skeleton class=@class shape=@shape}}></div>'
    ),
    ['data-part="skeleton" does not match the rendered slot; expected "base"']
  );
});

test('flags a missing data-part on a whole-config accessor call', async () => {
  assert.deepEqual(
    await lint(
      '<div class={{styles.skeleton class=@class shape=@shape}}></div>'
    ),
    ['Element renders slot "base" but is missing data-part="base"']
  );
});

// Bare-identifier config accessor: `const { divider } = useStyles();` at
// module scope, then `{{divider (hash class=@class orientation=@orientation)}}`
// in the template -- no `styles.`/`classNames.`/`classes.` owner segment at
// all, since the destructure already pulled the whole config out. This used
// to be structurally invisible to the rule (a single-part PathExpression has
// no "owner", so slotFromPath bailed out) -- see
// packages/frontile/src/components/utilities/divider.gts, and Task 12's
// report for the residual risk this still leaves for a hypothetical
// multi-slot config destructured the same way.

test('treats a bare destructured config identifier as the implicit "base" part', async () => {
  assert.deepEqual(
    await lint(
      '<div data-part="base" class={{divider (hash class=@class orientation=@orientation)}}></div>'
    ),
    []
  );
});

test('flags a missing data-part on a bare destructured config identifier', async () => {
  assert.deepEqual(
    await lint(
      '<div class={{divider (hash class=@class orientation=@orientation)}}></div>'
    ),
    ['Element renders slot "base" but is missing data-part="base"']
  );
});

// A slot name can coincidentally equal a slotless top-level config's own
// name (e.g. `listbox` is both a real slot of `select`/`autocomplete` and,
// separately, its own slotless top-level config). The single-`class=`-arg
// shape must still resolve this as the genuine slot it is, not get
// reclassified as a "base" config accessor just because the name collides.

test('does not reclassify a genuine single-class-arg slot access even when its name collides with a slotless config', async () => {
  assert.deepEqual(
    await lint(
      '<div data-part="listbox" class={{this.classes.listbox class=@classes.listbox}}></div>'
    ),
    []
  );
});

test('still requires the real slot name (not "base") for a colliding but genuine slot access', async () => {
  assert.deepEqual(
    await lint(
      '<div class={{this.classes.listbox class=@classes.listbox}}></div>'
    ),
    ['Element renders slot "listbox" but is missing data-part="listbox"']
  );
});

// --- Finding 1: forward check -----------------------------------------------
//
// Every check above only fires when a *slot accessor* is detected on the
// element's `class` -- it says nothing about an element that carries
// data-part/data-component whose class was never a slot at all. This is the
// exact counter-example the final whole-branch review constructed and
// confirmed passed both gates cleanly:
//
//   <div class="not-a-real-slot-class" data-component="table" data-part="tr">
//     rogue
//   </div>
//
// -- `tr` is a real `table` slot, so `check-anatomy.mjs`'s cross-file check
// (which only asks "is every real slot rendered somewhere, and does every
// rendered part name a real slot") is satisfied, and this rule's own
// slot-detection never even looks at a hardcoded class string, so it never
// gets a chance to object. This is exactly the shape a future author
// produces by copy-pasting an attribute pair from a nearby component instead
// of deriving it from their own config.

test('flags data-part on an element whose class is a plain static string (the rogue counter-example)', async () => {
  assert.deepEqual(
    await lint(
      '<div class="not-a-real-slot-class" data-component="table" data-part="tr">rogue</div>'
    ),
    [
      'data-part="tr" is written on an element whose class is a plain string, not a rendered slot; derive both from the same tv() slot accessor (or remove the attribute if this element isn\'t part of the component\'s anatomy)'
    ]
  );
});

test('flags data-component alone on an element whose class is a plain static string', async () => {
  assert.deepEqual(
    await lint(
      '<div class="not-a-real-slot-class" data-component="table">rogue</div>'
    ),
    [
      'data-component="table" is written on an element whose class is a plain string, not a rendered slot; derive both from the same tv() slot accessor (or remove the attribute if this element isn\'t part of the component\'s anatomy)'
    ]
  );
});

test('flags data-part alone on an element whose class is a plain static string, with no data-component present', async () => {
  assert.deepEqual(
    await lint('<div class="not-a-real-slot-class" data-part="tr">rogue</div>'),
    [
      'data-part="tr" is written on an element whose class is a plain string, not a rendered slot; derive both from the same tv() slot accessor (or remove the attribute if this element isn\'t part of the component\'s anatomy)'
    ]
  );
});

// Legitimate shape: a normal root where the class IS a genuine slot
// accessor -- the ordinary case, and the forward check must not add a
// second, redundant complaint on top of the existing reverse-direction
// checks (which already pass this shape, see the very first test above).

test('does not flag a normal root whose class is a genuine slot accessor', async () => {
  assert.deepEqual(
    await lint(
      '<div data-component="accordion" data-part="base" class={{this.styles.base}}></div>'
    ),
    []
  );
});

// Legitimate shape: packages/frontile/src/components/status/progress-bar.gts:226
// -- the outer <div data-component="progress-bar" ...attributes> renders no
// slot at all and deliberately carries no data-part, no class attribute
// whatsoever. Nothing here to contradict, so it must not be flagged.

test('does not flag a data-component-only root with no class attribute at all (progress-bar shape)', async () => {
  assert.deepEqual(
    await lint('<div data-component="progress-bar" ...attributes></div>'),
    []
  );
});

// Legitimate shape: packages/frontile/src/components/overlays/tooltip.gts --
// data-component/data-part set on a <@PopoverContent> *component
// invocation*, not a plain DOM element. Component invocations forward their
// attributes onto some other template's own root via ...attributes and have
// no `class` of their own for this rule to check.

test('does not flag data-component set on a component invocation (tooltip/@PopoverContent shape)', async () => {
  assert.deepEqual(
    await lint(
      '<@PopoverContent data-component="tooltip" data-part="base" ...attributes></@PopoverContent>'
    ),
    []
  );
});

// Legitimate shape: attributes forwarded onto a nested component invocation
// -- Collapsible receiving data-part="content", and Modal/Drawer's docs
// demos passing `<m.CloseButton data-part="close-button" />`. Uppercase-tag
// and path-expression component invocations alike are exempt.

test('does not flag data-part forwarded onto a <Collapsible> component invocation', async () => {
  assert.deepEqual(
    await lint(
      '<Collapsible data-part="content" @isExpanded={{true}}></Collapsible>'
    ),
    []
  );
});

test('does not flag data-part forwarded onto a <m.CloseButton> path-expression component invocation', async () => {
  assert.deepEqual(
    await lint('<m.CloseButton data-part="close-button" />'),
    []
  );
});

// Legitimate shape: simple-table/index.gts's conditional
// data-component={{if this.isRoot "table"}} -- a dynamic, non-literal value.
// attrValue only reads TextNode attribute values, so a dynamic
// data-component is invisible to this check entirely (same as it already is
// to the reverse-direction check above it).

test('does not flag a dynamic (non-literal) data-component value', async () => {
  assert.deepEqual(
    await lint(
      '<table data-component={{if this.isRoot "table"}} data-part="table" class={{this.tableClassNames}}></table>'
    ),
    []
  );
});

// Legitimate shape: an element whose class comes from a destructured local
// (const { divider } = useStyles()) or, more broadly, any opaque
// this.<getter> class computation this rule's static analysis cannot look
// through (this.classes, this.classNames, this.baseClass, ...) -- several
// real components use this pattern (e.g. form-feedback.gts, button.gts,
// listbox.gts). The forward check is deliberately scoped to "class is a bare
// TextNode (zero mustaches)" rather than "slotFromClassAttr returned null",
// specifically so it does not flag these already-legitimate, already-tested
// components.

test('does not flag an opaque this.<getter> class expression the rule cannot resolve to a slot (form-feedback/button shape)', async () => {
  assert.deepEqual(
    await lint(
      '<div class={{this.classes}} data-component="form-feedback" data-part="base"></div>'
    ),
    []
  );
});

test('does not flag a bare this.classNames getter with data-component and data-part (button/button-group shape)', async () => {
  assert.deepEqual(
    await lint(
      '<div class={{this.classNames}} data-component="button-group" data-part="base"></div>'
    ),
    []
  );
});
