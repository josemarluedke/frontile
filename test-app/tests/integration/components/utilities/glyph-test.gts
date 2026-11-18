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
