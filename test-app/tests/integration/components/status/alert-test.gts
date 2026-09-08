import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { Alert } from 'frontile';

module('Integration | Component | Alert | @frontile/status', function (hooks) {
  setupRenderingTest(hooks);

  module('content', function () {
    test('it renders @title and @description', async function (assert) {
      await render(
        <template>
          <Alert
            @title="Update available"
            @description="A new version is ready."
          />
        </template>
      );

      assert.dom('[data-test-id="alert"]').exists();
      assert
        .dom('[data-test-id="alert"]')
        .hasAttribute('data-component', 'alert');
      assert.dom('[data-test-id="alert-title"]').hasText('Update available');
      assert
        .dom('[data-test-id="alert-description"]')
        .hasText('A new version is ready.');
    });

    test('it omits the title and description elements when neither is given', async function (assert) {
      await render(<template><Alert /></template>);

      assert.dom('[data-test-id="alert"]').exists();
      assert.dom('[data-test-id="alert-title"]').doesNotExist();
      assert.dom('[data-test-id="alert-description"]').doesNotExist();
    });

    test('the title block overrides @title', async function (assert) {
      await render(
        <template>
          <Alert @title="From the argument">
            <:title>From the block</:title>
          </Alert>
        </template>
      );

      assert.dom('[data-test-id="alert-title"]').hasText('From the block');
      assert.dom('[data-test-id="alert-title"]').doesNotContainText('argument');
    });

    test('the description block overrides @description and takes markup', async function (assert) {
      await render(
        <template>
          <Alert @title="Unable to connect" @description="From the argument">
            <:description>
              <ul>
                <li>Check your internet connection</li>
                <li>Refresh the page</li>
              </ul>
            </:description>
          </Alert>
        </template>
      );

      assert
        .dom('[data-test-id="alert-description"]')
        .doesNotContainText('argument');
      assert.dom('[data-test-id="alert-description"] li').exists({ count: 2 });
      assert
        .dom('[data-test-id="alert-description"] li')
        .hasText('Check your internet connection');
    });

    test('attributes are forwarded to the root element', async function (assert) {
      await render(
        <template>
          <Alert @title="Saved" data-extra="yes" aria-label="Saved alert" />
        </template>
      );

      assert.dom('[data-test-id="alert"]').hasAttribute('data-extra', 'yes');
      assert
        .dom('[data-test-id="alert"]')
        .hasAttribute('aria-label', 'Saved alert');
    });
  });
});
