import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, mkdirSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { checkAnatomy } from '../check-anatomy.mjs';

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
