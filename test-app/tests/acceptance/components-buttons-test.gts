import { module, test } from 'qunit';
import { setupApplicationTest } from 'ember-qunit';
import { click, visit } from '@ember/test-helpers';
import { BUTTON_COLORS } from 'test-app/utils/workbench/options';

const CARDS = [
  'button',
  'button-group',
  'toggle-button',
  'chip',
  'close-button',
  'segmented-control'
];

const FORCE = [
  'data-force-hover',
  'data-force-active',
  'data-focus-visible-added'
];

module('Acceptance | components buttons', function (hooks) {
  setupApplicationTest(hooks);

  test('renders the six button cards', async function (assert) {
    await visit('/components/buttons');

    assert.dom('h1').hasText('Buttons');
    assert.dom('[data-workbench-card]').exists({ count: CARDS.length });
    for (const id of CARDS) {
      assert.dom(`#${id}[data-workbench-card]`).exists(`${id} card`);
    }
  });

  test('ButtonGroup and ToggleButton sections run Sizes, matrix, Live', async function (assert) {
    await visit('/components/buttons');

    const expected: Record<string, string[]> = {
      'button-group': ['sizes', 'variants'],
      'toggle-button': ['sizes', 'off', 'on', 'live']
    };
    for (const [card, ids] of Object.entries(expected)) {
      const root = document.getElementById(card)!;
      const sections = Array.from(
        root.querySelectorAll('[data-workbench-section]')
      ).map((s) => s.id);
      const chips = Array.from(
        root.querySelectorAll('[data-workbench-chip]')
      ).map((c) => c.getAttribute('href'));
      assert.deepEqual(
        sections,
        ids.map((id) => `${card}-${id}`),
        `${card} section order`
      );
      assert.deepEqual(
        chips,
        ids.map((id) => `#${card}-${id}`),
        `${card} chip order matches`
      );
    }
  });

  test('Button has one state matrix per color in each pane', async function (assert) {
    await visit('/components/buttons');

    assert.true(BUTTON_COLORS.length > 0, 'there are colors to check');
    assert
      .dom('#button [data-workbench-state-matrix]')
      .exists(
        { count: BUTTON_COLORS.length * 3 },
        'one matrix per color in each of LIGHT/DARK/INVERSE'
      );
    for (const color of BUTTON_COLORS) {
      assert
        .dom(
          `#button-${color} [data-workbench-state-matrix][data-color="${color}"]`
        )
        .exists({ count: 3 }, `${color} has a matrix in each pane`);
    }
  });

  test('matrix cells freeze the state on the control itself', async function (assert) {
    await visit('/components/buttons');

    const expect: Record<string, string | null> = {
      rest: null,
      hover: 'data-force-hover',
      pressed: 'data-force-active',
      focus: 'data-focus-visible-added',
      disabled: null
    };

    for (const [state, attribute] of Object.entries(expect)) {
      const buttons = document.querySelectorAll(
        `#button td[data-state="${state}"] button`
      );
      assert.true(buttons.length > 0, `${state} cells render buttons`);
      const ok = Array.from(buttons).every((b) =>
        FORCE.every((a) => b.hasAttribute(a) === (a === attribute))
      );
      assert.true(
        ok,
        `${state} buttons carry ${attribute ?? 'no force attribute'}`
      );
      const disabled = Array.from(buttons).every(
        (b) => (b as HTMLButtonElement).disabled === (state === 'disabled')
      );
      assert.true(
        disabled,
        `${state} buttons disabled only in the disabled column`
      );
    }
  });

  test('ToggleButton Live toggles flip aria-pressed', async function (assert) {
    await visit('/components/buttons');

    const selector = '#toggle-button-live [data-component="toggle-button"]';
    assert.dom(selector).exists('live toggles render');
    const toggle = document.querySelector(selector)!;
    const before = toggle.getAttribute('aria-pressed');
    assert.true(before === 'true' || before === 'false', 'aria-pressed is set');

    await click(toggle);
    const after = before === 'true' ? 'false' : 'true';
    assert.dom(toggle).hasAttribute('aria-pressed', after, 'first click flips');

    await click(toggle);
    assert
      .dom(toggle)
      .hasAttribute('aria-pressed', before!, 'second click flips back');
  });

  test('SegmentedControl Live changes the selection', async function (assert) {
    await visit('/components/buttons');

    const items = document.querySelectorAll<HTMLElement>(
      '#segmented-control-live [role="radio"]'
    );
    assert.true(items.length > 1, 'live items render');
    await click(items[items.length - 1]!);
    assert
      .dom('[data-segmented-live-value]')
      .hasText(items[items.length - 1]!.textContent!.trim());
  });

  test('the old /buttons and /core pages are gone', async function (assert) {
    for (const url of ['/buttons', '/core']) {
      await assert.rejects(
        visit(url),
        /UnrecognizedURLError|Unrecognized URL|no route/i,
        `${url} does not resolve`
      );
    }
  });
});
