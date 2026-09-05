import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  find,
  findAll,
  fillIn,
  blur,
  focus,
  settled
} from '@ember/test-helpers';
import { cell as trackedCell } from 'ember-resources';

import { Form, InputOtp } from 'frontile';

async function setCaret(at: number, to = at): Promise<void> {
  const input = find('[data-component="input-otp-input"]') as HTMLInputElement;
  input.setSelectionRange(at, to);
  document.dispatchEvent(new Event('selectionchange'));
  await settled();
}

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

  test('@onComplete fires once when the code becomes full', async function (assert) {
    const completed: string[] = [];
    const onComplete = (value: string) => completed.push(value);

    await render(
      <template>
        <InputOtp @label="Code" @length={{4}} @onComplete={{onComplete}} />
      </template>
    );

    await fillIn('[data-component="input-otp-input"]', '123');
    assert.deepEqual(completed, [], 'not fired while incomplete');

    await fillIn('[data-component="input-otp-input"]', '1234');
    assert.deepEqual(completed, ['1234'], 'fired on the transition to full');
  });

  test('@onComplete refires after an edit and refill', async function (assert) {
    const completed: string[] = [];
    const onComplete = (value: string) => completed.push(value);

    await render(
      <template>
        <InputOtp @label="Code" @length={{4}} @onComplete={{onComplete}} />
      </template>
    );

    await fillIn('[data-component="input-otp-input"]', '1234');
    await fillIn('[data-component="input-otp-input"]', '123');
    await fillIn('[data-component="input-otp-input"]', '1239');

    assert.deepEqual(completed, ['1234', '1239']);
  });

  test('@onComplete alone does not make the component controlled', async function (assert) {
    const onComplete = () => {};

    await render(
      <template>
        <InputOtp @label="Code" @length={{4}} @onComplete={{onComplete}} />
      </template>
    );

    await fillIn('[data-component="input-otp-input"]', '12');

    assert
      .dom(findAll('[data-test-id="input-otp-cell"]')[0] as Element)
      .hasText('1');
    assert
      .dom(findAll('[data-test-id="input-otp-cell"]')[1] as Element)
      .hasText('2');
  });

  test('a full autofill in a single event fires @onComplete exactly once', async function (assert) {
    // This is the SMS-autofill path: the platform drops the whole code in at
    // once, which is precisely what N one-character inputs cannot receive.
    const completed: string[] = [];
    const onComplete = (value: string) => completed.push(value);

    await render(
      <template>
        <InputOtp @label="Code" @length={{6}} @onComplete={{onComplete}} />
      </template>
    );

    await fillIn('[data-component="input-otp-input"]', '135790');

    assert.deepEqual(completed, ['135790']);
    assert
      .dom(findAll('[data-test-id="input-otp-cell"]')[5] as Element)
      .hasText('0');
  });

  test('digits is the default and rejects letters wholesale', async function (assert) {
    await render(<template><InputOtp @label="Code" @length={{6}} /></template>);

    const input = find(
      '[data-component="input-otp-input"]'
    ) as HTMLInputElement;

    await fillIn(input, '123');
    assert.strictEqual(input.value, '123');

    await fillIn(input, '12a');
    assert.strictEqual(input.value, '123', 'the rejected value did not stick');
    assert
      .dom(findAll('[data-test-id="input-otp-cell"]')[2] as Element)
      .hasText('3');
  });

  test('a pasted value with a separator is rejected, not filtered', async function (assert) {
    await render(<template><InputOtp @label="Code" @length={{6}} /></template>);

    const input = find(
      '[data-component="input-otp-input"]'
    ) as HTMLInputElement;
    // Six characters, not seven: `maxlength` truncates an over-long paste in a
    // real browser before our handler ever sees it, and fillIn guards on the
    // same limit. What reaches us is a full-length value with a separator in
    // it, which is exactly the case worth asserting on.
    await fillIn(input, '12-456');

    assert.strictEqual(
      input.value,
      '',
      'all-or-nothing, never silently repaired'
    );
  });

  test('@allowedChars alphanumeric accepts letters and switches inputmode', async function (assert) {
    await render(
      <template>
        <InputOtp @label="Code" @allowedChars="alphanumeric" @length={{6}} />
      </template>
    );

    const input = find(
      '[data-component="input-otp-input"]'
    ) as HTMLInputElement;
    await fillIn(input, 'a1b2');

    assert.strictEqual(input.value, 'a1b2');
    assert.dom(input).hasAttribute('inputmode', 'text');
  });

  test('@pattern overrides @allowedChars', async function (assert) {
    const hexish = /^[0-9a-f]+$/;

    await render(
      <template>
        <InputOtp @label="Code" @pattern={{hexish}} @length={{4}} />
      </template>
    );

    const input = find(
      '[data-component="input-otp-input"]'
    ) as HTMLInputElement;

    await fillIn(input, 'beef');
    assert.strictEqual(input.value, 'beef');

    await fillIn(input, 'zzzz');
    assert.strictEqual(input.value, 'beef');
  });

  test('it carries the attributes autofill and password managers need', async function (assert) {
    await render(<template><InputOtp @label="Code" @length={{6}} /></template>);

    assert
      .dom('[data-component="input-otp-input"]')
      .hasAttribute('autocomplete', 'one-time-code');
    assert
      .dom('[data-component="input-otp-input"]')
      .hasAttribute('type', 'text');
    assert
      .dom('[data-component="input-otp-input"]')
      .hasAttribute('inputmode', 'numeric');
    assert
      .dom('[data-component="input-otp-input"]')
      .hasAttribute('pattern', '^\\d+$');
    assert
      .dom('[data-component="input-otp-input"]')
      .hasAttribute('spellcheck', 'false');
    assert
      .dom('[data-component="input-otp-input"]')
      .hasAttribute('autocorrect', 'off');
    assert.dom('[data-component="input-otp"]').hasAttribute('translate', 'no');
  });

  test('moving forward, a collapsed caret widens onto the cell after it', async function (assert) {
    await render(<template><InputOtp @label="Code" @length={{6}} /></template>);

    await fillIn('[data-component="input-otp-input"]', '123456');
    await focus('[data-component="input-otp-input"]');

    // Establish the prior caret explicitly. Direction is inferred by comparing
    // against where the caret just was, and after fillIn that is not
    // deterministic -- browsers differ on whether a programmatic value set
    // fires selectionchange.
    await setCaret(0);
    await setCaret(2);

    const active = findAll(
      '[data-test-id="input-otp-cell"][data-active="true"]'
    );
    assert.strictEqual(active.length, 1, 'exactly one cell is active');
    assert
      .dom(active[0] as Element)
      .hasText('3', 'widened onto the following cell');
  });

  test('moving backward, a collapsed caret widens onto the cell before it', async function (assert) {
    // This is the ArrowLeft case: without the -1 shift the caret appears to
    // skip a cell.
    await render(<template><InputOtp @label="Code" @length={{6}} /></template>);

    await fillIn('[data-component="input-otp-input"]', '123456');
    await focus('[data-component="input-otp-input"]');

    await setCaret(5);
    await setCaret(2);

    const active = findAll(
      '[data-test-id="input-otp-cell"][data-active="true"]'
    );
    assert.strictEqual(active.length, 1, 'exactly one cell is active');
    assert
      .dom(active[0] as Element)
      .hasText('2', 'widened onto the preceding cell');
  });

  test('the caret at the start selects the first cell', async function (assert) {
    await render(<template><InputOtp @label="Code" @length={{6}} /></template>);

    await fillIn('[data-component="input-otp-input"]', '123456');
    await focus('[data-component="input-otp-input"]');
    await setCaret(0);

    const active = findAll(
      '[data-test-id="input-otp-cell"][data-active="true"]'
    );
    assert.strictEqual(active.length, 1);
    assert.dom(active[0] as Element).hasText('1');
  });

  test('the caret at the end selects the last cell, not past it', async function (assert) {
    await render(<template><InputOtp @label="Code" @length={{6}} /></template>);

    await fillIn('[data-component="input-otp-input"]', '123456');
    await focus('[data-component="input-otp-input"]');
    await setCaret(6);

    const active = findAll(
      '[data-test-id="input-otp-cell"][data-active="true"]'
    );
    assert.strictEqual(active.length, 1);
    assert.dom(active[0] as Element).hasText('6');
  });

  test('append mode leaves the next empty cell active', async function (assert) {
    // The exemption that stops the 4th keystroke replacing the 3rd character.
    await render(<template><InputOtp @label="Code" @length={{6}} /></template>);

    await fillIn('[data-component="input-otp-input"]', '123');
    await focus('[data-component="input-otp-input"]');
    await setCaret(3);

    const cells = findAll('[data-test-id="input-otp-cell"]');
    assert.dom(cells[3] as Element).hasAttribute('data-active', 'true');
    assert
      .dom(cells[3] as Element)
      .hasText('', 'the active cell is the empty one');
  });

  test('a range selection makes every covered cell active', async function (assert) {
    await render(<template><InputOtp @label="Code" @length={{6}} /></template>);

    await fillIn('[data-component="input-otp-input"]', '123456');
    await focus('[data-component="input-otp-input"]');
    await setCaret(1, 4);

    assert.strictEqual(
      findAll('[data-test-id="input-otp-cell"][data-active="true"]').length,
      3,
      'shift-arrow ranges light up every covered cell'
    );
  });

  test('an empty active cell shows the fake caret; a filled one does not', async function (assert) {
    await render(<template><InputOtp @label="Code" @length={{6}} /></template>);

    await focus('[data-component="input-otp-input"]');
    await setCaret(0);
    assert.dom('[data-test-id="input-otp-caret"]').exists('empty active cell');

    await fillIn('[data-component="input-otp-input"]', '123456');
    await setCaret(2);
    assert
      .dom('[data-test-id="input-otp-caret"]')
      .doesNotExist('a filled active cell shows its character instead');
  });

  test('no cell is active while the input is not focused', async function (assert) {
    await render(<template><InputOtp @label="Code" @length={{6}} /></template>);

    await fillIn('[data-component="input-otp-input"]', '123456');
    await focus('[data-component="input-otp-input"]');
    await setCaret(2);
    await blur('[data-component="input-otp-input"]');

    assert.strictEqual(
      findAll('[data-test-id="input-otp-cell"][data-active="true"]').length,
      0
    );
  });

  test('deleting moves the active cell without any selectionchange from the browser', async function (assert) {
    // No browser fires selectionchange for a deletion, so the component has to
    // dispatch one itself or the active cell would stick where it was.
    await render(<template><InputOtp @label="Code" @length={{6}} /></template>);

    await fillIn('[data-component="input-otp-input"]', '123456');
    await focus('[data-component="input-otp-input"]');
    await setCaret(6);

    await fillIn('[data-component="input-otp-input"]', '12345');

    const active = findAll(
      '[data-test-id="input-otp-cell"][data-active="true"]'
    );
    assert.strictEqual(active.length, 1, 'still exactly one active cell');
    assert.dom(active[0] as Element).hasText('', 'it followed the deletion');
  });

  test('focusing a full code selects the last cell', async function (assert) {
    await render(<template><InputOtp @label="Code" @length={{6}} /></template>);

    await fillIn('[data-component="input-otp-input"]', '123456');
    await blur('[data-component="input-otp-input"]');
    await focus('[data-component="input-otp-input"]');

    const active = findAll(
      '[data-test-id="input-otp-cell"][data-active="true"]'
    );
    assert.strictEqual(active.length, 1);
    assert.dom(active[0] as Element).hasText('6');
  });
});
