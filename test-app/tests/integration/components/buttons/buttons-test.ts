import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

module('Integration | Component | @frontile/buttons', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders', async function (assert) {
    await render(hbs`<Button data-test-id="button">My Button</Button>`);

    assert.dom('[data-test-id="button"]').hasText('My Button');
    assert.dom('[data-test-id="button"]').hasAttribute('type', 'button');
  });

  test('it accepts @type argument', async function (assert) {
    await render(
      hbs`<Button @type="submit" data-test-id="button">My Button</Button>`
    );

    assert.dom('[data-test-id="button"]').hasAttribute('type', 'submit');
  });

  module('Style classes', () => {
    module('@appearance', () => {
      test('it adds class for default appearance', async function (assert) {
        await render(hbs`<Button data-test-id="button">My Button</Button>`);

        assert.dom('[data-test-id="button"]').doesNotHaveClass('btn-outlined');
        assert.dom('[data-test-id="button"]').doesNotHaveClass('btn-minimal');
        assert.dom('[data-test-id="button"]').doesNotHaveClass('btn-custom');
        assert.dom('[data-test-id="button"]').hasClass('btn');
      });

      test('it adds class for outlined appearance', async function (assert) {
        await render(
          hbs`<Button @appearance="outlined" data-test-id="button">My Button</Button>`
        );

        assert.dom('[data-test-id="button"]').doesNotHaveClass('btn');
        assert.dom('[data-test-id="button"]').doesNotHaveClass('btn-minimal');
        assert.dom('[data-test-id="button"]').doesNotHaveClass('btn-custom');
        assert.dom('[data-test-id="button"]').hasClass('btn-outlined');
      });

      test('it adds class for minimal appearance', async function (assert) {
        await render(
          hbs`<Button @appearance="minimal" data-test-id="button">My Button</Button>`
        );

        assert.dom('[data-test-id="button"]').doesNotHaveClass('btn');
        assert.dom('[data-test-id="button"]').doesNotHaveClass('btn-outlined');
        assert.dom('[data-test-id="button"]').doesNotHaveClass('btn-custom');
        assert.dom('[data-test-id="button"]').hasClass('btn-minimal');
      });

      test('it adds class for custom appearance', async function (assert) {
        await render(
          hbs`<Button @appearance="custom" data-test-id="button">My Button</Button>`
        );

        assert.dom('[data-test-id="button"]').doesNotHaveClass('btn');
        assert.dom('[data-test-id="button"]').doesNotHaveClass('btn-outlined');
        assert.dom('[data-test-id="button"]').doesNotHaveClass('btn-minimal');
        assert.dom('[data-test-id="button"]').hasClass('btn-custom');
      });
    });

    module('@intent', () => {
      test('it adds class for the an intent', async function (assert) {
        await render(
          hbs`<Button @intent="primary" data-test-id="button">My Button</Button>`
        );

        assert.dom('[data-test-id="button"]').hasClass('btn--primary');
        assert
          .dom('[data-test-id="button"]')
          .doesNotHaveClass('btn-outlined--primary');
        assert
          .dom('[data-test-id="button"]')
          .doesNotHaveClass('btn-minimal--primary');
      });

      test('it adds class for the an intent with appearance=outlined', async function (assert) {
        await render(
          hbs`<Button
                @appearance="outlined"
                @intent="primary"
                data-test-id="button"
              >
                My Button
             </Button>`
        );

        assert.dom('[data-test-id="button"]').hasClass('btn-outlined--primary');
        assert.dom('[data-test-id="button"]').doesNotHaveClass('btn--primary');
        assert
          .dom('[data-test-id="button"]')
          .doesNotHaveClass('btn-minimal--primary');
      });

      test('it adds class for the an intent with appearance=minimal', async function (assert) {
        await render(
          hbs`<Button
                @appearance="minimal"
                @intent="primary"
                data-test-id="button"
              >
                My Button
             </Button>`
        );

        assert.dom('[data-test-id="button"]').hasClass('btn-minimal--primary');
        assert.dom('[data-test-id="button"]').doesNotHaveClass('btn--primary');
        assert
          .dom('[data-test-id="button"]')
          .doesNotHaveClass('btn-outlined--primary');
      });
    });

    module('sizes', () => {
      test('it adds class size xs"', async function (assert) {
        await render(
          hbs`<Button @size="xs" data-test-id="button">My Button</Button>`
        );

        assert.dom('[data-test-id="button"]').hasClass('btn--xs');
      });

      test('it adds class size sm', async function (assert) {
        await render(
          hbs`<Button @size="sm" data-test-id="button">My Button</Button>`
        );

        assert.dom('[data-test-id="button"]').hasClass('btn--sm');
      });

      test('it adds class size lg', async function (assert) {
        await render(
          hbs`<Button @size="lg" data-test-id="button">My Button</Button>`
        );

        assert.dom('[data-test-id="button"]').hasClass('btn--lg');
      });

      test('it adds class size xl', async function (assert) {
        await render(
          hbs`<Button @size="xl" data-test-id="button">My Button</Button>`
        );

        assert.dom('[data-test-id="button"]').hasClass('btn--xl');
      });

      test('it adds class size with appearance', async function (assert) {
        await render(
          hbs`<Button @appearance="outlined" @size="lg" data-test-id="button">My Button</Button>`
        );

        assert.dom('[data-test-id="button"]').hasClass('btn-outlined--lg');
      });
    });
  });

  test('it yields classNames when renderless', async function (assert) {
    await render(
      hbs`<Button @isRenderless={{true}} as |btn|>
            <div data-test-id="my-div">{{btn.classNames}}</div>
          </Button>`
    );
    assert.dom('[data-test-id="my-div"]').hasText('btn');
  });
});
