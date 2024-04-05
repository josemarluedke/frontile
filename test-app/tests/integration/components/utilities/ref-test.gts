import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click } from '@ember/test-helpers';

import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { ref } from '@frontile/utilities';

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
      {{this.myRef.element.tagName}}
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
  });

  test('it can be used as a helper', async function (assert) {
    await render(
      <template>
        {{#let (ref) as |myRef|}}
          <div {{myRef.setup}} data-test-ref>
            Hello World
          </div>

          <div data-test-id="element-tag-name">
            {{myRef.element.tagName}}
          </div>
        {{/let}}
      </template>
    );

    assert.dom('[data-test-id="element-tag-name"]').hasText('DIV');
  });
});
