import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { Avatar } from 'frontile';

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

    // An <img> with no alt attribute at all is announced by its filename or URL,
    // which for `pravatar.cc/150?img=5` is noise. An empty alt marks it
    // decorative instead, which is the right default beside a visible name.
    test('an image with no @alt is marked decorative', async function (assert) {
      await render(
        <template><Avatar data-test-avatar @src="/avatar.jpg" /></template>
      );

      assert.dom('[data-test-avatar] img').hasAttribute('alt', '');
    });

    // role="img" makes an element's contents presentational, so the initials
    // stop being read and the only name left is aria-label. Without one the
    // avatar is an unnamed image — worse than plain text.
    test('initials with no @alt are readable rather than an unnamed image', async function (assert) {
      await render(
        <template><Avatar data-test-avatar @name="John Smith" /></template>
      );

      assert.dom('[data-test-avatar] [role="img"]').doesNotExist();
      assert.dom('[data-test-avatar]').hasText('JS');
    });

    test('initials with @alt are named for assistive technology', async function (assert) {
      await render(
        <template>
          <Avatar data-test-avatar @name="John Smith" @alt="John Smith" />
        </template>
      );

      assert
        .dom('[data-test-avatar] [role="img"]')
        .hasAttribute('aria-label', 'John Smith');
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
