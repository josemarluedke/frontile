import { module, test } from 'qunit';
import {
  buildParts,
  fromDate,
  isSegment,
  parsePasted,
  formatForClipboard,
  resolveTwoDigitYear,
  toDate
} from 'frontile';
import type { Part } from 'frontile';

function dateOf(parts: Part[] | null): string | null {
  const d = parts && toDate(parts);
  return d ? `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()}` : null;
}

module('Unit | date-input clipboard | parsePasted', function () {
  test('an ISO date wins regardless of the locale order', function (assert) {
    assert.strictEqual(
      dateOf(parsePasted('2026-01-20', buildParts('en-US'))),
      '2026-1-20'
    );
    assert.strictEqual(
      dateOf(parsePasted('2026-01-20', buildParts('en-GB'))),
      '2026-1-20',
      'not read as day 2026'
    );
  });

  test('a locale-shaped date maps onto the locale segment order', function (assert) {
    assert.strictEqual(
      dateOf(parsePasted('12/25/2026', buildParts('en-US'))),
      '2026-12-25'
    );
    assert.strictEqual(
      dateOf(parsePasted('25/12/2026', buildParts('en-GB'))),
      '2026-12-25'
    );
    assert.strictEqual(
      dateOf(parsePasted('25.12.2026', buildParts('de-DE'))),
      '2026-12-25'
    );
  });

  test('a bare digit run is split by segment width', function (assert) {
    assert.strictEqual(
      dateOf(parsePasted('12252026', buildParts('en-US'))),
      '2026-12-25'
    );
    assert.strictEqual(
      dateOf(parsePasted('25122026', buildParts('en-GB'))),
      '2026-12-25'
    );
  });

  test('a two-digit year resolves through the hundred-year window', function (assert) {
    const parsed = parsePasted('12/25/26', buildParts('en-US'));
    const year = parsed?.filter(isSegment).find((s) => s.type === 'year');
    // Pin the actual expected year from the window rule itself, rather than
    // a self-referential comparison that degenerates to `year?.value ===
    // year?.value` once the current year drops below 2026.
    assert.strictEqual(year?.value, resolveTwoDigitYear('26'));
    assert.strictEqual(
      String(year?.value).length,
      4,
      'expanded, not left as 26'
    );
  });

  test('surrounding whitespace is tolerated', function (assert) {
    assert.strictEqual(
      dateOf(parsePasted('  2026-01-20\n', buildParts('en-US'))),
      '2026-1-20'
    );
  });

  test('unparseable text yields null rather than a guess', function (assert) {
    assert.strictEqual(parsePasted('next tuesday', buildParts('en-US')), null);
    assert.strictEqual(parsePasted('', buildParts('en-US')), null);
    assert.strictEqual(
      parsePasted('12', buildParts('en-US')),
      null,
      'one number is not a date'
    );
    assert.strictEqual(
      parsePasted('99/99/2026', buildParts('en-US')),
      null,
      'out of bounds is not clamped into something plausible'
    );
  });
});

module('Unit | date-input clipboard | formatForClipboard', function () {
  test('writes the displayed string, literals included', function (assert) {
    const parts = fromDate(buildParts('en-US'), new Date(2026, 0, 20));
    assert.strictEqual(formatForClipboard(parts), '01/20/2026');

    const gb = fromDate(buildParts('en-GB'), new Date(2026, 0, 20));
    assert.strictEqual(formatForClipboard(gb), '20/01/2026');
  });

  test('round-trips through parsePasted', function (assert) {
    const parts = fromDate(buildParts('en-GB'), new Date(2026, 11, 25));
    const text = formatForClipboard(parts);
    assert.strictEqual(
      dateOf(parsePasted(text, buildParts('en-GB'))),
      '2026-12-25'
    );
  });

  test('an empty field copies its placeholders', function (assert) {
    assert.strictEqual(formatForClipboard(buildParts('en-US')), 'mm/dd/yyyy');
  });
});
