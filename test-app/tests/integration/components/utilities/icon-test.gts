import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { hash } from '@ember/helper';
import { Icon } from 'frontile';

const Mark = <template>
  <svg viewBox="0 0 24 24" data-test-svg><path d="M0 0h24v24H0z" /></svg>
</template>;

const style = (selector: string) =>
  getComputedStyle(document.querySelector(selector) as HTMLElement);
const px = (value: string) => parseFloat(value);

module('Integration | Component | @frontile/utilities/Icon', function (hooks) {
  setupRenderingTest(hooks);

  module('default', function () {
    test('it is a plain icon: no fill, no ring, and it inherits the text color', async function (assert) {
      await render(
        <template>
          <span class="text-danger-strong" data-test-parent>
            <Icon data-test-icon><Mark /></Icon>
          </span>
        </template>
      );

      const icon = style('[data-test-icon]');
      assert.strictEqual(
        icon.backgroundColor,
        'rgba(0, 0, 0, 0)',
        'no background'
      );
      assert.strictEqual(icon.borderTopWidth, '0px', 'no border');
      assert.strictEqual(
        icon.color,
        style('[data-test-parent]').color,
        'color is inherited'
      );
    });

    test('it renders the block it is given', async function (assert) {
      await render(
        <template>
          <Icon><Mark /></Icon>
        </template>
      );
      assert.dom('[data-test-svg]').exists();
    });
  });

  module('size', function () {
    // [size, circle px, glyph px]. The glyph px are what platform-web's
    // icon-canvas renders today, so swapping it for Icon changes nothing.
    const sizes = [
      ['4xs', 16, 12.3],
      ['3xs', 20, 14.06],
      ['2xs', 24, 16],
      ['xs', 32, 20.7],
      ['sm', 40, 23.6],
      ['md', 48, 32.6],
      ['lg', 64, 39.7],
      ['xl', 72, 39.7],
      ['2xl', 80, 48.1],
      ['3xl', 96, 54.9]
    ] as const;

    for (const [size, circle, glyph] of sizes) {
      test(`@size="${size}" is a ${circle}px circle with a ${glyph}px icon`, async function (assert) {
        await render(
          <template>
            <Icon @size={{size}} data-test-icon><Mark /></Icon>
          </template>
        );

        const icon = style('[data-test-icon]');
        assert.strictEqual(px(icon.width), circle, 'width');
        assert.strictEqual(px(icon.height), circle, 'height');
        assert.strictEqual(icon.flexShrink, '0', 'does not shrink');

        const mark = style('[data-test-svg]');
        assert.true(
          Math.abs(px(mark.width) - glyph) < 0.5,
          `icon width ${mark.width} is about ${glyph}px`
        );
        assert.true(
          Math.abs(px(mark.height) - glyph) < 0.5,
          `icon height ${mark.height} is about ${glyph}px`
        );
      });
    }

    test('it defaults to md', async function (assert) {
      await render(
        <template>
          <Icon data-test-icon><Mark /></Icon>
        </template>
      );
      assert.strictEqual(px(style('[data-test-icon]').width), 48);
    });
  });

  module('variant and color', function () {
    // Each reference is written out in full so Tailwind generates it. The
    // reference is the shipped utility for the token the variant should use.
    test('@variant="solid" fills with the color and sets the contrast text', async function (assert) {
      await render(
        <template>
          <Icon @variant="solid" @color="primary" data-test-icon><Mark /></Icon>
          <span class="bg-primary text-on-primary" data-test-ref></span>
        </template>
      );
      const icon = style('[data-test-icon]');
      const ref = style('[data-test-ref]');
      assert.strictEqual(icon.backgroundColor, ref.backgroundColor, 'fill');
      assert.strictEqual(icon.color, ref.color, 'icon color');
    });

    test('@variant="soft" uses the muted fill', async function (assert) {
      await render(
        <template>
          <Icon @variant="soft" @color="success" data-test-icon><Mark /></Icon>
          <span
            class="bg-success-muted text-on-success-muted"
            data-test-ref
          ></span>
        </template>
      );
      const icon = style('[data-test-icon]');
      const ref = style('[data-test-ref]');
      assert.strictEqual(icon.backgroundColor, ref.backgroundColor, 'fill');
      assert.strictEqual(icon.color, ref.color, 'icon color');
    });

    test('@variant="subtle" uses the subtle fill', async function (assert) {
      await render(
        <template>
          <Icon @variant="subtle" @color="warning" data-test-icon><Mark
            /></Icon>
          <span
            class="bg-warning-subtle text-on-warning-subtle"
            data-test-ref
          ></span>
        </template>
      );
      const icon = style('[data-test-icon]');
      const ref = style('[data-test-ref]');
      assert.strictEqual(icon.backgroundColor, ref.backgroundColor, 'fill');
      assert.strictEqual(icon.color, ref.color, 'icon color');
    });

    test('@variant="outline" draws a ring and no fill, inside the same box', async function (assert) {
      await render(
        <template>
          <Icon @variant="outline" @color="danger" data-test-icon><Mark
            /></Icon>
          <Icon @variant="solid" @color="danger" data-test-solid><Mark /></Icon>
          <span
            class="border border-danger text-danger-strong"
            data-test-ref
          ></span>
        </template>
      );
      const icon = style('[data-test-icon]');
      const ref = style('[data-test-ref]');
      assert.strictEqual(icon.backgroundColor, 'rgba(0, 0, 0, 0)', 'no fill');
      assert.strictEqual(icon.borderTopColor, ref.borderTopColor, 'ring color');
      assert.true(px(icon.borderTopWidth) > 0, 'ring is drawn');
      assert.strictEqual(icon.color, ref.color, 'icon color');
      assert.strictEqual(
        icon.width,
        style('[data-test-solid]').width,
        'same box as a filled icon'
      );
    });

    test('@variant="plain" with a color tints only the icon', async function (assert) {
      await render(
        <template>
          <Icon @variant="plain" @color="success" data-test-icon><Mark /></Icon>
          <span class="text-success-strong" data-test-ref></span>
        </template>
      );
      const icon = style('[data-test-icon]');
      assert.strictEqual(icon.backgroundColor, 'rgba(0, 0, 0, 0)', 'no fill');
      assert.strictEqual(icon.borderTopWidth, '0px', 'no ring');
      assert.strictEqual(icon.color, style('[data-test-ref]').color);
    });

    test('a filled variant with no @color is neutral', async function (assert) {
      await render(
        <template>
          <Icon @variant="solid" data-test-icon><Mark /></Icon>
          <span class="bg-neutral" data-test-ref></span>
        </template>
      );
      assert.strictEqual(
        style('[data-test-icon]').backgroundColor,
        style('[data-test-ref]').backgroundColor
      );
    });

    test('each color gives a different fill', async function (assert) {
      await render(
        <template>
          <Icon @variant="solid" @color="neutral" data-test-neutral><Mark
            /></Icon>
          <Icon @variant="solid" @color="primary" data-test-primary><Mark
            /></Icon>
          <Icon @variant="solid" @color="danger" data-test-danger><Mark
            /></Icon>
        </template>
      );
      const fills = ['neutral', 'primary', 'danger'].map(
        (c) => style(`[data-test-${c}]`).backgroundColor
      );
      assert.strictEqual(new Set(fills).size, 3, fills.join(' | '));
    });
  });

  module('@inverse', function () {
    test('it resolves its colors in the opposite scheme', async function (assert) {
      await render(
        <template>
          <div class="light">
            <Icon @variant="solid" @color="neutral" data-test-plain><Mark
              /></Icon>
            <Icon
              @variant="solid"
              @color="neutral"
              @inverse={{true}}
              data-test-inverse
            ><Mark /></Icon>
          </div>
        </template>
      );
      assert.notStrictEqual(
        style('[data-test-inverse]').backgroundColor,
        style('[data-test-plain]').backgroundColor
      );
      assert.dom('[data-test-inverse]').hasClass('theme-inverse');
      assert.dom('[data-test-plain]').doesNotHaveClass('theme-inverse');
    });
  });

  module('accessibility', function () {
    test('without @label it is decorative and hidden from screen readers', async function (assert) {
      await render(
        <template>
          <Icon data-test-icon><Mark /></Icon>
        </template>
      );
      assert.dom('[data-test-icon]').hasAttribute('aria-hidden', 'true');
      assert.dom('[data-test-icon]').doesNotHaveAttribute('role');
    });

    test('@label makes it an image with that name', async function (assert) {
      await render(
        <template>
          <Icon @label="Warning" data-test-icon><Mark /></Icon>
        </template>
      );
      assert.dom('[data-test-icon]').hasAttribute('role', 'img');
      assert.dom('[data-test-icon]').hasAttribute('aria-label', 'Warning');
      assert.dom('[data-test-icon]').doesNotHaveAttribute('aria-hidden');
    });
  });

  module('customizing', function () {
    test('...attributes land on the root span', async function (assert) {
      await render(
        <template>
          <Icon data-test-icon id="mine"><Mark /></Icon>
        </template>
      );
      assert.dom('span#mine[data-test-icon]').exists();
    });

    test('@classes.base is merged into the root', async function (assert) {
      await render(
        <template>
          <Icon @classes={{hash base="custom-base"}} data-test-icon><Mark
            /></Icon>
        </template>
      );
      assert.dom('[data-test-icon]').hasClass('custom-base');
    });
  });
});
