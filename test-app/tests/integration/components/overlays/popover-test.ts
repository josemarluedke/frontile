import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { click, render } from '@ember/test-helpers';
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
  }
);
