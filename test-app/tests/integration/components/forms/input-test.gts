import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, fillIn, find, settled, click } from '@ember/test-helpers';

import { Input } from 'frontile';
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

  test('it renders the @value in the HTML', async function (assert) {
    await render(
      <template>
        <Input @label="Name" @value="Hello World" data-test-input />
      </template>
    );

    assert.dom('[data-test-input]').hasValue('Hello World');
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

  test('uncontrolled input behavior', async function (assert) {
    // No onChange or onInput callbacks provided = uncontrolled
    await render(
      <template>
        <Input @label="Name" @value="Initial Value" data-test-input />
      </template>
    );

    // Initial value should be rendered
    assert.dom('[data-test-input]').hasValue('Initial Value');

    // User can type and change the value
    await fillIn('[data-test-input]', 'User Typed Value');
    assert.dom('[data-test-input]').hasValue('User Typed Value');

    // The input manages its own state internally
  });

  test('controlled input behavior with onChange', async function (assert) {
    const value = cell('Controlled Value');
    const onChange = (newValue: string) => {
      value.current = newValue;
    };

    await render(
      <template>
        <Input
          @label="Name"
          @value={{value.current}}
          @onChange={{onChange}}
          data-test-input
        />
      </template>
    );

    // Initial controlled value should be rendered
    assert.dom('[data-test-input]').hasValue('Controlled Value');

    // When user types, onChange callback should be called and state updated
    await fillIn('[data-test-input]', 'New Controlled Value');
    assert.equal(
      value.current,
      'New Controlled Value',
      'onChange callback should update the state'
    );
    assert.dom('[data-test-input]').hasValue('New Controlled Value');
  });

  test('controlled input behavior with onInput', async function (assert) {
    const value = cell('Input Controlled');
    const onInput = (newValue: string) => {
      value.current = newValue;
    };

    await render(
      <template>
        <Input
          @label="Name"
          @value={{value.current}}
          @onInput={{onInput}}
          data-test-input
        />
      </template>
    );

    // Initial controlled value should be rendered
    assert.dom('[data-test-input]').hasValue('Input Controlled');

    // When user types, onInput callback should be called and state updated
    await fillIn('[data-test-input]', 'New Input Value');
    assert.equal(
      value.current,
      'New Input Value',
      'onInput callback should update the state'
    );
    assert.dom('[data-test-input]').hasValue('New Input Value');
  });

  test('controlled input behavior with both onChange and onInput', async function (assert) {
    const value = cell('Both Callbacks');
    const inputCalls: string[] = [];
    const changeCalls: string[] = [];

    const onInput = (newValue: string) => {
      value.current = newValue;
      inputCalls.push(newValue);
    };

    const onChange = (newValue: string) => {
      changeCalls.push(newValue);
    };

    await render(
      <template>
        <Input
          @label="Name"
          @value={{value.current}}
          @onInput={{onInput}}
          @onChange={{onChange}}
          data-test-input
        />
      </template>
    );

    // Initial controlled value should be rendered
    assert.dom('[data-test-input]').hasValue('Both Callbacks');

    // When user types, both callbacks should be called
    await fillIn('[data-test-input]', 'Updated Value');

    assert.equal(
      value.current,
      'Updated Value',
      'onInput callback should update the state'
    );
    assert.ok(inputCalls.includes('Updated Value'), 'onInput should be called');
    assert.ok(
      changeCalls.includes('Updated Value'),
      'onChange should be called'
    );
    assert.dom('[data-test-input]').hasValue('Updated Value');
  });

  test('uncontrolled input with initial value', async function (assert) {
    // Uncontrolled input can have an initial value but no callbacks
    await render(
      <template>
        <Input @label="Name" @value="Initial" data-test-input />
      </template>
    );

    assert.dom('[data-test-input]').hasValue('Initial');

    // User can change the value and it persists
    await fillIn('[data-test-input]', 'Changed by user');
    assert.dom('[data-test-input]').hasValue('Changed by user');
  });
});
