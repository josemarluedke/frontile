import { module, test } from 'qunit';
import {
  parseKeys,
  setKbdPlatform,
  resolveKbdPlatform
} from 'frontile/utils/keys';

/**
 * The parser is the whole reason `Kbd` is more than a styled `<kbd>`: it turns
 * one authored string into per-key glyphs, human names, and a platform-correct
 * reading of `mod`.
 */
module('Unit | utils | keys', function (hooks) {
  hooks.afterEach(function () {
    setKbdPlatform('auto');
  });

  module('glyphs', function () {
    test('it resolves named keys to glyphs', function (assert) {
      setKbdPlatform('apple');

      assert.deepEqual(
        parseKeys('mod+shift+p').map((k) => k.glyph),
        ['⌘', '⇧', 'P'],
        'each token becomes its glyph, and a bare letter uppercases'
      );
    });

    test('it uppercases a single letter but leaves longer tokens alone', function (assert) {
      assert.strictEqual(parseKeys('k')[0]?.glyph, 'K');
      assert.strictEqual(
        parseKeys('F5')[0]?.glyph,
        'F5',
        'an unknown multi-character token renders verbatim'
      );
      assert.strictEqual(
        parseKeys('Ins')[0]?.glyph,
        'Ins',
        'casing of an unknown token is preserved'
      );
    });

    test('lookup is case-insensitive and tolerates surrounding space', function (assert) {
      setKbdPlatform('apple');

      assert.deepEqual(
        parseKeys('  MOD + Shift ').map((k) => k.glyph),
        ['⌘', '⇧']
      );
    });

    test('`plus` is the escape for a literal +', function (assert) {
      setKbdPlatform('other');

      assert.deepEqual(
        parseKeys('mod+plus').map((k) => k.glyph),
        ['Ctrl', '+'],
        'on a non-Apple platform mod reads as Ctrl'
      );
    });

    test('empty and whitespace-only input yields no keys', function (assert) {
      setKbdPlatform('other');

      assert.deepEqual(parseKeys(''), []);
      assert.deepEqual(parseKeys('   '), []);
      assert.deepEqual(parseKeys(undefined), []);
      assert.deepEqual(
        parseKeys('mod++k').map((k) => k.glyph),
        ['Ctrl', 'K'],
        'an empty token between separators is dropped rather than rendered'
      );
    });

    test('every alias resolves to the glyph and name of its canonical key', function (assert) {
      setKbdPlatform('apple');

      // One case per alias group, so a typo in the table is caught rather
      // than being covered only by the handful used elsewhere.
      const ALIASES: [string, string, string][] = [
        ['cmd', '⌘', 'Command'],
        ['command', '⌘', 'Command'],
        ['control', '⌃', 'Control'],
        ['option', '⌥', 'Option'],
        ['windows', '⊞', 'Windows'],
        ['fn', 'fn', 'Function'],
        ['return', '↵', 'Enter'],
        ['escape', 'Esc', 'Escape'],
        ['tab', '⇥', 'Tab'],
        ['spacebar', '␣', 'Space'],
        ['backspace', '⌫', 'Backspace'],
        ['delete', '⌦', 'Delete'],
        ['capslock', '⇪', 'Caps Lock'],
        ['arrowup', '↑', 'Arrow up'],
        ['arrowdown', '↓', 'Arrow down'],
        ['arrowleft', '←', 'Arrow left'],
        ['arrowright', '→', 'Arrow right'],
        ['pageup', '⇞', 'Page up'],
        ['pagedown', '⇟', 'Page down'],
        ['home', '↖', 'Home'],
        ['end', '↘', 'End']
      ];

      for (const [token, glyph, name] of ALIASES) {
        const key = parseKeys(token)[0];

        assert.strictEqual(key?.glyph, glyph, `${token} glyph`);
        assert.strictEqual(key?.name, name, `${token} name`);
      }
    });

    test('a string with no separator is a single verbatim key', function (assert) {
      // Listbox and Dropdown pass `@shortcut` strings like this today, so this
      // is the guarantee that adopting Kbd there changes nothing.
      const keys = parseKeys('⌘⇧S');

      assert.strictEqual(keys.length, 1);
      assert.strictEqual(keys[0]?.glyph, '⌘⇧S');
    });
  });

  module('platform', function () {
    test('mod, ctrl and alt differ by platform; meta does not', function (assert) {
      setKbdPlatform('apple');
      assert.deepEqual(
        parseKeys('mod+ctrl+alt+meta').map((k) => k.glyph),
        ['⌘', '⌃', '⌥', '⌘']
      );

      setKbdPlatform('other');
      assert.deepEqual(
        parseKeys('mod+ctrl+alt+meta').map((k) => k.glyph),
        ['Ctrl', 'Ctrl', 'Alt', '⌘'],
        'meta names a physical key, so it stays ⌘ everywhere'
      );
    });

    test('keys unaffected by platform resolve the same either way', function (assert) {
      setKbdPlatform('apple');
      const apple = parseKeys('shift+enter+esc').map((k) => k.glyph);

      setKbdPlatform('other');
      const other = parseKeys('shift+enter+esc').map((k) => k.glyph);

      assert.deepEqual(apple, other);
    });

    test('an explicit platform argument overrides the module setting', function (assert) {
      setKbdPlatform('other');

      assert.strictEqual(
        parseKeys('mod', 'apple')[0]?.glyph,
        '⌘',
        'the per-instance override wins'
      );
      assert.strictEqual(
        parseKeys('mod')[0]?.glyph,
        'Ctrl',
        'and does not leak into subsequent calls'
      );
    });

    test('resolveKbdPlatform reports a concrete platform, never "auto"', function (assert) {
      setKbdPlatform('auto');

      assert.ok(
        ['apple', 'other'].includes(resolveKbdPlatform()),
        'auto is resolved at read time so callers never see it'
      );
    });
  });

  module('accessibility metadata', function () {
    test('named keys carry a human name; literals do not', function (assert) {
      setKbdPlatform('apple');

      assert.strictEqual(parseKeys('mod')[0]?.name, 'Command');
      assert.strictEqual(parseKeys('esc')[0]?.name, 'Escape');
      assert.strictEqual(
        parseKeys('k')[0]?.name,
        undefined,
        'we have no name to offer for a literal character'
      );
    });

    test('mod names the key it actually resolves to', function (assert) {
      setKbdPlatform('other');

      assert.strictEqual(
        parseKeys('mod')[0]?.name,
        'Control',
        'announcing "Command" while showing Ctrl would be a lie'
      );
    });

    test('only non-alphanumeric glyphs need a spoken label', function (assert) {
      setKbdPlatform('apple');

      assert.true(
        parseKeys('mod')[0]?.needsSpokenLabel,
        '⌘ is meaningless to a screen reader'
      );
      assert.false(
        parseKeys('esc')[0]?.needsSpokenLabel,
        'Esc already reads correctly, so labelling it would say "Escape Escape"'
      );
      assert.false(parseKeys('k')[0]?.needsSpokenLabel);
    });
  });
});
