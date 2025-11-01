import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import Header from '@frontile/overlays/components/drawer/header';

module(
  'Integration | Component | @frontile/overlays/Drawer::Header',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders, content, html attributes, and @labelledById', async function (assert) {
      await render(
        <template>
          <Header
            @labelledById="hello"
            data-test-id="header"
            class="other-class"
          >
            My Header
          </Header>
        </template>
      );

      assert.dom('[data-test-id="header"]').hasText('My Header');
      assert.dom('[data-test-id="header"]').hasAttribute('id', 'hello');
      assert.dom('[data-test-id="header"]').hasClass('other-class');
    });
  }
);
