import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, rerender, waitUntil } from '@ember/test-helpers';
import { tracked } from '@glimmer/tracking';
import { Avatar } from 'frontile';

// A 1x1 transparent GIF, so the "loads" case never touches the network.
const GOOD_SRC =
  'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7';
// Decodes to bytes that are not an image, so the browser fires `error`
// without a network request.
const BROKEN_SRC = 'data:image/png;base64,AAAA';

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
          <Avatar data-test-avatar @src={{GOOD_SRC}} @alt="User Avatar" />
        </template>
      );

      assert.dom('[data-test-avatar] img').exists();
      assert.dom('[data-test-avatar] img').hasAttribute('src', GOOD_SRC);
      assert.dom('[data-test-avatar] img').hasAttribute('alt', 'User Avatar');
    });

    // An <img> with no alt attribute at all is announced by its filename or URL,
    // which for `pravatar.cc/150?img=5` is noise. An empty alt marks it
    // decorative instead, which is the right default beside a visible name.
    test('an image with no @alt is marked decorative', async function (assert) {
      await render(
        <template><Avatar data-test-avatar @src={{GOOD_SRC}} /></template>
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
          <Avatar data-test-avatar @name="John Smith" @src={{GOOD_SRC}} />
        </template>
      );

      assert.dom('[data-test-avatar] img').exists();
      assert.dom('[data-test-avatar]').doesNotContainText('JS');
    });

    test('renders data-component="avatar" on the root only, with data-part on every slot', async function (assert) {
      await render(
        <template>
          <Avatar data-test-initials @name="John Smith" @alt="John Smith" />
          <Avatar data-test-image @src={{GOOD_SRC}} @alt="John Smith" />
        </template>
      );

      assert
        .dom('[data-test-initials]')
        .hasAttribute('data-component', 'avatar');
      assert.dom('[data-test-initials]').hasAttribute('data-part', 'base');
      assert.dom('[data-test-initials] [data-part="name"]').exists();
      assert.dom('[data-test-image] [data-part="img"]').exists();
      assert.strictEqual(
        document.querySelectorAll('[data-component="avatar"]').length,
        2,
        'data-component="avatar" marks each root only, never a part'
      );
    });

    // Without an object-fit the image is stretched to the box, which distorts
    // anything that is not already square.
    test('an image covers the avatar by default', async function (assert) {
      await render(
        <template><Avatar data-test-avatar @src={{GOOD_SRC}} /></template>
      );

      assert.dom('[data-test-avatar] img').hasClass('object-cover');
      assert.dom('[data-test-avatar] img').doesNotHaveClass('object-contain');
    });

    test('@fit="contain" shows the whole image, inset from the edge', async function (assert) {
      await render(
        <template>
          <Avatar data-test-avatar @src={{GOOD_SRC}} @fit="contain" />
        </template>
      );

      assert.dom('[data-test-avatar] img').hasClass('object-contain');
      assert.dom('[data-test-avatar] img').doesNotHaveClass('object-cover');
      assert.dom('[data-test-avatar] img').hasClass('p-0.5');
    });

    test('the inset of @fit="contain" scales with @size', async function (assert) {
      await render(
        <template>
          <Avatar data-test-xs @src={{GOOD_SRC}} @fit="contain" @size="xs" />
          <Avatar data-test-xl @src={{GOOD_SRC}} @fit="contain" @size="xl" />
        </template>
      );

      assert.dom('[data-test-xs] img').hasClass('p-px');
      assert.dom('[data-test-xl] img').hasClass('p-1');
    });

    test('the ring is off by default', async function (assert) {
      await render(
        <template>
          <Avatar data-test-image @src={{GOOD_SRC}} />
          <Avatar data-test-initials @name="John Smith" />
        </template>
      );

      assert.dom('[data-test-image]').doesNotHaveClass('ring-1');
      assert.dom('[data-test-initials]').doesNotHaveClass('ring-1');
    });

    test('@isBordered draws the ring', async function (assert) {
      await render(
        <template>
          <Avatar data-test-avatar @src={{GOOD_SRC}} @isBordered={{true}} />
        </template>
      );

      assert.dom('[data-test-avatar]').hasClass('ring-1');
      assert.dom('[data-test-avatar]').hasClass('ring-offset-1');
    });

    test('a failed image falls back to the initials', async function (assert) {
      await render(
        <template>
          <Avatar data-test-avatar @src={{BROKEN_SRC}} @name="John Smith" />
        </template>
      );

      await waitUntil(() => !document.querySelector('[data-test-avatar] img'), {
        timeout: 2000
      });

      assert.dom('[data-test-avatar] img').doesNotExist();
      assert.dom('[data-test-avatar] [data-part="name"]').hasText('JS');
    });

    test('a failed image with no name leaves the empty plate', async function (assert) {
      await render(
        <template><Avatar data-test-avatar @src={{BROKEN_SRC}} /></template>
      );

      await waitUntil(() => !document.querySelector('[data-test-avatar] img'), {
        timeout: 2000
      });

      assert.dom('[data-test-avatar]').exists();
      assert.dom('[data-test-avatar] img').doesNotExist();
      assert.dom('[data-test-avatar]').hasText('');
    });

    test('changing @src after a failure tries the new image', async function (assert) {
      class State {
        @tracked src = BROKEN_SRC;
      }
      const state = new State();

      await render(
        <template>
          <Avatar data-test-avatar @src={{state.src}} @name="John Smith" />
        </template>
      );

      await waitUntil(() => !document.querySelector('[data-test-avatar] img'), {
        timeout: 2000
      });

      state.src = GOOD_SRC;
      await rerender();

      assert.dom('[data-test-avatar] img').hasAttribute('src', GOOD_SRC);
      assert.dom('[data-test-avatar] [data-part="name"]').doesNotExist();
    });
  }
);
