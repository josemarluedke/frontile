import { test } from 'node:test';
import assert from 'node:assert/strict';
import Linter from 'ember-template-lint';
import plugin from '../../frontile-template-lint-plugin.mjs';

async function lint(template, filePath = 'a.hbs') {
  const linter = new Linter({
    config: {
      plugins: [plugin],
      rules: { 'frontile/require-root-data-component': true }
    }
  });
  const results = await linter.verify({
    source: template,
    filePath,
    moduleId: filePath
  });
  return results.map((r) => r.message);
}

const MESSAGE =
  "data-component must be written on this template's outermost element, not on an element nested inside another element";

test("accepts data-component on the template's sole root element", async () => {
  assert.deepEqual(
    await lint('<div data-component="skeleton" data-part="base"></div>'),
    []
  );
});

// The historical bug this rule exists to catch (Task 12's brief: Tasks 5 and
// 7a both shipped this shape, caught only by human review): a wrapping
// element that is part of THIS component's own template, with
// data-component misplaced on a child instead of the wrapper.

test('flags data-component nested one level inside a plain wrapping element (the Task 5/7a bug shape)', async () => {
  assert.deepEqual(
    await lint(
      '<div class="wrapper"><div data-component="skeleton" data-part="base"></div></div>'
    ),
    [MESSAGE]
  );
});

test('flags data-component nested multiple levels deep', async () => {
  assert.deepEqual(
    await lint(
      '<div><div><div data-component="skeleton" data-part="base"></div></div></div>'
    ),
    [MESSAGE]
  );
});

test('flags every misplaced data-component when more than one element has one', async () => {
  assert.deepEqual(
    await lint(
      '<div class="wrapper">' +
        '<div data-component="a" data-part="base"></div>' +
        '<div data-component="b" data-part="base"></div>' +
        '</div>'
    ),
    [MESSAGE, MESSAGE]
  );
});

// Legitimate shape 1: a component invocation (e.g. `<Overlay>`) wrapping the
// real root is not "this component's own markup nested wrong" -- see
// overlays/modal.gts, where `<div data-component="modal" ...>` sits directly
// inside `<Overlay>...</Overlay>` in modal.gts's own template. Overlay is
// explicitly out-of-scope portal machinery (scripts/check-anatomy.mjs's
// NEVER_RENDERED_CONFIGS), not a plain element modal.gts itself renders.

test('accepts data-component on a plain element wrapped only by a component invocation (the Overlay/modal.gts shape)', async () => {
  assert.deepEqual(
    await lint(
      '<Overlay><div data-component="modal" data-part="base"></div></Overlay>'
    ),
    []
  );
});

// But a *plain* element still counts even when component-invocation wrapping
// is also present above it -- component-invocation ancestors are the only
// ones treated as transparent.

test('still flags data-component nested inside a plain element even when a component invocation wraps everything', async () => {
  assert.deepEqual(
    await lint(
      '<Overlay><div class="wrapper"><div data-component="modal" data-part="base"></div></div></Overlay>'
    ),
    [MESSAGE]
  );
});

// Legitimate shape 2: data-component written directly on a component
// invocation that is itself the template's sole top-level node -- see
// overlays/tooltip.gts, whose only rendered node is
// `<@PopoverContent data-component="tooltip" ...>` (no wrapping element in
// that file at all).

test("accepts data-component on a component invocation that is the template's sole top-level node (the Tooltip/@PopoverContent shape)", async () => {
  assert.deepEqual(
    await lint('<@PopoverContent data-component="tooltip" data-part="base" />'),
    []
  );
});

// Legitimate shape 3: two independent templates render data-component with
// the same value, each on its own root -- see tab-nav.gts and
// navigation/tabs/tabs.gts, both rendering data-component="tabs". This rule
// checks one <template> at a time and says nothing about repeated values, so
// two separate `lint()` calls (independent Linter/Rule instances, exactly
// like linting two separate files) each see their own root and pass.

test('accepts the same data-component value on two independently-linted roots (the tab-nav/tabs shape)', async () => {
  assert.deepEqual(
    await lint('<nav data-component="tabs" data-part="list"></nav>'),
    []
  );
  assert.deepEqual(
    await lint('<div data-component="tabs" data-part="list"></div>'),
    []
  );
});

// Non-element wrappers ({{#if}}, {{#let}}) are a different AST node type
// entirely and never count as nesting.

test('does not treat a {{#let}} wrapper as nesting', async () => {
  assert.deepEqual(
    await lint(
      '{{#let (foo) as |x|}}<div data-component="skeleton" data-part="base"></div>{{/let}}'
    ),
    []
  );
});

test('does not treat an {{#if}}/{{else}} wrapper as nesting (the button.gts isRenderless shape)', async () => {
  assert.deepEqual(
    await lint(
      '{{#if @isRenderless}}{{yield}}{{else}}<button data-component="button" data-part="base"></button>{{/if}}'
    ),
    []
  );
});

test('ignores elements with no data-component at all', async () => {
  assert.deepEqual(
    await lint('<div class="wrapper"><div data-part="base"></div></div>'),
    []
  );
});

// The one documented, tested exception: SimpleTable's standalone rendering
// (packages/frontile/src/components/collections/simple-table/index.gts)
// deliberately puts data-component="table" on the inner <table>, not the
// wrapping <div data-part="wrapper">, because <table> -- not the wrapper --
// is what ...attributes targets. Pinned by
// test-app/tests/integration/components/collections/simple-table-test.gts.
//
// A `.gts`/`.gjs` filePath makes ember-template-lint look for a
// `<template>...</template>` tag to extract and early-exits with zero
// results if the source has none -- so, unlike every other test in this
// file (which lint raw .hbs source directly), these two wrap the markup in
// an actual `<template>` tag.

test('exempts the documented simple-table/index.gts standalone-wrapper shape by file path', async () => {
  assert.deepEqual(
    await lint(
      '<template><div data-part="wrapper"><table data-component="table" data-part="table"></table></div></template>',
      'packages/frontile/src/components/collections/simple-table/index.gts'
    ),
    []
  );
});

test('does not exempt the same shape in an unrelated file', async () => {
  assert.deepEqual(
    await lint(
      '<template><div data-part="wrapper"><table data-component="table" data-part="table"></table></div></template>',
      'packages/frontile/src/components/collections/table/table.gts'
    ),
    [MESSAGE]
  );
});
