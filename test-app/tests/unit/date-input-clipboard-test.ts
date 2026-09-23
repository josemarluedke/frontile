import { module, test } from 'qunit';
import {
  buildParts,
  fromDate,
  isSegment,
  parsePasted,
  splitRange,
  applyDigit,
  commitSegment,
  formatForClipboard,
  resolveTwoDigitYear,
  toDate
} from 'frontile';
import type { Part, Segment } from 'frontile';

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
    // A lone `12` is *not* unparseable -- it is a partial paste that fills the
    // month, which the partial-paste module below covers. A digit run that
    // stops mid-segment is the real "no telling what was meant" case.
    assert.strictEqual(
      parsePasted('12345', buildParts('en-US')),
      null,
      'a digit run that does not end on a segment boundary is refused'
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

  test('a mid-entry, uncommitted year copies as typed rather than padded', function (assert) {
    // Typing "2" then "6" into a bare year: a two-digit buffer stays
    // uncommitted until focus leaves the segment, so this reproduces the
    // on-screen state `displaySegment` renders as "26".
    const parts = buildParts('en-US');
    const year = parts.find(
      (p): p is Segment => isSegment(p) && p.type === 'year'
    );
    if (!year) throw new Error('en-US always has a year segment');

    const { segment: afterFirstDigit } = applyDigit(year, '2');
    const { segment: afterSecondDigit } = applyDigit(afterFirstDigit, '6');

    assert.false(
      afterSecondDigit.isCommitted,
      'a two-digit year buffer has not committed yet'
    );
    assert.strictEqual(afterSecondDigit.buffer, '26');

    const withMidEntryYear = parts.map((p) =>
      isSegment(p) && p.type === 'year' ? afterSecondDigit : p
    );

    assert.strictEqual(
      formatForClipboard(withMidEntryYear),
      'mm/dd/26',
      'copies the digits actually typed, matching the on-screen display -- ' +
        'not "0026", which the old padStart(String(value)) implementation wrote'
    );
  });

  test('a committed year still copies padded to width', function (assert) {
    // Typing all four digits of "0026" is a finished answer for the year
    // 26 (as opposed to two digits, which run through the sliding window
    // instead) -- see segments.ts's `commitSegment` docstring.
    const parts = buildParts('en-US');
    const year = parts.find(
      (p): p is Segment => isSegment(p) && p.type === 'year'
    );
    if (!year) throw new Error('en-US always has a year segment');

    let typed = year;
    for (const digit of '0026') {
      typed = applyDigit(typed, digit).segment;
    }
    const committed = commitSegment(typed);

    assert.true(committed.isCommitted);
    assert.strictEqual(committed.value, 26);

    const withYear = parts.map((p) =>
      isSegment(p) && p.type === 'year' ? committed : p
    );

    assert.strictEqual(
      formatForClipboard(withYear),
      'mm/dd/0026',
      'a fully committed year of 26 reads as 0026, not the mid-entry "26"'
    );
  });
});

module('Unit | date-input clipboard | paste bounds and partials', function () {
  function segmentOf(parts: Part[] | null, type: string): Segment | undefined {
    return (
      parts?.find((p): p is Segment => isSegment(p) && p.type === type) ??
      undefined
    );
  }

  test('an ISO date out of bounds is refused, not rolled over', function (assert) {
    assert.strictEqual(
      parsePasted('2026-13-01', buildParts('en-US')),
      null,
      'month 13 is refused rather than becoming January 2027'
    );
    assert.strictEqual(
      parsePasted('2026-00-10', buildParts('en-US')),
      null,
      'month 0 is refused rather than becoming December 2025'
    );
  });

  test('an impossible ISO day clamps exactly as typing it does', function (assert) {
    // The spec puts the day clamp at compose time, so 31 is in bounds for the
    // segment and February shortens it -- it must not roll into March.
    assert.strictEqual(
      dateOf(parsePasted('2026-02-31', buildParts('en-US'))),
      '2026-2-28'
    );
  });

  test('a pasted four-digit year is taken literally', function (assert) {
    assert.strictEqual(
      segmentOf(parsePasted('12/25/0045', buildParts('en-US')), 'year')?.value,
      45,
      '0045 is the year 45, not 2045 -- same as typing it'
    );
  });

  test('a pasted two-digit year still runs through the window', function (assert) {
    assert.strictEqual(
      segmentOf(parsePasted('12/25/45', buildParts('en-US')), 'year')?.value,
      resolveTwoDigitYear('45')
    );
  });

  test('a partial paste fills what it can', function (assert) {
    const filled = parsePasted('12/25', buildParts('en-US'));

    assert.strictEqual(segmentOf(filled, 'month')?.value, 12);
    assert.strictEqual(segmentOf(filled, 'day')?.value, 25);
    assert.strictEqual(
      segmentOf(filled, 'year')?.value,
      null,
      'the segment it could not fill is left alone'
    );
    assert.strictEqual(
      dateOf(filled),
      null,
      'and an incomplete field composes no date'
    );
  });

  test('a partial paste that is out of bounds is still refused', function (assert) {
    assert.strictEqual(parsePasted('99/25', buildParts('en-US')), null);
  });

  test('more numbers than segments is refused', function (assert) {
    assert.strictEqual(parsePasted('12/25/2026/03', buildParts('en-US')), null);
  });
});

module('Unit | date-input clipboard | splitRange', function () {
  test('a two-date string is beyond what parsePasted can read', function (assert) {
    // The premise splitRange exists for: six digit groups is more than any
    // single-date format has segments, so parsePasted declines it outright
    // rather than filling a prefix.
    assert.strictEqual(
      parsePasted('2026-01-20 \u2013 2026-01-25', buildParts('en-US')),
      null
    );
  });

  test('splits on an en or em dash, spaces or not', function (assert) {
    assert.deepEqual(splitRange('2026-01-20 \u2013 2026-01-25'), [
      '2026-01-20',
      '2026-01-25'
    ]);
    assert.deepEqual(splitRange('2026-01-20\u20142026-01-25'), [
      '2026-01-20',
      '2026-01-25'
    ]);
  });

  test('splits on a spaced hyphen but never on an ISO one', function (assert) {
    assert.deepEqual(splitRange('01/20/2026 - 01/25/2026'), [
      '01/20/2026',
      '01/25/2026'
    ]);
    assert.strictEqual(
      splitRange('2026-01-20'),
      null,
      'a lone ISO date is one date, not a range'
    );
    assert.strictEqual(
      splitRange('2026-01'),
      null,
      'and so is one with a single hyphen in it, which the refusal above ' +
        'would otherwise get right only via the two-halves check'
    );
  });

  test('splits on the word "to"', function (assert) {
    assert.deepEqual(splitRange('01/20/2026 to 01/25/2026'), [
      '01/20/2026',
      '01/25/2026'
    ]);
    assert.strictEqual(
      splitRange('12/25/2026'),
      null,
      'and not on letters inside a word'
    );
  });

  test('refuses anything that is not exactly two halves', function (assert) {
    assert.strictEqual(splitRange(''), null);
    assert.strictEqual(splitRange('   '), null);
    assert.strictEqual(splitRange('\u2013 2026-01-25'), null, 'no start half');
    assert.strictEqual(splitRange('2026-01-20 \u2013'), null, 'no end half');
    assert.strictEqual(
      splitRange('01/01 \u2013 01/02 \u2013 01/03'),
      null,
      'three halves is not a range'
    );
  });

  test('each half is then a date parsePasted can read', function (assert) {
    const halves = splitRange('2026-01-20 \u2013 2026-01-25');
    assert.ok(halves);
    assert.strictEqual(
      dateOf(parsePasted(halves![0], buildParts('en-US'))),
      '2026-1-20'
    );
    assert.strictEqual(
      dateOf(parsePasted(halves![1], buildParts('en-US'))),
      '2026-1-25'
    );
  });
});
