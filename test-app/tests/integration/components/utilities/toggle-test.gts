import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click } from '@ember/test-helpers';
import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import { toggleState } from 'frontile';

class MyTestComponent extends Component {
  showingState = toggleState(false);

  show = () => {
    this.showingState.toggle(true);
  };

  <template>
    {{#if this.showingState.current}}
      <div data-test-content>
        Hello World
      </div>
    {{/if}}

    <button
      data-test-id="button-toggle"
      type="button"
      {{on "click" this.showingState.toggle}}
    >
      Toggle
    </button>

    <input
      data-test-id="input-toggle"
      type="checkbox"
      checked={{this.showingState.current}}
      {{on "change" this.showingState.toggle}}
    />

    <button data-test-id="button-direct" type="button" {{on "click" this.show}}>
      Show
    </button>
  </template>
}

module('Integration | @frontile/utilities/toggleState', function (hooks) {
  setupRenderingTest(hooks);

  test('it works', async function (assert) {
    await render(<template><MyTestComponent /></template>);

    assert.dom('[data-test-content]').doesNotExist();
    await click('[data-test-id="button-toggle"]');
    assert.dom('[data-test-content]').exists();

    await click('[data-test-id="input-toggle"]');
    assert.dom('[data-test-content]').doesNotExist();

    await click('[data-test-id="button-direct"]');
    assert.dom('[data-test-content]').exists();
  });

  test('it can be used as a helper', async function (assert) {
    await render(
      <template>
        {{#let (toggleState) as |state|}}
          {{#if state.current}}
            <div data-test-content>
              Hello World
            </div>
          {{/if}}

          <button
            data-test-id="button-toggle"
            type="button"
            {{on "click" state.toggle}}
          >
            Toggle
          </button>
        {{/let}}
      </template>
    );

    assert.dom('[data-test-content]').doesNotExist();
    await click('[data-test-id="button-toggle"]');
    assert.dom('[data-test-content]').exists();
  });

  test('it calls callbacks onOn, onOff', async function (assert) {
    let calledOn = false;
    let calledOff = false;

    const onChange = (val: boolean) => {
      if (val) {
        calledOn = true;
      } else {
        calledOff = true;
      }
    };

    await render(
      <template>
        {{#let (toggleState false onChange) as |state|}}
          {{#if state.current}}
            <div data-test-content>
              Hello World
            </div>
          {{/if}}

          <button
            data-test-id="button-toggle"
            type="button"
            {{on "click" state.toggle}}
          >
            Toggle
          </button>
        {{/let}}
      </template>
    );

    assert.equal(calledOn, false);
    assert.equal(calledOff, false);

    await click('[data-test-id="button-toggle"]');
    assert.equal(calledOn, true);
    assert.equal(calledOff, false);

    await click('[data-test-id="button-toggle"]');
    assert.equal(calledOff, true);
  });
});
