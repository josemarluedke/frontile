import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { click, render, triggerEvent, find } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';

module(
  'Integration | Component | Popover | @frontile/overlays',
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

    test('it works with trigger and opening content', async function (assert) {
      await render(
        hbs`
          <div id="my-destination"></div>
          <Popover as |p|>
            <button {{p.trigger}} {{p.anchor}} data-test-id="trigger">
              Trigger
            </button>

            <p.Content
              @destinationElementId="my-destination"
              data-test-id="content"
            >
              Content here
            </p.Content>
          </Popover>`
      );

      assert.dom('[data-test-id="content"]').doesNotExist();
      await click('[data-test-id="trigger"]');

      assert.dom('[data-test-id="content"]').exists();
      assert.dom('[data-test-id="content"]').containsText('Content here');
      assert
        .dom(document.activeElement)
        .hasAttribute(
          'data-test-id',
          'content',
          'should have focused in the content'
        );
    });

    test('it works with trigger hover mode, prevents focus restore', async function (assert) {
      await render(
        hbs`
          <div id="my-destination"></div>
          <button type="button" data-test-id="focused-element">Button</button>
          <Popover as |p|>
            <button {{p.trigger "hover"}} {{p.anchor}} data-test-id="trigger">
              Trigger
            </button>

            <p.Content
              @destinationElementId="my-destination"
              data-test-id="content"
            >
              Content here
            </p.Content>
          </Popover>`
      );

      (find('[data-test-id="focused-element"]') as HTMLButtonElement).focus();

      assert.dom('[data-test-id="content"]').doesNotExist();
      await triggerEvent('[data-test-id="trigger"]', 'mouseenter');

      assert.dom('[data-test-id="content"]').exists();
      assert.dom('[data-test-id="content"]').containsText('Content here');
      assert
        .dom(document.activeElement)
        .hasAttribute(
          'data-test-id',
          'content',
          'should have focused in the content'
        );

      await triggerEvent('[data-test-id="trigger"]', 'mouseleave');
      assert.dom('[data-test-id="content"]').doesNotExist();

      assert
        .dom(document.activeElement)
        .doesNotHaveAttribute(
          'data-test-id',
          'should have not restored the focus'
        );
    });

    test('it renders accessibility attributes', async function (assert) {
      await render(
        hbs`
          <div id="my-destination"></div>
          <Popover as |p|>
            <button {{p.trigger}} {{p.anchor}} data-test-id="trigger">
              Trigger
            </button>

            <p.Content
              @destinationElementId="my-destination"
              data-test-id="content"
            >
              Content here
            </p.Content>
          </Popover>`
      );

      assert.dom('[data-test-id="trigger"]').hasAria('haspopup', 'true');
      assert.dom('[data-test-id="trigger"]').hasAria('expanded', 'false');
      assert.dom('[data-test-id="trigger"]').hasAttribute('aria-controls');

      await click('[data-test-id="trigger"]');

      assert.dom('[data-test-id="trigger"]').hasAria('expanded', 'true');
      assert.dom('[data-test-id="content"]').hasAttribute('id');
    });

    test('it shows backdrop when @backdrop=none', async function (assert) {
      this.set('backdrop', 'none');

      await render(
        hbs`
          <div id="my-destination"></div>
          <Popover as |p|>
            <button {{p.trigger}} {{p.anchor}} data-test-id="trigger">
              Trigger
            </button>

            <p.Content
              @destinationElementId="my-destination"
              @backdrop={{this.backdrop}}
              @disableTransitions={{true}}
              data-test-id="content"
            >
              Content here
            </p.Content>
          </Popover>`
      );

      await click('[data-test-id="trigger"]');

      assert.dom('.overlay__backdrop').doesNotExist();

      this.set('backdrop', 'faded');

      assert.dom('.overlay__backdrop').exists();
    });

    test('clicking outside closes menu', async function (assert) {
      let calledClosed = false;
      this.set('didClose', () => {
        calledClosed = true;
      });

      await render(
        hbs`
          <div id="my-destination" tabindex="0"></div>
          <Popover @didClose={{this.didClose}} as |p|>
            <button {{p.trigger}} {{p.anchor}} data-test-id="trigger">
              Trigger
            </button>

            <p.Content
              @destinationElementId="my-destination"
              @backdrop={{this.backdrop}}
              @disableTransitions={{true}}
              data-test-id="content"
            >
              Content here
            </p.Content>
          </Popover>`
      );

      assert.dom('[data-test-id="content"]').doesNotExist();
      await click('[data-test-id="trigger"]');
      assert.dom('[data-test-id="content"]').exists();

      await click('#my-destination');
      assert.dom('[data-test-id="content"]').doesNotExist();
      assert.equal(calledClosed, true, 'should called didClose argument');
      assert
        .dom(document.activeElement)
        .hasAttribute(
          'data-test-id',
          'trigger',
          'should have restored the focus to the triggeer'
        );
    });

    test('controlled isOpen', async function (assert) {
      let isOpen = false;
      this.set('isOpen', false);
      this.set('onOpenChange', (value: boolean) => {
        isOpen = value;
        this.set('isOpen', value);
      });

      await render(
        hbs`
          <div id="my-destination" tabindex="0"></div>
          <Popover @isOpen={{this.isOpen}} @onOpenChange={{this.onOpenChange}} as |p|>
            <button {{p.trigger}} {{p.anchor}} data-test-id="trigger">
              Trigger
            </button>

            <p.Content
              @destinationElementId="my-destination"
              @backdrop={{this.backdrop}}
              @disableTransitions={{true}}
              data-test-id="content"
            >
              Content here
            </p.Content>
          </Popover>`
      );

      assert.dom('[data-test-id="content"]').doesNotExist();
      await click('[data-test-id="trigger"]');
      assert.dom('[data-test-id="content"]').exists();
      assert.equal(isOpen, true);

      await click('#my-destination');
      assert.dom('[data-test-id="content"]').doesNotExist();
      assert.equal(isOpen, false);

      this.set('isOpen', true);
      assert.dom('[data-test-id="content"]').exists();

      this.set('isOpen', false);
      assert.dom('[data-test-id="content"]').doesNotExist();
    });

    test('it prevents trigger event bubbling', async function (assert) {
      assert.expect(1);

      this.set('parentClick', () => {
        assert.ok(false, 'popover trigger should not bubble click event');
      });

      await render(
        hbs`
          <div id="my-destination"></div>
          <Popover as |p|>
            <button {{on "click" this.parentClick}}>
              <button {{p.trigger}} {{p.anchor}} data-test-id="trigger">
                Trigger
              </button>
<           </button>
            <p.Content
              @destinationElementId="my-destination"
              data-test-id="content"
            >
              Content here
            </p.Content>
          </Popover>`
      );

      await click('[data-test-id="trigger"]');

      assert.dom('[data-test-id="content"]').exists();
    });
  }
);
