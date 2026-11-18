import { module, test } from 'qunit';
import { realStyles } from 'test-app/tests/helpers/real-theme-styles';

/**
 * Badge, Chip and Button share one text size per `@size` step: the same size
 * name gives the same `text-strong-*` token on all three. Heights and padding
 * are set per component, so they are not compared. Reads the shipped class
 * strings out of `realStyles`.
 */
const SIZES = ['xs', 'sm', 'md', 'lg', 'xl', '2xl'] as const;

const tokens = (classes: string) => classes.split(/\s+/);
const textOf = (classes: string) =>
  tokens(classes).filter((c) => /^text-strong-/.test(c));

module('Unit | Theme | Badge, Chip and Button text ramp', function () {
  for (const size of SIZES) {
    test(`${size}: Badge and Chip use Button's text class`, function (assert) {
      const button = textOf(realStyles.button({ size }));
      assert.strictEqual(button.length, 1, `${size} button has one text class`);
      assert.deepEqual(
        textOf(realStyles.chip({ size }).base()),
        button,
        `${size} chip matches button`
      );
      assert.deepEqual(
        textOf(realStyles.badge({ size }).base()),
        button,
        `${size} badge matches button`
      );
    });
  }

  test('Chip and Badge are regular weight', function (assert) {
    for (const size of SIZES) {
      for (const [name, classes] of [
        ['chip', realStyles.chip({ size }).base()],
        ['badge', realStyles.badge({ size }).base()]
      ] as const) {
        assert.true(
          tokens(classes).includes('font-normal'),
          `${size} ${name} is font-normal`
        );
      }
    }
  });

  test("Badge's value stays bold and sets no size of its own", function (assert) {
    const value = tokens(realStyles.badge({}).value());
    assert.true(value.includes('font-bold'));
    assert.false(value.some((c) => /^text-/.test(c)));
  });

  test('Badge and Chip offer Button sizes, with no 2xs', function (assert) {
    assert.deepEqual(Object.keys(realStyles.badge.variants.size), [...SIZES]);
    assert.deepEqual(Object.keys(realStyles.chip.variants.size), [...SIZES]);
  });

  test('Badge and Chip default to xs; Button keeps md', function (assert) {
    assert.strictEqual(
      realStyles.badge({}).base(),
      realStyles.badge({ size: 'xs' }).base()
    );
    assert.strictEqual(
      realStyles.chip({}).base(),
      realStyles.chip({ size: 'xs' }).base()
    );
    assert.strictEqual(
      realStyles.button({}),
      realStyles.button({ size: 'md' })
    );
  });

  test('each size gets a taller Badge and Chip than the one below', function (assert) {
    const px = (classes: string) =>
      Number(
        tokens(classes)
          .find((c) => /^h-\d/.test(c))
          ?.slice(2)
      );
    for (const recipe of [
      (size: (typeof SIZES)[number]) => realStyles.chip({ size }).base(),
      (size: (typeof SIZES)[number]) => realStyles.badge({ size }).base()
    ]) {
      const heights = SIZES.map((s) => px(recipe(s)));
      assert.ok(
        heights.every((h) => h > 0),
        'every size has a height'
      );
      assert.deepEqual(
        heights,
        [...heights].sort((a, b) => a - b),
        'heights never shrink'
      );
    }
  });
});
