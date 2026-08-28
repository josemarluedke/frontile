import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  settled,
  click,
  triggerKeyEvent,
  find
} from '@ember/test-helpers';
import { Overlay } from 'frontile/overlays';
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

    test('nested overlays keep the body scroll locked until the last one closes', async function (assert) {
      const outerIsOpen = cell(false);
      const innerIsOpen = cell(false);

      await render(
        <template>
          <Overlay
            @isOpen={{outerIsOpen.current}}
            @disableTransitions={{true}}
            data-test-id="outer"
          >
            Outer Content
            <button type="button">Outer focusable</button>

            <Overlay
              @isOpen={{innerIsOpen.current}}
              @disableTransitions={{true}}
              data-test-id="inner"
            >
              Inner Content
              <button type="button">Inner focusable</button>
            </Overlay>
          </Overlay>
        </template>
      );

      outerIsOpen.current = true;
      await settled();
      assert.strictEqual(
        document.body.style.overflow,
        'hidden',
        'the outer overlay locks the body scroll'
      );

      innerIsOpen.current = true;
      await settled();
      assert.strictEqual(
        document.body.style.overflow,
        'hidden',
        'the nested overlay keeps the body scroll locked'
      );

      innerIsOpen.current = false;
      await settled();
      assert.strictEqual(
        document.body.style.overflow,
        'hidden',
        'closing the nested overlay does not unlock the still open outer overlay'
      );

      outerIsOpen.current = false;
      await settled();
      assert.strictEqual(
        document.body.style.overflow,
        '',
        'closing the last overlay releases the body scroll'
      );
    });

    test('it restores a pre-existing inline body overflow instead of blanking it', async function (assert) {
      document.body.style.overflow = 'scroll';

      try {
        const isOpen = cell(false);

        await render(
          <template>
            <Overlay
              @isOpen={{isOpen.current}}
              @disableTransitions={{true}}
              data-test-id="overlay"
            >
              My Content
              <button type="button">Something focusable</button>
            </Overlay>
          </template>
        );

        isOpen.current = true;
        await settled();
        assert.strictEqual(document.body.style.overflow, 'hidden');

        isOpen.current = false;
        await settled();
        assert.strictEqual(
          document.body.style.overflow,
          'scroll',
          'the value the app had set inline is restored'
        );
      } finally {
        document.body.style.overflow = '';
      }
    });

    test('when @blockScroll={{false}} it neither locks the body nor affects other overlays', async function (assert) {
      const lockingIsOpen = cell(false);
      const nonBlockingIsOpen = cell(false);

      await render(
        <template>
          <Overlay
            @isOpen={{nonBlockingIsOpen.current}}
            @blockScroll={{false}}
            @disableTransitions={{true}}
            data-test-id="non-blocking"
          >
            Non Blocking
            <button type="button">Something focusable</button>
          </Overlay>

          <Overlay
            @isOpen={{lockingIsOpen.current}}
            @disableTransitions={{true}}
            data-test-id="locking"
          >
            Locking
            <button type="button">Something focusable</button>
          </Overlay>
        </template>
      );

      nonBlockingIsOpen.current = true;
      await settled();
      assert.strictEqual(
        document.body.style.overflow,
        '',
        '@blockScroll={{false}} does not lock the body'
      );

      nonBlockingIsOpen.current = false;
      await settled();

      lockingIsOpen.current = true;
      await settled();
      assert.strictEqual(document.body.style.overflow, 'hidden');

      // Open and close a non-locking overlay while the locking one is still
      // open: it must not participate in the reference count.
      nonBlockingIsOpen.current = true;
      await settled();
      assert.strictEqual(
        document.body.style.overflow,
        'hidden',
        'still locked while the non-blocking overlay is open'
      );

      nonBlockingIsOpen.current = false;
      await settled();
      assert.strictEqual(
        document.body.style.overflow,
        'hidden',
        'closing the non-blocking overlay does not release the lock'
      );

      lockingIsOpen.current = false;
      await settled();
      assert.strictEqual(document.body.style.overflow, '');
    });

    test('when @renderInPlace={{true}} it neither locks the body nor affects other overlays', async function (assert) {
      const lockingIsOpen = cell(false);
      const inPlaceIsOpen = cell(false);

      await render(
        <template>
          <Overlay
            @isOpen={{inPlaceIsOpen.current}}
            @renderInPlace={{true}}
            @disableTransitions={{true}}
            data-test-id="in-place"
          >
            In Place
            <button type="button">Something focusable</button>
          </Overlay>

          <Overlay
            @isOpen={{lockingIsOpen.current}}
            @disableTransitions={{true}}
            data-test-id="locking"
          >
            Locking
            <button type="button">Something focusable</button>
          </Overlay>
        </template>
      );

      inPlaceIsOpen.current = true;
      await settled();
      assert.strictEqual(
        document.body.style.overflow,
        '',
        '@renderInPlace={{true}} does not lock the body'
      );

      lockingIsOpen.current = true;
      await settled();
      assert.strictEqual(document.body.style.overflow, 'hidden');

      inPlaceIsOpen.current = false;
      await settled();
      assert.strictEqual(
        document.body.style.overflow,
        'hidden',
        'tearing down the in-place overlay does not release the lock'
      );

      lockingIsOpen.current = false;
      await settled();
      assert.strictEqual(document.body.style.overflow, '');
    });
  }
);
