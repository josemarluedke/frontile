import { module, test } from 'qunit';
import { realStyles } from 'test-app/tests/helpers/real-theme-styles';

/**
 * The shipped Button recipe adopts the Facet 2.0 size scale. Each size keeps
 * its name; label / vertical padding / horizontal padding / gap come from the
 * spec's Button card (gaps: xs 4px, sm 4px, md 6px, lg 6px, xl 8px, 2xl 10px).
 */
const SCALE = {
  xs: ['text-strong-xs', 'py-0.5', 'px-3.5', 'gap-1'],
  sm: ['text-strong-sm', 'py-1', 'px-4', 'gap-1'],
  md: ['text-strong-md', 'py-1.5', 'px-5', 'gap-1.5'],
  lg: ['text-strong-lg', 'py-2', 'px-6', 'gap-1.5'],
  xl: ['text-strong-xl', 'py-2.5', 'px-8', 'gap-2'],
  '2xl': ['text-strong-2xl', 'py-3', 'px-10', 'gap-2.5']
} as const;

type Size = keyof typeof SCALE;
const sizes = Object.keys(SCALE) as Size[];

const tokens = (classes: string) => classes.split(/\s+/);

module('Unit | Theme | button sizes (shipped theme)', function () {
  for (const size of sizes) {
    test(`${size} renders the spec label, padding and gap`, function (assert) {
      const classes = tokens(realStyles.button({ size }));
      for (const expected of SCALE[size]) {
        assert.true(classes.includes(expected), `${size} has ${expected}`);
      }
      assert.true(classes.includes('rounded-full'), `${size} is a pill`);
    });
  }

  test('md is the default size', function (assert) {
    const defaults = tokens(realStyles.button({}));
    for (const expected of SCALE.md) {
      assert.true(defaults.includes(expected), `default has ${expected}`);
    }
    assert.deepEqual(
      [...defaults].sort(),
      [...tokens(realStyles.button({ size: 'md' }))].sort()
    );
  });

  test('the old 37px-label 2xl classes are gone from every size', function (assert) {
    for (const size of sizes) {
      const classes = tokens(realStyles.button({ size }));
      for (const old of ['text-strong-3xl', 'px-12', 'py-3.5']) {
        assert.false(classes.includes(old), `${size} has no ${old}`);
      }
    }
  });

  for (const size of sizes) {
    test(`grouped ${size} keeps the joined-pill radius`, function (assert) {
      const classes = tokens(realStyles.button({ size, isInGroup: true }));
      for (const expected of [
        'rounded-none',
        'first-of-type:rounded-s-full',
        'last-of-type:rounded-e-full',
        'not-last-of-type:-me-px'
      ]) {
        assert.true(
          classes.includes(expected),
          `${size} group has ${expected}`
        );
      }
    });
  }
});
