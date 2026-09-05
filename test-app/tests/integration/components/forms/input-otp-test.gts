import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find, findAll, fillIn, blur } from '@ember/test-helpers';
import { cell as trackedCell } from 'ember-resources';

import { Form, InputOtp } from 'frontile';

module('Integration | Component | @frontile/forms/InputOtp', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders a label, one real input and six cells by default', async function (assert) {
    await render(<template><InputOtp @label="Verification code" /></template>);

    assert.dom('[data-component="label"]').hasText('Verification code');
    assert.dom('[data-component="input-otp"]').exists();
    assert.strictEqual(
      findAll('[data-component="input-otp-input"]').length,
      1,
      'there is exactly one real input'
    );
    assert.strictEqual(
      findAll('[data-test-id="input-otp-cell"]').length,
      6,
      'defaults to six cells'
    );
  });

  test('@length controls the number of cells and the maxlength', async function (assert) {
    await render(<template><InputOtp @label="Code" @length={{4}} /></template>);

    assert.strictEqual(findAll('[data-test-id="input-otp-cell"]').length, 4);
    assert
      .dom('[data-component="input-otp-input"]')
      .hasAttribute('maxlength', '4');
  });

  test('the label is associated with the real input', async function (assert) {
    await render(<template><InputOtp @label="Code" /></template>);

    const input = find(
      '[data-component="input-otp-input"]'
    ) as HTMLInputElement;
    const id = input.getAttribute('id') || '';

    assert.ok(/ember[1-9.]/.test(id), 'the input has a generated id');
    assert.dom('[data-component="label"]').hasAttribute('for', id);
  });

  test('typing fills the cells left to right', async function (assert) {
    await render(<template><InputOtp @label="Code" @length={{6}} /></template>);

    await fillIn('[data-component="input-otp-input"]', '123');

    const cells = findAll('[data-test-id="input-otp-cell"]');
    assert.dom(cells[0] as Element).hasText('1');
    assert.dom(cells[1] as Element).hasText('2');
    assert.dom(cells[2] as Element).hasText('3');
    assert.dom(cells[3] as Element).hasText('');
  });

  test('the cells are decoration: no roles, no labels, no tab stops', async function (assert) {
    await render(<template><InputOtp @label="Code" /></template>);

    for (const cell of findAll('[data-test-id="input-otp-cell"]')) {
      assert.dom(cell).hasAttribute('aria-hidden', 'true');
      assert.dom(cell).doesNotHaveAttribute('role');
      assert.dom(cell).doesNotHaveAttribute('tabindex');
      assert.dom(cell).doesNotHaveAttribute('aria-label');
    }

    assert.strictEqual(
      findAll(
        '[data-component="input-otp"] [tabindex], [data-component="input-otp"] button'
      ).length,
      0,
      'nothing but the input is focusable'
    );
  });

  test('...attributes land on the real input', async function (assert) {
    await render(
      <template><InputOtp @label="Code" @name="otp" data-test-otp /></template>
    );

    assert
      .dom('[data-component="input-otp-input"]')
      .hasAttribute('name', 'otp');
    assert
      .dom('[data-component="input-otp-input"]')
      .hasAttribute('data-test-otp');
  });

  test('uncontrolled: it owns its own value', async function (assert) {
    await render(<template><InputOtp @label="Code" /></template>);

    await fillIn('[data-component="input-otp-input"]', '42');

    assert
      .dom(findAll('[data-test-id="input-otp-cell"]')[0] as Element)
      .hasText('4');
    assert
      .dom(findAll('[data-test-id="input-otp-cell"]')[1] as Element)
      .hasText('2');
  });

  test('controlled: @value drives the cells and @onChange reports back', async function (assert) {
    const value = trackedCell<string>('');
    const update = (next: string) => value.set(next);

    await render(
      <template>
        <InputOtp @label="Code" @value={{value.current}} @onChange={{update}} />
      </template>
    );

    await fillIn('[data-component="input-otp-input"]', '99');

    assert.strictEqual(
      value.current,
      '99',
      'the parent received the new value'
    );
    assert
      .dom(findAll('[data-test-id="input-otp-cell"]')[0] as Element)
      .hasText('9');
  });

  test('controlled without feedback: cells still render what was typed', async function (assert) {
    // <Form> is exactly this parent -- it binds a value it does not feed back,
    // reading the real one off the DOM instead.
    const noop = () => {};

    await render(
      <template><InputOtp @label="Code" @onChange={{noop}} /></template>
    );

    await fillIn('[data-component="input-otp-input"]', '77');

    assert
      .dom(findAll('[data-test-id="input-otp-cell"]')[0] as Element)
      .hasText('7');
    assert
      .dom(findAll('[data-test-id="input-otp-cell"]')[1] as Element)
      .hasText('7');
  });

  test('@onInput fires per keystroke and @onBlur on blur', async function (assert) {
    const seen: string[] = [];
    const onInput = (next: string) => seen.push(next);
    const onBlur = () => assert.step('blurred');

    await render(
      <template>
        <InputOtp @label="Code" @onInput={{onInput}} @onBlur={{onBlur}} />
      </template>
    );

    await fillIn('[data-component="input-otp-input"]', '5');
    await blur('[data-component="input-otp-input"]');

    assert.deepEqual(seen, ['5']);
    assert.verifySteps(['blurred']);
  });
});
