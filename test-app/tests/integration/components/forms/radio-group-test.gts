import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { find, render, settled, click } from '@ember/test-helpers';

import { RadioGroup, type RadioGroupSignature } from 'frontile';
import { cell } from 'ember-resources';

module(
  'Integration | Component | @frontile/forms/RadioGroup',
  function (hooks) {
    setupRenderingTest(hooks);

    const errors = cell<string[]>([]);
    const classes = cell<RadioGroupSignature<unknown>['Args']['classes']>({});
    const value = cell<string>();
    const updateValue = (val: string) => (value.current = val);

    hooks.beforeEach(async function () {
      await render(
        <template>
          <RadioGroup
            @name="interests"
            @label="Interests"
            @errors={{errors.current}}
            @orientation="horizontal"
            @classes={{classes.current}}
            @value={{value.current}}
            @onChange={{updateValue}}
            data-test-input
            as |Radio|
          >
            <Radio @label="Music" @value="music" />
            <Radio @label="IoT" @value="iot" />
          </RadioGroup>
        </template>
      );
    });

    test('it renders', async function (assert) {
      assert.dom('[data-component="label"]').hasText('Interests');
      assert.dom('[data-component="radio"]').exists();
    });

    test('it renders html attributes', async function (assert) {
      assert.dom('[data-test-input]').exists();
      assert.dom('[value="music"]').exists();
      assert.dom('[value="iot"]').exists();
    });

    test('it changes value and render checked value', async function (assert) {
      value.current = 'music';
      await settled();
      assert.dom('[value="music"]').isChecked();

      await click('[value="iot"]');
      assert.dom('[value="music"]').isNotChecked();
      assert.dom('[value="iot"]').isChecked();

      assert.equal(value.current, 'iot');

      await click('[value="music"]');
      assert.dom('[value="music"]').isChecked();
      assert.dom('[value="iot"]').isNotChecked();
      assert.equal(value.current, 'music');
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

    test('renders data-component="radio-group" on the root only, with data-part on every slot', async function (assert) {
      assert
        .dom('[data-component="radio-group"]')
        .hasAttribute('data-part', 'base');
      assert
        .dom('[data-component="radio-group"] [data-part="options-container"]')
        .exists();
      // Scoped with the direct-child combinator: a radio-group's
      // options-container yields full Radio components, and each Radio has
      // its own [data-part="label"] for its own label slot. An unscoped
      // descendant selector for [data-part="label"] would match both the
      // group's own label and every nested radio's label.
      assert
        .dom('[data-component="radio-group"] > [data-part="label"]')
        .exists();
      assert.strictEqual(
        document.querySelectorAll('[data-component="radio-group"]').length,
        1,
        'data-component="radio-group" marks the root only, never a part'
      );
    });

    test('it renders the description after the label', async function (assert) {
      await render(
        <template>
          <RadioGroup
            @label="Interests"
            @description="Choose one option"
            as |Radio|
          >
            <Radio @value="music" @label="Music" />
          </RadioGroup>
        </template>
      );

      assert
        .dom('[data-component="form-description"]')
        .hasText('Choose one option');

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
