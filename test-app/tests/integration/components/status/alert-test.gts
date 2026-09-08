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

  module('icon', function () {
    test('each intent gets its own default glyph', async function (assert) {
      await render(
        <template>
          <Alert @title="Default" data-test-id="d" />
          <Alert @intent="info" @title="Info" data-test-id="i" />
          <Alert @intent="success" @title="Success" data-test-id="s" />
          <Alert @intent="warning" @title="Warning" data-test-id="w" />
          <Alert @intent="danger" @title="Danger" data-test-id="x" />
        </template>
      );

      // The `default` intent shares the info glyph, as NotificationCard does.
      assert.dom('[data-test-id="d"] [data-test-icon="info"]').exists();
      assert.dom('[data-test-id="i"] [data-test-icon="info"]').exists();
      assert.dom('[data-test-id="s"] [data-test-icon="success"]').exists();
      assert.dom('[data-test-id="w"] [data-test-icon="warning"]').exists();
      assert.dom('[data-test-id="x"] [data-test-icon="danger"]').exists();
    });

    test('the icon block replaces the default glyph', async function (assert) {
      await render(
        <template>
          <Alert @intent="success" @title="Saved">
            <:icon><span data-test-id="custom-icon">*</span></:icon>
          </Alert>
        </template>
      );

      assert.dom('[data-test-id="custom-icon"]').exists();
      assert.dom('[data-test-icon="success"]').doesNotExist();
    });

    test('@hideIcon removes the icon entirely', async function (assert) {
      await render(
        <template>
          <Alert @intent="danger" @title="Failed" @hideIcon={{true}} />
        </template>
      );

      assert.dom('[data-test-id="alert-icon"]').doesNotExist();
      assert.dom('[data-test-icon="danger"]').doesNotExist();
    });

    test('@hideIcon wins over the icon block', async function (assert) {
      await render(
        <template>
          <Alert @title="Saved" @hideIcon={{true}}>
            <:icon><span data-test-id="custom-icon">*</span></:icon>
          </Alert>
        </template>
      );

      assert.dom('[data-test-id="alert-icon"]').doesNotExist();
      assert.dom('[data-test-id="custom-icon"]').doesNotExist();
    });
  });
});
