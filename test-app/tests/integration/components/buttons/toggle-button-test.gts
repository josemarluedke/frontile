import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { click, render } from '@ember/test-helpers';
import { tv } from 'tailwind-variants';
import { ToggleButton } from 'frontile';
import { cell } from 'ember-resources';
import { settled } from '@ember/test-helpers';
import { collectAssertions } from '../../../helpers/collect-assertions';
import { useCustomStyles } from '../../../helpers/scoped-styles';

module(
  'Integration | Component | ToggleButton | @frontile/buttons',
  function (hooks) {
    setupRenderingTest(hooks);

    useCustomStyles(hooks, {
      toggleButton: tv({
        base: 'toggle-button',
        variants: {
          isInGroup: { true: ['in-group'] },
          color: {
            neutral: 'button-neutral',
            primary: 'button-primary',
            secondary: 'button-secondary',
            tertiary: 'button-tertiary',
            success: 'button-success',
            warning: 'button-warning',
            danger: 'button-danger'
          },
          size: {
            xs: 'toggle-button-xs',
            sm: 'toggle-button-sm',
            md: 'toggle-button-md',
            lg: 'toggle-button-lg',
            xl: 'toggle-button-xl'
          }
        },
        defaultVariants: {
          size: 'md',
          color: 'neutral'
        }
      }) as never
    });

    test('it renders', async function (assert) {
      await render(
        <template>
          <ToggleButton data-test-id="button">My ToggleButton</ToggleButton>
        </template>
      );

      assert.dom('[data-test-id="button"]').hasText('My ToggleButton');
    });

    module('@isSelected', () => {
      test('adds aria-pressed', async function (assert) {
        const isSelected = cell(false);
        await render(
          <template>
            <ToggleButton
              @isSelected={{isSelected.current}}
              data-test-id="button"
            >My ToggleButton</ToggleButton>
          </template>
        );

        assert.dom('[data-test-id="button"]').hasAria('pressed', 'false');
        isSelected.current = true;
        await settled();

        assert.dom('[data-test-id="button"]').hasAria('pressed', 'true');
      });
    });

    module('@onChange', () => {
      test('calls onChange argument', async function (assert) {
        const onChange = (val: boolean) => {
          assert.equal(val, true);
        };
        await render(
          <template>
            <ToggleButton
              @isSelected={{false}}
              @onChange={{onChange}}
              data-test-id="button"
            >
              My ToggleButton
            </ToggleButton>
          </template>
        );
        await click('[data-test-id="button"]');

        assert.expect(1);
      });
    });

    module('Style classes', () => {
      module('@color', () => {
        test('it adds class for the a color', async function (assert) {
          await render(
            <template>
              <ToggleButton @color="primary" data-test-id="button">
                My ToggleButton
              </ToggleButton>
            </template>
          );

          assert.dom('[data-test-id="button"]').hasClass('button-primary');
        });

        test('@intent fails in development', async function (assert) {
          const failed = await collectAssertions(() =>
            render(
              <template>
                {{! @glint-expect-error -- removed in 0.19.0 }}
                <ToggleButton @intent="danger" data-test-id="button">
                  My ToggleButton
                </ToggleButton>
              </template>
            )
          );

          assert.true(
            failed.includes(
              'ToggleButton: @intent was removed in 0.19.0. Use @color.'
            ),
            `got: ${failed.join(' | ')}`
          );
        });

        test('@appearance fails in development', async function (assert) {
          const failed = await collectAssertions(() =>
            render(
              <template>
                {{! @glint-expect-error -- removed in 0.19.0 }}
                <ToggleButton @appearance="outlined" data-test-id="button">
                  My ToggleButton
                </ToggleButton>
              </template>
            )
          );

          assert.true(
            failed.includes(
              'ToggleButton: @appearance was removed in 0.19.0. Use @variant.'
            ),
            `got: ${failed.join(' | ')}`
          );
        });

        test('explicitly undefined @intent and @appearance stay silent', async function (assert) {
          const failed = await collectAssertions(() =>
            render(
              <template>
                {{! @glint-expect-error -- removed in 0.19.0 }}
                <ToggleButton @intent={{undefined}} @appearance={{undefined}}>
                  My ToggleButton
                </ToggleButton>
              </template>
            )
          );

          assert.deepEqual(failed, []);
        });
      });

      module('@size', () => {
        test('it adds class size sm"', async function (assert) {
          await render(
            <template>
              <ToggleButton @size="sm" data-test-id="button">My ToggleButton</ToggleButton>
            </template>
          );

          assert.dom('[data-test-id="button"]').hasClass('toggle-button-sm');
        });

        test('it adds class size lg', async function (assert) {
          await render(
            <template>
              <ToggleButton @size="lg" data-test-id="button">My ToggleButton</ToggleButton>
            </template>
          );

          assert.dom('[data-test-id="button"]').hasClass('toggle-button-lg');
        });
      });
    });
  }
);
