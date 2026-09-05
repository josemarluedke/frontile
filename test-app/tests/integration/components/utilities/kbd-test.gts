import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { hash } from '@ember/helper';
import { Kbd, setKbdPlatform } from 'frontile';

module('Integration | Component | @frontile/utilities/Kbd', function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    // Pinned so these assertions do not depend on the machine running them.
    setKbdPlatform('apple');
  });

  hooks.afterEach(function () {
    setKbdPlatform('auto');
  });

  module('structure', function () {
    test('it nests one kbd per key inside a wrapper kbd', async function (assert) {
      await render(<template><Kbd @keys="mod+shift+p" /></template>);

      assert.dom('[data-test-id="kbd"]').hasTagName('kbd');
      assert.dom('[data-test-id="kbd"]').hasAttribute('data-component', 'kbd');
      assert.dom('[data-test-id="kbd-key"]').exists({ count: 3 });

      const caps = [
        ...document.querySelectorAll('[data-test-id="kbd-key"]')
      ].map((el) => el.textContent?.replace(/\s+/g, ' ').trim());

      // Symbol keys carry their spoken name alongside the glyph; a plain
      // letter needs none.
      assert.deepEqual(caps, ['⌘ Command', '⇧ Shift', 'P']);
    });

    test('a single key still renders a wrapper and one cap', async function (assert) {
      await render(<template><Kbd @keys="esc" /></template>);

      assert.dom('[data-test-id="kbd"]').hasTagName('kbd');
      assert.dom('[data-test-id="kbd-key"]').exists({ count: 1 });
      assert.dom('[data-test-id="kbd-key"]').hasText('Esc');
    });

    test('block content renders as a single cap and wins over @keys', async function (assert) {
      await render(
        <template>
          <Kbd @keys="mod+k">Custom</Kbd>
        </template>
      );

      assert.dom('[data-test-id="kbd-key"]').exists({ count: 1 });
      assert.dom('[data-test-id="kbd-key"]').hasText('Custom');
    });

    test('merged puts every glyph in one cap', async function (assert) {
      await render(
        <template><Kbd @keys="mod+k" @display="merged" /></template>
      );

      assert.dom('[data-test-id="kbd-key"]').exists({ count: 1 });
      assert
        .dom('[data-test-id="kbd-key"] [aria-hidden="true"]')
        .hasText('⌘K', 'glyphs concatenate with no gap between them');
      assert
        .dom('[data-test-id="kbd-key"] .sr-only')
        .hasText(
          'Command K',
          'a run of glyphs is unintelligible aloud, so the names are spoken'
        );
    });

    test('a separator renders between caps but not before the first', async function (assert) {
      await render(<template><Kbd @keys="ctrl+b" @separator="+" /></template>);

      assert.dom('[data-test-id="kbd-separator"]').exists({ count: 1 });
      assert.dom('[data-test-id="kbd-separator"]').hasText('+');
      assert
        .dom('[data-test-id="kbd-separator"]')
        .hasAttribute('aria-hidden', 'true');
    });

    test('no keys renders no caps', async function (assert) {
      await render(<template><Kbd @keys="" /></template>);

      assert.dom('[data-test-id="kbd"]').exists();
      assert.dom('[data-test-id="kbd-key"]').doesNotExist();
    });
  });

  module('accessibility', function () {
    test('a symbol glyph is hidden and its name spoken', async function (assert) {
      await render(<template><Kbd @keys="mod" /></template>);

      assert
        .dom('[data-test-id="kbd-key"] [aria-hidden="true"]')
        .hasText('⌘', 'the glyph itself says nothing useful aloud');
      assert.dom('[data-test-id="kbd-key"] .sr-only').hasText('Command');
    });

    test('a readable glyph gets no spoken label', async function (assert) {
      await render(<template><Kbd @keys="esc" /></template>);

      assert
        .dom('[data-test-id="kbd-key"] .sr-only')
        .doesNotExist(
          'labelling Esc would make a screen reader say "Escape Escape"'
        );
    });

    test('a merged cap follows the same two rules as a split one', async function (assert) {
      await render(<template><Kbd @keys="esc" @display="merged" /></template>);

      assert
        .dom('[data-test-id="kbd-key"] .sr-only')
        .doesNotExist(
          'Esc reads correctly on its own, so merging must not make it say "Esc Escape"'
        );
      assert.dom('[data-test-id="kbd-key"]').hasAttribute('title', 'Escape');

      await render(
        <template><Kbd @keys="mod+shift+p" @display="merged" /></template>
      );

      assert
        .dom('[data-test-id="kbd-key"] .sr-only')
        .hasText('Command Shift P', 'a run containing symbols is spoken');
      assert
        .dom('[data-test-id="kbd-key"]')
        .hasAttribute('title', 'Command Shift');
    });

    test('named keys carry a title; literals do not', async function (assert) {
      await render(<template><Kbd @keys="mod+k" /></template>);

      const caps = document.querySelectorAll('[data-test-id="kbd-key"]');

      assert.dom(caps[0]).hasAttribute('title', 'Command');
      assert.dom(caps[1]).doesNotHaveAttribute('title');
    });
  });

  module('platform', function () {
    test('@platform overrides the module setting for this keycap only', async function (assert) {
      await render(<template><Kbd @keys="mod" @platform="other" /></template>);

      assert.dom('[data-test-id="kbd-key"]').hasText('Ctrl');
      assert
        .dom('[data-test-id="kbd-key"]')
        .hasAttribute(
          'title',
          'Control',
          'the name follows the glyph actually shown'
        );
    });
  });

  module('styling', function () {
    test('size, intent and appearance apply their classes', async function (assert) {
      await render(
        <template>
          <Kbd @keys="k" @size="lg" @intent="danger" @appearance="faded" />
        </template>
      );

      assert.dom('[data-test-id="kbd-key"]').hasClass('h-7');
      assert.dom('[data-test-id="kbd-key"]').hasClass('bg-danger-subtle');
      assert.dom('[data-test-id="kbd-key"]').hasClass('border-danger-soft');
    });

    test('inherit and plain follow the surrounding colour', async function (assert) {
      await render(
        <template>
          <Kbd @keys="k" @appearance="inherit" data-test-inherit />
          <Kbd @keys="k" @appearance="plain" data-test-plain />
        </template>
      );

      assert
        .dom('[data-test-inherit] [data-test-id="kbd-key"]')
        .hasClass('text-current');
      assert
        .dom('[data-test-plain] [data-test-id="kbd-key"]')
        .hasClass('border-0', 'plain drops the box entirely');
    });

    test('@class and @classes override the defaults', async function (assert) {
      await render(
        <template>
          <Kbd
            @keys="k"
            @class="custom-base"
            @classes={{hash key="custom-key"}}
          />
        </template>
      );

      assert.dom('[data-test-id="kbd"]').hasClass('custom-base');
      assert.dom('[data-test-id="kbd-key"]').hasClass('custom-key');
    });
  });
});
