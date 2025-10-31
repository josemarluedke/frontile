import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, fillIn, find, settled } from '@ember/test-helpers';

import { Textarea } from 'frontile';
import { cell } from 'ember-resources';

module('Integration | Component | @frontile/forms/Textarea', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders', async function (assert) {
    await render(<template><Textarea @label="Name" /></template>);

    assert.dom('[data-component="label"]').hasText('Name');
    assert.dom('[data-component="textarea"]').exists();
  });

  test('it renders html attributes', async function (assert) {
    await render(
      <template>
        <Textarea @label="Name" @name="some-name" data-test-input />
      </template>
    );

    assert.dom('[data-test-input]').exists();
    assert.dom('[name="some-name"]').exists();
  });

  test('it should have id attr with matching label attr `for`', async function (assert) {
    await render(
      <template><Textarea @label="Name" data-test-input /></template>
    );

    const el = find('[data-test-input]') as HTMLInputElement;
    const id = el.getAttribute('id') || '';

    assert.ok(/ember[1-9.]/.test(id), 'should have generated an id');

    assert.dom('[data-component="label"]').hasAttribute('for', id);
  });

  test('should mutate the value using onInput action', async function (assert) {
    const myTextareaValue = cell('Josemar');
    const updateValue = (value: string) => (myTextareaValue.current = value);

    await render(
      <template>
        <Textarea
          data-test-input
          @label="Name"
          @value={{myTextareaValue.current}}
          @onInput={{updateValue}}
        />
      </template>
    );

    assert.dom('[data-test-input]').hasValue('Josemar');
    await fillIn('[data-test-input]', 'Sam');
    assert.equal(
      myTextareaValue.current,
      'Sam',
      'should have mutated the value'
    );
  });

  test('show error messages when errors has items', async function (assert) {
    const errors = cell<string[]>([]);
    await render(
      <template>
        <div class="my-container">
          <Textarea data-test-input @errors={{errors.current}} @label="Name" />
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
          <Textarea data-test-input @label="Name" />
        </div>
      </template>
    );

    assert.dom('[data-test-input]').doesNotHaveAttribute('aria-invalid');
    assert.dom('[data-component="form-feedback"]').doesNotExist();
  });

  test('it triggers actions for onInput and onChange', async function (assert) {
    const calls: string[] = [];

    const onInput = () => {
      calls.push('onInput');
    };
    const onChange = () => {
      calls.push('onChange');
    };

    await render(
      <template>
        <Textarea data-test-input @onInput={{onInput}} @onChange={{onChange}} />
      </template>
    );

    await fillIn('[data-test-input]', 'Josemar');
    assert.ok(calls.includes('onInput'));
    assert.ok(calls.includes('onChange'));
  });

  test('it add classes to all slots', async function (assert) {
    const classes = {
      base: 'my-base-class',
      input: 'my-input-class'
    };
    await render(<template><Textarea @classes={{classes}} /></template>);

    assert.dom('.my-base-class').exists();
    assert.dom('.my-input-class').exists();
  });
});
