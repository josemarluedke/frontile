import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { find, render, settled } from '@ember/test-helpers';

import { CheckboxGroup, type CheckboxGroupSignature } from 'frontile';
import { cell } from 'ember-resources';

module(
  'Integration | Component | @frontile/forms/CheckboxGroup',
  function (hooks) {
    setupRenderingTest(hooks);

    const errors = cell<string[]>([]);
    const classes = cell<CheckboxGroupSignature['Args']['classes']>({});
    const musicInterested = cell(false);
    const updateMusic = (value: boolean) => (musicInterested.current = value);

    const iotInterested = cell(false);
    const updateIot = (value: boolean) => (iotInterested.current = value);

    hooks.beforeEach(async function () {
      await render(
        <template>
          <CheckboxGroup
            @label="Interests"
            @errors={{errors.current}}
            @orientation="horizontal"
            @classes={{classes.current}}
            data-test-input
            as |Checkbox|
          >
            <Checkbox
              @name="music"
              @label="Music"
              @checked={{musicInterested.current}}
              @onChange={{updateMusic}}
            />
            <Checkbox
              @name="iot"
              @label="IoT"
              @checked={{iotInterested.current}}
              @onChange={{updateIot}}
            />
          </CheckboxGroup>
        </template>
      );
    });

    test('it renders', async function (assert) {
      assert.dom('[data-component="label"]').hasText('Interests');
      assert.dom('[data-component="checkbox"]').exists();
    });

    test('it renders html attributes', async function (assert) {
      assert.dom('[data-test-input]').exists();
      assert.dom('[name="music"]').exists();
      assert.dom('[name="iot"]').exists();
    });

    test('show error messages when errors has items', async function (assert) {
      errors.current = ['This field is required'];
      await settled();

      assert
        .dom('[data-component="form-feedback"]')
        .hasText('This field is required');
    });

    test('do not show error messages if errors has no elements', async function (assert) {
      errors.current = [];
      await settled();
      assert.dom('[data-component="form-feedback"]').doesNotExist();
    });

    test('it add classes to all slots', async function (assert) {
      classes.current = {
        base: 'my-base-class',
        optionsContainer: 'my-options-container',
        label: 'my-label-class'
      };
      await settled();

      assert.dom('.my-base-class').exists();
      assert.dom('.my-options-container').exists();
      assert.dom('.my-label-class').exists();
    });

    test('renders data-component="checkbox-group" on the root only, with data-part on every slot', async function (assert) {
      assert
        .dom('[data-component="checkbox-group"]')
        .hasAttribute('data-part', 'base');
      assert
        .dom(
          '[data-component="checkbox-group"] [data-part="options-container"]'
        )
        .exists();
      // Scoped with the direct-child combinator: a checkbox-group's
      // options-container yields full Checkbox components, and each
      // Checkbox has its own [data-part="label"] for its own label slot.
      // An unscoped descendant selector for [data-part="label"] would match
      // both the group's own label and every nested checkbox's label.
      assert
        .dom('[data-component="checkbox-group"] > [data-part="label"]')
        .exists();
      assert.strictEqual(
        document.querySelectorAll('[data-component="checkbox-group"]').length,
        1,
        'data-component="checkbox-group" marks the root only, never a part'
      );
    });

    test('it renders the description after the label', async function (assert) {
      await render(
        <template>
          <CheckboxGroup
            @label="Interests"
            @description="Choose all that apply"
            as |Checkbox|
          >
            <Checkbox @name="music" @label="Music" />
          </CheckboxGroup>
        </template>
      );

      assert
        .dom('[data-component="form-description"]')
        .hasText('Choose all that apply');

      const label = find('[data-component="label"]') as HTMLElement;
      const description = find(
        '[data-component="form-description"]'
      ) as HTMLElement;

      assert.true(
        !!(
          label.compareDocumentPosition(description) &
          Node.DOCUMENT_POSITION_FOLLOWING
        ),
        'description is rendered after the label'
      );
    });
  }
);
