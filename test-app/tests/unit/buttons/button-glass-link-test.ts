import { module, test } from 'qunit';
import { realStyles } from 'test-app/tests/helpers/real-theme-styles';

/**
 * The shipped Button recipe gains `glass` and `link`. Classes are read from
 * `realStyles` (the shipped theme), never from `useStyles()`, which other test
 * files overwrite with stub markers.
 */

type Color =
  | 'neutral'
  | 'primary'
  | 'secondary'
  | 'tertiary'
  | 'success'
  | 'warning'
  | 'danger';

const COLORS: Color[] = [
  'neutral',
  'primary',
  'secondary',
  'tertiary',
  'success',
  'warning',
  'danger'
];

function tokens(props: Record<string, unknown>): string[] {
  return realStyles
    .button(props as Parameters<typeof realStyles.button>[0])
    .split(/\s+/)
    .filter(Boolean);
}

const SIZES = ['xs', 'sm', 'md', 'lg', 'xl', '2xl'] as const;
const SIZE_PADDING = [
  'px-3.5',
  'px-4',
  'px-5',
  'px-6',
  'px-8',
  'px-10'
] as const;

module('Unit | Theme | Button link', function () {
  test('link has no horizontal padding at any size', function (assert) {
    for (const size of SIZES) {
      const got = tokens({ variant: 'link', size });
      assert.true(got.includes('px-0'), `link/${size} has px-0`);
      for (const pad of SIZE_PADDING) {
        assert.false(got.includes(pad), `link/${size} lacks ${pad}`);
      }
    }
  });

  test('link is ink only', function (assert) {
    const got = tokens({ variant: 'link', color: 'neutral' });
    assert.true(got.includes('hover:underline'));
    assert.true(got.includes('border-transparent'));
    const fills = got.filter(
      (t) => /^(hover:|active:)?bg-/.test(t) && t !== 'bg-transparent'
    );
    assert.deepEqual(fills, [], 'no fill classes');
  });

  test('neutral link ink steps', function (assert) {
    const got = tokens({ variant: 'link', color: 'neutral' });
    assert.true(got.includes('text-on-neutral-subtle'));
    assert.true(got.includes('active:text-neutral-firm'));
  });

  test('link honors @color', function (assert) {
    const primary = tokens({ variant: 'link', color: 'primary' });
    const neutral = tokens({ variant: 'link', color: 'neutral' });
    assert.true(primary.includes('text-primary'));
    assert.notDeepEqual(primary.sort(), neutral.sort());
  });

  test('disabled link does not underline', function (assert) {
    for (const color of COLORS) {
      assert.true(
        tokens({ variant: 'link', color }).includes('disabled:no-underline'),
        `link/${color} has disabled:no-underline`
      );
    }
  });
});

module('Unit | Theme | Button glass', function () {
  test('glass uses the overlay fills', function (assert) {
    const got = tokens({ variant: 'glass' });
    for (const cls of [
      'bg-surface-overlay-soft',
      'hover:bg-surface-overlay-mild',
      'active:bg-surface-overlay-firm',
      'backdrop-blur-md',
      'text-on-neutral-subtle'
    ]) {
      assert.true(got.includes(cls), `glass has ${cls}`);
    }
    assert.false(got.includes('shadow-elevation-2'), 'glass has no shadow');
  });

  test('glass ignores @color', function (assert) {
    const neutral = tokens({ variant: 'glass', color: 'neutral' }).sort();
    for (const color of COLORS) {
      assert.deepEqual(
        tokens({ variant: 'glass', color }).sort(),
        neutral,
        `glass/${color} matches glass/neutral`
      );
    }
  });

  test('glass keeps the disabled rules', function (assert) {
    const got = tokens({ variant: 'glass' });
    assert.true(got.includes('disabled:opacity-disabled'));
    assert.true(got.includes('disabled:cursor-not-allowed'));
  });

  test('glass in a group keeps group rounding', function (assert) {
    const got = tokens({ variant: 'glass', isInGroup: true });
    assert.true(got.includes('first-of-type:rounded-s-full'));
  });
});
