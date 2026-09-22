import { module, test } from 'qunit';
import { buildParts, isSegment } from 'frontile';
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
