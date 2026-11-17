import { module, test } from 'qunit';
import { semanticColors, wcagContrast } from '@frontile/theme/colors';
import { realStyles } from 'test-app/tests/helpers/real-theme-styles';

/**
 * DSYS-457: the shipped Button recipe adopts the Facet 2.0 color and state
 * shifts. Classes are read from `realStyles` (the shipped theme), never from
 * `useStyles()`, which other test files overwrite with stub markers.
 */

type Variant = 'solid' | 'subtle' | 'soft' | 'plain' | 'outline' | 'ghost';
type Color =
  | 'neutral'
  | 'primary'
  | 'secondary'
  | 'tertiary'
  | 'success'
  | 'warning'
  | 'danger';

function tokens(variant: Variant | 'custom', color: Color): string[] {
  return realStyles
    .button({ variant, color } as Parameters<typeof realStyles.button>[0])
    .split(/\s+/)
    .filter(Boolean);
}

function assertHas(
  assert: Assert,
  variant: Variant | 'custom',
  color: Color,
  expected: string[],
  absent: string[] = []
) {
  const got = tokens(variant, color);
  for (const cls of expected) {
    assert.true(got.includes(cls), `${variant}/${color} has ${cls}`);
  }
  for (const cls of absent) {
    assert.false(got.includes(cls), `${variant}/${color} lacks ${cls}`);
  }
}

module('Unit | Theme | Button colors (DSYS-457)', function () {
  module(
    'neutral uses the spec pure black/white instead of neutral-bolder',
    function () {
      test('solid neutral rest fill and border', function (assert) {
        assertHas(
          assert,
          'solid',
          'neutral',
          [
            'bg-on-neutral-subtle',
            'border-on-neutral-subtle',
            'text-on-neutral-bolder',
            'hover:bg-neutral-strong',
            'hover:text-on-neutral-strong',
            'active:bg-neutral-firm',
            'active:text-on-neutral-firm'
          ],
          ['bg-neutral-bolder', 'border-neutral-bolder']
        );
      });

      test('subtle neutral ramp', function (assert) {
        assertHas(
          assert,
          'subtle',
          'neutral',
          [
            'bg-neutral-muted',
            'border-on-neutral-subtle',
            'text-on-neutral-subtle',
            'hover:bg-neutral-soft',
            'hover:border-neutral-strong',
            'hover:text-neutral-strong',
            'active:bg-neutral-mild',
            'active:border-neutral-firm',
            'active:text-neutral-firm'
          ],
          ['bg-neutral-soft', 'border-neutral-bolder', 'text-neutral-bolder']
        );
      });

      test('soft neutral ramp', function (assert) {
        assertHas(
          assert,
          'soft',
          'neutral',
          [
            'bg-neutral-muted',
            'text-on-neutral-subtle',
            'hover:bg-neutral-soft',
            'hover:text-neutral-strong',
            'active:bg-neutral-mild',
            'active:text-neutral-firm'
          ],
          ['bg-neutral-soft', 'text-on-neutral-soft', 'hover:bg-neutral-muted']
        );
      });

      test('plain neutral ink', function (assert) {
        assertHas(
          assert,
          'plain',
          'neutral',
          [
            'text-on-neutral-subtle',
            'hover:text-neutral-strong',
            'active:text-neutral-firm'
          ],
          ['text-neutral-bolder', 'hover:text-neutral-firm/80']
        );
      });

      test('outline neutral border and ink', function (assert) {
        assertHas(
          assert,
          'outline',
          'neutral',
          [
            'text-on-neutral-subtle',
            'border-on-neutral-subtle',
            'hover:bg-neutral-subtle',
            'hover:text-neutral-strong',
            'hover:border-neutral-strong',
            'active:bg-neutral-muted',
            'active:text-neutral-firm',
            'active:border-neutral-firm'
          ],
          ['text-neutral-bolder', 'border-neutral-bolder']
        );
      });
    }
  );

  module('soft hover background for secondary, success, tertiary', function () {
    for (const color of ['secondary', 'success', 'tertiary'] as const) {
      test(`soft ${color} hover uses ${color}-subtle`, function (assert) {
        assertHas(
          assert,
          'soft',
          color,
          [
            `bg-${color}-soft`,
            `hover:bg-${color}-subtle`,
            `hover:text-on-${color}-subtle`
          ],
          [`hover:bg-${color}-muted`, `hover:text-on-${color}-muted`]
        );
      });
    }

    test('primary, danger and warning soft hover is unchanged', function (assert) {
      for (const color of ['primary', 'danger', 'warning'] as const) {
        assertHas(assert, 'soft', color, [`hover:bg-${color}-muted`]);
      }
    });
  });

  module('tertiary hover ink', function () {
    for (const variant of ['subtle', 'plain', 'outline'] as const) {
      test(`${variant} tertiary hover ink is tertiary`, function (assert) {
        assertHas(
          assert,
          variant,
          'tertiary',
          ['hover:text-tertiary'],
          ['hover:text-tertiary-firm']
        );
      });
    }

    test('subtle and outline tertiary keep their firm hover border', function (assert) {
      assertHas(assert, 'subtle', 'tertiary', ['hover:border-tertiary-firm']);
      assertHas(assert, 'outline', 'tertiary', ['hover:border-tertiary-firm']);
    });
  });

  module('secondary pressed state', function () {
    test('subtle secondary pressed background is secondary-mild', function (assert) {
      assertHas(
        assert,
        'subtle',
        'secondary',
        ['active:bg-secondary-mild', 'active:text-secondary-bolder'],
        ['active:bg-secondary-muted']
      );
    });

    test('plain secondary pressed gains the soft background', function (assert) {
      assertHas(assert, 'plain', 'secondary', [
        'active:bg-secondary-soft',
        'active:border-secondary-soft',
        'active:text-secondary-bolder'
      ]);
    });
  });

  module('kept as is', function () {
    test('solid keeps elevation-2 and the generated on-colors', function (assert) {
      for (const color of [
        'primary',
        'secondary',
        'tertiary',
        'success',
        'warning',
        'danger'
      ] as const) {
        assertHas(assert, 'solid', color, [
          'shadow-elevation-2',
          `bg-${color}`,
          `text-on-${color}`,
          `hover:text-on-${color}-mild`,
          `active:text-on-${color}-firm`
        ]);
      }
      assertHas(assert, 'solid', 'neutral', ['shadow-elevation-2']);
    });

    test('ghost neutral is unchanged', function (assert) {
      assertHas(assert, 'ghost', 'neutral', [
        'text-neutral-bolder',
        'hover:bg-neutral-subtle',
        'hover:text-neutral-firm/80',
        'active:bg-neutral-muted',
        'active:text-neutral-firm'
      ]);
    });

    test('ghost tertiary keeps its firm hover ink', function (assert) {
      assertHas(assert, 'ghost', 'tertiary', ['hover:text-tertiary-firm']);
    });

    test('soft tertiary pressed is unchanged', function (assert) {
      assertHas(assert, 'soft', 'tertiary', [
        'active:bg-tertiary-mild',
        'active:text-on-tertiary-mild'
      ]);
    });

    test('custom neutral does not pick up the new neutral', function (assert) {
      assert.false(
        tokens('custom', 'neutral').some((c) => c.includes('on-neutral-subtle'))
      );
    });

    test('toggle button selected neutral keeps neutral-bolder', function (assert) {
      const cls = realStyles.toggleButton({
        variant: 'outline',
        color: 'neutral',
        isSelected: true
      } as Parameters<typeof realStyles.toggleButton>[0]);
      assert.true(cls.split(/\s+/).includes('bg-neutral-bolder'));
    });
  });

  module('contrast sanity for plain-ink ramps', function () {
    // Known failure, deliberately NOT asserted: the spec's soft/subtle neutral
    // pressed state is plain `neutral-firm` ink on a `neutral-mild` fill, which
    // is 1.87:1 in dark mode (the old soft pressed used `on-neutral-mild`).
    // Light mode passes. Restyling it is a design decision (DSYS-457 report).
    const pairs: [string, string, string][] = [
      ['soft hover: neutral-strong on neutral-soft', 'strong', 'soft'],
      ['outline hover: neutral-strong on neutral-subtle', 'strong', 'subtle'],
      ['outline pressed: neutral-firm on neutral-muted', 'firm', 'muted']
    ];
    test('light soft pressed: neutral-firm on neutral-mild is >= 4.5:1', function (assert) {
      const neutral = (
        semanticColors.light as unknown as { neutral: Record<string, string> }
      ).neutral;
      const ratio = wcagContrast(neutral.firm!, neutral.mild!);
      assert.true(ratio >= 4.5, `${ratio.toFixed(2)}:1`);
    });

    for (const theme of ['light', 'dark'] as const) {
      for (const [name, ink, bg] of pairs) {
        test(`${theme} ${name} is >= 4.5:1`, function (assert) {
          const neutral = (
            semanticColors[theme] as unknown as {
              neutral: Record<string, string>;
            }
          ).neutral;
          const ratio = wcagContrast(neutral[ink]!, neutral[bg]!);
          assert.true(ratio >= 4.5, `${ratio.toFixed(2)}:1`);
        });
      }
    }
  });
});
