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

const identity = (value: string) => value;

function rank(query: string): string[] {
  return filterAndRankItems([...COMPONENTS], query, identity) as string[];
}

module('Unit | @frontile/collections/utils/filter', function () {
  module('defaultFilter', function () {
    test('an exact match outranks a longer name containing the query', function (assert) {
      assert.ok(
        defaultFilter('Button', 'button') >
          defaultFilter('ButtonGroup', 'button'),
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

    test('a whitespace-only query matches everything', function (assert) {
      // fuzzysort returns null for a blank OR whitespace-only needle. Treating
      // that as "no match" would empty the list when a user types a space.
      assert.ok(defaultFilter('Button', '   ') > 0);
    });
  });

  module('match threshold', function () {
    // fuzzysort cannot tell a desirable abbreviation (btn -> Button) from noise
    // (sa -> Spain): both are scattered mid-word subsequences. The threshold
    // draws the line where fuzzysort actually separates them -- at word
    // boundaries and contiguous runs -- so the default stays as precise as the
    // old `includes()` filter while gaining acronym matching.
    test('it cuts scattered mid-word subsequences', function (assert) {
      assert.strictEqual(
        defaultFilter('Spain', 'sa'),
        0,
        'sa does not match Spain'
      );
      assert.strictEqual(
        defaultFilter('Italy', 'ia'),
        0,
        'ia does not match Italy'
      );
      assert.strictEqual(
        defaultFilter('Argentina', 'an'),
        0,
        'an does not match Argentina'
      );
    });

    test('it keeps word-boundary and camelCase acronyms', function (assert) {
      assert.ok(
        defaultFilter('South Africa', 'sa') > 0,
        'sa matches South Africa'
      );
      assert.ok(
        defaultFilter('ButtonGroup', 'bg') > 0,
        'bg matches ButtonGroup'
      );
      assert.ok(
        defaultFilter('New Zealand', 'nz') > 0,
        'nz matches New Zealand'
      );
      assert.ok(
        defaultFilter('ProgressBar', 'prog') > 0,
        'prog matches ProgressBar'
      );
    });

    test('every substring match survives, however badly it scores', function (assert) {
      // The old default was `includes()`, and the filter must be a strict
      // superset of it. These all score BELOW the threshold on their own
      // (Guatemala/ma is 0.500, Switzerland/an is 0.447) and survive only
      // because of the substring floor.
      for (const [target, query] of [
        ['Guatemala', 'ma'],
        ['Netherlands', 'an'],
        ['Switzerland', 'an'],
        ['Canada', 'an'],
        ['United Kingdom', 'united'],
        ['Germany', 'ger']
      ] as [string, string][]) {
        assert.ok(
          defaultFilter(target, query) > 0,
          `"${query}" still matches ${target}`
        );
      }
    });

    test('the substring floor holds even at a punishing threshold', function (assert) {
      // Raising the threshold must never make an old `includes()` result vanish
      // — that is the property that lets us promise "same items, better order".
      const strict = createFuzzyFilter({ threshold: 0.99 });

      assert.ok(
        strict('Switzerland', 'an') > 0,
        'a substring match is immune to the threshold'
      );
      assert.strictEqual(
        strict('ButtonGroup', 'bg'),
        0,
        'a non-substring match is not'
      );
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

  module('superset property', function () {
    // The migration promise is "same items, better order, plus acronyms".
    // Assert it as a property over a corpus rather than on hand-picked cases,
    // so a future scorer swap cannot quietly break it.
    const CORPUS = [
      'Argentina',
      'Australia',
      'Austria',
      'Belgium',
      'Brazil',
      'Canada',
      'China',
      'Denmark',
      'Egypt',
      'Finland',
      'France',
      'Germany',
      'Guatemala',
      'India',
      'Italy',
      'Japan',
      'Kenya',
      'Mexico',
      'Morocco',
      'Netherlands',
      'New Zealand',
      'Nigeria',
      'Norway',
      'Poland',
      'Portugal',
      'South Africa',
      'Spain',
      'Sweden',
      'Switzerland',
      'United Kingdom',
      'United States'
    ];
    const QUERIES = [
      'a',
      'an',
      'ia',
      'ma',
      'ra',
      'sa',
      'ge',
      'united',
      'ger',
      'land',
      'new',
      'so',
      'ne',
      'ca',
      'in'
    ];

    test('no result the old includes() filter returned is lost', function (assert) {
      for (const query of QUERIES) {
        const expected = CORPUS.filter((c) =>
          c.toLowerCase().includes(query.toLowerCase())
        );
        const actual = filterAndRankItems([...CORPUS], query, identity) ?? [];

        for (const item of expected) {
          assert.ok(actual.includes(item), `"${query}" still returns ${item}`);
        }
      }
    });

    test('scattered subsequences below the threshold are dropped', function (assert) {
      // The flip side: the filter must not have simply become permissive.
      for (const [query, junk] of [
        ['sa', 'Spain'],
        ['ra', 'Argentina'],
        ['ia', 'Italy'],
        ['xo', 'Mexico']
      ] as [string, string][]) {
        const actual = filterAndRankItems([...CORPUS], query, identity) ?? [];
        assert.notOk(
          actual.includes(junk),
          `"${query}" does not return ${junk}`
        );
      }
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
      assert.strictEqual(
        filterAndRankItems(items, '', identity),
        items,
        'the same array reference, untouched'
      );
    });

    test('undefined items pass through', function (assert) {
      assert.strictEqual(
        filterAndRankItems<string>(undefined, 'x', identity),
        undefined
      );
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
          identity,
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
        filterAndRankItems(['aa', 'aaaa', 'b', 'aaa'], 'a', identity, byLength),
        ['aaaa', 'aaa', 'aa'],
        'higher scores first, non-matches dropped'
      );
    });

    test('equal scores keep source order (stable sort)', function (assert) {
      const constant = () => 5;

      assert.deepEqual(
        filterAndRankItems(['x', 'y', 'z'], 'q', identity, constant),
        ['x', 'y', 'z'],
        'ties do not get shuffled'
      );
    });

    test('the ranked path drops non-matches', function (assert) {
      assert.deepEqual(
        filterAndRankItems(['Button', 'Checkbox'], 'zzzz', identity),
        [],
        'nothing matches, nothing is returned'
      );
    });

    test('a whitespace-only query returns the items untouched', function (assert) {
      const items = ['b', 'a', 'c'];
      assert.strictEqual(filterAndRankItems(items, '   ', identity), items);
    });

    test('true outranks a weak numeric score, not the other way round', function (assert) {
      // A filter mixing booleans and numbers used to sort every `true` BELOW
      // every number, because `true` was recorded as score 0.
      const mixed = (itemValue: string) =>
        itemValue === 'boolean-match' ? true : 0.01;

      assert.deepEqual(
        filterAndRankItems(
          ['weak-a', 'boolean-match', 'weak-b'],
          'q',
          identity,
          mixed
        ),
        ['boolean-match', 'weak-a', 'weak-b'],
        'true is a full match, so it sorts above a 0.01 score'
      );
    });

    test('it ranks objects using a label accessor', function (assert) {
      const items = [
        { key: 'bg', label: 'ButtonGroup' },
        { key: 'b', label: 'Button' }
      ];

      const ranked = filterAndRankItems(items, 'button', (item) => item.label);

      assert.deepEqual(
        ranked?.map((i) => i.key),
        ['b', 'bg'],
        'ranks by the accessed label, not by source order'
      );
    });
  });
});
