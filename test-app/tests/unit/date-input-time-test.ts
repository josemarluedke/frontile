import { module, test } from 'qunit';
import {
  buildParts,
  isSegment,
  applyDigit,
  applyLetter,
  step,
  toDate,
  fromDate,
  findSegment,
  displaySegment,
  formatForClipboard,
  parsePasted,
  parseDate,
  toWire
} from 'frontile';
import type { Part, Segment } from 'frontile';

const minute = { granularity: 'minute' } as const;

function order(parts: Part[]): string[] {
  return parts.filter(isSegment).map((p) => (p as Segment).type);
}

function segment(parts: Part[], type: Segment['type']): Segment {
  const found = findSegment(parts, type);
  if (!found) throw new Error(`no ${type} segment`);
  return found;
}

/** The composed value as local `yyyy-M-d H:m`, or null. */
function valueOf(parts: Part[] | null): string | null {
  const d = parts && toDate(parts);
  return d
    ? `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()} ${d.getHours()}:${d.getMinutes()}`
    : null;
}

module('Unit | date-input time | buildParts', function () {
  test('day granularity adds nothing', function (assert) {
    assert.deepEqual(order(buildParts('en-GB')), ['day', 'month', 'year']);
    assert.deepEqual(
      order(buildParts('en-GB', undefined, { granularity: 'day' })),
      ['day', 'month', 'year']
    );
  });

  test('hour and minute follow the date, in the locale order', function (assert) {
    assert.deepEqual(order(buildParts('en-GB', undefined, minute)), [
      'day',
      'month',
      'year',
      'hour',
      'minute'
    ]);
    assert.deepEqual(
      order(buildParts('en-GB', undefined, { granularity: 'hour' })),
      ['day', 'month', 'year', 'hour']
    );
  });

  test('a 12-hour locale adds AM/PM and counts hours 1-12', function (assert) {
    const parts = buildParts('en-US', undefined, minute);
    assert.deepEqual(order(parts), [
      'month',
      'day',
      'year',
      'hour',
      'minute',
      'dayPeriod'
    ]);

    const hour = segment(parts, 'hour');
    assert.deepEqual([hour.min, hour.max, hour.hourCycle], [1, 12, 'h12']);
    assert.deepEqual(segment(parts, 'dayPeriod').labels, ['AM', 'PM']);
  });

  test('a 24-hour locale has no AM/PM and counts hours 0-23', function (assert) {
    const parts = buildParts('cs-CZ', undefined, minute);
    assert.notOk(findSegment(parts, 'dayPeriod'));

    const hour = segment(parts, 'hour');
    assert.deepEqual([hour.min, hour.max, hour.hourCycle], [0, 23, 'h23']);
  });

  test('@hourCycle overrides the locale either way', function (assert) {
    assert.notOk(
      findSegment(
        buildParts('en-US', undefined, { ...minute, hourCycle: 24 }),
        'dayPeriod'
      ),
      'en-US on a 24-hour clock'
    );
    assert.ok(
      findSegment(
        buildParts('cs-CZ', undefined, { ...minute, hourCycle: 12 }),
        'dayPeriod'
      ),
      'cs-CZ on a 12-hour clock'
    );
  });
});

module('Unit | date-input time | typing', function () {
  test('a 24-hour hour waits after 0-2 and is full after 3-9', function (assert) {
    const hour = segment(buildParts('cs-CZ', undefined, minute), 'hour');

    assert.false(applyDigit(hour, '2').isFull, '2 could become 23');
    assert.true(applyDigit(hour, '3').isFull, '3 cannot grow');

    const twenty = applyDigit(applyDigit(hour, '2').segment, '3');
    assert.strictEqual(twenty.segment.value, 23);
    assert.true(twenty.isFull);
  });

  test('AM/PM takes a letter, not a digit', function (assert) {
    const dayPeriod = segment(
      buildParts('en-US', undefined, minute),
      'dayPeriod'
    );

    assert.strictEqual(applyDigit(dayPeriod, '1').segment, dayPeriod);
    assert.strictEqual(applyLetter(dayPeriod, 'p').segment.value, 1);
    assert.strictEqual(applyLetter(dayPeriod, 'A').segment.value, 0);
    assert.true(applyLetter(dayPeriod, 'p').isFull);
    assert.strictEqual(
      applyLetter(dayPeriod, 'x').segment,
      dayPeriod,
      'a letter no label starts with is ignored'
    );
  });

  test('AM/PM shows its label and steps between the two', function (assert) {
    const dayPeriod = segment(
      buildParts('en-US', undefined, minute),
      'dayPeriod'
    );
    assert.strictEqual(displaySegment(dayPeriod), 'AM', 'placeholder');

    const pm = applyLetter(dayPeriod, 'p').segment;
    assert.strictEqual(displaySegment(pm), 'PM');
    assert.strictEqual(
      displaySegment(step(pm, 1, new Date())),
      'AM',
      'wraps round'
    );
  });

  test('an empty hour steps from the placeholder time, on the field clock', function (assert) {
    const hour = segment(buildParts('en-US', undefined, minute), 'hour');
    const at = new Date(2026, 0, 20, 21, 5);
    assert.strictEqual(
      step(hour, 1, at).value,
      9,
      '21:00 is 9 on a 12-hour clock'
    );
  });
});

module('Unit | date-input time | toDate and fromDate', function () {
  test('a 24-hour field round-trips', function (assert) {
    const parts = fromDate(
      buildParts('cs-CZ', undefined, minute),
      new Date(2026, 0, 20, 9, 15)
    );
    assert.strictEqual(valueOf(parts), '2026-1-20 9:15');
  });

  test('a 12-hour field round-trips, noon and midnight included', function (assert) {
    for (const [hours, shown, period] of [
      [0, 12, 'AM'],
      [9, 9, 'AM'],
      [12, 12, 'PM'],
      [21, 9, 'PM']
    ] as const) {
      const parts = fromDate(
        buildParts('en-US', undefined, minute),
        new Date(2026, 0, 20, hours, 30)
      );
      assert.strictEqual(segment(parts, 'hour').value, shown, `${hours}:30`);
      assert.strictEqual(displaySegment(segment(parts, 'dayPeriod')), period);
      assert.strictEqual(valueOf(parts), `2026-1-20 ${hours}:30`);
    }
  });

  test('nothing composes until the time is complete', function (assert) {
    const parts = fromDate(
      buildParts('en-US', undefined, minute),
      new Date(2026, 0, 20, 9, 15)
    ).map((p) =>
      isSegment(p) && p.type === 'dayPeriod'
        ? { ...p, value: null, buffer: '', isCommitted: false }
        : p
    );
    assert.strictEqual(toDate(parts), null, 'AM/PM still empty');
  });

  test('hour granularity composes on the hour', function (assert) {
    const parts = fromDate(
      buildParts('cs-CZ', undefined, { granularity: 'hour' }),
      new Date(2026, 0, 20, 9, 15)
    );
    assert.strictEqual(valueOf(parts), '2026-1-20 9:0');
  });
});

module('Unit | date-input time | clipboard', function () {
  test('an ISO date-time fills the date and the time', function (assert) {
    assert.strictEqual(
      valueOf(
        parsePasted('2026-01-20T21:05', buildParts('en-US', undefined, minute))
      ),
      '2026-1-20 21:5',
      'on a 12-hour field, as 9:05 PM'
    );
    assert.strictEqual(
      valueOf(
        parsePasted('2026-01-20 09:15', buildParts('cs-CZ', undefined, minute))
      ),
      '2026-1-20 9:15'
    );
  });

  test('positional text reads AM/PM from its words', function (assert) {
    const parts = buildParts('en-US', undefined, minute);
    assert.strictEqual(
      valueOf(parsePasted('1/20/2026 9:15 PM', parts)),
      '2026-1-20 21:15'
    );
    assert.strictEqual(
      valueOf(parsePasted('1/20/2026 9:15 a.m.', parts)),
      '2026-1-20 9:15'
    );
  });

  test('a 24-hour time pasted into a 12-hour field lands as PM', function (assert) {
    assert.strictEqual(
      valueOf(
        parsePasted('1/20/2026 21:15', buildParts('en-US', undefined, minute))
      ),
      '2026-1-20 21:15'
    );
  });

  test('an out-of-range time is refused', function (assert) {
    const parts = buildParts('cs-CZ', undefined, minute);
    assert.strictEqual(parsePasted('2026-01-20T24:00', parts), null);
    assert.strictEqual(parsePasted('20. 1. 2026 9:75', parts), null);
  });

  test('copy writes the time as shown', function (assert) {
    const parts = fromDate(
      buildParts('en-US', undefined, minute),
      new Date(2026, 0, 20, 21, 5)
    );
    assert.strictEqual(formatForClipboard(parts), '01/20/2026, 09:05 PM');
  });
});

module('Unit | date-input time | wire', function () {
  test('parseDate reads a local date-time', function (assert) {
    const parsed = parseDate('2026-01-20T09:15');
    assert.strictEqual(parsed?.getHours(), 9);
    assert.strictEqual(parsed?.getMinutes(), 15);
    assert.strictEqual(parseDate('2026-01-20 09:15:30')?.getSeconds(), 30);
    assert.strictEqual(parseDate('2026-01-20T09:15Z'), null, 'no offsets');
  });

  test('toWire writes the time only under a time granularity', function (assert) {
    const date = new Date(2026, 0, 20, 9, 5);
    assert.strictEqual(toWire(date), '2026-01-20');
    assert.strictEqual(toWire(date, 'minute'), '2026-01-20T09:05');
    assert.strictEqual(toWire(date, 'hour'), '2026-01-20T09:05');
  });
});
