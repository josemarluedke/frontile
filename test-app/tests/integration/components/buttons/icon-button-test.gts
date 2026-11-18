import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click, triggerKeyEvent } from '@ember/test-helpers';
import { IconButton } from 'frontile';
import { collectAssertions } from '../../../helpers/collect-assertions';

module(
  'Integration | Component | @frontile/buttons/IconButton',
  function (hooks) {
    setupRenderingTest(hooks);

    module('size', function () {
      // Diameter and icon size in px, from the design artifact's icon button
      // spec (button width; glyph size). Literals on purpose.
      const spec = {
        xs: [24, 10],
        sm: [34, 12],
        md: [42, 16],
        lg: [52, 20],
        xl: [68, 28],
        '2xl': [80, 32]
      } as const;

      for (const [size, [diameter, glyph]] of Object.entries(spec) as [
        keyof typeof spec,
        readonly [number, number]
      ][]) {
        test(`@size="${size}" is a ${diameter}px circle with a ${glyph}px icon`, async function (assert) {
          await render(
            <template>
              <IconButton @label="Delete" @size={{size}} data-test-id="btn"><svg
                  data-test-icon
                  viewBox="0 0 24 24"
                ><path d="M0 0h24v24H0z" /></svg></IconButton>
            </template>
          );

          const btn = document.querySelector(
            '[data-test-id="btn"]'
          ) as HTMLElement;
          assert.strictEqual(btn.offsetWidth, diameter, 'width');
          assert.strictEqual(btn.offsetHeight, diameter, 'height');
          assert.true(
            parseFloat(getComputedStyle(btn).borderRadius) >= diameter / 2,
            'fully rounded'
          );

          const icon = btn.querySelector('[data-test-icon]') as SVGElement;
          assert.strictEqual(getComputedStyle(icon).width, `${glyph}px`);
          assert.strictEqual(getComputedStyle(icon).height, `${glyph}px`);
        });
      }

      test('it defaults to md', async function (assert) {
        await render(
          <template>
            <IconButton @label="a" data-test-id="def"><svg
                viewBox="0 0 24 24"
              ><path d="M0 0h24v24H0z" /></svg></IconButton>
          </template>
        );

        const btn = document.querySelector(
          '[data-test-id="def"]'
        ) as HTMLElement;
        assert.strictEqual(btn.offsetWidth, 42);
      });
    });

    module('color and variant', function () {
      test("it takes Button's @color and @variant", async function (assert) {
        await render(
          <template>
            <IconButton
              @label="Delete"
              @color="danger"
              @variant="soft"
              data-test-id="btn"
            ><svg data-test-icon viewBox="0 0 24 24"><path
                  d="M0 0h24v24H0z"
                /></svg></IconButton>
          </template>
        );

        assert.dom('[data-test-id="btn"]').hasClass('bg-danger-soft');
        assert.dom('[data-test-id="btn"]').hasClass('text-on-danger-soft');
      });

      test("it defaults to Button's solid neutral look", async function (assert) {
        await render(
          <template>
            <IconButton @label="Delete" data-test-id="btn"><svg
                data-test-icon
                viewBox="0 0 24 24"
              ><path d="M0 0h24v24H0z" /></svg></IconButton>
          </template>
        );

        assert.dom('[data-test-id="btn"]').hasClass('bg-on-neutral-subtle');
      });
    });

    module('disabled and loading', function () {
      test('the native disabled attribute disables it', async function (assert) {
        await render(
          <template>
            <IconButton @label="Delete" disabled data-test-id="btn"><svg
                data-test-icon
                viewBox="0 0 24 24"
              ><path d="M0 0h24v24H0z" /></svg></IconButton>
          </template>
        );

        assert.dom('[data-test-id="btn"]').isDisabled();
      });

      test('@isLoading replaces the glyph with a spinner, disables, and marks it busy', async function (assert) {
        await render(
          <template>
            <IconButton
              @label="Delete"
              @isLoading={{true}}
              data-test-id="btn"
            ><svg data-test-icon viewBox="0 0 24 24"><path
                  d="M0 0h24v24H0z"
                /></svg></IconButton>
          </template>
        );

        assert.dom('[data-test-id="btn"]').isDisabled();
        assert.dom('[data-test-id="btn"]').hasAttribute('aria-busy', 'true');
        assert.dom('[data-test-id="btn"] [data-test-icon]').doesNotExist();
        assert.dom('[data-test-id="btn"] svg').exists('the spinner');
        assert
          .dom('[data-test-id="btn"]')
          .hasAttribute('aria-label', 'Delete', 'keeps its name while loading');
      });
    });

    module('pressing', function () {
      test('@onPress fires for click and for keyboard Enter and Space', async function (assert) {
        let count = 0;
        const onPress = () => count++;

        await render(
          <template>
            <IconButton
              @label="Delete"
              @onPress={{onPress}}
              data-test-id="btn"
            ><svg data-test-icon viewBox="0 0 24 24"><path
                  d="M0 0h24v24H0z"
                /></svg></IconButton>
          </template>
        );

        await click('[data-test-id="btn"]');
        assert.strictEqual(count, 1, 'click');

        await triggerKeyEvent('[data-test-id="btn"]', 'keydown', 'Enter');
        await triggerKeyEvent('[data-test-id="btn"]', 'keyup', 'Enter');
        assert.strictEqual(count, 2, 'Enter');

        await triggerKeyEvent('[data-test-id="btn"]', 'keydown', ' ');
        await triggerKeyEvent('[data-test-id="btn"]', 'keyup', ' ');
        assert.strictEqual(count, 3, 'Space');
      });
    });

    module('cursor', function () {
      test('it shows a pointer, and not-allowed once disabled', async function (assert) {
        await render(
          <template>
            <IconButton @label="Delete" data-test-id="on"><svg
                viewBox="0 0 24 24"
              ><path d="M0 0h24v24H0z" /></svg></IconButton>
            <IconButton @label="Delete" disabled data-test-id="off"><svg
                viewBox="0 0 24 24"
              ><path d="M0 0h24v24H0z" /></svg></IconButton>
          </template>
        );

        const cursor = (id: string) =>
          getComputedStyle(document.querySelector(`[data-test-id="${id}"]`)!)
            .cursor;
        assert.strictEqual(cursor('on'), 'pointer');
        assert.strictEqual(cursor('off'), 'not-allowed');
      });
    });

    module('accessible name and icon', function () {
      test('an empty @label is refused', async function (assert) {
        const failed = await collectAssertions(() =>
          render(
            <template>
              <IconButton @label="">
                <svg data-test-icon viewBox="0 0 24 24"><path
                    d="M0 0h24v24H0z"
                  /></svg>
              </IconButton>
            </template>
          )
        );

        assert.true(failed.some((m) => m.includes('@label is required')));
      });

      test('it is a button named by @label, with the block as its icon', async function (assert) {
        await render(
          <template>
            <IconButton @label="Delete item" data-test-id="btn"><svg
                data-test-icon
                viewBox="0 0 24 24"
              ><path d="M0 0h24v24H0z" /></svg></IconButton>
          </template>
        );

        assert.dom('button[data-test-id="btn"]').hasAttribute('type', 'button');
        assert
          .dom('[data-test-id="btn"]')
          .hasAttribute('aria-label', 'Delete item');
        assert.dom('[data-test-id="btn"] svg[data-test-icon]').exists();
      });
    });
  }
);
