import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  settled,
  click,
  triggerKeyEvent,
  find
} from '@ember/test-helpers';
import Overlay from 'frontile/components/overlays/overlay';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';
import { cell } from 'ember-resources';

module(
  'Integration | Component | @frontile/overlays/Overlay',
  function (hooks) {
    setupRenderingTest(hooks);

    registerCustomStyles({
      backdrop: tv({ base: 'overlay__backdrop' }) as never,
      overlay: tv({
        base: 'overlay__content',
        variants: {
          inPlace: {
            true: 'overlay--in-place'
          }
        }
      }) as never
    });

    test('it renders the content, into portal and only when opened', async function (assert) {
      const disableTransitions = cell(true);
      const isOpen = cell(true);

      await render(
        <template>
          <button type="button" data-test-id="some-button">Button</button>
          <Overlay
            @isOpen={{isOpen.current}}
            @disableTransitions={{disableTransitions.current}}
            data-test-id="overlay"
          >
            My Content
            <button type="button">Something focusable</button>
          </Overlay>
        </template>
      );

      assert.dom('[data-test-id="overlay"]').exists();
      assert
        .dom('[data-test-id="overlay"]')
        .hasText('My Content Something focusable');

      assert.dom('.overlay__backdrop').exists();

      assert.dom('[data-portal] > [data-test-id="overlay"]').exists();

      isOpen.current = false;
      await settled();
      assert.dom('[data-test-id="overlay"]').doesNotExist();
    });

    test('when @renderInPlace={{true}} renders in place', async function (assert) {
      const disableTransitions = cell(true);
      const renderInPlace = cell(true);
      const isOpen = cell(true);

      await render(
        <template>
          <button type="button" data-test-id="some-button">Button</button>
          <Overlay
            @isOpen={{isOpen.current}}
            @renderInPlace={{renderInPlace.current}}
            @disableTransitions={{disableTransitions.current}}
            data-test-id="overlay"
          >
            My Content
            <button type="button">Something focusable</button>
          </Overlay>
        </template>
      );
      assert
        .dom('[data-portal-target] > [data-test-id="overlay"]')
        .doesNotExist();
      assert.dom('[data-test-id="overlay"]').exists();
      assert.dom('[data-test-id="overlay"]').hasClass('overlay--in-place');
    });

    test('when @backdrop=none does not render backdrop', async function (assert) {
      const disableTransitions = cell(true);
      const isOpen = cell(true);
      const backdrop = cell<'none' | 'faded' | undefined>('none');

      await render(
        <template>
          <button type="button" data-test-id="some-button">Button</button>
          <Overlay
            @isOpen={{isOpen.current}}
            @backdrop={{backdrop.current}}
            @disableTransitions={{disableTransitions.current}}
            data-test-id="overlay"
          >
            My Content
            <button type="button">Something focusable</button>
          </Overlay>
        </template>
      );

      assert.dom('.overlay__backdrop').doesNotExist();
    });

    test('it closes overlay when backdrop is clicked', async function (assert) {
      assert.expect(2);

      const disableTransitions = cell(true);
      const isOpen = cell(true);
      const onClose = () => {
        assert.ok(true);
        isOpen.current = false;
      };

      await render(
        <template>
          <button type="button" data-test-id="some-button">Button</button>
          <Overlay
            @isOpen={{isOpen.current}}
            @onClose={{onClose}}
            @disableTransitions={{disableTransitions.current}}
            data-test-id="overlay"
          >
            My Content
            <button type="button">Something focusable</button>
          </Overlay>
        </template>
      );
      await click('.overlay__backdrop');
      assert.dom('[data-test-id="overlay"]').doesNotExist();
    });

    test('when @closeOnOutsideClick={{false}} does not close overlay', async function (assert) {
      assert.expect(1);

      const disableTransitions = cell(true);
      const closeOnOutsideClick = cell(false);
      const isOpen = cell(true);
      const onClose = () => {
        assert.ok(false, 'should not have been called');
        isOpen.current = false;
      };

      await render(
        <template>
          <button type="button" data-test-id="some-button">Button</button>
          <Overlay
            @isOpen={{isOpen.current}}
            @onClose={{onClose}}
            @closeOnOutsideClick={{closeOnOutsideClick.current}}
            @disableTransitions={{disableTransitions.current}}
            data-test-id="overlay"
          >
            My Content
            <button type="button">Something focusable</button>
          </Overlay>
        </template>
      );
      await click('.overlay__backdrop');
      assert.dom('[data-test-id="overlay"]').exists();
    });

    test('it closes overlay when pressing Escape', async function (assert) {
      assert.expect(2);

      const disableTransitions = cell(true);
      const isOpen = cell(true);
      const onClose = () => {
        assert.ok(true);
        isOpen.current = false;
      };

      await render(
        <template>
          <button type="button" data-test-id="some-button">Button</button>
          <Overlay
            @isOpen={{isOpen.current}}
            @onClose={{onClose}}
            @disableTransitions={{disableTransitions.current}}
            data-test-id="overlay"
          >
            My Content
            <button type="button">Something focusable</button>
          </Overlay>
        </template>
      );
      await triggerKeyEvent(
        find('.overlay__content') as Element,
        'keydown',
        'Escape'
      );
      assert.dom('[data-test-id="overlay"]').doesNotExist();
    });

    test('when @closeOnEscapeKey={{false}} does not close overlay', async function (assert) {
      assert.expect(1);

      const disableTransitions = cell(true);
      const closeOnEscapeKey = cell(false);
      const isOpen = cell(true);
      const onClose = () => {
        assert.ok(false, 'should not have been called');
        isOpen.current = false;
      };

      await render(
        <template>
          <button type="button" data-test-id="some-button">Button</button>
          <Overlay
            @isOpen={{isOpen.current}}
            @onClose={{onClose}}
            @closeOnEscapeKey={{closeOnEscapeKey.current}}
            @disableTransitions={{disableTransitions.current}}
            data-test-id="overlay"
          >
            My Content
            <button type="button">Something focusable</button>
          </Overlay>
        </template>
      );
      await triggerKeyEvent(document as never, 'keydown', 'Escape');
      assert.dom('[data-test-id="overlay"]').exists();
    });

    test('it calles didClose when closed', async function (assert) {
      const calls: string[] = [];

      const disableTransitions = cell(true);
      const isOpen = cell(true);
      const onClose = () => {
        calls.push('onClose');
        isOpen.current = false;
      };
      const didClose = () => {
        calls.push('didClose');
      };

      await render(
        <template>
          <button type="button" data-test-id="some-button">Button</button>
          <Overlay
            @isOpen={{isOpen.current}}
            @onClose={{onClose}}
            @didClose={{didClose}}
            @disableTransitions={{disableTransitions.current}}
            data-test-id="overlay"
          >
            My Content
            <button type="button">Something focusable</button>
          </Overlay>
        </template>
      );
      await click('.overlay__backdrop');
      assert.deepEqual(calls, ['onClose', 'didClose']);
    });

    test('it adds class to body to disable scroll', async function (assert) {
      const disableTransitions = cell(true);
      const isOpen = cell(true);

      await render(
        <template>
          <button type="button" data-test-id="some-button">Button</button>
          <Overlay
            @isOpen={{isOpen.current}}
            @disableTransitions={{disableTransitions.current}}
            data-test-id="overlay"
          >
            My Content
            <button type="button">Something focusable</button>
          </Overlay>
        </template>
      );
      assert.dom(document.body).hasStyle({ overflow: 'hidden' });
    });

    test('it does not add class to body when renderInPlace', async function (assert) {
      const isOpen = cell(true);
      const renderInPlace = cell(true);
      const disableTransitions = cell(true);

      await render(
        <template>
          <button type="button" data-test-id="some-button">Button</button>
          <Overlay
            @isOpen={{isOpen.current}}
            @renderInPlace={{renderInPlace.current}}
            @disableTransitions={{disableTransitions.current}}
            data-test-id="overlay"
          >
            My Content
            <button type="button">Something focusable</button>
          </Overlay>
        </template>
      );
      assert.dom(document.body).doesNotHaveStyle({ overflow: 'hidden' });
    });

    test('it executes onOpen when overlay is opened', async function (assert) {
      assert.expect(2);

      const isOpen = cell<boolean | undefined>(undefined);
      const onOpen = () => {
        assert.ok(true);
      };

      await render(
        <template>
          <button type="button" data-test-id="some-button">Button</button>
          <Overlay
            @isOpen={{isOpen.current}}
            @onOpen={{onOpen}}
            data-test-id="overlay"
          >
            My Content
            <button type="button">Something focusable</button>
          </Overlay>
        </template>
      );
      isOpen.current = true;
      await settled();
      isOpen.current = false;
      await settled();
      isOpen.current = true;
      await settled();
    });

    test('it manages focusing in content and restoration when focusTrap is disabled', async function (assert) {
      const disableTransitions = cell(true);
      const disableFocusTrap = cell(true);
      const isOpen = cell(false);
      const preventFocusRestore = cell<boolean | undefined>(undefined);

      await render(
        <template>
          <button type="button" data-test-id="some-button">Button</button>
          <Overlay
            @isOpen={{isOpen.current}}
            @disableTransitions={{disableTransitions.current}}
            @disableFocusTrap={{disableFocusTrap.current}}
            @preventFocusRestore={{preventFocusRestore.current}}
            data-test-id="overlay"
          >
            My Content
            <button type="button">Something focusable</button>
          </Overlay>
        </template>
      );

      (find('[data-test-id="some-button"]') as HTMLButtonElement).focus();
      isOpen.current = true;
      await settled();
      assert.dom('[data-test-id="overlay"]').exists();

      assert
        .dom(document.activeElement)
        .hasAttribute(
          'data-test-id',
          'overlay',
          'should have focused in the overlay'
        );

      isOpen.current = false;
      await settled();
      assert.dom('[data-test-id="overlay"]').doesNotExist();

      assert
        .dom(document.activeElement)
        .hasAttribute(
          'data-test-id',
          'some-button',
          'should have restored the focus'
        );

      // Test when preventFocusRestore is true
      // *************************************

      preventFocusRestore.current = true;
      isOpen.current = true;
      await settled();
      assert
        .dom(document.activeElement)
        .hasAttribute(
          'data-test-id',
          'overlay',
          'should have focused in the overlay'
        );

      isOpen.current = false;
      await settled();
      assert.dom('[data-test-id="overlay"]').doesNotExist();

      assert
        .dom(document.activeElement)
        .doesNotHaveAttribute(
          'data-test-id',
          'should have not restored the focus'
        );
    });
  }
);
