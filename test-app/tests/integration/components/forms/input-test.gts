import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, fillIn, find, settled, click } from '@ember/test-helpers';

import { Input } from '@frontile/forms';
import { cell } from 'ember-resources';

module('Integration | Component | @frontile/forms/Input', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders', async function (assert) {
    await render(<template><Input @label="Name" /></template>);

    assert.dom('[data-component="label"]').hasText('Name');
    assert.dom('[data-component="input"]').exists();
  });

  test('it should default type as text', async function (assert) {
    await render(<template><Input @label="Name" data-test-input /></template>);

    assert.dom('[data-test-input]').hasAttribute('type', 'text');
  });

  test('it should allow to change the input type', async function (assert) {
    await render(
      <template>
        <Input @label="Name" @type="number" data-test-input />
      </template>
    );

    assert.dom('[data-test-input]').hasAttribute('type', 'number');
  });

  test('it renders html attributes', async function (assert) {
    await render(
      <template>
        <Input @label="Name" @name="some-name" data-test-input />
      </template>
    );

    assert.dom('[data-test-input]').exists();
    assert.dom('[name="some-name"]').exists();
  });

  test('it should have id attr with matching label attr `for`', async function (assert) {
    await render(<template><Input @label="Name" data-test-input /></template>);

    const el = find('[data-test-input]') as HTMLInputElement;
    const id = el.getAttribute('id') || '';

    assert.ok(/ember[1-9.]/.test(id), 'should have generated an id');

    assert.dom('[data-component="label"]').hasAttribute('for', id);
  });

  test('it renders named blocks startContent and endContent', async function (assert) {
    const classes = { innerContainer: 'input-container' };
    await render(
      <template>
        <Input @label="Name" @classes={{classes}}>
          <:startContent>Start</:startContent>
          <:endContent>End</:endContent>
        </Input>
      </template>
    );

    assert.dom('[data-component="input"]').exists();
    assert.dom('.input-container div:first-child').exists();
    assert.dom('.input-container div:first-child').hasTextContaining('Start');

    assert.dom('.input-container div:last-child').exists();
    assert.dom('.input-container div:last-child').hasTextContaining('End');
  });

  test('it respect options for start/end content pointer events', async function (assert) {
    const classes = { innerContainer: 'input-container' };

    const startContentPointerEvents = cell<'none' | 'auto'>('none');
    const endContentPointerEvents = cell<'none' | 'auto'>('none');

    await render(
      <template>
        <Input
          @label="Name"
          @classes={{classes}}
          @startContentPointerEvents={{startContentPointerEvents.current}}
          @endContentPointerEvents={{endContentPointerEvents.current}}
        >
          <:startContent>
            <button>
              Start
            </button>
          </:startContent>
          <:endContent>
            <button>
              Start
            </button>
          </:endContent>
        </Input>
      </template>
    );

    assert.dom('[data-component="input"]').exists();
    assert
      .dom('[data-test-id="input-start-content"]')
      .hasClass(/pointer-events-none/);
    assert
      .dom('[data-test-id="input-end-content"]')
      .hasClass(/pointer-events-none/);

    startContentPointerEvents.current = 'auto';
    endContentPointerEvents.current = 'auto';
    await settled();

    assert.dom('[data-component="input"]').exists();
    assert
      .dom('[data-test-id="input-start-content"]')
      .hasClass(/pointer-events-auto/);
    assert
      .dom('[data-test-id="input-end-content"]')
      .hasClass(/pointer-events-auto/);
  });

  test('should mutate the value using onInput action', async function (assert) {
    const myInputValue = cell('Josemar');
    const updateValue = (value: string) => (myInputValue.current = value);

    await render(
      <template>
        <Input
          data-test-input
          @label="Name"
          @value={{myInputValue.current}}
          @onInput={{updateValue}}
        />
      </template>
    );

    assert.dom('[data-test-input]').hasValue('Josemar');
    await fillIn('[data-test-input]', 'Sam');
    assert.equal(myInputValue.current, 'Sam', 'should have mutated the value');
  });

  test('show error messages when errors has items', async function (assert) {
    const errors = cell<string[]>([]);
    await render(
      <template>
        <div class="my-container">
          <Input data-test-input @errors={{errors.current}} @label="Name" />
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
          <Input data-test-input @label="Name" />
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
        <Input data-test-input @onInput={{onInput}} @onChange={{onChange}} />
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
    await render(<template><Input @classes={{classes}} /></template>);

    assert.dom('.my-base-class').exists();
    assert.dom('.my-input-class').exists();
  });

  test('clear button', async function (assert) {
    const value = cell('');

    const onInput = (val: string) => {
      value.current = val;
    };

    await render(
      <template>
        <Input
          data-test-input
          @value={{value.current}}
          @onInput={{onInput}}
          @isClearable={{true}}
        />
      </template>
    );

    assert.dom('[data-test-id="input-clear-button"]').doesNotExist();
    await fillIn('[data-test-input]', 'Josemar');
    assert.equal(value.current, 'Josemar');

    assert.dom('[data-test-id="input-clear-button"]').exists();

    await click('[data-test-id="input-clear-button"]');
    assert.equal(value.current, '');
  });
});
