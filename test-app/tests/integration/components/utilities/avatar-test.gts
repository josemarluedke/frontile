import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { Avatar } from '@frontile/utilities';

module(
  'Integration | Component | @frontile/utilities/Avatar',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders initials from full name', async function (assert) {
      await render(
        <template><Avatar data-test-avatar @name="John Smith" /></template>
      );

      assert.dom('[data-test-avatar]').hasText('JS');
    });

    test('it renders initials from first and last name', async function (assert) {
      await render(
        <template>
          <Avatar data-test-avatar @firstName="John" @lastName="Doe" />
        </template>
      );

      assert.dom('[data-test-avatar]').hasText('JD');
    });

    test('it renders initials when only first name is provided', async function (assert) {
      await render(
        <template><Avatar data-test-avatar @firstName="Alice" /></template>
      );

      assert.dom('[data-test-avatar]').hasText('A');
    });

    test('it renders initials when only last name is provided', async function (assert) {
      await render(
        <template><Avatar data-test-avatar @lastName="Brown" /></template>
      );

      assert.dom('[data-test-avatar]').hasText('B');
    });

    test('it prioritizes name over first and last name', async function (assert) {
      await render(
        <template>
          <Avatar
            data-test-avatar
            @name="Charlie Chaplin"
            @firstName="Wrong"
            @lastName="Name"
          />
        </template>
      );

      assert.dom('[data-test-avatar]').hasText('CC');
    });

    test('it handles extra spaces in the full name', async function (assert) {
      await render(
        <template>
          <Avatar data-test-avatar @name="  Anna   Marie   " />
        </template>
      );

      assert.dom('[data-test-avatar]').hasText('AM');
    });

    test('it shows only one initial if only one name is available', async function (assert) {
      await render(
        <template><Avatar data-test-avatar @name="Madonna" /></template>
      );

      assert.dom('[data-test-avatar]').hasText('M');
    });

    test('it does not render initials if no name, first name, or last name is provided', async function (assert) {
      await render(<template><Avatar data-test-avatar /></template>);

      assert.dom('[data-test-avatar]').hasText('');
    });

    test('it renders image when src is provided', async function (assert) {
      await render(
        <template>
          <Avatar data-test-avatar @src="/avatar.jpg" @alt="User Avatar" />
        </template>
      );

      assert.dom('[data-test-avatar] img').exists();
      assert.dom('[data-test-avatar] img').hasAttribute('src', '/avatar.jpg');
      assert.dom('[data-test-avatar] img').hasAttribute('alt', 'User Avatar');
    });

    test('it does not render initials when an image is present', async function (assert) {
      await render(
        <template>
          <Avatar data-test-avatar @name="John Smith" @src="/avatar.jpg" />
        </template>
      );

      assert.dom('[data-test-avatar] img').exists();
      assert.dom('[data-test-avatar]').doesNotContainText('JS');
    });
  }
);
