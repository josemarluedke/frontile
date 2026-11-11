import { module, test } from 'qunit';
import { setupApplicationTest } from 'ember-qunit';
import { click, fillIn, visit } from '@ember/test-helpers';

const CARDS = [
  'input',
  'textarea',
  'select',
  'native-select',
  'checkbox',
  'checkbox-group',
  'radio',
  'radio-group',
  'switch',
  'input-otp',
  'field-parts',
  'form-live'
];

const FOCUS = 'data-focus-visible-added';

/**
 * Where the forced focus attribute has to land for each control's focus style
 * to show. `null` means the control's focus style cannot be forced, so its
 * matrix has no focus columns.
 */
const FOCUS_TARGETS: Record<string, string | null> = {
  input: 'input[data-part="input"]',
  textarea: 'textarea[data-part="input"]',
  select: 'button[data-part="input"]',
  'native-select': 'select[data-part="input"]',
  checkbox: 'input[type="checkbox"]',
  'checkbox-group': 'input[type="checkbox"]',
  radio: 'input[type="radio"]',
  'radio-group': 'input[type="radio"]',
  switch: null,
  'input-otp': null
};

const ALL_COLUMNS = [
  'default',
  'filled',
  'focus',
  'disabled',
  'readonly',
  'invalid',
  'invalid·focus'
];

function headers(card: string): string[] {
  const matrix = document.querySelector(
    `#${card} [data-workbench-state-matrix]`
  );
  return Array.from(matrix?.querySelectorAll('thead th[data-state]') ?? []).map(
    (th) => th.textContent!.trim()
  );
}

module('Acceptance | components form controls', function (hooks) {
  setupApplicationTest(hooks);

  test('renders the twelve form cards', async function (assert) {
    await visit('/components/form-controls');

    assert.dom('h1').hasText('Form controls');
    assert.dom('[data-workbench-card]').exists({ count: CARDS.length });
    for (const id of CARDS) {
      assert.dom(`#${id}[data-workbench-card]`).exists(`${id} card`);
    }
  });

  test('each control has a States matrix and a Sizes section', async function (assert) {
    await visit('/components/form-controls');

    for (const card of Object.keys(FOCUS_TARGETS)) {
      assert
        .dom(`#${card}-states [data-workbench-state-matrix]`)
        .exists(`${card} has a states matrix`);
      assert.dom(`#${card}-sizes`).exists(`${card} has a sizes section`);
    }
    assert.dom('#field-parts-states').exists('field parts states');
    assert.dom('#field-parts-sizes').exists('field parts sizes');
  });

  test('state columns follow what each control supports', async function (assert) {
    await visit('/components/form-controls');

    assert.deepEqual(headers('input'), ALL_COLUMNS, 'Input has every column');
    assert.deepEqual(
      headers('textarea'),
      ALL_COLUMNS,
      'Textarea has every column'
    );
    assert.deepEqual(
      headers('checkbox'),
      ALL_COLUMNS.filter((c) => c !== 'readonly'),
      'Checkbox has no readonly column'
    );
    assert.deepEqual(
      headers('input-otp'),
      ['default', 'filled', 'disabled', 'readonly', 'invalid'],
      'InputOTP has no focus columns: its focus style is not forceable'
    );
  });

  test('choice controls are labelled with the column label, not the state id', async function (assert) {
    await visit('/components/form-controls');

    for (const card of ['checkbox', 'checkbox-group', 'radio', 'radio-group']) {
      const cells = Array.from(
        document.querySelectorAll(
          `#${card} [data-workbench-state-matrix] td[data-state="invalid-focus"]`
        )
      );
      // One row per size, in each of the two panes.
      assert.true(cells.length >= 2, `${card} has invalid·focus cells`);
      const labelled = cells.filter((td) =>
        td.textContent!.includes('invalid·focus')
      );
      assert.strictEqual(
        labelled.length,
        cells.length,
        `every ${card} invalid·focus cell is labelled invalid·focus`
      );
      assert.notOk(
        cells.some((td) => td.textContent!.includes('invalid-focus')),
        `no ${card} cell shows the raw state id`
      );
    }
  });

  test("Input's invalid cell is aria-invalid, the default cell is not", async function (assert) {
    await visit('/components/form-controls');

    const invalid = document.querySelectorAll(
      '#input-states td[data-state="invalid"] input'
    );
    assert.true(invalid.length > 0, 'invalid cells render inputs');
    assert.true(
      Array.from(invalid).every(
        (i) => i.getAttribute('aria-invalid') === 'true'
      ),
      'every invalid input has aria-invalid="true"'
    );
    const plain = document.querySelectorAll(
      '#input-states td[data-state="default"] input'
    );
    assert.true(plain.length > 0, 'default cells render inputs');
    assert.true(
      Array.from(plain).every((i) => !i.hasAttribute('aria-invalid')),
      'default inputs are not invalid'
    );
    assert.true(
      Array.from(
        document.querySelectorAll<HTMLInputElement>(
          '#input-states td[data-state="readonly"] input'
        )
      ).every((i) => i.readOnly),
      'readonly inputs are read-only'
    );
  });

  test('focus is forced on the element that carries the focus style', async function (assert) {
    await visit('/components/form-controls');

    for (const [card, target] of Object.entries(FOCUS_TARGETS)) {
      const scope = `#${card}-states`;
      if (target === null) {
        assert
          .dom(`${scope} [${FOCUS}]`)
          .doesNotExist(`${card} forces no focus`);
        continue;
      }
      for (const state of ['focus', 'invalid-focus']) {
        const cells = document.querySelectorAll(
          `${scope} td[data-state="${state}"]`
        );
        assert.true(cells.length > 0, `${card} has ${state} cells`);
        for (const cell of Array.from(cells)) {
          const forced = cell.querySelectorAll(`[${FOCUS}]`);
          assert.strictEqual(
            forced.length,
            1,
            `${card} ${state}: one forced element`
          );
          assert.true(
            forced[0]!.matches(target),
            `${card} ${state}: forced on ${target}`
          );
        }
      }
      for (const state of ['default', 'filled', 'disabled', 'invalid']) {
        assert
          .dom(`${scope} td[data-state="${state}"] [${FOCUS}]`)
          .doesNotExist(`${card} ${state} is not focused`);
      }
    }
  });

  test('the Live form validates on submit and shows the submitted data', async function (assert) {
    await visit('/components/form-controls');

    const live = '#form-live';
    assert.dom(`${live} form`).exists('a real form renders');
    assert.dom(`${live} [data-form-live-output]`).doesNotExist('no output yet');

    await click(`${live} button[type="submit"]`);
    assert
      .dom(`${live} [data-component="form-feedback"]`)
      .exists('empty submit shows feedback');
    assert
      .dom(`${live} [data-form-live-output]`)
      .doesNotExist('empty submit shows no output');

    await fillIn(`${live} input[name="name"]`, 'Ada Lovelace');
    await fillIn(`${live} input[name="email"]`, 'not-an-email');
    await click(`${live} button[type="submit"]`);
    assert
      .dom(`${live} input[name="email"]`)
      .hasAttribute('aria-invalid', 'true', 'a malformed email is invalid');
    assert
      .dom(`${live} [data-form-live-output]`)
      .doesNotExist('an invalid submit shows no output');

    await fillIn(`${live} input[name="email"]`, 'ada@example.com');
    await click(`${live} button[type="submit"]`);
    assert
      .dom(`${live} [data-form-live-output]`)
      .includesText('ada@example.com', 'the submitted email is shown');
    assert
      .dom(`${live} [data-form-live-output]`)
      .includesText('Ada Lovelace', 'the submitted name is shown');
  });

  test('invalid cells show visible feedback, default cells none', async function (assert) {
    await visit('/components/form-controls');

    for (const card of [
      'checkbox',
      'checkbox-group',
      'radio',
      'radio-group',
      'switch'
    ]) {
      // Switch has no invalid-focus column (its focus cannot be forced).
      const states =
        card === 'switch' ? ['invalid'] : ['invalid', 'invalid-focus'];
      for (const state of states) {
        const cells = document.querySelectorAll(
          `#${card}-states td[data-state="${state}"]`
        );
        assert.true(cells.length > 0, `${card} has ${state} cells`);
        for (const cell of Array.from(cells)) {
          const text = Array.from(
            cell.querySelectorAll('[data-component="form-feedback"]')
          )
            .map((f) => f.textContent!.trim())
            .join('');
          assert.true(text.length > 0, `${card} ${state}: feedback has text`);
        }
      }
      assert
        .dom(
          `#${card}-states td[data-state="default"] [data-component="form-feedback"]`
        )
        .doesNotExist(`${card} default: no feedback`);
    }
  });

  test('Clear empties the Live form, its data, and the output', async function (assert) {
    await visit('/components/form-controls');

    const live = '#form-live';
    await fillIn(`${live} input[name="name"]`, 'Ada Lovelace');
    await fillIn(`${live} input[name="email"]`, 'ada@example.com');
    await click(`${live} button[type="submit"]`);
    assert
      .dom(`${live} [data-form-live-output]`)
      .exists('valid submit shows output');

    await click(`${live} [data-form-live-clear]`);
    assert.dom(`${live} input[name="name"]`).hasValue('', 'name is cleared');
    assert.dom(`${live} input[name="email"]`).hasValue('', 'email is cleared');
    assert
      .dom(`${live} [data-form-live-output]`)
      .doesNotExist('clear removes the output');

    await click(`${live} button[type="submit"]`);
    assert
      .dom(`${live} [data-component="form-feedback"]`)
      .exists('an empty submit right after clear shows feedback');
    assert
      .dom(`${live} [data-form-live-output]`)
      .doesNotExist('and no stale output');
  });

  test('the old /forms pages are gone', async function (assert) {
    for (const url of ['/forms', '/forms/style-variants']) {
      await assert.rejects(
        visit(url),
        /UnrecognizedURLError|Unrecognized URL|no route/i,
        `${url} does not resolve`
      );
    }
  });
});
