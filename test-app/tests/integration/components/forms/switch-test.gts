import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click, find, settled } from '@ember/test-helpers';

import { Switch } from '@frontile/forms';
import { cell } from 'ember-resources';

module('Integration | Component | @frontile/forms/Switch', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders', async function (assert) {
    await render(<template><Switch @label="Name" /></template>);

    assert.dom('[data-component="label"]').hasText('Name');
    assert.dom('[data-component="switch"]').exists();
  });

  test('it renders html attributes', async function (assert) {
    await render(
      <template>
        <Switch @label="Name" @name="some-name" data-test-input />
      </template>
    );

    assert.dom('[data-test-input]').exists();
    assert.dom('[name="some-name"]').exists();
  });

  test('it should have id attr with matching label attr `for`', async function (assert) {
    await render(<template><Switch @label="Name" data-test-input /></template>);

    const el = find('[data-test-input]') as HTMLInputElement;
    const id = el.getAttribute('id') || '';

    assert.ok(/ember[1-9.]/.test(id), 'should have generated an id');

    assert.dom('[data-component="label"]').hasAttribute('for', id);
  });

  test('should mutate the value using onChange action (controlled)', async function (assert) {
    const mySwitchValue = cell(false);
    const updateValue = (value: boolean) => (mySwitchValue.current = value);

    await render(
      <template>
        <Switch
          data-test-input
          @label="Name"
          @isSelected={{mySwitchValue.current}}
          @onChange={{updateValue}}
        />
      </template>
    );

    assert.dom('[data-test-input]').isNotChecked();
    await click('[data-test-input]');

    assert.dom('[data-test-input]').isChecked();
    assert.equal(mySwitchValue.current, true, 'should have mutated the value');

    await click('[data-test-input]');
    assert.dom('[data-test-input]').isNotChecked();
    assert.equal(
      mySwitchValue.current,
      false,
      'should have mutated the value again'
    );
  });

  test('should mutate the value using onChange action (uncontrolled)', async function (assert) {
    let mySwitchValue = true;
    const updateValue = (value: boolean) => (mySwitchValue = value);

    await render(
      <template>
        <Switch
          data-test-input
          @label="Name"
          @defaultSelected={{true}}
          @onChange={{updateValue}}
        />
      </template>
    );

    assert.dom('[data-test-input]').isChecked();
    await click('[data-test-input]');

    assert.dom('[data-test-input]').isNotChecked();
    assert.equal(mySwitchValue, false, 'should have mutated the value');

    await click('[data-test-input]');
    assert.dom('[data-test-input]').isChecked();
    assert.equal(mySwitchValue, true, 'should have mutated the value again');
  });

  test('renders data attributes (uncontrolled)', async function (assert) {
    const disabled = cell(false);
    await render(
      <template>
        <Switch
          data-test-input
          @isDisabled={{disabled.current}}
          @label="Name"
          @defaultSelected={{true}}
        />
      </template>
    );

    assert.dom('[data-test-input]').isChecked();
    assert
      .dom('[data-component="switch"]')
      .hasAttribute('data-selected', 'true');
    assert
      .dom('[data-component="switch"]')
      .hasAttribute('data-disabled', 'false');

    await click('[data-test-input]');

    assert.dom('[data-test-input]').isNotChecked();
    assert
      .dom('[data-component="switch"]')
      .hasAttribute('data-selected', 'false');

    disabled.current = true;
    await settled();

    assert
      .dom('[data-component="switch"]')
      .hasAttribute('data-disabled', 'true');
  });

  test('it renders content blocks', async function (assert) {
    await render(
      <template>
        <Switch data-test-input @label="Name">
          <:startContent>Start</:startContent>
          <:thumbContent>T</:thumbContent>
          <:endContent>End</:endContent>
        </Switch>
      </template>
    );

    assert.dom('[data-test-id="switch-start-content"]').hasText('Start');
    assert.dom('[data-test-id="switch-end-content"]').hasText('End');
    assert.dom('[data-test-id="switch-thumb-content"]').hasText('T');
  });

  test('show error messages when errors has items', async function (assert) {
    const errors = cell<string[]>([]);
    await render(
      <template>
        <div class="my-container">
          <Switch data-test-input @errors={{errors.current}} @label="Name" />
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
          <Switch data-test-input @label="Name" />
        </div>
      </template>
    );

    assert.dom('[data-test-input]').doesNotHaveAttribute('aria-invalid');
    assert.dom('[data-component="form-feedback"]').doesNotExist();
  });

  test('it add classes to all slots', async function (assert) {
    const classes = {
      base: 'my-base-class',
      wrapper: 'my-wrapper-class',
      labelContainer: 'my-label-container-class',
      hiddenInput: 'my-hidden-input-class',
      startContent: 'my-start-content-class',
      endContent: 'my-end-content-class',
      label: 'my-label-class'
    };
    await render(
      <template>
        <Switch @label="Cool" @classes={{classes}}>
          <:startContent>S</:startContent>
          <:endContent>E</:endContent>
        </Switch>
      </template>
    );

    assert.dom('.my-base-class').exists();
    assert.dom('.my-wrapper-class').exists();
    assert.dom('.my-label-container-class').exists();
    assert.dom('.my-label-class').exists();
    assert.dom('.my-hidden-input-class').exists();
    assert.dom('.my-start-content-class').exists();
    assert.dom('.my-end-content-class').exists();
  });
});
