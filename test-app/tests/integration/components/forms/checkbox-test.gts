import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click, find, settled } from '@ember/test-helpers';

import { Checkbox } from '@frontile/forms';
import { cell } from 'ember-resources';

module('Integration | Component | @frontile/forms/Checkbox', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders', async function (assert) {
    await render(<template><Checkbox @label="Name" /></template>);

    assert.dom('[data-component="label"]').hasText('Name');
    assert.dom('[data-component="checkbox"]').exists();
  });

  test('it renders html attributes', async function (assert) {
    await render(
      <template>
        <Checkbox @label="Name" @name="some-name" data-test-input />
      </template>
    );

    assert.dom('[data-test-input]').exists();
    assert.dom('[name="some-name"]').exists();
  });

  test('it should have id attr with matching label attr `for`', async function (assert) {
    await render(
      <template><Checkbox @label="Name" data-test-input /></template>
    );

    const el = find('[data-test-input]') as HTMLInputElement;
    const id = el.getAttribute('id') || '';

    assert.ok(/ember[1-9.]/.test(id), 'should have generated an id');

    assert.dom('[data-component="label"]').hasAttribute('for', id);
  });

  test('should mutate the value using onChange action', async function (assert) {
    const myCheckboxValue = cell(false);
    const updateValue = (value: boolean) => (myCheckboxValue.current = value);

    await render(
      <template>
        <Checkbox
          data-test-input
          @label="Name"
          @checked={{myCheckboxValue.current}}
          @onChange={{updateValue}}
        />
      </template>
    );

    assert.dom('[data-test-input]').isNotChecked();
    await click('[data-test-input]');

    assert.dom('[data-test-input]').isChecked();
    assert.equal(
      myCheckboxValue.current,
      true,
      'should have mutated the value'
    );

    await click('[data-test-input]');
    assert.dom('[data-test-input]').isNotChecked();
    assert.equal(
      myCheckboxValue.current,
      false,
      'should have mutated the value again'
    );
  });

  test('show error messages when errors has items', async function (assert) {
    const errors = cell<string[]>([]);
    await render(
      <template>
        <div class="my-container">
          <Checkbox data-test-input @errors={{errors.current}} @label="Name" />
        </div>
      </template>
    );

    assert.dom('[data-test-input]').doesNotHaveAttribute('aria-invalid');

    errors.current = ['This field is required'];
    await settled();

    assert.dom('[data-test-input]').hasAttribute('aria-invalid');
    assert
      .dom('[data-component="form-feedback"]')
      .hasText('This field is required');
  });

  test('do not show error messages if errors has no elements', async function (assert) {
    await render(
      <template>
        <div class="my-container">
          <Checkbox data-test-input @label="Name" />
        </div>
      </template>
    );

    assert.dom('[data-test-input]').doesNotHaveAttribute('aria-invalid');
    assert.dom('[data-component="form-feedback"]').doesNotExist();
  });

  test('it add classes to all slots', async function (assert) {
    const classes = {
      base: 'my-base-class',
      input: 'my-input-class',
      labelContainer: 'my-label-container-class',
      label: 'my-label-class'
    };
    await render(
      <template><Checkbox @label="Cool" @classes={{classes}} /></template>
    );

    assert.dom('.my-base-class').exists();
    assert.dom('.my-input-class').exists();
    assert.dom('.my-label-container-class').exists();
    assert.dom('.my-label-class').exists();
  });
});
