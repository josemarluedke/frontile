import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

module('Integration | Component | Button', function(hooks) {
  setupRenderingTest(hooks);

  test('it renders', async function(assert) {
    await render(hbs`<Button data-test-id="button">My Button</Button>`);

    assert.dom('[data-test-id="button"]').hasText('My Button');
  });

  test('it accepts type attribute', async function(assert) {
    await render(
      hbs`<Button type="submit" data-test-id="button">My Button</Button>`
    );

    assert.dom('[data-test-id="button"]').hasAttribute('type', 'submit');
  });

  module('Style classes', () => {
    module('@appearance', () => {
      test('it adds class for default appearance', async function(assert) {
        await render(hbs`<Button data-test-id="button">My Button</Button>`);

        assert.dom('[data-test-id="button"]').hasClass('btn');
      });

      test('it adds class for outlined appearance', async function(assert) {
        await render(
          hbs`<Button @appearance="outlined" data-test-id="button">My Button</Button>`
        );

        assert.dom('[data-test-id="button"]').doesNotHaveClass('btn');
        assert.dom('[data-test-id="button"]').doesNotHaveClass('btn-minimal');
        assert.dom('[data-test-id="button"]').hasClass('btn-outlined');
      });

      test('it adds class for outlined appearance', async function(assert) {
        await render(
          hbs`<Button @appearance="minimal" data-test-id="button">My Button</Button>`
        );

        assert.dom('[data-test-id="button"]').doesNotHaveClass('btn');
        assert.dom('[data-test-id="button"]').doesNotHaveClass('btn-outlined');
        assert.dom('[data-test-id="button"]').hasClass('btn-minimal');
      });
    });

    module('@intent', () => {
      test('it adds class for the an intent', async function(assert) {
        await render(
          hbs`<Button @intent="primary" data-test-id="button">My Button</Button>`
        );

        assert.dom('[data-test-id="button"]').hasClass('btn-primary');
        assert
          .dom('[data-test-id="button"]')
          .doesNotHaveClass('btn-outlined-primary');
        assert
          .dom('[data-test-id="button"]')
          .doesNotHaveClass('btn-minimal-primary');
      });

      test('it adds class for the an intent with appearance=outlined', async function(assert) {
        await render(
          hbs`<Button
                @appearance="outlined"
                @intent="primary"
                data-test-id="button"
              >
                My Button
             </Button>`
        );

        assert.dom('[data-test-id="button"]').hasClass('btn-outlined-primary');
        assert.dom('[data-test-id="button"]').doesNotHaveClass('btn-primary');
        assert
          .dom('[data-test-id="button"]')
          .doesNotHaveClass('btn-minimal-primary');
      });

      test('it adds class for the an intent with appearance=minimal', async function(assert) {
        await render(
          hbs`<Button
                @appearance="minimal"
                @intent="primary"
                data-test-id="button"
              >
                My Button
             </Button>`
        );

        assert.dom('[data-test-id="button"]').hasClass('btn-minimal-primary');
        assert.dom('[data-test-id="button"]').doesNotHaveClass('btn-primary');
        assert
          .dom('[data-test-id="button"]')
          .doesNotHaveClass('btn-outlined-primary');
      });
    });
  });
});
