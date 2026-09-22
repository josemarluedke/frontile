import { module, test } from 'qunit';
import {
  buildParts,
  isSegment,
  applyDigit,
  step,
  clearSegment,
  deleteDigit,
  toDate,
  fromDate,
  emptySegment,
  resolveTwoDigitYear
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
  });

  test('a first digit that could be extended waits', function (assert) {
    // 1 in a month might still become 10, 11 or 12.
    const { segment, isFull } = applyDigit(emptySegment('month'), '1');
    assert.strictEqual(segment.value, 1);
    assert.strictEqual(segment.buffer, '1');
    assert.false(isFull, 'focus stays put for a possible second digit');
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
    }
    const last = applyDigit(seg, '6');
    assert.strictEqual(last.segment.value, 2026);
    assert.true(last.isFull);
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

  test('deleteDigit drops the last digit typed', function (assert) {
    const year = { ...emptySegment('year'), value: 2026, buffer: '2026' };
    const once = deleteDigit(year);
    assert.strictEqual(once.buffer, '202');
    assert.strictEqual(once.value, 202, 'still a usable partial year');

    const empty = deleteDigit({
      ...emptySegment('day'),
      value: 5,
      buffer: '5'
    });
    assert.strictEqual(empty.buffer, '');
    assert.strictEqual(empty.value, null);
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
    assert.strictEqual(resolveTwoDigitYear('45', now), 1945);
    assert.strictEqual(resolveTwoDigitYear('00', now), 2000);
    assert.strictEqual(
      resolveTwoDigitYear('46', now),
      2046,
      'the last year in the window'
    );
    assert.strictEqual(
      resolveTwoDigitYear('47', now),
      1947,
      'one past it falls back a century'
    );
  });

  test('three and four digits are taken literally', function (assert) {
    assert.strictEqual(resolveTwoDigitYear('045', now), 45);
    assert.strictEqual(resolveTwoDigitYear('1945', now), 1945);
  });
});
