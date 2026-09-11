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

// --- MANUAL_PART_OWNERS: the tooltip/popover-arrow escape hatch -------------
//
// `MANUAL_PART_OWNERS` hard-codes exactly one entry today: the `arrow` part
// physically rendered in `overlays/popover.gts` belongs to the `tooltip`
// config, not to `popover` (which has no data-component of its own) and not
// to whatever the directory-walk-up fallback would guess. These tests drive
// `readRenderedParts`/`checkAnatomy` against a real `overlays/popover.gts`
// path (the map key is a path suffix) to prove the mechanism attributes
// exactly the named part to the named owner -- not every part in that file,
// and not by disabling the missing/orphan checks for `tooltip` generally.

test('MANUAL_PART_OWNERS attributes only the mapped part to the mapped owner, not other parts in the same file', () => {
  const { componentsDir } = bareRoot();
  mkdirSync(join(componentsDir, 'overlays'), { recursive: true });
  writeFileSync(
    join(componentsDir, 'overlays', 'popover.gts'),
    `<span data-part="arrow"></span>
     <span data-part="sparkle"></span>`
  );

  const rendered = readRenderedParts(componentsDir, new Set(['tooltip']));

  // The mapped part lands on the mapped owner.
  assert.deepEqual([...rendered.tooltip.parts], ['arrow']);
  // A second, unmapped part in the very same file is not swept in too --
  // it has no data-component, its directory ("overlays") doesn't kebab-match
  // any known config, and it isn't in MANUAL_PART_OWNERS, so it must be left
  // unattributed rather than silently folded into "tooltip" or any other
  // config.
  assert.ok(
    !rendered.sparkle,
    'an unmapped part must not be attributed to a config named after itself'
  );
  for (const [name, entry] of Object.entries(rendered)) {
    assert.ok(
      !entry.parts.has('sparkle'),
      `"sparkle" must not be attributed to "${name}"`
    );
  }
});

test('MANUAL_PART_OWNERS makes checkAnatomy report zero missing/orphan for tooltip when the arrow is rendered only in popover.gts', () => {
  const { themeDir, componentsDir } = bareRoot();
  writeFileSync(
    join(themeDir, 'tooltip.ts'),
    `const tooltip = tv({
  slots: {
    base: '',
    arrow: ''
  }
});
`
  );
  writeFileSync(
    join(componentsDir, 'tooltip.gts'),
    '<div data-component="tooltip" data-part="base"></div>'
  );
  mkdirSync(join(componentsDir, 'overlays'), { recursive: true });
  writeFileSync(
    join(componentsDir, 'overlays', 'popover.gts'),
    '<span data-part="arrow"></span>'
  );

  const r = checkAnatomy({ themeDir, componentsDir });
  assert.deepEqual(
    r.missing.filter((m) => m.config === 'tooltip'),
    []
  );
  assert.deepEqual(
    r.orphan.filter((o) => o.config === 'tooltip'),
    []
  );
});

test('MANUAL_PART_OWNERS does not blanket-exempt tooltip: a genuinely unrendered tooltip slot is still reported missing', () => {
  const { themeDir, componentsDir } = bareRoot();
  writeFileSync(
    join(themeDir, 'tooltip.ts'),
    `const tooltip = tv({
  slots: {
    base: '',
    arrow: '',
    glow: ''
  }
});
`
  );
  writeFileSync(
    join(componentsDir, 'tooltip.gts'),
    '<div data-component="tooltip" data-part="base"></div>'
  );
  mkdirSync(join(componentsDir, 'overlays'), { recursive: true });
  writeFileSync(
    join(componentsDir, 'overlays', 'popover.gts'),
    '<span data-part="arrow"></span>'
  );

  // "glow" is a real slot on the tooltip config but is never rendered
  // anywhere -- the manual-owner map for "arrow" must not paper over it.
  const r = checkAnatomy({ themeDir, componentsDir });
  assert.deepEqual(
    r.missing.filter((m) => m.config === 'tooltip'),
    [{ config: 'tooltip', slot: 'glow' }]
  );
});

test('MANUAL_PART_OWNERS does not silently swallow a genuine orphan: a mapped part that names no real slot is still reported', () => {
  const { themeDir, componentsDir } = bareRoot();
  // tooltip's config here has no "arrow" slot at all -- MANUAL_PART_OWNERS
  // still attributes popover.gts's "arrow" data-part to tooltip, so it must
  // surface as an orphan rather than being dropped because the attribution
  // came from the manual-owner escape hatch instead of a normal same-file
  // data-component.
  writeFileSync(
    join(themeDir, 'tooltip.ts'),
    `const tooltip = tv({
  slots: {
    base: ''
  }
});
`
  );
  writeFileSync(
    join(componentsDir, 'tooltip.gts'),
    '<div data-component="tooltip" data-part="base"></div>'
  );
  mkdirSync(join(componentsDir, 'overlays'), { recursive: true });
  writeFileSync(
    join(componentsDir, 'overlays', 'popover.gts'),
    '<span data-part="arrow"></span>'
  );

  const r = checkAnatomy({ themeDir, componentsDir });
  assert.equal(
    r.orphan.filter((o) => o.config === 'tooltip' && o.part === 'arrow').length,
    1
  );
});

// --- Implicit `base` for slotless configs -----------------------------------

test('a slotless config requires only a base part', () => {
  const { themeDir, componentsDir } = fixture(
    `const divider = tv({ base: 'h-px' });`,
    `<hr data-component="divider" data-part="base" />`
  );
  const r = checkAnatomy({ themeDir, componentsDir });
  assert.deepEqual(r.missing, []);
  assert.deepEqual(r.orphan, []);
});

// --- Finding 2: orphan.file must cite the file the orphan actually occurred in

test('orphan.file cites the file the orphan data-part actually occurred in, not the first file ever seen for that component (Finding 2)', () => {
  const { themeDir, componentsDir } = bareRoot();
  writeFileSync(
    join(themeDir, 'kbd.ts'),
    `const kbd = tv({
  slots: {
    base: ''
  }
});
`
  );
  // "first.gts" is walked first (alphabetically) and establishes the
  // "kbd" bucket via its data-component, with no data-part of its own.
  // "second.gts" is walked afterwards and is where the actual orphan
  // data-part lives. Before the fix, orphan.file was
  // `[...entry.files][0]` -- the first file *ever* added to the bucket
  // (first.gts) -- rather than the file the orphan was found in
  // (second.gts).
  writeFileSync(
    join(componentsDir, 'first.gts'),
    '<div data-component="kbd"></div>'
  );
  writeFileSync(
    join(componentsDir, 'second.gts'),
    '<div data-component="kbd" data-part="base"><i data-part="stray"></i></div>'
  );

  const r = checkAnatomy({ themeDir, componentsDir });
  const orphan = r.orphan.find(
    (o) => o.config === 'kbd' && o.part === 'stray'
  );
  assert.ok(orphan, 'expected a "stray" orphan for kbd');
  assert.ok(
    orphan.file.endsWith('second.gts'),
    `expected orphan.file to point at second.gts (where "stray" was found), got ${orphan.file}`
  );
});
