import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, findAll } from '@ember/test-helpers';
import { array } from '@ember/helper';
import WorkbenchStateMatrix, {
  FORM_STATES,
  WORKBENCH_STATES
} from 'test-app/components/workbench/state-matrix';

const FORCE = [
  'data-force-hover',
  'data-force-active',
  'data-focus-visible-added'
];

function forced(el: Element): string[] {
  return FORCE.filter((a) => el.hasAttribute(a));
}

module('Integration | Workbench | state matrix', function (hooks) {
  setupRenderingTest(hooks);

  test('the scroller contains absolutely positioned descendants', async function (assert) {
    // Visually hidden inputs are `position: absolute`. Absolute boxes escape
    // an `overflow` ancestor unless it is also their containing block, so an
    // unpositioned scroller lets them widen the page on narrow screens.
    const rows = ['a'];
    await render(
      <template>
        <WorkbenchStateMatrix @rows={{rows}} as |row|>
          <span class="absolute">{{row}}</span>
        </WorkbenchStateMatrix>
      </template>
    );

    const scroller = document.querySelector('[data-workbench-state-matrix]')!;
    assert.strictEqual(
      window.getComputedStyle(scroller).position,
      'relative',
      'the scroller is the containing block'
    );
    assert.strictEqual(
      window.getComputedStyle(scroller).overflowX,
      'auto',
      'and it still scrolls'
    );
    const absolute = scroller.querySelector('span.absolute') as HTMLElement;
    assert.strictEqual(
      absolute.offsetParent,
      scroller,
      'absolute cells resolve against it'
    );
  });

  test('rows x states with headers', async function (assert) {
    const rows = ['solid', 'outline'];
    await render(
      <template>
        <WorkbenchStateMatrix @rows={{rows}} as |row state cell|>
          <button
            type="button"
            data-test-control
            disabled={{cell.isDisabled}}
            {{cell.force}}
          >{{row}} {{state}}</button>
        </WorkbenchStateMatrix>
      </template>
    );

    assert.dom('[data-workbench-state-matrix]').exists();
    const cols = findAll('thead th[scope="col"][data-state]').map((th) =>
      th.textContent!.trim()
    );
    assert.deepEqual(cols, [...WORKBENCH_STATES], 'one column per state');
    const rowHeaders = findAll('tbody th[scope="row"]').map((th) =>
      th.textContent!.trim()
    );
    assert.deepEqual(rowHeaders, rows, 'one header per row');
    assert
      .dom('td[data-state]')
      .exists({ count: rows.length * WORKBENCH_STATES.length });
  });

  test('each cell forces its state on the yielded control', async function (assert) {
    const rows = ['solid', 'outline'];
    await render(
      <template>
        <WorkbenchStateMatrix @rows={{rows}} as |row state cell|>
          <button
            type="button"
            data-test-control
            disabled={{cell.isDisabled}}
            {{cell.force}}
          >{{row}} {{state}}</button>
        </WorkbenchStateMatrix>
      </template>
    );

    const expected: Record<string, string[]> = {
      rest: [],
      hover: ['data-force-hover'],
      pressed: ['data-force-active'],
      focus: ['data-focus-visible-added'],
      disabled: []
    };
    for (const [state, attrs] of Object.entries(expected)) {
      const controls = findAll(`td[data-state="${state}"] [data-test-control]`);
      assert.strictEqual(controls.length, rows.length, `${state}: one per row`);
      for (const c of controls) {
        assert.deepEqual(forced(c), attrs, `${state} control attributes`);
        assert.strictEqual(
          (c as HTMLButtonElement).disabled,
          state === 'disabled',
          `${state} disabled`
        );
      }
      // The cell wrapper itself does not carry the force attribute.
      for (const td of findAll(`td[data-state="${state}"]`)) {
        assert.deepEqual(forced(td), [], `${state} cell is not forced`);
      }
    }
  });

  test('@states picks columns; without frozen states only rest and disabled remain', async function (assert) {
    const rows = ['solid'];
    await render(
      <template>
        <div data-test-some>
          <WorkbenchStateMatrix
            @rows={{rows}}
            @states={{array "rest" "hover" "disabled"}}
            as |row state cell|
          >
            <button type="button" {{cell.force}}>{{row}} {{state}}</button>
          </WorkbenchStateMatrix>
        </div>
        <div data-test-unfrozen>
          <WorkbenchStateMatrix @rows={{rows}} @frozen={{false}} as |row state|>
            {{row}}
            {{state}}
          </WorkbenchStateMatrix>
        </div>
      </template>
    );

    const cols = (scope: string) =>
      findAll(`${scope} thead th[data-state]`).map((th) =>
        th.getAttribute('data-state')
      );
    assert.deepEqual(cols('[data-test-some]'), ['rest', 'hover', 'disabled']);
    assert.deepEqual(cols('[data-test-unfrozen]'), ['rest', 'disabled']);
  });

  test('form states: labels, value flags, and focus forced twice', async function (assert) {
    const rows = ['md'];
    await render(
      <template>
        <WorkbenchStateMatrix
          @rows={{rows}}
          @states={{FORM_STATES}}
          as |row state cell|
        >
          <input
            data-test-control
            data-filled={{if cell.isFilled "true"}}
            aria-invalid={{if cell.isInvalid "true"}}
            disabled={{cell.isDisabled}}
            readonly={{cell.isReadonly}}
            aria-label="{{row}} {{state}}"
            {{cell.force}}
          />
        </WorkbenchStateMatrix>
      </template>
    );

    const labels = findAll('thead th[data-state]').map((th) =>
      th.textContent!.trim()
    );
    assert.deepEqual(labels, [
      'default',
      'filled',
      'focus',
      'disabled',
      'readonly',
      'invalid',
      'invalid·focus'
    ]);
    const states = findAll('thead th[data-state]').map((th) =>
      th.getAttribute('data-state')
    );
    assert.deepEqual(states, [...FORM_STATES], 'data-state is the state id');

    const expected: Record<string, string[]> = {
      default: [],
      filled: ['filled'],
      focus: ['focus'],
      disabled: ['disabled'],
      readonly: ['readonly'],
      invalid: ['invalid'],
      'invalid-focus': ['invalid', 'focus']
    };
    for (const [state, flags] of Object.entries(expected)) {
      const controls = findAll(`td[data-state="${state}"] [data-test-control]`);
      assert.strictEqual(controls.length, 1, `${state}: one control`);
      const c = controls[0] as HTMLInputElement;
      const actual = [
        c.dataset['filled'] === 'true' ? 'filled' : null,
        forced(c).length > 0 ? 'focus' : null,
        c.disabled ? 'disabled' : null,
        c.readOnly ? 'readonly' : null,
        c.getAttribute('aria-invalid') === 'true' ? 'invalid' : null
      ].filter(Boolean);
      assert.deepEqual(actual.sort(), [...flags].sort(), `${state} flags`);
    }
  });

  test('form states without frozen states drop both focus columns', async function (assert) {
    const rows = ['md'];
    await render(
      <template>
        <WorkbenchStateMatrix
          @rows={{rows}}
          @states={{FORM_STATES}}
          @frozen={{false}}
          as |row state|
        >
          {{row}}
          {{state}}
        </WorkbenchStateMatrix>
      </template>
    );

    const states = findAll('thead th[data-state]').map((th) =>
      th.getAttribute('data-state')
    );
    assert.deepEqual(states, [
      'default',
      'filled',
      'disabled',
      'readonly',
      'invalid'
    ]);
  });
});
