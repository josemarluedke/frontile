import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, findAll } from '@ember/test-helpers';
import { array } from '@ember/helper';
import WorkbenchStateMatrix, {
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
});
