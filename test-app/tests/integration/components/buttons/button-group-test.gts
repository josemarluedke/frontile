import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';
import { ButtonGroup } from 'frontile';
import { cell } from 'ember-resources';
import { settled } from '@ember/test-helpers';
import { trackDeprecations } from '../../../helpers/deprecations';

module(
  'Integration | Component | ButtonGroup | @frontile/buttons',
  function (hooks) {
    setupRenderingTest(hooks);

    registerCustomStyles({
      button: tv({
        base: [],
        variants: {
          isInGroup: { true: ['in-group'] },
          variant: {
            solid: 'button-solid',
            soft: 'button-soft',
            subtle: 'button-subtle',
            outline: 'button-outline',
            ghost: 'button-ghost',
            plain: 'button-plain',
            custom: 'button-custom'
          },
          intent: {
            default: 'intent-default',
            primary: 'intent-primary',
            success: 'intent-success',
            warning: 'intent-warning',
            danger: 'intent-danger'
          },
          size: {
            xs: 'btn-xs',
            sm: 'btn-sm',
            md: 'btn-md',
            lg: 'btn-lg',
            xl: 'btn-xl'
          }
        }
      }) as never,
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
        }
      }) as never
    });

    test('it renders', async function (assert) {
      await render(
        <template>
          <ButtonGroup data-test-id="group" as |g|>
            <g.Button data-test-id="button">Button</g.Button>
            <g.ToggleButton data-test-id="toggle">Toggle</g.ToggleButton>
          </ButtonGroup>
        </template>
      );

      assert.dom('[data-test-id="group"]').exists();
      assert.dom('[data-test-id="button"]').hasClass('in-group');
      assert.dom('[data-test-id="toggle"]').hasClass('in-group');
    });

    module('Style classes', () => {
      module('@variant', () => {
        test('it adds class for default variant', async function (assert) {
          await render(
            <template>
              <ButtonGroup data-test-id="group" as |g|>
                <g.Button data-test-id="button">Button</g.Button>
                <g.ToggleButton data-test-id="toggle">Toggle</g.ToggleButton>
              </ButtonGroup>
            </template>
          );

          assert
            .dom('[data-test-id="button"]')
            .doesNotHaveClass('button-outline');
          assert
            .dom('[data-test-id="button"]')
            .doesNotHaveClass('button-plain');
          assert
            .dom('[data-test-id="button"]')
            .doesNotHaveClass('button-custom');
          assert.dom('[data-test-id="button"]').hasClass('button-solid');
        });

        test('it adds class for outline variant', async function (assert) {
          const variant = cell<'outline'>('outline');
          await render(
            <template>
              <ButtonGroup
                data-test-id="group"
                @variant={{variant.current}}
                as |g|
              >
                <g.Button data-test-id="button">Button</g.Button>
                <g.ToggleButton data-test-id="toggle">Toggle</g.ToggleButton>
              </ButtonGroup>
            </template>
          );

          assert.dom('[data-test-id="button"]').doesNotHaveClass('button-solid');
          assert
            .dom('[data-test-id="button"]')
            .doesNotHaveClass('button-plain');
          assert
            .dom('[data-test-id="button"]')
            .doesNotHaveClass('button-custom');
          assert.dom('[data-test-id="button"]').hasClass('button-outline');
        });

        test('ButtonGroup forwards @variant to its buttons', async function (assert) {
          await render(
            <template>
              <ButtonGroup @variant="outline" as |g|>
                <g.Button data-test-id="button">x</g.Button>
              </ButtonGroup>
            </template>
          );

          assert.dom('[data-test-id="button"]').hasClass('button-outline');
        });

        test('ButtonGroup @appearance deprecates exactly once', async function (assert) {
          const { ids } = trackDeprecations();

          await render(
            <template>
              <ButtonGroup @appearance="outlined" as |g|>
                <g.Button data-test-id="button">x</g.Button>
              </ButtonGroup>
            </template>
          );

          assert.dom('[data-test-id="button"]').hasClass('button-outline');
          assert.deepEqual(ids, ['frontile.button-group.appearance']);
        });
      });

      module('@intent', () => {
        test('it adds class for the an intent', async function (assert) {
          const intent = cell<'primary' | 'danger'>('primary');
          await render(
            <template>
              <ButtonGroup
                data-test-id="group"
                @intent={{intent.current}}
                as |g|
              >
                <g.Button data-test-id="button">Button</g.Button>
                <g.ToggleButton data-test-id="toggle">Toggle</g.ToggleButton>
              </ButtonGroup>
            </template>
          );
          assert.dom('[data-test-id="button"]').hasClass('intent-primary');
          assert.dom('[data-test-id="toggle"]').hasClass('intent-primary');

          intent.current = 'danger';
          await settled();
          assert.dom('[data-test-id="button"]').hasClass('intent-danger');
          assert.dom('[data-test-id="toggle"]').hasClass('intent-danger');
        });
      });

      module('@size', () => {
        test('it adds class for the an intent', async function (assert) {
          const size = cell<'sm' | 'lg'>('sm');
          await render(
            <template>
              <ButtonGroup data-test-id="group" @size={{size.current}} as |g|>
                <g.Button data-test-id="button">Button</g.Button>
                <g.ToggleButton data-test-id="toggle">Toggle</g.ToggleButton>
              </ButtonGroup>
            </template>
          );
          assert.dom('[data-test-id="button"]').hasClass('btn-sm');
          assert.dom('[data-test-id="toggle"]').hasClass('toggle-button-sm');

          size.current = 'lg';
          await settled();
          assert.dom('[data-test-id="button"]').hasClass('btn-lg');
          assert.dom('[data-test-id="toggle"]').hasClass('toggle-button-lg');
        });
      });
    });
  }
);
