import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { Button, ButtonGroup } from 'frontile';
import { useRealStyles } from '../../../helpers/scoped-styles';

module(
  'Integration | Component | Button | glass and link',
  function (hooks) {
    setupRenderingTest(hooks);

    // These assert on real CSS, so they run against the shipped theme rather
    // than the stub markers other Button tests register.
    useRealStyles(hooks, ['button']);

    module('glass', function () {
      test('glass renders and blurs what is behind it', async function (assert) {
        await render(
          <template>
            <div
              class="dark"
              style="background: linear-gradient(red, blue); padding: 16px"
            >
              <Button @variant="glass" data-test-id="b">x</Button>
            </div>
          </template>
        );

        const el = document.querySelector('[data-test-id="b"]') as HTMLElement;
        const style = window.getComputedStyle(el) as unknown as Record<
          string,
          string
        >;
        const backdrop = style['backdropFilter'] ?? style['webkitBackdropFilter'];
        assert.true(
          String(backdrop).includes('blur(12px)'),
          `backdrop-filter is a 12px blur (got "${backdrop}")`
        );
      });

      test('glass in a ButtonGroup renders', async function (assert) {
        await render(
          <template>
            <ButtonGroup @variant="glass" as |group|>
              <group.Button data-test-id="first">One</group.Button>
              <group.Button data-test-id="second">Two</group.Button>
            </ButtonGroup>
          </template>
        );

        const first = document.querySelector('[data-test-id="first"]');
        assert.dom(first).exists();
        assert.true(
          first!.className.includes('first-of-type:rounded-s-full'),
          'first button keeps the group start rounding'
        );
      });

      test('loading glass is disabled and the spinner inherits ink', async function (assert) {
        await render(
          <template>
            <div class="dark">
              <Button
                @variant="glass"
                @isLoading={{true}}
                data-test-id="b"
              >x</Button>
            </div>
          </template>
        );

        const el = document.querySelector('[data-test-id="b"]') as HTMLElement;
        assert.dom(el).isDisabled();
        const spinner = el.querySelector('svg') as SVGElement;
        assert.dom(spinner).exists('a spinner is rendered');
        // The spinner is the button's ink at 25% alpha (`text-current/25`), so
        // it is white-based here, not exact-equal to the ink and not `none`.
        const fill = window.getComputedStyle(spinner).fill;
        assert.notStrictEqual(fill, 'none', 'spinner has a fill');
        assert.true(
          /^(oklab|oklch|rgb)a?\(1 0 0|rgba?\(255, 255, 255/.test(fill),
          `spinner fill derives from the white glass ink (got "${fill}")`
        );
      });
    });
  }
);
