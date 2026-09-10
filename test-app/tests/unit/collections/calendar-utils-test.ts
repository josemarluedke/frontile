/* eslint-disable @typescript-eslint/no-non-null-assertion */
import { module, test } from 'qunit';
import {
  toDayKey,
  resolveWeekStart,
  buildMonthGrid,
  formatMonthCaption,
  formatWeekdays,
  isWithinBounds,
  normalizeRange,
  rangeLimits
} from 'frontile/components/collections/calendar/utils';

const sep2026 = new Date(2026, 8, 1);

module('Unit | collections | calendar utils', function () {
  test('toDayKey is a stable zero-padded local key', function (assert) {
    assert.strictEqual(toDayKey(new Date(2026, 8, 9)), '2026-09-09');
    assert.strictEqual(toDayKey(new Date(2026, 11, 31)), '2026-12-31');
  });

  test('resolveWeekStart prefers an explicit value over the locale', function (assert) {
    assert.strictEqual(resolveWeekStart('en-US', 1), 1, 'explicit wins');
    assert.strictEqual(resolveWeekStart('en-US'), 0, 'en-US starts Sunday');
    assert.strictEqual(resolveWeekStart('de-DE'), 1, 'de-DE starts Monday');
  });

  test('buildMonthGrid lays September 2026 out from Sunday', function (assert) {
    const grid = buildMonthGrid({
      month: sep2026,
      weekStartsOn: 0,
      fixedWeeks: false
    });

    assert.strictEqual(grid.weeks.length, 5, 'September 2026 needs five rows');
    assert.deepEqual(
      grid.weeks[0]!.days.map((d) => d.dayOfMonth),
      [30, 31, 1, 2, 3, 4, 5],
      'the first row is padded with August 30 and 31'
    );
    assert.true(grid.weeks[0]!.days[0]!.isOutside, 'Aug 30 is an outside day');
    assert.false(grid.weeks[0]!.days[2]!.isOutside, 'Sep 1 is not');
    assert.deepEqual(
      grid.weeks.at(-1)!.days.map((d) => d.dayOfMonth),
      [27, 28, 29, 30, 1, 2, 3],
      'the last row runs into October'
    );
  });

  test('buildMonthGrid respects weekStartsOn', function (assert) {
    const grid = buildMonthGrid({
      month: sep2026,
      weekStartsOn: 1,
      fixedWeeks: false
    });

    assert.deepEqual(
      grid.weeks[0]!.days.map((d) => d.dayOfMonth),
      [31, 1, 2, 3, 4, 5, 6],
      'a Monday start drops the leading Sunday'
    );
  });

  test('fixedWeeks always produces six rows', function (assert) {
    const grid = buildMonthGrid({
      month: sep2026,
      weekStartsOn: 0,
      fixedWeeks: true
    });

    assert.strictEqual(grid.weeks.length, 6);
    assert.strictEqual(
      grid.weeks.at(-1)!.days[0]!.dayOfMonth,
      4,
      'the sixth row continues into October'
    );
  });

  test('buildMonthGrid survives a DST transition month', function (assert) {
    // US DST ends 2026-11-01. A naive `+24h` walk loses or repeats a day.
    const grid = buildMonthGrid({
      month: new Date(2026, 10, 1),
      weekStartsOn: 0,
      fixedWeeks: false
    });

    const inMonth = grid.weeks
      .flatMap((w) => w.days)
      .filter((d) => !d.isOutside)
      .map((d) => d.dayOfMonth);

    assert.deepEqual(
      inMonth,
      Array.from({ length: 30 }, (_, i) => i + 1),
      'November 2026 yields exactly 1..30 with no gap or repeat'
    );
  });

  test('buildMonthGrid does not drop the last day of the month when it falls on a week-start day (May 2026, Sunday start)', function (assert) {
    const grid = buildMonthGrid({
      month: new Date(2026, 4, 1),
      weekStartsOn: 0,
      fixedWeeks: false
    });

    const inMonth = grid.weeks
      .flatMap((w) => w.days)
      .filter((d) => !d.isOutside)
      .map((d) => d.dayOfMonth);

    assert.deepEqual(
      inMonth,
      Array.from({ length: 31 }, (_, i) => i + 1),
      'May 2026 yields exactly 1..31 with no gap -- May 31 2026 is a Sunday'
    );
  });

  test('buildMonthGrid does not drop the last day of the month when it falls on a week-start day (February 2027, Sunday start, four-week month)', function (assert) {
    const grid = buildMonthGrid({
      month: new Date(2027, 1, 1),
      weekStartsOn: 0,
      fixedWeeks: false
    });

    const inMonth = grid.weeks
      .flatMap((w) => w.days)
      .filter((d) => !d.isOutside)
      .map((d) => d.dayOfMonth);

    assert.deepEqual(
      inMonth,
      Array.from({ length: 28 }, (_, i) => i + 1),
      'February 2027 yields exactly 1..28 with no gap'
    );
  });

  test('formatMonthCaption and formatWeekdays use Intl', function (assert) {
    assert.strictEqual(formatMonthCaption(sep2026, 'en-US'), 'September 2026');
    assert.strictEqual(formatMonthCaption(sep2026, 'nl-NL'), 'september 2026');

    const wd = formatWeekdays('en-US', 0);
    assert.strictEqual(wd.length, 7);
    assert.strictEqual(wd[0]!.short, 'Sun');
    assert.strictEqual(wd[0]!.index, 0, 'index is the real weekday number');

    const mondayFirst = formatWeekdays('en-US', 1);
    assert.strictEqual(mondayFirst[0]!.short, 'Mon');
    assert.strictEqual(mondayFirst[0]!.index, 1);
  });

  test('isWithinBounds is inclusive and day-granular', function (assert) {
    const min = new Date(2026, 8, 5);
    const max = new Date(2026, 8, 20);

    assert.true(
      isWithinBounds(new Date(2026, 8, 5, 23, 59), min, max),
      'min day is in'
    );
    assert.true(
      isWithinBounds(new Date(2026, 8, 20, 0, 1), min, max),
      'max day is in'
    );
    assert.false(isWithinBounds(new Date(2026, 8, 4), min, max));
    assert.false(isWithinBounds(new Date(2026, 8, 21), min, max));
    assert.true(
      isWithinBounds(new Date(2026, 8, 4)),
      'no bounds means always in'
    );
  });

  test('normalizeRange orders its endpoints', function (assert) {
    const early = new Date(2026, 8, 9);
    const late = new Date(2026, 8, 18);

    assert.deepEqual(normalizeRange(early, late), { start: early, end: late });
    assert.deepEqual(
      normalizeRange(late, early),
      { start: early, end: late },
      'a backwards drag still yields an ordered range'
    );
  });

  test('rangeLimits stops at the nearest unavailable day in each direction', function (assert) {
    const anchor = new Date(2026, 8, 10);
    const isDateUnavailable = (d: Date) =>
      d.getDate() === 6 || d.getDate() === 14;

    const limits = rangeLimits(anchor, isDateUnavailable);

    assert.strictEqual(
      toDayKey(limits.min!),
      '2026-09-07',
      'cannot reach back past the 6th'
    );
    assert.strictEqual(
      toDayKey(limits.max!),
      '2026-09-13',
      'cannot reach forward past the 14th'
    );
  });

  test('rangeLimits falls back to the min/max bounds', function (assert) {
    const anchor = new Date(2026, 8, 10);
    const limits = rangeLimits(
      anchor,
      undefined,
      new Date(2026, 8, 5),
      new Date(2026, 8, 20)
    );

    assert.strictEqual(toDayKey(limits.min!), '2026-09-05');
    assert.strictEqual(toDayKey(limits.max!), '2026-09-20');
  });
});
