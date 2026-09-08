import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { click, render } from '@ember/test-helpers';
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

  module('actions and closing', function () {
    test('the actions block renders', async function (assert) {
      await render(
        <template>
          <Alert @intent="danger" @title="Unable to connect">
            <:actions><button
                type="button"
                data-test-id="retry"
              >Retry</button></:actions>
          </Alert>
        </template>
      );

      assert.dom('[data-test-id="alert-actions"]').exists();
      assert
        .dom('[data-test-id="alert-actions"] [data-test-id="retry"]')
        .exists();
    });

    test('there is no actions element when the block is not passed', async function (assert) {
      await render(<template><Alert @title="Saved" /></template>);

      assert.dom('[data-test-id="alert-actions"]').doesNotExist();
    });

    test('the close button appears only when @onClose is passed', async function (assert) {
      await render(<template><Alert @title="Saved" /></template>);

      assert.dom('[data-test-id="alert-close-button"]').doesNotExist();
    });

    test('clicking the close button calls @onClose', async function (assert) {
      let closed = 0;
      const onClose = () => {
        closed++;
      };

      await render(
        <template><Alert @title="Saved" @onClose={{onClose}} /></template>
      );

      assert.dom('[data-test-id="alert-close-button"]').exists();

      await click('[data-test-id="alert-close-button"]');

      assert.strictEqual(closed, 1, 'the close button called @onClose once');
    });

    test('@closeButtonTitle names the close button, defaulting to Close', async function (assert) {
      const onClose = () => {};

      await render(
        <template>
          <Alert
            @title="Alpha"
            @onClose={{onClose}}
            data-test-id="default-title"
          />
          <Alert
            @title="Beta"
            @onClose={{onClose}}
            @closeButtonTitle="Dismiss the beta alert"
            data-test-id="custom-title"
          />
        </template>
      );

      assert
        .dom(
          '[data-test-id="default-title"] [data-test-id="alert-close-button"]'
        )
        .hasText('Close');
      assert
        .dom(
          '[data-test-id="custom-title"] [data-test-id="alert-close-button"]'
        )
        .hasText('Dismiss the beta alert');
    });
  });
});
