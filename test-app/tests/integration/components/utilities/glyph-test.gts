import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { Glyph } from 'frontile';

module('Integration | Component | @frontile/utilities/Glyph', function (hooks) {
  setupRenderingTest(hooks);

  test('@name becomes the icon-font class the consumer supplies', async function (assert) {
    await render(
      <template><Glyph @name="chevron-down" data-test-glyph /></template>
    );

    assert.dom('[data-test-glyph]').hasClass('icon');
    assert.dom('[data-test-glyph]').hasClass('icon-chevron-down');
  });

  module('accessibility', function () {
    test('is hidden from assistive tech by default, since most glyphs only decorate', async function (assert) {
      await render(
        <template><Glyph @name="check" data-test-glyph /></template>
      );

      assert.dom('[data-test-glyph]').hasAttribute('aria-hidden', 'true');
      assert.dom('[data-test-glyph]').doesNotHaveAttribute('role');
      assert.dom('[data-test-glyph]').doesNotHaveAttribute('aria-label');
    });

    test('@label makes it an image with that name', async function (assert) {
      await render(
        <template>
          <Glyph @name="alert" @label="Warning" data-test-glyph />
        </template>
      );

      assert.dom('[data-test-glyph]').hasAttribute('role', 'img');
      assert.dom('[data-test-glyph]').hasAttribute('aria-label', 'Warning');
      assert.dom('[data-test-glyph]').doesNotHaveAttribute('aria-hidden');
    });
  });

  module('attributes', function () {
    test('@class merges with the defaults and ...attributes pass through', async function (assert) {
      await render(
        <template>
          <Glyph
            @name="check"
            @class="text-primary"
            data-test-glyph
            title="Done"
          />
        </template>
      );

      assert.dom('[data-test-glyph]').hasClass('text-primary');
      assert.dom('[data-test-glyph]').hasClass('icon-check');
      assert.dom('[data-test-glyph]').hasAttribute('title', 'Done');
    });
  });

  module('size', function () {
    // The ten steps are the names of Button's label ramp, so an icon at a
    // step matches the text at that step. The class reads the ramp's token
    // rather than copying a number, so it follows the ramp if it moves.
    const sizes = [
      '4xs',
      '3xs',
      '2xs',
      'xs',
      'sm',
      'md',
      'lg',
      'xl',
      '2xl',
      '3xl'
    ] as const;

    for (const size of sizes) {
      test(`${size} takes its font size from the Button text ramp`, async function (assert) {
        await render(
          <template>
            <Glyph @name="check" @size={{size}} data-test-glyph />
          </template>
        );

        assert
          .dom('[data-test-glyph]')
          .hasClass(`text-(length:--text-strong-${size})`);
      });
    }

    // Classes are written out in full so Tailwind generates each one for the
    // test build; the reference is the shipped `text-strong-*` utility, an
    // independent route to the same token.
    const REFERENCE = {
      '4xs': 'text-strong-4xs',
      '3xs': 'text-strong-3xs',
      '2xs': 'text-strong-2xs',
      xs: 'text-strong-xs',
      sm: 'text-strong-sm',
      md: 'text-strong-md',
      lg: 'text-strong-lg',
      xl: 'text-strong-xl',
      '2xl': 'text-strong-2xl',
      '3xl': 'text-strong-3xl'
    } as const;

    for (const size of sizes) {
      test(`${size} renders at the same pixel size as text-strong-${size}`, async function (assert) {
        const reference = REFERENCE[size];

        await render(
          <template>
            <span class={{reference}} data-test-reference>Aa</span>
            <Glyph @name="check" @size={{size}} data-test-glyph />
          </template>
        );

        const expected = getComputedStyle(
          document.querySelector('[data-test-reference]') as HTMLElement
        ).fontSize;
        const actual = getComputedStyle(
          document.querySelector('[data-test-glyph]') as HTMLElement
        ).fontSize;

        assert.strictEqual(actual, expected);
      });
    }

    test('the ten steps get progressively larger, so the comparison above is not vacuous', async function (assert) {
      await render(
        <template>
          {{#each sizes as |size|}}
            <Glyph @name="check" @size={{size}} data-test-step={{size}} />
          {{/each}}
        </template>
      );

      const px = sizes.map((size) =>
        parseFloat(
          getComputedStyle(
            document.querySelector(`[data-test-step="${size}"]`) as HTMLElement
          ).fontSize
        )
      );

      px.slice(1).forEach((value, index) => {
        assert.true(
          value > (px[index] as number),
          `${sizes[index + 1]} (${value}px) is larger than ${sizes[index]} (${px[index]}px)`
        );
      });
    });

    test('inherit renders at the size of the surrounding text', async function (assert) {
      await render(
        <template>
          <span style="font-size: 40px">
            <Glyph @name="check" @size="inherit" data-test-glyph />
          </span>
        </template>
      );

      assert.dom('[data-test-glyph]').hasStyle({ fontSize: '40px' });
    });

    test('@class can override the size', async function (assert) {
      await render(
        <template>
          <Glyph
            @name="check"
            @size="sm"
            @class="text-[2rem]"
            data-test-glyph
          />
        </template>
      );

      assert.dom('[data-test-glyph]').hasStyle({ fontSize: '32px' });
    });

    test('inherit follows the surrounding text instead of a ramp step', async function (assert) {
      await render(
        <template>
          <span style="font-size: 40px">
            <Glyph @name="check" @size="inherit" data-test-glyph />
          </span>
        </template>
      );

      assert.dom('[data-test-glyph]').hasClass('text-[1em]');
      assert
        .dom('[data-test-glyph]')
        .doesNotHaveClass('text-(length:--text-strong-md)');
    });

    test('md is the default size', async function (assert) {
      await render(
        <template><Glyph @name="check" data-test-glyph /></template>
      );

      assert
        .dom('[data-test-glyph]')
        .hasClass('text-(length:--text-strong-md)');
    });
  });
});
