import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { click, render } from '@ember/test-helpers';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';
import { ToggleButton } from '@frontile/buttons';
import { cell } from 'ember-resources';
import { settled } from '@ember/test-helpers';

module(
  'Integration | Component | ToggleButton | @frontile/buttons',
  function (hooks) {
    setupRenderingTest(hooks);

    registerCustomStyles({
      toggleButton: tv({
        base: 'toggle-button',
        variants: {
          isInGroup: { true: ['in-group'] },
          intent: {
            default: 'intent-default',
            primary: 'intent-primary',
            success: 'intent-success',
            warning: 'intent-warning',
            danger: 'intent-danger'
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
          intent: 'default'
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
      module('@intent', () => {
        test('it adds class for the an intent', async function (assert) {
          await render(
            <template>
              <ToggleButton @intent="primary" data-test-id="button">
                My ToggleButton
              </ToggleButton>
            </template>
          );

          assert.dom('[data-test-id="button"]').hasClass('intent-primary');
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
