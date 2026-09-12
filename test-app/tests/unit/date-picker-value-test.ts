import { module, test } from 'qunit';
import {
  parseDate,
  parseRange,
  toWire,
  formatValue,
  isEmptyValue
} from 'frontile';

module('Unit | date-picker value helpers', function () {
  test('parseDate accepts Date and yyyy-MM-dd strings', function (assert) {
    const d = new Date(2026, 0, 20);
    assert.strictEqual(parseDate(d), d, 'a Date passes through unchanged');

    const parsed = parseDate('2026-01-20');
    assert.strictEqual(parsed?.getFullYear(), 2026);
    assert.strictEqual(parsed?.getMonth(), 0, 'January, not off by one');
    assert.strictEqual(parsed?.getDate(), 20);
    assert.strictEqual(parsed?.getHours(), 0, 'local midnight');
  });

  test('parseDate returns null for empty and malformed input', function (assert) {
    assert.strictEqual(parseDate(null), null);
    assert.strictEqual(parseDate(undefined), null);
    assert.strictEqual(parseDate(''), null);
    assert.strictEqual(parseDate('not-a-date'), null);
    assert.strictEqual(
      parseDate(new Date(NaN)),
      null,
      'an Invalid Date is empty'
    );
  });

  test('toWire round-trips through parseDate without shifting the day', function (assert) {
    // 23:30 local on the 20th. toISOString() would report the 21st for any
    // timezone behind UTC by less than 30 minutes, and the 20th elsewhere.
    const late = new Date(2026, 0, 20, 23, 30);
    assert.strictEqual(toWire(late), '2026-01-20', 'local calendar fields win');
    assert.strictEqual(parseDate(toWire(late))?.getDate(), 20);
  });

  test('toWire returns an empty string for no date', function (assert) {
    assert.strictEqual(toWire(null), '');
    assert.strictEqual(toWire(undefined), '');
  });

  test('parseRange parses both ends and tolerates a half-open range', function (assert) {
    const range = parseRange({ start: '2026-01-20', end: '2026-02-09' });
    assert.strictEqual(range?.start.getDate(), 20);
    assert.strictEqual(range?.end?.getMonth(), 1, 'February');

    const half = parseRange({ start: '2026-01-20', end: null });
    assert.strictEqual(half?.start.getDate(), 20);
    assert.strictEqual(half?.end, null, 'an anchored range keeps a null end');

    assert.strictEqual(parseRange(null), null);
    assert.strictEqual(
      parseRange({ start: 'nope', end: null }),
      null,
      'an unparseable start makes the whole range empty'
    );
  });

  test('formatValue renders a single date with the given locale', function (assert) {
    const out = formatValue(new Date(2026, 0, 20), 'en-US');
    assert.strictEqual(out, 'Jan 20, 2026', 'dateStyle medium by default');
  });

  test('formatValue honours explicit format options', function (assert) {
    const out = formatValue(new Date(2026, 0, 20), 'en-US', {
      dateStyle: 'full'
    });
    assert.strictEqual(out, 'Tuesday, January 20, 2026');
  });

  test('formatValue joins a range with an en dash', function (assert) {
    const out = formatValue(
      { start: new Date(2026, 0, 20), end: new Date(2026, 1, 9) },
      'en-US'
    );
    assert.strictEqual(out, 'Jan 20, 2026 – Feb 9, 2026');
  });

  test('formatValue renders only the start of a half-open range', function (assert) {
    const out = formatValue(
      { start: new Date(2026, 0, 20), end: null },
      'en-US'
    );
    assert.strictEqual(out, 'Jan 20, 2026', 'no trailing dash while anchoring');
  });

  test('formatValue returns an empty string when there is no value', function (assert) {
    assert.strictEqual(formatValue(null, 'en-US'), '');
  });

  test('isEmptyValue distinguishes empty from anchored ranges', function (assert) {
    assert.true(isEmptyValue(null));
    assert.true(isEmptyValue(undefined));
    assert.false(isEmptyValue(new Date(2026, 0, 20)));
    assert.false(
      isEmptyValue({ start: new Date(2026, 0, 20), end: null }),
      'an anchored range is not empty — the trigger must show the start'
    );
  });
});
