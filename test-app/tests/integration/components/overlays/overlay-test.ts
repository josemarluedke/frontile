import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  settled,
  click,
  triggerKeyEvent,
  find
} from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';

module(
  'Integration | Component | @frontile/overlays/Overlay',
  function (hooks) {
    setupRenderingTest(hooks);

    registerCustomStyles({
      overlay: tv({
        slots: {
          base: 'overlay',
          backdrop: 'overlay__backdrop',
          content: 'overlay__content'
        },
        variants: {
          inPlace: {
            true: {
              base: 'overlay--in-place',
              backdrop: '',
              content: ''
            }
          }
        }
      }) as never
    });

    const template = hbs`
    <div id="my-destination"></div>
    <Overlay
      @isOpen={{this.isOpen}}
      @onClose={{this.onClose}}
      @onOpen={{this.onOpen}}
      @didClose={{this.didClose}}
      @renderInPlace={{this.renderInPlace}}
      @destinationElementId="my-destination"
      @transitionDuration={{this.transitionDuration}}
      @disableBackdrop={{this.disableBackdrop}}
      @disableTransitions={{this.disableTransitions}}
      @disableFocusTrap={{this.disableFocusTrap}}
      @closeOnOutsideClick={{this.closeOnOutsideClick}}
      @closeOnEscapeKey={{this.closeOnEscapeKey}}
      @backdropTransitionName={{this.backdropTransitionName}}
      @contentTransitionName={{this.contentTransitionName}}
      data-test-id="overlay"
    >
      My Content
      <button type="button">Something focusable</button>
    </Overlay>
  `;

    test('it renders the content, into destination and only when opened', async function (assert) {
      this.set('disableTransitions', true);
      this.set('isOpen', true);
      await render(template);

      assert.dom('[data-test-id="overlay"]').exists();
      assert
        .dom('[data-test-id="overlay"] .overlay__content')
        .hasText('My Content Something focusable');

      assert.dom('[data-test-id="overlay"] .overlay__backdrop').exists();

      assert.dom('#my-destination > [data-test-id="overlay"]').exists();

      this.set('isOpen', false);
      await settled();
      assert.dom('[data-test-id="overlay"]').doesNotExist();
    });

    test('when @renderInPlace={{true}} renders in place', async function (assert) {
      this.set('disableTransitions', true);
      this.set('renderInPlace', true);
      this.set('isOpen', true);

      await render(template);
      assert.dom('.my-destination > [data-test-id="overlay"]').doesNotExist();
      // @ts-ignore
      assert.dom('[data-test-id="overlay"]', this.element).exists();
      assert.dom('[data-test-id="overlay"]').hasClass('overlay--in-place');
    });

    test('when @disableBackdrop=true does not render backdrop', async function (assert) {
      this.set('disableTransitions', true);
      this.set('isOpen', true);
      this.set('disableBackdrop', true);
      await render(template);

      assert.dom('[data-test-id="overlay"] .overlay__backdrop').doesNotExist();
    });

    test('it closes overlay when backdrop is clicked', async function (assert) {
      assert.expect(2);

      this.set('disableTransitions', true);
      this.set('isOpen', true);

      this.set('onClose', () => {
        assert.ok(true);
        this.set('isOpen', false);
      });

      await render(template);
      await click('[data-test-id="overlay"] .overlay__backdrop');
      assert.dom('[data-test-id="overlay"]').doesNotExist();
    });

    test('when @closeOnOutsideClick={{false}} does not close overlay', async function (assert) {
      assert.expect(1);

      this.set('disableTransitions', true);
      this.set('closeOnOutsideClick', false);
      this.set('isOpen', true);

      this.set('onClose', () => {
        assert.ok(false, 'should not have been called');
        this.set('isOpen', false);
      });

      await render(template);
      await click('[data-test-id="overlay"] .overlay__backdrop');
      assert.dom('[data-test-id="overlay"]').exists();
    });

    test('it closes overlay when pressing Escape', async function (assert) {
      assert.expect(2);

      this.set('disableTransitions', true);
      this.set('isOpen', true);

      this.set('onClose', () => {
        assert.ok(true);
        this.set('isOpen', false);
      });

      await render(template);
      await triggerKeyEvent(
        find('[data-test-id="overlay"] .overlay__content') as Element,
        'keydown',
        'Escape'
      );
      assert.dom('[data-test-id="overlay"]').doesNotExist();
    });

    test('when @closeOnEscapeKey={{false}} does not close overlay', async function (assert) {
      assert.expect(1);

      this.set('disableTransitions', true);
      this.set('closeOnEscapeKey', false);
      this.set('isOpen', true);

      this.set('onClose', () => {
        assert.ok(false, 'should not have been called');
        this.set('isOpen', false);
      });

      await render(template);
      await triggerKeyEvent(document as never, 'keydown', 'Escape');
      assert.dom('[data-test-id="overlay"]').exists();
    });

    test('it calles didClose when closed', async function (assert) {
      const calls: string[] = [];

      this.set('disableTransitions', true);
      this.set('isOpen', true);

      this.set('onClose', () => {
        calls.push('onClose');
        this.set('isOpen', false);
      });

      this.set('didClose', () => {
        calls.push('didClose');
      });

      await render(template);
      await click('[data-test-id="overlay"] .overlay__backdrop');
      assert.deepEqual(calls, ['onClose', 'didClose']);
    });

    test('it adds class to body to disable scroll', async function (assert) {
      this.set('disableTransitions', true);
      this.set('isOpen', true);

      await render(template);
      assert.dom(document.body).hasStyle({ overflow: 'hidden' });
    });

    test('it does not add class to body when renderInPlace', async function (assert) {
      this.set('isOpen', true);
      this.set('renderInPlace', true);
      this.set('disableTransitions', true);

      await render(template);
      assert.dom(document.body).doesNotHaveStyle({ overflow: 'hidden' });
    });

    test('it executes onOpen when overlay is opened', async function (assert) {
      assert.expect(2);
      this.set('onOpen', () => {
        assert.ok(true);
      });
      await render(template);
      this.set('isOpen', true);
      this.set('isOpen', false);
      this.set('isOpen', true);
    });
  }
);
