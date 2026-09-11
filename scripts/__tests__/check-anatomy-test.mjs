import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, mkdirSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import {
  checkAnatomy,
  readThemeSlots,
  readRenderedParts
} from '../check-anatomy.mjs';

function fixture(themeSrc, gtsSrc) {
  const root = mkdtempSync(join(tmpdir(), 'anatomy-'));
  const themeDir = join(root, 'theme');
  const componentsDir = join(root, 'components');
  mkdirSync(themeDir, { recursive: true });
  mkdirSync(componentsDir, { recursive: true });
  writeFileSync(join(themeDir, 'accordion.ts'), themeSrc);
  writeFileSync(join(componentsDir, 'accordion.gts'), gtsSrc);
  return { themeDir, componentsDir };
}

/** A bare temp root with just empty theme/components dirs, for tests that
 * write their own arbitrary directory layout. */
function bareRoot() {
  const root = mkdtempSync(join(tmpdir(), 'anatomy-'));
  const themeDir = join(root, 'theme');
  const componentsDir = join(root, 'components');
  mkdirSync(themeDir, { recursive: true });
  mkdirSync(componentsDir, { recursive: true });
  return { root, themeDir, componentsDir };
}

const THEME = `const accordion = tv({
  slots: {
    base: '',
    trigger: '',
    startContent: ''
  }
});`;

test('passes when every slot is rendered and every part is a slot', () => {
  const r = checkAnatomy(
    fixture(
      THEME,
      `<div data-component="accordion" data-part="base">
       <button data-part="trigger"></button>
       <span data-part="start-content"></span>
     </div>`
    )
  );
  assert.deepEqual(r.missing, []);
  assert.deepEqual(r.orphan, []);
});

test('reports a slot that is never rendered', () => {
  const r = checkAnatomy(
    fixture(
      THEME,
      `<div data-component="accordion" data-part="base">
       <button data-part="trigger"></button>
     </div>`
    )
  );
  assert.deepEqual(r.missing, [{ config: 'accordion', slot: 'start-content' }]);
});

test('reports a part that is not a slot', () => {
  const r = checkAnatomy(
    fixture(
      THEME,
      `<div data-component="accordion" data-part="base">
       <button data-part="trigger"></button>
       <span data-part="start-content"></span>
       <i data-part="sparkle"></i>
     </div>`
    )
  );
  assert.equal(r.orphan.length, 1);
  assert.equal(r.orphan[0].part, 'sparkle');
});

test('ignores forms-legacy', () => {
  const { themeDir, componentsDir } = fixture(
    THEME,
    '<div data-component="accordion" data-part="base"></div>'
  );
  writeFileSync(
    join(themeDir, 'forms-legacy.ts'),
    `const legacy = tv({ slots: { base: '', ghost: '' } });`
  );
  const r = checkAnatomy({ themeDir, componentsDir });
  assert.ok(!r.missing.some((m) => m.config === 'legacy'));
});

// --- Finding 1: extend-chain resolution -------------------------------------

test('a config that extends a slotted base with no own slots: key is discovered and checked (Finding 1)', () => {
  const { themeDir, componentsDir } = bareRoot();
  writeFileSync(
    join(themeDir, 'radio.ts'),
    `const checkboxRadioGroupBase = tv({
  slots: {
    base: '',
    optionsContainer: '',
    label: ''
  }
});

const radioGroup = tv({
  extend: checkboxRadioGroupBase
});
`
  );
  writeFileSync(
    join(componentsDir, 'radio-group.gts'),
    `<div data-component="radio-group" data-part="base">
       <div data-part="options-container"></div>
       <label data-part="label"></label>
     </div>`
  );

  const slots = readThemeSlots(themeDir);
  // The config must be discovered at all (this is exactly what Finding 1's
  // `if (entry.ownSlots === null) continue` dropped) ...
  assert.ok('radioGroup' in slots, 'radioGroup must be discovered');
  // ... and must carry the full set of slots resolved from its base, not an
  // empty list.
  assert.deepEqual(
    [...slots.radioGroup].sort(),
    ['base', 'label', 'options-container'].sort()
  );

  const r = checkAnatomy({ themeDir, componentsDir });
  assert.deepEqual(
    r.missing.filter((m) => m.config === 'radio-group'),
    []
  );
  assert.deepEqual(
    r.orphan.filter((o) => o.config === 'radio-group'),
    []
  );
});

test('a config that extends a slotted base and adds its own slots resolves to the union with no duplicates', () => {
  const { themeDir, componentsDir } = bareRoot();
  writeFileSync(
    join(themeDir, 'checkbox.ts'),
    `const checkboxRadioBase = tv({
  slots: {
    base: '',
    labelContainer: '',
    label: ''
  }
});

const checkbox = tv({
  extend: checkboxRadioBase,
  slots: {
    input: '',
    label: ''
  }
});
`
  );
  writeFileSync(join(componentsDir, 'checkbox.gts'), '<div></div>');

  const slots = readThemeSlots(themeDir);
  assert.deepEqual(
    [...slots.checkbox].sort(),
    ['base', 'input', 'label', 'label-container'].sort()
  );
  // No duplicate 'label' even though both base and child declare it.
  assert.equal(slots.checkbox.filter((s) => s === 'label').length, 1);
});

// --- comment-aware brace matching -------------------------------------------

test('a slots block parsed from a file whose comments contain an apostrophe does not leak variants keys as slots', () => {
  const { themeDir, componentsDir } = bareRoot();
  writeFileSync(
    join(themeDir, 'table.ts'),
    `const table = tv({
  slots: {
    base: '',
    // a comment mentioning a column's skeleton preset, with an unbalanced
    // apostrophe that must not desync the brace/quote scanner
    skeleton: ''
  },
  variants: {
    size: {
      sm: '',
      md: ''
    },
    isLoading: {
      true: '',
      false: ''
    }
  }
});
`
  );
  writeFileSync(join(componentsDir, 'table.gts'), '<div></div>');

  const slots = readThemeSlots(themeDir);
  assert.deepEqual([...slots.table].sort(), ['base', 'skeleton'].sort());
  // The variant keys/values must never leak in as fake slots.
  for (const leaked of ['size', 'sm', 'md', 'is-loading', 'true', 'false']) {
    assert.ok(
      !slots.table.includes(leaked),
      `variant key "${leaked}" must not appear in resolved slots`
    );
  }
});

// --- attribution: nearest-preceding data-component --------------------------

test('nearest-preceding-data-component attributes each part to whichever root opened before it', () => {
  const { componentsDir } = bareRoot();
  writeFileSync(
    join(componentsDir, 'two-roots.gts'),
    `<div data-component="foo" data-part="base"></div>
     <div data-component="bar" data-part="base">
       <span data-part="label"></span>
     </div>`
  );

  const rendered = readRenderedParts(componentsDir, new Set(['foo', 'bar']));
  assert.deepEqual([...rendered.foo.parts].sort(), ['base']);
  assert.deepEqual([...rendered.bar.parts].sort(), ['base', 'label']);
});

// --- attribution: directory walk-up fallback --------------------------------

test('a sub-template with parts but no data-component of its own is attributed via directory walk-up', () => {
  const { componentsDir } = bareRoot();
  mkdirSync(join(componentsDir, 'modal'), { recursive: true });
  writeFileSync(
    join(componentsDir, 'modal.gts'),
    '<div data-component="modal" data-part="base"></div>'
  );
  writeFileSync(
    join(componentsDir, 'modal', 'body.gts'),
    '<div data-part="body"></div>'
  );

  const rendered = readRenderedParts(componentsDir, new Set(['modal']));
  assert.deepEqual([...rendered.modal.parts].sort(), ['base', 'body']);
});

// --- KNOWN_UNRENDERED_SLOTS exception ---------------------------------------

test('textarea does not report its inherited-but-unrendered input/start-content/end-content slots as missing', () => {
  const { themeDir, componentsDir } = bareRoot();
  writeFileSync(
    join(themeDir, 'textarea.ts'),
    `const input = tv({
  slots: {
    base: '',
    innerContainer: '',
    startContent: '',
    endContent: '',
    input: ''
  }
});

const textarea = tv({
  extend: input
});
`
  );
  // Textarea only ever renders 'base' (via FormControl) and 'input' (the
  // <textarea> tag) -- it deliberately has no wrapper or start/end-content
  // elements, unlike Input which it extends.
  writeFileSync(
    join(componentsDir, 'textarea.gts'),
    `<div data-component="textarea" data-part="base">
       <textarea data-part="input"></textarea>
     </div>`
  );

  const r = checkAnatomy({ themeDir, componentsDir });
  assert.deepEqual(
    r.missing.filter((m) => m.config === 'textarea'),
    [],
    'inner-container/start-content/end-content must be excused, not reported as missing'
  );
  assert.deepEqual(
    r.orphan.filter((o) => o.config === 'textarea'),
    []
  );
});

test('a sub-template whose owner cannot be inferred is left unattributed rather than guessed at', () => {
  const { componentsDir } = bareRoot();
  mkdirSync(join(componentsDir, 'mystery'), { recursive: true });
  writeFileSync(
    join(componentsDir, 'mystery', 'fragment.gts'),
    '<div data-part="orphaned"></div>'
  );

  const rendered = readRenderedParts(componentsDir, new Set(['modal']));
  assert.ok(!rendered.mystery);
});
