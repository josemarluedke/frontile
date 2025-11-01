import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import Body from '@frontile/overlays/components/modal/body';

module(
  'Integration | Component | @frontile/overlays/Modal::Body',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders, content and html attributes', async function (assert) {
      await render(
        <template>
          <Body data-test-id="body" class="other-class">
            My Body
          </Body>
        </template>
      );

      assert.dom('[data-test-id="body"]').hasText('My Body');
      assert.dom('[data-test-id="body"]').hasClass('other-class');
    });
  }
);
