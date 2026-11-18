import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { Card } from 'frontile';
import { realStyles } from '../../../helpers/real-theme-styles';

// `card` has a single class set and no slots, so it returns the class string.
const base = (props?: Parameters<typeof realStyles.card>[0]) =>
  realStyles.card(props);

// Whole class names, so `includes('border-primary')` cannot be satisfied by
// `hover:border-primary-muted`.
const tokens = (cls: string) => cls.split(/\s+/);

module('Integration | Component | Card | @frontile/utilities', function () {
  module('recipe', function () {
    test('defaults are outline, neutral, comfortable, raised', function (assert) {
      const t = tokens(base());
      for (const c of [
        'border',
        'rounded-[20px]',
        'bg-surface-card',
        'border-neutral-muted',
        'p-5',
        'shadow-elevation-2'
      ]) {
        assert.true(t.includes(c), `has ${c}`);
      }
      assert.false(t.includes('border-2'), 'the border is never 2px');
    });

    // The border is 1px in every variant and state, so states never shift the
    // layout. Only selected has a thicker border, and only under forced-colors.
    test('no variant or state sets a border wider than 1px outside forced-colors', function (assert) {
      for (const variant of ['outline', 'flat', 'soft'] as const) {
        for (const isSelected of [false, true]) {
          for (const isInteractive of [false, true]) {
            const t = tokens(base({ variant, isSelected, isInteractive }));
            const widths = t.filter(
              (c) =>
                /^(\w+:)*border(-\d+|-\[\d+px\])$/.test(c) &&
                !c.startsWith('forced-colors:')
            );
            assert.deepEqual(
              widths,
              [],
              `${variant} selected=${isSelected} interactive=${isInteractive}`
            );
            assert.true(t.includes('border'), 'has the 1px border');
          }
        }
      }
    });

    test('hover adds a 1px inset layer in the hover border colour, unselected only', function (assert) {
      const primary = tokens(base({ isInteractive: true, color: 'primary' }));
      assert.true(
        primary.includes(
          'hover:inset-shadow-[0_0_0_1px_var(--color-primary-muted)]'
        )
      );
      const neutral = tokens(base({ isInteractive: true }));
      assert.true(
        neutral.includes(
          'hover:inset-shadow-[0_0_0_1px_var(--color-neutral-soft)]'
        )
      );
      const selected = tokens(
        base({ isInteractive: true, isSelected: true, color: 'primary' })
      );
      assert.false(selected.some((c) => c.startsWith('hover:inset-shadow')));
      assert.false(
        tokens(base({ isInteractive: true, isDisabled: true })).some((c) =>
          c.includes('inset-shadow')
        )
      );
      assert.false(tokens(base()).some((c) => c.includes('inset-shadow')));
    });

    test('hover inset layer is kept when elevation is none', function (assert) {
      const t = tokens(base({ isInteractive: true, elevation: 'none' }));
      assert.true(
        t.includes('hover:inset-shadow-[0_0_0_1px_var(--color-neutral-soft)]')
      );
    });

    test('selected adds a 1px inset layer in the border colour, and no ring or outline', function (assert) {
      const primary = tokens(base({ isSelected: true, color: 'primary' }));
      assert.true(
        primary.includes('inset-shadow-[0_0_0_1px_var(--color-primary)]')
      );
      const neutral = tokens(base({ isSelected: true }));
      assert.true(
        neutral.includes('inset-shadow-[0_0_0_1px_var(--color-neutral-bolder)]')
      );
      for (const t of [primary, neutral]) {
        assert.false(t.some((c) => /^(ring-(?!offset)|ring$|outline)/.test(c)));
        assert.true(t.includes('shadow-elevation-2'), 'elevation is kept');
      }
    });

    test('selected and disabled keeps the inset layer', function (assert) {
      const t = tokens(
        base({ isSelected: true, isDisabled: true, color: 'primary' })
      );
      assert.true(t.includes('inset-shadow-[0_0_0_1px_var(--color-primary)]'));
    });

    test('selected thickens the border under forced-colors, where box-shadow is not drawn', function (assert) {
      assert.true(
        tokens(base({ isSelected: true })).includes(
          'forced-colors:border-[3px]'
        )
      );
      assert.false(tokens(base()).some((c) => c.startsWith('forced-colors:')));
    });

    test('flat has a transparent border and no shadow', function (assert) {
      const cls = base({ variant: 'flat' });
      assert.true(cls.includes('border-transparent'));
      assert.false(cls.includes('shadow-elevation'));
    });

    test('soft has the overlay-soft fill, a transparent border and no shadow', function (assert) {
      const cls = base({ variant: 'soft' });
      assert.true(tokens(cls).includes('bg-surface-overlay-soft'));
      assert.false(tokens(cls).includes('bg-surface-card'));
      assert.true(cls.includes('border-transparent'));
      assert.false(cls.includes('shadow-elevation'));
    });

    // In dark mode `surface-card` and `surface-overlay-subtle` are the same
    // colour (white @ 7%), so a fill, hover or pressed state that used
    // `overlay-subtle` against a card fill would be invisible there. Every
    // interactive step has to be a different level from the one before it.
    for (const variant of ['outline', 'flat', 'soft'] as const) {
      test(`${variant}: pressed is distinct from rest and hover, and never overlay-subtle`, function (assert) {
        const t = tokens(base({ variant, isInteractive: true }));
        const bg = (prefix: string) =>
          t.find((c) => c.startsWith(`${prefix}bg-surface-`));
        const rest = t.find(
          (c) => c.startsWith('bg-surface-') && !c.includes(':')
        );
        const hover = bg('hover:');
        const active = bg('active:');

        assert.ok(active, 'has a pressed fill');
        assert.notStrictEqual(active?.replace('active:', ''), rest);
        assert.notStrictEqual(
          active?.replace('active:', ''),
          hover?.replace('hover:', '')
        );
        assert.false(
          active?.endsWith('overlay-subtle'),
          'pressed is not overlay-subtle'
        );
        if (hover) {
          assert.notStrictEqual(hover.replace('hover:', ''), rest);
          assert.false(
            hover.endsWith('overlay-subtle'),
            'hover is not overlay-subtle'
          );
        }
      });
    }

    test('flat hover steps up to overlay-soft and soft hover to overlay-mild', function (assert) {
      assert.true(
        tokens(base({ variant: 'flat', isInteractive: true })).includes(
          'hover:bg-surface-overlay-soft'
        )
      );
      assert.true(
        tokens(base({ variant: 'soft', isInteractive: true })).includes(
          'hover:bg-surface-overlay-mild'
        )
      );
    });

    test('density maps to padding', function (assert) {
      assert.true(base({ density: 'compact' }).includes('p-3'));
      assert.true(base({ density: 'spacious' }).includes('p-8'));
    });

    test('elevation none removes every shadow', function (assert) {
      const cls = base({ elevation: 'none', isInteractive: true });
      assert.false(cls.includes('shadow-elevation'));
    });

    test('static card has no interactive classes', function (assert) {
      const cls = base();
      assert.false(cls.includes('hover:'));
      assert.false(cls.includes('active:'));
      assert.false(cls.includes('cursor-pointer'));
    });

    test('interactive outline hovers to primary-muted and elevation-3', function (assert) {
      const cls = base({ isInteractive: true, color: 'primary' });
      for (const c of [
        'hover:border-primary-muted',
        'hover:shadow-elevation-3',
        'cursor-pointer',
        'focus-visible:ring-3'
      ]) {
        assert.true(cls.includes(c), `has ${c}`);
      }
    });

    test('neutral interactive hovers to neutral-soft', function (assert) {
      assert.true(
        base({ isInteractive: true }).includes('hover:border-neutral-soft')
      );
    });

    test('selected uses the colour border and never the unselected hover border', function (assert) {
      const primary = base({
        isSelected: true,
        isInteractive: true,
        color: 'primary'
      });
      assert.true(primary.includes('border-primary'));
      assert.false(primary.includes('hover:border-primary-muted'));
      assert.true(
        base({ isSelected: true, color: 'neutral' }).includes(
          'border-neutral-bolder'
        )
      );
    });

    test('disabled has no hover or pointer classes even when interactive', function (assert) {
      const cls = base({ isDisabled: true, isInteractive: true });
      assert.true(cls.includes('opacity-disabled'));
      assert.true(cls.includes('cursor-not-allowed'));
      assert.false(cls.includes('hover:'));
      assert.false(cls.includes('cursor-pointer'));
    });

    test('selected and disabled keeps the selected border', function (assert) {
      const cls = base({
        isSelected: true,
        isDisabled: true,
        color: 'primary'
      });
      assert.true(cls.includes('border-primary'));
      assert.true(cls.includes('opacity-disabled'));
    });

    test('card is a positioning context for its indicator', function (assert) {
      assert.true(tokens(base()).includes('relative'));
    });

    // Offsets are measured from the padding box, inside the 1px border, so
    // -top-1.25 (5px) puts the circle 4px past the card's outer edge.
    test('indicator is a small circle overhanging the top-right corner', function (assert) {
      const t = tokens(realStyles.cardIndicator());
      for (const c of [
        'absolute',
        '-top-1.25',
        '-right-1.25',
        'size-5',
        'rounded-full',
        'motion-reduce:transition-none'
      ]) {
        assert.true(t.includes(c), `has ${c}`);
      }
    });

    test('indicator fill follows color', function (assert) {
      const primary = tokens(realStyles.cardIndicator({ color: 'primary' }));
      assert.true(primary.includes('bg-primary'));
      assert.true(primary.includes('text-on-primary'));
      const neutral = tokens(realStyles.cardIndicator({ color: 'neutral' }));
      assert.true(neutral.includes('bg-neutral-bolder'));
      assert.true(neutral.includes('text-on-neutral-bolder'));
    });
  });

  module('component', function (hooks) {
    setupRenderingTest(hooks);

    test('it renders its contents in a div', async function (assert) {
      await render(
        <template>
          <Card data-test-card>Hello</Card>
        </template>
      );

      assert.dom('[data-test-card]').hasTagName('div');
      assert.dom('[data-test-card]').hasText('Hello');
      assert.dom('[data-test-card]').hasAttribute('data-component', 'card');
      assert.dom('[data-test-card]').hasAttribute('data-part', 'base');
    });

    test('it publishes state hooks only when set', async function (assert) {
      await render(
        <template>
          <Card data-test-plain />
          <Card @isSelected={{true}} data-test-selected />
          <Card @isDisabled={{true}} data-test-disabled />
        </template>
      );

      assert.dom('[data-test-plain]').doesNotHaveAttribute('data-selected');
      assert.dom('[data-test-plain]').doesNotHaveAttribute('data-disabled');
      assert.dom('[data-test-selected]').hasAttribute('data-selected');
      assert.dom('[data-test-disabled]').hasAttribute('data-disabled');
    });

    test('it forwards attributes and merges @class', async function (assert) {
      await render(
        <template>
          <Card
            role="radio"
            aria-checked="false"
            tabindex="0"
            @class="custom"
            data-test-card
          >x</Card>
        </template>
      );

      assert.dom('[data-test-card]').hasAttribute('role', 'radio');
      assert.dom('[data-test-card]').hasAttribute('tabindex', '0');
      assert.dom('[data-test-card]').hasClass('custom');
      assert.dom('[data-test-card]').hasClass('border');
      assert.dom('[data-test-card]').doesNotHaveClass('border-2');
    });

    test('it adds no ARIA or focusability by itself', async function (assert) {
      await render(
        <template><Card @isInteractive={{true}} data-test-card /></template>
      );

      assert.dom('[data-test-card]').doesNotHaveAttribute('role');
      assert.dom('[data-test-card]').doesNotHaveAttribute('tabindex');
      assert.dom('[data-test-card]').doesNotHaveAttribute('aria-pressed');
    });

    test('it renders with no contents', async function (assert) {
      await render(<template><Card data-test-card /></template>);

      assert.dom('[data-test-card]').exists();
      assert.dom('[data-test-card]').hasText('');
    });

    test('its args reach the recipe', async function (assert) {
      await render(
        <template>
          <Card
            @variant="soft"
            @density="spacious"
            @isDisabled={{true}}
            data-test-card
          />
        </template>
      );

      assert.dom('[data-test-card]').hasClass('bg-surface-overlay-soft');
      assert.dom('[data-test-card]').hasClass('p-8');
      assert.dom('[data-test-card]').hasClass('opacity-disabled');
    });

    test('no indicator block means no indicator, even when selected', async function (assert) {
      await render(
        <template>
          <Card @isSelected={{true}} data-test-card>x</Card>
        </template>
      );

      assert.dom('[data-part="indicator"]').doesNotExist();
    });

    test('an indicator block is hidden while the card is not selected', async function (assert) {
      await render(
        <template>
          <Card data-test-card>
            <:default>Plan</:default>
            <:indicator>✓</:indicator>
          </Card>
        </template>
      );

      assert.dom('[data-test-card]').hasText('Plan');
      assert.dom('[data-part="indicator"]').doesNotExist();
    });

    test('a selected card with an indicator block shows it, decoratively', async function (assert) {
      await render(
        <template>
          <Card @isSelected={{true}} data-test-card>
            <:default>Plan</:default>
            <:indicator><svg data-test-icon></svg></:indicator>
          </Card>
        </template>
      );

      assert.dom('[data-test-card]').containsText('Plan');
      assert
        .dom('[data-test-card] [data-part="indicator"]')
        .hasAttribute('aria-hidden', 'true');
      assert
        .dom('[data-part="indicator"] [data-test-icon]')
        .exists('the call site supplies the icon');
    });

    test('the indicator takes its fill from @color', async function (assert) {
      await render(
        <template>
          <Card @isSelected={{true}} @color="primary">
            <:default>Plan</:default>
            <:indicator>✓</:indicator>
          </Card>
        </template>
      );

      assert.dom('[data-part="indicator"]').hasClass('bg-primary');
    });
  });
});
