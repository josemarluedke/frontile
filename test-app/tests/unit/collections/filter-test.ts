import { module, test } from 'qunit';
import {
  defaultFilter,
  createFuzzyFilter,
  filterAndRankItems,
  DEFAULT_MATCH_THRESHOLD
} from 'frontile/utils/filter';

/**
 * Ranking order, as a table. The `Button` vs `ButtonGroup` case is the one that
 * motivated the whole component: a predicate-based filter can only include or
 * exclude, so it always returned items in source order and a longer name that
 * merely contained the query could sit above an exact match.
 */
const COMPONENTS = [
  'ButtonGroup',
  'Button Group',
  'ToggleButton',
  'Close Button',
  'Button',
  'Checkbox',
  'Checkbox Group',
  'Table',
  'Tabs',
  'Tab'
];

function rank(query: string): string[] {
  return filterAndRankItems([...COMPONENTS], query) as string[];
}

module('Unit | @frontile/collections/utils/filter', function () {
  module('defaultFilter', function () {
    test('an exact match outranks a longer name containing the query', function (assert) {
      assert.ok(
        defaultFilter('Button', 'button') > defaultFilter('ButtonGroup', 'button'),
        'Button scores above ButtonGroup for "button"'
      );
    });

    test('the exact match wins at every prefix length', function (assert) {
      // The original defect was a *tie* at every partial prefix, which let
      // source order decide for the entire time the user was typing.
      for (const prefix of ['b', 'bu', 'but', 'butt', 'butto', 'button']) {
        assert.ok(
          defaultFilter('Button', prefix) >
            defaultFilter('ButtonGroup', prefix),
          `"${prefix}" ranks Button above ButtonGroup`
        );
      }
    });

    test('a non-match scores 0', function (assert) {
      assert.strictEqual(defaultFilter('Button', 'zzzz'), 0);
    });

    test('an empty query matches everything', function (assert) {
      // fuzzysort.single('', target) returns null, which would otherwise filter
      // every item out and leave a palette empty until the first keystroke.
      assert.ok(
        defaultFilter('Button', '') > 0,
        'an empty query must not be treated as "no match"'
      );
    });

    test('a real match never scores exactly 0', function (assert) {
      // 0 is reserved to mean "no match", so with the threshold disabled a
      // legitimate but very poor match must stay strictly above it rather than
      // being indistinguishable from no match at all.
      const loose = createFuzzyFilter({ threshold: 0 });
      const poor = loose(`a${'q'.repeat(900)}b${'q'.repeat(900)}c`, 'abc');
      assert.ok(poor > 0, 'a weak subsequence match still scores above zero');
    });
  });

  module('match threshold', function () {
    // fuzzysort cannot tell a desirable abbreviation (btn -> Button) from noise
    // (sa -> Spain): both are scattered mid-word subsequences. The threshold
    // draws the line where fuzzysort actually separates them -- at word
    // boundaries and contiguous runs -- so the default stays as precise as the
    // old `includes()` filter while gaining acronym matching.
    test('it cuts scattered mid-word subsequences', function (assert) {
      assert.strictEqual(defaultFilter('Spain', 'sa'), 0, 'sa does not match Spain');
      assert.strictEqual(defaultFilter('Italy', 'ia'), 0, 'ia does not match Italy');
      assert.strictEqual(
        defaultFilter('Argentina', 'an'),
        0,
        'an does not match Argentina'
      );
    });

    test('it keeps word-boundary and camelCase acronyms', function (assert) {
      assert.ok(defaultFilter('South Africa', 'sa') > 0, 'sa matches South Africa');
      assert.ok(defaultFilter('ButtonGroup', 'bg') > 0, 'bg matches ButtonGroup');
      assert.ok(defaultFilter('New Zealand', 'nz') > 0, 'nz matches New Zealand');
      assert.ok(
        defaultFilter('ProgressBar', 'prog') > 0,
        'prog matches ProgressBar'
      );
    });

    test('it keeps every plain substring match', function (assert) {
      // The old default was `includes()`. Nothing it matched may be lost.
      for (const [target, query] of [
        ['Canada', 'an'],
        ['Netherlands', 'an'],
        ['Switzerland', 'an'],
        ['United Kingdom', 'united'],
        ['Germany', 'ger']
      ] as [string, string][]) {
        assert.ok(
          defaultFilter(target, query) > 0,
          `"${query}" still matches ${target}`
        );
      }
    });

    test('the threshold is configurable', function (assert) {
      const loose = createFuzzyFilter({ threshold: 0 });

      assert.strictEqual(
        defaultFilter('Button', 'btn'),
        0,
        'the default is precision-first and drops btn -> Button'
      );
      assert.ok(
        loose('Button', 'btn') > 0,
        'a caller that wants recall can lower the threshold'
      );
      assert.ok(
        DEFAULT_MATCH_THRESHOLD > 0,
        'the default threshold is documented as a constant'
      );
    });
  });

  module('ranking table', function () {
    test('Button outranks ButtonGroup at every prefix length', function (assert) {
      for (const prefix of ['b', 'bu', 'but', 'butt', 'butto', 'button']) {
        const results = rank(prefix);
        assert.strictEqual(
          results[0],
          'Button',
          `"${prefix}" ranks Button first (got ${results.slice(0, 3).join(' > ')})`
        );
      }
    });

    test('camelCase acronyms resolve to the camelCase name', function (assert) {
      assert.strictEqual(rank('bg')[0], 'ButtonGroup');
    });

    test('an exact match wins over longer names sharing the prefix', function (assert) {
      assert.strictEqual(rank('tab')[0], 'Tab');
      assert.strictEqual(rank('table')[0], 'Table');
    });
  });

  module('filterAndRankItems', function () {
    test('an empty query returns the items untouched', function (assert) {
      const items = ['b', 'a', 'c'];
      assert.deepEqual(
        filterAndRankItems(items, ''),
        items,
        'no filtering and no reordering'
      );
    });

    test('undefined items pass through', function (assert) {
      assert.strictEqual(filterAndRankItems(undefined, 'x'), undefined);
    });

    test('a boolean filter filters but preserves source order', function (assert) {
      // Backwards compatibility: existing consumers pass predicates and must
      // keep getting results in the order they supplied them.
      const contains = (itemValue: string, input: string) =>
        itemValue.toLowerCase().includes(input.toLowerCase());

      assert.deepEqual(
        filterAndRankItems(
          ['ButtonGroup', 'Button', 'Checkbox'],
          'button',
          contains
        ),
        ['ButtonGroup', 'Button'],
        'source order is preserved for predicate filters'
      );
    });

    test('a numeric filter sorts by score descending', function (assert) {
      const byLength = (itemValue: string, input: string) =>
        itemValue.includes(input) ? itemValue.length : 0;

      assert.deepEqual(
        filterAndRankItems(['aa', 'aaaa', 'b', 'aaa'], 'a', byLength),
        ['aaaa', 'aaa', 'aa'],
        'higher scores first, non-matches dropped'
      );
    });

    test('equal scores keep source order (stable sort)', function (assert) {
      const constant = () => 5;

      assert.deepEqual(
        filterAndRankItems(['x', 'y', 'z'], 'q', constant),
        ['x', 'y', 'z'],
        'ties do not get shuffled'
      );
    });

    test('it ranks objects using a label accessor', function (assert) {
      const items = [
        { key: 'bg', label: 'ButtonGroup' },
        { key: 'b', label: 'Button' }
      ];

      const ranked = filterAndRankItems(
        items,
        'button',
        defaultFilter,
        (item) => item.label
      );

      assert.deepEqual(
        ranked?.map((i) => i.key),
        ['b', 'bg'],
        'ranks by the accessed label, not by source order'
      );
    });
  });
});
