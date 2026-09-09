import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { hash } from '@ember/helper';
import { ExternalLink } from 'frontile';

module(
  'Integration | Component | @frontile/navigation/ExternalLink',
  function (hooks) {
    setupRenderingTest(hooks);

    module('structure', function () {
      test('it renders an anchor with the href and the yielded content', async function (assert) {
        await render(
          <template>
            <ExternalLink @href="https://frontile.dev">Frontile</ExternalLink>
          </template>
        );

        assert.dom('[data-test-id="external-link"]').hasTagName('a');
        assert
          .dom('[data-test-id="external-link"]')
          .hasAttribute('data-component', 'external-link');
        assert
          .dom('[data-test-id="external-link"]')
          .hasAttribute('href', 'https://frontile.dev');
        assert.dom('[data-test-id="external-link"]').containsText('Frontile');
      });

      test('attributes are spread onto the anchor', async function (assert) {
        await render(
          <template>
            <ExternalLink
              @href="https://frontile.dev"
              id="cta"
              data-test-spread
            >Frontile</ExternalLink>
          </template>
        );

        assert.dom('[data-test-spread]').hasAttribute('id', 'cta');
        assert.dom('[data-test-spread]').hasTagName('a');
      });
    });

    module('target and rel', function () {
      test('it opens a new tab and protects the opener by default', async function (assert) {
        await render(
          <template>
            <ExternalLink @href="https://frontile.dev">Frontile</ExternalLink>
          </template>
        );

        assert
          .dom('[data-test-id="external-link"]')
          .hasAttribute('target', '_blank');
        assert
          .dom('[data-test-id="external-link"]')
          .hasAttribute('rel', 'noopener noreferrer');
      });

      // `_self` stays in the current browsing context, so there is no opener to
      // protect -- emitting `rel` there would be meaningless noise.
      test('a _self target emits no rel', async function (assert) {
        await render(
          <template>
            <ExternalLink
              @href="https://frontile.dev"
              @target="_self"
            >Frontile</ExternalLink>
          </template>
        );

        assert
          .dom('[data-test-id="external-link"]')
          .hasAttribute('target', '_self');
        assert.dom('[data-test-id="external-link"]').hasNoAttribute('rel');
      });

      // A named target is a new browsing context just as `_blank` is.
      test('a named target is still treated as a new context', async function (assert) {
        await render(
          <template>
            <ExternalLink
              @href="https://frontile.dev"
              @target="docs"
            >Frontile</ExternalLink>
          </template>
        );

        assert
          .dom('[data-test-id="external-link"]')
          .hasAttribute('rel', 'noopener noreferrer');
      });

      // The whole reason the implementation uses `??` rather than `||`: an
      // explicit empty string has to clear the default, not fall back to it.
      test('an empty @rel clears the default', async function (assert) {
        await render(
          <template>
            <ExternalLink
              @href="https://frontile.dev"
              @rel=""
            >Frontile</ExternalLink>
          </template>
        );

        assert.dom('[data-test-id="external-link"]').hasAttribute('rel', '');
      });

      test('@rel replaces the default verbatim', async function (assert) {
        await render(
          <template>
            <ExternalLink
              @href="https://frontile.dev"
              @rel="nofollow"
            >Frontile</ExternalLink>
          </template>
        );

        assert
          .dom('[data-test-id="external-link"]')
          .hasAttribute('rel', 'nofollow');
      });
    });

    module('accessibility', function () {
      test('it announces that the link opens a new tab', async function (assert) {
        await render(
          <template>
            <ExternalLink @href="https://frontile.dev">Frontile</ExternalLink>
          </template>
        );

        assert
          .dom('[data-test-id="external-link-new-tab-label"]')
          .hasText('(opens in a new tab)');
        assert
          .dom('[data-test-id="external-link-new-tab-label"]')
          .hasClass('sr-only');
      });

      // The space between the link text and the announcement lives inside the
      // out-of-flow span, on a `prettier-ignore` line where it is invisible.
      // Without it a screen reader runs the two together as "Frontile(opens".
      test('the announcement is separated from the link text', async function (assert) {
        await render(
          <template>
            <ExternalLink @href="https://frontile.dev">Frontile</ExternalLink>
          </template>
        );

        const label = document.querySelector(
          '[data-test-id="external-link-new-tab-label"]'
        );

        assert.strictEqual(
          label?.textContent,
          ' (opens in a new tab)',
          'the label carries its own leading space'
        );
      });

      test('@newTabLabel customises the wording', async function (assert) {
        await render(
          <template>
            <ExternalLink
              @href="https://frontile.dev"
              @newTabLabel="(abre em uma nova aba)"
            >Frontile</ExternalLink>
          </template>
        );

        assert
          .dom('[data-test-id="external-link-new-tab-label"]')
          .hasText('(abre em uma nova aba)');
      });

      test('an empty @newTabLabel suppresses the announcement', async function (assert) {
        await render(
          <template>
            <ExternalLink
              @href="https://frontile.dev"
              @newTabLabel=""
            >Frontile</ExternalLink>
          </template>
        );

        assert
          .dom('[data-test-id="external-link-new-tab-label"]')
          .doesNotExist();
      });

      test('a blank @newTabLabel suppresses the announcement', async function (assert) {
        await render(
          <template>
            <ExternalLink
              @href="https://frontile.dev"
              @newTabLabel="   "
            >Frontile</ExternalLink>
          </template>
        );

        assert
          .dom('[data-test-id="external-link-new-tab-label"]')
          .doesNotExist();
      });

      // Nothing opens a new tab, so there is nothing to announce -- saying so
      // anyway would misinform assistive technology.
      test('a _self target is not announced as a new tab', async function (assert) {
        await render(
          <template>
            <ExternalLink
              @href="https://frontile.dev"
              @target="_self"
            >Frontile</ExternalLink>
          </template>
        );

        assert
          .dom('[data-test-id="external-link-new-tab-label"]')
          .doesNotExist();
      });

      test('the glyph is hidden from assistive technology', async function (assert) {
        await render(
          <template>
            <ExternalLink @href="https://frontile.dev">Frontile</ExternalLink>
          </template>
        );

        assert
          .dom('[data-test-id="external-link-icon"]')
          .hasAttribute('aria-hidden', 'true');
      });
    });

    module('icon', function () {
      test('the glyph renders by default', async function (assert) {
        await render(
          <template>
            <ExternalLink @href="https://frontile.dev">Frontile</ExternalLink>
          </template>
        );

        assert.dom('[data-test-id="external-link-icon"]').exists();
      });

      // Dropping the glyph keeps the target/rel/announcement correctness, for a
      // prose author who does not want the visual marker.
      test('@showIcon={{false}} drops the glyph but keeps the announcement', async function (assert) {
        await render(
          <template>
            <ExternalLink
              @href="https://frontile.dev"
              @showIcon={{false}}
            >Frontile</ExternalLink>
          </template>
        );

        assert.dom('[data-test-id="external-link-icon"]').doesNotExist();
        assert.dom('[data-test-id="external-link-new-tab-label"]').exists();
      });

      test('the icon block replaces the built-in glyph', async function (assert) {
        await render(
          <template>
            <ExternalLink @href="https://frontile.dev">
              <:default>Frontile</:default>
              <:icon><span data-test-custom-icon>↗</span></:icon>
            </ExternalLink>
          </template>
        );

        assert.dom('[data-test-custom-icon]').exists();
        assert.dom('[data-test-icon="external-link"]').doesNotExist();
      });

      test('@iconPlacement controls the DOM order', async function (assert) {
        await render(
          <template>
            <ExternalLink @href="https://frontile.dev" data-test-end>
              Frontile
            </ExternalLink>
            <ExternalLink
              @href="https://frontile.dev"
              @iconPlacement="start"
              data-test-start
            >Frontile</ExternalLink>
          </template>
        );

        const atEnd = document.querySelector('[data-test-end]');
        const atStart = document.querySelector('[data-test-start]');

        // Both ends are asserted for each link: checking only the end the
        // glyph is expected at passes even if it renders on both sides, or if
        // the opposite end simply holds no element.
        assert.strictEqual(
          atEnd?.lastElementChild?.getAttribute('data-test-id'),
          'external-link-icon',
          'the glyph is the last element when placed at the end'
        );
        assert.strictEqual(
          atEnd?.firstElementChild?.getAttribute('data-test-id'),
          'external-link-new-tab-label',
          'and is not also at the start'
        );
        assert.strictEqual(
          atStart?.firstElementChild?.getAttribute('data-test-id'),
          'external-link-icon',
          'the glyph is the first element when placed at the start'
        );
        assert.strictEqual(
          atStart?.lastElementChild?.getAttribute('data-test-id'),
          'external-link-new-tab-label',
          'and is not also at the end'
        );
      });

      // The spec calls for the placement variant's classes, not just DOM order:
      // without this the theme's `iconPlacement` variant could be deleted and
      // the suite would stay green.
      test('@iconPlacement applies the variant classes', async function (assert) {
        await render(
          <template>
            <ExternalLink @href="https://frontile.dev" data-test-end>
              Frontile
            </ExternalLink>
            <ExternalLink
              @href="https://frontile.dev"
              @iconPlacement="start"
              data-test-start
            >Frontile</ExternalLink>
          </template>
        );

        assert
          .dom('[data-test-end] [data-test-id="external-link-icon"]')
          .hasClass('ml-0.5', 'a trailing glyph is spaced on its left');
        assert
          .dom('[data-test-end] [data-test-id="external-link-icon"]')
          .doesNotHaveClass('mr-0.5');
        assert
          .dom('[data-test-start] [data-test-id="external-link-icon"]')
          .hasClass('mr-0.5', 'a leading glyph is spaced on its right');
        assert
          .dom('[data-test-start] [data-test-id="external-link-icon"]')
          .doesNotHaveClass('ml-0.5');
      });
    });

    module('styles', function () {
      // `inline`, not `inline-flex`: the link has to break across lines inside
      // running text.
      test('the anchor is inline so it wraps in prose', async function (assert) {
        await render(
          <template>
            <ExternalLink @href="https://frontile.dev">Frontile</ExternalLink>
          </template>
        );

        assert.dom('[data-test-id="external-link"]').hasClass('inline');
        assert
          .dom('[data-test-id="external-link"]')
          .doesNotHaveClass('inline-flex');
      });

      test('it is underlined by default', async function (assert) {
        await render(
          <template>
            <ExternalLink @href="https://frontile.dev">Frontile</ExternalLink>
          </template>
        );

        assert.dom('[data-test-id="external-link"]').hasClass('underline');
      });

      test('@underline="hover" reveals the underline on hover only', async function (assert) {
        await render(
          <template>
            <ExternalLink
              @href="https://frontile.dev"
              @underline="hover"
            >Frontile</ExternalLink>
          </template>
        );

        assert
          .dom('[data-test-id="external-link"]')
          .hasClass('hover:underline');
        assert
          .dom('[data-test-id="external-link"]')
          .doesNotHaveClass('underline');
      });

      test('@underline="none" removes it entirely', async function (assert) {
        await render(
          <template>
            <ExternalLink
              @href="https://frontile.dev"
              @underline="none"
            >Frontile</ExternalLink>
          </template>
        );

        assert
          .dom('[data-test-id="external-link"]')
          .hasClass('hover:no-underline');
        assert
          .dom('[data-test-id="external-link"]')
          .doesNotHaveClass('underline');
      });

      test('@class and @classes merge over the theme classes', async function (assert) {
        await render(
          <template>
            <ExternalLink
              @href="https://frontile.dev"
              @class="text-primary"
              @classes={{hash icon="size-4"}}
            >Frontile</ExternalLink>
          </template>
        );

        assert.dom('[data-test-id="external-link"]').hasClass('text-primary');
        assert.dom('[data-test-id="external-link-icon"]').hasClass('size-4');
      });
    });
  }
);
