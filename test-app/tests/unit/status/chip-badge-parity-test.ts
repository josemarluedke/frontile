import { module, test } from 'qunit';
import { realStyles } from 'test-app/tests/helpers/real-theme-styles';

/**
 * Chip and Badge sit side by side, so at the same `@size` they share one
 * height and one text weight. Reads the shipped class strings out of
 * `realStyles`.
 */
const SIZES = ['xs', 'sm', 'md', 'lg'] as const;
const heightOf = (classes: string) =>
  classes.split(' ').find((c) => /^h-\d/.test(c));

module('Unit | Theme | Chip and Badge parity', function () {
  test('each size has the same height class', function (assert) {
    for (const size of SIZES) {
      const chip = heightOf(realStyles.chip({ size }).base());
      const badge = heightOf(realStyles.badge({ size }).base());
      assert.ok(chip, `${size} chip has a height class`);
      assert.strictEqual(chip, badge, `${size}: chip ${chip}, badge ${badge}`);
    }
  });

  test('Chip is regular weight, like Badge', function (assert) {
    for (const size of SIZES) {
      const classes = realStyles.chip({ size }).base().split(' ');
      assert.true(
        classes.includes('font-normal'),
        `${size} chip is font-normal`
      );
      assert.false(
        classes.some((c) =>
          /^font-(medium|semibold|bold|label-strong)$/.test(c)
        ),
        `${size} chip sets no heavier weight`
      );
    }
  });
});
