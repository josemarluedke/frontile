import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click } from '@ember/test-helpers';

import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { ref } from 'frontile';

class MyTestComponent extends Component {
  @tracked isShowing = false;

  myRef = ref<HTMLDivElement>();

  toggle = () => {
    this.isShowing = !this.isShowing;
  };

  <template>
    {{#if this.isShowing}}
      <div {{this.myRef.setup}} data-test-ref>
        Hello World
      </div>
    {{/if}}

    <button data-test-id="toggle" {{on "click" this.toggle}}>
      Toggle
    </button>

    <div data-test-id="element-tag-name">
      {{this.myRef.current.tagName}}
    </div>
  </template>
}

module('Integration | @frontile/utilities/ref', function (hooks) {
  setupRenderingTest(hooks);

  test('it works', async function (assert) {
    await render(<template><MyTestComponent /></template>);

    assert.dom('[data-test-id="element-tag-name"]').hasText('');
    await click('[data-test-id="toggle"]');

    assert.dom('[data-test-id="element-tag-name"]').hasText('DIV');

    await click('[data-test-id="toggle"]');
    assert.dom('[data-test-id="element-tag-name"]').hasText('');
  });

  test('it can be used as a helper', async function (assert) {
    await render(
      <template>
        {{#let (ref) as |myRef|}}
          <div {{myRef.setup}} data-test-ref>
            Hello World
          </div>

          <div data-test-id="element-tag-name">
            {{myRef.current.tagName}}
          </div>
        {{/let}}
      </template>
    );

    assert.dom('[data-test-id="element-tag-name"]').hasText('DIV');
  });

  test('it calls onChange callback when element changes', async function (assert) {
    let lastElement: HTMLDivElement | undefined = undefined;
    let callbackCalls = 0;
    const onChange = (el: HTMLDivElement | undefined) => {
      callbackCalls++;
      lastElement = el;
    };

    class MyTestComponentWithCallback extends Component {
      @tracked isShowing = false;
      myRef = ref<HTMLDivElement>(onChange);

      toggle = () => {
        this.isShowing = !this.isShowing;
      };

      <template>
        {{#if this.isShowing}}
          <div {{this.myRef.setup}} data-test-ref>
            Callback Test
          </div>
        {{/if}}
        <button data-test-id="toggle" {{on "click" this.toggle}}>
          Toggle
        </button>
        <div data-test-id="callback-status">
          {{if this.myRef.current "Element Present" "No Element"}}
        </div>
      </template>
    }

    await render(<template><MyTestComponentWithCallback /></template>);

    // Initially, no element is rendered, so the callback should not have been called yet.
    assert.strictEqual(
      lastElement,
      undefined,
      'Initial state: no element present'
    );

    // Toggle on: the element is rendered.
    await click('[data-test-id="toggle"]');
    assert.ok(
      lastElement,
      'Callback was called with an element when toggled on'
    );
    assert.equal(lastElement!.tagName, 'DIV', 'The element is a DIV');
    assert.ok(callbackCalls > 0, 'onChange callback was called at least once');

    // Toggle off: the element is removed.
    await click('[data-test-id="toggle"]');
    assert.strictEqual(
      lastElement,
      undefined,
      'Callback was called with undefined when element was removed'
    );
  });
});
