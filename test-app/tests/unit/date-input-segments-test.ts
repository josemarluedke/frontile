import { module, test } from 'qunit';
import {
  buildParts,
  isSegment,
  applyDigit,
  commitSegment,
  step,
  clearSegment,
  deleteDigit,
  toDate,
  fromDate,
  emptySegment,
  resolveTwoDigitYear,
  carryOver,
  toNumericFormat,
  hasTextualMonth
} from 'frontile';
import type { Part, Segment } from 'frontile';

/** The segment types in order, ignoring literals. */
function order(parts: Part[]): string[] {
  return parts.filter(isSegment).map((p) => (p as Segment).type);
}

/** The literal texts, in order. */
function literals(parts: Part[]): string[] {
  return parts
    .filter((p) => !isSegment(p))
    .map((p) => (p as { text: string }).text);
}

module('Unit | date-input segments | buildParts', function () {
  test('derives segment order from the locale', function (assert) {
    assert.deepEqual(order(buildParts('en-US')), ['month', 'day', 'year']);
    assert.deepEqual(order(buildParts('en-GB')), ['day', 'month', 'year']);
    assert.deepEqual(order(buildParts('ja-JP')), ['year', 'month', 'day']);
  });

  test('takes literals from the locale rather than hardcoding a slash', function (assert) {
    assert.deepEqual(literals(buildParts('en-US')), ['/', '/']);
    assert.deepEqual(literals(buildParts('de-DE')), ['.', '.']);
  });

  test('segments start empty, with bounds and a placeholder', function (assert) {
    const parts = buildParts('en-US');
    const month = parts.filter(isSegment)[0] as Segment;

    assert.strictEqual(month.type, 'month');
    assert.strictEqual(month.value, null, 'no value until the user types one');
    assert.strictEqual(month.buffer, '', 'no digits typed yet');
    assert.strictEqual(month.min, 1);
    assert.strictEqual(month.max, 12);
    assert.strictEqual(month.placeholder, 'mm');
  });

  test('year bounds and placeholder', function (assert) {
    const year = buildParts('en-US').filter(isSegment)[2] as Segment;

    assert.strictEqual(year.type, 'year');
    assert.strictEqual(year.min, 1);
    assert.strictEqual(year.max, 9999);
    assert.strictEqual(year.placeholder, 'yyyy');
  });

  test('a textual month falls back to a numeric segment', function (assert) {
    // `dateStyle: 'medium'` is DatePicker's current default and yields
    // "Jan 20, 2026" -- a month with no editable numeric representation.
    const parts = buildParts('en-US', { dateStyle: 'medium' });

    assert.deepEqual(order(parts), ['month', 'day', 'year']);
    const month = parts.filter(isSegment)[0] as Segment;
    assert.strictEqual(month.max, 12, 'numeric month, not a name list');
  });
});

module('Unit | date-input segments | applyDigit', function () {
  test('a first digit that cannot be extended commits immediately', function (assert) {
    // 5 in a month can only ever be May: no second digit makes 5X <= 12.
    const { segment, isFull } = applyDigit(emptySegment('month'), '5');
    assert.strictEqual(segment.value, 5);
    assert.true(isFull, 'focus should advance');
    assert.true(segment.isCommitted, 'and the value is final');
  });

  test('a first digit that could be extended waits', function (assert) {
    // 1 in a month might still become 10, 11 or 12.
    const { segment, isFull } = applyDigit(emptySegment('month'), '1');
    assert.strictEqual(segment.value, 1);
    assert.strictEqual(segment.buffer, '1');
    assert.false(isFull, 'focus stays put for a possible second digit');
    assert.false(segment.isCommitted, 'and 1 is not yet the answer');
  });

  test('a second digit completes the segment', function (assert) {
    const first = applyDigit(emptySegment('month'), '1').segment;
    const { segment, isFull } = applyDigit(first, '2');
    assert.strictEqual(segment.value, 12);
    assert.true(isFull);
  });

  test('a second digit that would overflow starts the segment over', function (assert) {
    // 1 then 5 cannot be 15, so the 5 begins a fresh month of May.
    const first = applyDigit(emptySegment('month'), '1').segment;
    const { segment, isFull } = applyDigit(first, '5');
    assert.strictEqual(segment.value, 5);
    assert.true(isFull);
  });

  test('a leading zero is held rather than committed', function (assert) {
    const { segment, isFull } = applyDigit(emptySegment('month'), '0');
    assert.strictEqual(segment.buffer, '0');
    assert.strictEqual(segment.value, null, '0 is not a valid month');
    assert.false(isFull);

    const second = applyDigit(segment, '9');
    assert.strictEqual(second.segment.value, 9);
    assert.true(second.isFull);
  });

  test('a year accumulates four digits before it is full', function (assert) {
    let seg = emptySegment('year');
    for (const d of ['2', '0', '2']) {
      const r = applyDigit(seg, d);
      seg = r.segment;
      assert.false(r.isFull, `${seg.buffer} is still incomplete`);
      assert.false(
        seg.isCommitted,
        `${seg.buffer} is mid-entry, not an answer`
      );
    }
    const last = applyDigit(seg, '6');
    assert.strictEqual(last.segment.value, 2026);
    assert.true(last.isFull);
    assert.true(last.segment.isCommitted, 'a full segment commits itself');
  });

  test('a partial year is its literal number, not a windowed one', function (assert) {
    // The window belongs to commitSegment. Applying it per keystroke would
    // make the first digit of 2026 compose the year 2002.
    const { segment } = applyDigit(emptySegment('year'), '2');
    assert.strictEqual(segment.value, 2, 'the literal 2, not 2002');
    assert.false(segment.isCommitted);
  });

  test('the buffer never outgrows the segment', function (assert) {
    // 0 then 0 is a held '00', and neither overflows a month's bound -- so
    // without a width check the next digit makes '001', which padStart cannot
    // trim back to two characters and the segment would render three wide.
    let seg = applyDigit(emptySegment('month'), '0').segment;
    seg = applyDigit(seg, '0').segment;
    assert.strictEqual(seg.buffer, '00');

    const third = applyDigit(seg, '1');
    assert.strictEqual(
      third.segment.buffer,
      '1',
      'the third digit starts over'
    );
    assert.strictEqual(third.segment.value, 1, 'January');
  });

  test('non-digits are ignored', function (assert) {
    const { segment } = applyDigit(emptySegment('day'), 'x');
    assert.strictEqual(segment.buffer, '');
    assert.strictEqual(segment.value, null);
  });
});

module('Unit | date-input segments | step', function () {
  const placeholder = new Date(2026, 8, 22);

  test('increments and decrements', function (assert) {
    const march = { ...emptySegment('month'), value: 3, buffer: '03' };
    assert.strictEqual(step(march, 1, placeholder).value, 4);
    assert.strictEqual(step(march, -1, placeholder).value, 2);
  });

  test('wraps at the segment bounds', function (assert) {
    const december = { ...emptySegment('month'), value: 12, buffer: '12' };
    assert.strictEqual(
      step(december, 1, placeholder).value,
      1,
      'December wraps to January'
    );

    const january = { ...emptySegment('month'), value: 1, buffer: '01' };
    assert.strictEqual(step(january, -1, placeholder).value, 12);
  });

  test('an empty segment seeds from the placeholder value', function (assert) {
    assert.strictEqual(
      step(emptySegment('month'), 1, placeholder).value,
      9,
      'September'
    );
    assert.strictEqual(step(emptySegment('day'), 1, placeholder).value, 22);
    assert.strictEqual(step(emptySegment('year'), 1, placeholder).value, 2026);
  });

  test('a page step moves further', function (assert) {
    const day = { ...emptySegment('day'), value: 10, buffer: '10' };
    assert.strictEqual(step(day, 7, placeholder).value, 17);

    const year = { ...emptySegment('year'), value: 2026, buffer: '2026' };
    assert.strictEqual(step(year, 10, placeholder).value, 2036);
  });

  test('a stepped segment is a finished answer', function (assert) {
    // Arrow keys alone must compose a date: nothing else commits them, and
    // an uncommitted segment composes nothing.
    const march = { ...emptySegment('month'), value: 3, buffer: '03' };
    assert.true(step(march, 1, placeholder).isCommitted);
    assert.true(
      step(emptySegment('year'), 1, placeholder).isCommitted,
      'including one seeded from the placeholder'
    );
  });

  test('the buffer follows the stepped value so Backspace stays coherent', function (assert) {
    const march = { ...emptySegment('month'), value: 3, buffer: '03' };
    assert.strictEqual(step(march, 1, placeholder).buffer, '04');
  });
});

module('Unit | date-input segments | clearing', function () {
  test('clearSegment empties value and buffer', function (assert) {
    const filled = { ...emptySegment('day'), value: 20, buffer: '20' };
    const cleared = clearSegment(filled);
    assert.strictEqual(cleared.value, null);
    assert.strictEqual(cleared.buffer, '');
  });

  test('clearSegment leaves nothing committed', function (assert) {
    const filled = {
      ...emptySegment('day'),
      value: 20,
      buffer: '20',
      isCommitted: true
    };
    assert.false(clearSegment(filled).isCommitted);
  });

  test('deleteDigit drops the last digit typed', function (assert) {
    const year = {
      ...emptySegment('year'),
      value: 2026,
      buffer: '2026',
      isCommitted: true
    };
    const once = deleteDigit(year);
    assert.strictEqual(once.buffer, '202');
    assert.strictEqual(once.value, 202, 'the literal remaining digits');
    assert.false(
      once.isCommitted,
      'a year being backspaced through is being typed again'
    );

    const empty = deleteDigit({
      ...emptySegment('day'),
      value: 5,
      buffer: '5'
    });
    assert.strictEqual(empty.buffer, '');
    assert.strictEqual(empty.value, null);
  });
});

module('Unit | date-input segments | commitSegment', function () {
  test('a two-digit year expands through the window', function (assert) {
    const typed = applyDigit(
      applyDigit(emptySegment('year'), '2').segment,
      '6'
    ).segment;
    assert.strictEqual(typed.value, 26, 'the literal 26 while it is typed');

    const committed = commitSegment(typed);
    assert.strictEqual(
      committed.value,
      resolveTwoDigitYear('26'),
      'and 2026 once the user is done with it'
    );
    assert.strictEqual(committed.buffer, '2026', 'the buffer follows');
    assert.true(committed.isCommitted);
  });

  test('a four-digit year is taken as written', function (assert) {
    const year = {
      ...emptySegment('year'),
      value: 26,
      buffer: '0026',
      isCommitted: false
    };
    assert.strictEqual(
      commitSegment(year).value,
      26,
      'spelled out in full, the year 26 is the year 26'
    );
  });

  test('a three-digit year is taken as written', function (assert) {
    const year = {
      ...emptySegment('year'),
      value: 202,
      buffer: '202',
      isCommitted: false
    };
    assert.strictEqual(commitSegment(year).value, 202);
    assert.true(commitSegment(year).isCommitted);
  });

  test('an empty segment stays empty and uncommitted', function (assert) {
    const empty = emptySegment('year');
    const committed = commitSegment(empty);
    assert.strictEqual(committed.value, null);
    assert.false(
      committed.isCommitted,
      'leaving a blank field invents nothing'
    );
  });

  test('a non-year segment only flips the flag', function (assert) {
    const month = applyDigit(emptySegment('month'), '1').segment;
    const committed = commitSegment(month);
    assert.strictEqual(committed.value, 1, 'January, unchanged');
    assert.strictEqual(committed.buffer, '1');
    assert.true(committed.isCommitted);
  });
});

module('Unit | date-input segments | toDate and fromDate', function () {
  function filled(locale = 'en-US'): Part[] {
    return fromDate(buildParts(locale), new Date(2026, 0, 20));
  }

  test('fromDate fills every segment', function (assert) {
    const parts = filled();
    const [month, day, year] = parts.filter(isSegment) as Segment[];
    assert.strictEqual(month!.value, 1);
    assert.strictEqual(day!.value, 20);
    assert.strictEqual(year!.value, 2026);
    assert.strictEqual(
      month!.buffer,
      '01',
      'buffer is padded to the segment width'
    );
  });

  test('fromDate commits every segment it fills', function (assert) {
    assert.true(
      filled()
        .filter(isSegment)
        .every((s) => (s as Segment).isCommitted),
      'a value handed in is nobody mid-keystroke'
    );
  });

  test('fromDate with null empties every segment', function (assert) {
    const parts = fromDate(filled(), null);
    assert.true(
      parts.filter(isSegment).every((s) => (s as Segment).value === null)
    );
  });

  test('toDate round-trips', function (assert) {
    const date = toDate(filled());
    assert.strictEqual(date?.getFullYear(), 2026);
    assert.strictEqual(date?.getMonth(), 0, 'January, not off by one');
    assert.strictEqual(date?.getDate(), 20);
    assert.strictEqual(
      date?.getHours(),
      0,
      'local midnight, like toWire expects'
    );
  });

  test('toDate returns null while any segment is empty', function (assert) {
    const parts = buildParts('en-US');
    assert.strictEqual(toDate(parts), null);

    const partial = fromDate(buildParts('en-US'), new Date(2026, 0, 20));
    const cleared = partial.map((p) =>
      isSegment(p) && p.type === 'day' ? clearSegment(p) : p
    );
    assert.strictEqual(toDate(cleared), null, 'two of three is still nothing');
  });

  test('toDate returns null while any segment is mid-entry', function (assert) {
    const parts = fromDate(buildParts('en-US'), new Date(2026, 0, 20));
    // The year as it stands one keystroke into being retyped.
    const typing = parts.map((p) =>
      isSegment(p) && p.type === 'year'
        ? { ...p, value: 2, buffer: '2', isCommitted: false }
        : p
    );

    assert.strictEqual(
      toDate(typing),
      null,
      'half a year composes no date at all'
    );
  });

  test('the day clamps to the length of the chosen month', function (assert) {
    const parts = fromDate(buildParts('en-US'), new Date(2026, 0, 31));
    const toFeb = parts.map((p) =>
      isSegment(p) && p.type === 'month' ? { ...p, value: 2, buffer: '02' } : p
    );

    const date = toDate(toFeb);
    assert.strictEqual(date?.getMonth(), 1, 'stays in February');
    assert.strictEqual(date?.getDate(), 28, '2026 is not a leap year');
  });

  test('February 29 survives in a leap year', function (assert) {
    const parts = fromDate(buildParts('en-US'), new Date(2024, 1, 29));
    assert.strictEqual(toDate(parts)?.getDate(), 29);
  });
});

module('Unit | date-input segments | two-digit years', function () {
  const now = new Date(2026, 8, 22);

  test('maps into the window from 80 years back to 19 forward', function (assert) {
    assert.strictEqual(resolveTwoDigitYear('26', now), 2026);
    assert.strictEqual(
      resolveTwoDigitYear('45', now),
      2045,
      '2045 -- the last year in the window'
    );
    assert.strictEqual(resolveTwoDigitYear('00', now), 2000);
    assert.strictEqual(
      resolveTwoDigitYear('46', now),
      1946,
      '1946 -- the first year in the window'
    );
    assert.strictEqual(
      resolveTwoDigitYear('47', now),
      1947,
      '1947, just inside the window on the low side'
    );
  });

  test('the window boundaries resolve to themselves', function (assert) {
    const currentYear = now.getFullYear();
    const lowYear = currentYear - 80;
    const highYear = currentYear + 19;

    assert.strictEqual(
      resolveTwoDigitYear(String(lowYear).slice(-2), now),
      lowYear,
      'the two-digit form of the low bound resolves to the low bound itself'
    );
    assert.strictEqual(
      resolveTwoDigitYear(String(highYear).slice(-2), now),
      highYear,
      'the two-digit form of the high bound resolves to the high bound itself'
    );
  });

  test('three and four digits are taken literally', function (assert) {
    assert.strictEqual(resolveTwoDigitYear('045', now), 45);
    assert.strictEqual(resolveTwoDigitYear('1945', now), 1945);
  });
});

module('Unit | date-input segments | carryOver', function () {
  test('a rebuilt format keeps a complete value', function (assert) {
    const filled = fromDate(buildParts('en-US'), new Date(2026, 11, 25));
    const carried = carryOver(buildParts('en-GB'), filled);

    assert.deepEqual(order(carried), ['day', 'month', 'year']);
    assert.strictEqual(
      toDate(carried)?.getTime(),
      new Date(2026, 11, 25).getTime()
    );
  });

  test('a rebuilt format keeps a half-typed entry', function (assert) {
    // The whole point: a locale change mid-entry must not discard the digits
    // already typed just because they compose no date yet.
    const parts = buildParts('en-US');
    const month = parts.find(
      (p): p is Segment => isSegment(p) && p.type === 'month'
    );
    if (!month) throw new Error('en-US always has a month segment');

    const typed = parts.map((p) =>
      isSegment(p) && p.type === 'month' ? applyDigit(month, '7').segment : p
    );

    const carried = carryOver(buildParts('de-DE'), typed);
    const carriedMonth = carried.find(
      (p): p is Segment => isSegment(p) && p.type === 'month'
    );

    assert.strictEqual(carriedMonth?.value, 7);
    assert.strictEqual(toDate(carried), null, 'still composes no date');
  });

  test('a segment the new format drops is simply gone', function (assert) {
    const filled = fromDate(buildParts('en-US'), new Date(2026, 11, 25));
    const carried = carryOver(
      buildParts('en-US', { month: '2-digit', day: '2-digit' }),
      filled
    );

    assert.deepEqual(order(carried), ['month', 'day']);
  });
});

module('Unit | date-input segments | toNumericFormat', function () {
  test('a textual month is detected', function (assert) {
    assert.true(hasTextualMonth({ month: 'short', day: '2-digit' }));
    assert.true(hasTextualMonth({ dateStyle: 'medium' }));
    assert.false(hasTextualMonth({ month: '2-digit', day: '2-digit' }));
  });

  test('only the month falls back -- the rest of the format survives', function (assert) {
    const parts = buildParts(
      'en-US',
      toNumericFormat({ month: 'short', day: '2-digit' })
    );

    assert.deepEqual(
      order(parts),
      ['month', 'day'],
      'no year segment is invented that the consumer never asked for'
    );
  });

  test('a dateStyle preset falls back to the default numeric format', function (assert) {
    const parts = buildParts('en-US', toNumericFormat({ dateStyle: 'medium' }));

    assert.deepEqual(order(parts), ['month', 'day', 'year']);
  });
});
