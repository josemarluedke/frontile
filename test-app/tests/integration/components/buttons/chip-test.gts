import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { click, render, triggerKeyEvent } from '@ember/test-helpers';
import { registerCustomStyles } from '@frontile/theme';
import { Chip } from 'frontile';
import { trackDeprecations } from '../../../helpers/deprecations';
import { realStyles } from '../../../helpers/real-theme-styles';
import { chipStubStyles } from '../../../helpers/chip-stub-styles';

registerCustomStyles({ chip: chipStubStyles });

module('Integration | Component | Chip | @frontile/buttons', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders', async function (assert) {
    await render(
      <template>
        <Chip data-test-id="button">My Chip</Chip>
      </template>
    );

    assert.dom('[data-test-id="button"]').hasText('My Chip');
  });

  module('Style classes', () => {
    module('@variant', () => {
      test('it adds class for solid variant', async function (assert) {
        await render(
          <template>
            <Chip data-test-id="button">My Chip</Chip>
          </template>
        );

        assert.dom('[data-test-id="button"]').doesNotHaveClass('chip-outline');
        assert.dom('[data-test-id="button"]').doesNotHaveClass('chip-soft');
        assert.dom('[data-test-id="button"]').hasClass('chip-solid');
      });

      test('it adds class for outline variant', async function (assert) {
        await render(
          <template>
            <Chip @variant="outline" data-test-id="button">My Chip</Chip>
          </template>
        );

        assert.dom('[data-test-id="button"]').doesNotHaveClass('chip-solid');
        assert.dom('[data-test-id="button"]').doesNotHaveClass('chip-soft');
        assert.dom('[data-test-id="button"]').hasClass('chip-outline');
      });

      test('it adds class for soft variant', async function (assert) {
        await render(
          <template>
            <Chip @variant="soft" data-test-id="button">My Chip</Chip>
          </template>
        );

        assert.dom('[data-test-id="button"]').doesNotHaveClass('chip-solid');
        assert.dom('[data-test-id="button"]').doesNotHaveClass('chip-outline');
        assert.dom('[data-test-id="button"]').hasClass('chip-soft');
      });

      test('@variant renders the new class', async function (assert) {
        await render(
          <template>
            <Chip @variant="soft" data-test-id="chip">x</Chip>
          </template>
        );

        assert.dom('[data-test-id="chip"]').hasClass('chip-soft');
      });

      test('@appearance="faded" maps to soft and deprecates once', async function (assert) {
        const { ids } = trackDeprecations();

        await render(
          <template>
            <Chip @appearance="faded" data-test-id="chip">x</Chip>
          </template>
        );

        assert.dom('[data-test-id="chip"]').hasClass('chip-soft');
        assert.deepEqual(ids, ['frontile.chip.appearance']);
      });
    });

    module('@color', () => {
      test('it adds class for a color', async function (assert) {
        await render(
          <template>
            <Chip @color="primary" data-test-id="button">My Chip</Chip>
          </template>
        );

        assert.dom('[data-test-id="button"]').hasClass('chip-primary');
      });

      test('@color renders the new class', async function (assert) {
        await render(
          <template>
            <Chip @color="danger" data-test-id="chip">x</Chip>
          </template>
        );

        assert.dom('[data-test-id="chip"]').hasClass('chip-danger');
      });

      test('@intent still renders, and deprecates exactly once', async function (assert) {
        const { ids } = trackDeprecations();

        await render(
          <template>
            <Chip @intent="danger" data-test-id="chip">x</Chip>
          </template>
        );

        assert.dom('[data-test-id="chip"]').hasClass('chip-danger');
        assert.deepEqual(ids, ['frontile.chip.intent']);
      });

      test('@intent="default" maps to neutral', async function (assert) {
        await render(
          <template>
            <Chip @intent="default" data-test-id="chip">x</Chip>
          </template>
        );

        assert.dom('[data-test-id="chip"]').hasClass('chip-neutral');
      });

      test('@color wins when both are passed', async function (assert) {
        await render(
          <template>
            <Chip @color="success" @intent="danger" data-test-id="chip">x</Chip>
          </template>
        );

        assert.dom('[data-test-id="chip"]').hasClass('chip-success');
        assert.dom('[data-test-id="chip"]').doesNotHaveClass('chip-danger');
      });
    });

    module('@size', () => {
      test('it adds class size xs', async function (assert) {
        await render(
          <template>
            <Chip @size="xs" data-test-id="button">My Chip</Chip>
          </template>
        );

        assert.dom('[data-test-id="button"]').hasClass('chip-xs');
      });

      test('it adds class size sm"', async function (assert) {
        await render(
          <template>
            <Chip @size="sm" data-test-id="button">My Chip</Chip>
          </template>
        );

        assert.dom('[data-test-id="button"]').hasClass('chip-sm');
      });

      test('it adds class size lg', async function (assert) {
        await render(
          <template>
            <Chip @size="lg" data-test-id="button">My Chip</Chip>
          </template>
        );

        assert.dom('[data-test-id="button"]').hasClass('chip-lg');
      });
    });

    module('@withDot', () => {
      test('it adds dot when argument is passed in', async function (assert) {
        await render(
          <template>
            <Chip @withDot={{true}} data-test-id="button">My Chip</Chip>
          </template>
        );

        assert.dom('[data-test-id="button"] .chip-dot').exists();
      });
    });

    module('@onClose', () => {
      test('adds close button when onClose argument is passed in', async function (assert) {
        const onClose = () => {};
        await render(
          <template>
            <Chip @onClose={{onClose}} data-test-id="button">My Chip</Chip>
          </template>
        );

        assert.dom('[data-test-id="button"] .chip-close-button').exists();
      });

      // Chip used to wire @onClose to CloseButton's deprecated @onClick, so
      // every closable chip emitted a deprecation the consumer could not
      // silence. Keyboard activation is the part @onClick never covered.
      test('close button responds to keyboard activation', async function (assert) {
        let closed = 0;
        const onClose = () => {
          closed++;
        };
        await render(
          <template>
            <Chip @onClose={{onClose}} data-test-id="button">My Chip</Chip>
          </template>
        );

        const selector = '[data-test-id="button"] .chip-close-button';
        await triggerKeyEvent(selector, 'keydown', 'Enter');
        await triggerKeyEvent(selector, 'keyup', 'Enter');

        assert.strictEqual(closed, 1, 'Enter closed the chip');
      });
    });

    module('@closeButtonTitle', () => {
      test('it names the close button, defaulting to Close', async function (assert) {
        const onClose = () => {};
        await render(
          <template>
            <Chip @onClose={{onClose}} data-test-id="default">Alpha</Chip>
            <Chip
              @onClose={{onClose}}
              @closeButtonTitle="Remove Beta"
              data-test-id="named"
            >Beta</Chip>
          </template>
        );

        assert
          .dom('[data-test-id="default"] .chip-close-button')
          .hasText('Close');
        assert
          .dom('[data-test-id="named"] .chip-close-button')
          .hasText('Remove Beta');
      });
    });
  });

  module('shape', function () {
    test('it is always a pill', function (assert) {
      const { base } = realStyles.chip({});
      const classes = base();

      assert.true(classes.includes('rounded-full'), 'base is rounded-full');
      for (const other of ['rounded-none', 'rounded-sm', 'rounded-lg']) {
        assert.false(classes.split(' ').includes(other), `no ${other}`);
      }
    });

    test('@radius is ignored and deprecated', async function (assert) {
      const { ids } = trackDeprecations();

      await render(
        <template>
          <Chip @radius="none" data-test-id="chip">x</Chip>
        </template>
      );

      assert.deepEqual(ids, ['frontile.chip.radius']);
      assert.dom('[data-test-id="chip"]').doesNotHaveClass('radius-none');
    });

    test('no deprecation without @radius', async function (assert) {
      const { ids } = trackDeprecations();

      await render(
        <template>
          <Chip data-test-id="chip">x</Chip>
        </template>
      );

      assert.deepEqual(ids, []);
    });
  });

  module('close button', function () {
    test('close button is a pointer', function (assert) {
      const { closeButton } = realStyles.chip({});
      const classes = closeButton();

      assert.true(classes.includes('cursor-pointer'), 'cursor-pointer');
      assert.true(
        classes.includes('disabled:cursor-not-allowed'),
        'disabled keeps not-allowed'
      );
    });

    test('disabled chip keeps a disabled close button', async function (assert) {
      const onClose = () => {};
      await render(
        <template>
          <Chip @isDisabled={{true}} @onClose={{onClose}}>x</Chip>
        </template>
      );

      assert.dom('[data-part="close-button"]').isDisabled();
    });

    test('no close button without @onClose', async function (assert) {
      await render(
        <template>
          <Chip>x</Chip>
        </template>
      );

      assert.dom('[data-part="close-button"]').doesNotExist();
    });
  });

  module('body', function () {
    test('href renders a link body', async function (assert) {
      await render(
        <template>
          <Chip @href="/x">Go</Chip>
        </template>
      );

      assert.dom('a[data-part="body"]').hasAttribute('href', '/x');
      assert.dom('a[data-part="body"]').hasText('Go');
      assert.dom('a[data-part="body"]').doesNotHaveAttribute('aria-disabled');
    });

    test('route renders a LinkTo body', async function (assert) {
      await render(
        <template>
          <Chip @route="tab-nav-demo.item" @model={{0}}>Item</Chip>
        </template>
      );

      const body = document.querySelector('a[data-part="body"]');
      assert.dom(body).exists();
      assert.dom(body).hasText('Item');
      assert.ok(
        body?.getAttribute('href')?.includes('/tab-nav-demo/item/0'),
        `href resolves the route, got: ${body?.getAttribute('href')}`
      );
    });

    test('onPress renders a button body and fires', async function (assert) {
      let pressed = 0;
      const onPress = () => {
        pressed++;
      };
      await render(
        <template>
          <Chip @onPress={{onPress}}>Filter</Chip>
        </template>
      );

      const selector = 'button[type="button"][data-part="body"]';
      assert.dom(selector).exists();
      assert.dom(selector).hasText('Filter');

      await click(selector);
      assert.strictEqual(pressed, 1, 'click pressed once');

      await triggerKeyEvent(selector, 'keydown', 'Enter');
      await triggerKeyEvent(selector, 'keyup', 'Enter');
      assert.strictEqual(pressed, 2, 'Enter pressed');

      await triggerKeyEvent(selector, 'keydown', ' ');
      await triggerKeyEvent(selector, 'keyup', ' ');
      assert.strictEqual(pressed, 3, 'Space pressed');
    });

    test('route wins over href, and href over onPress', async function (assert) {
      const onPress = () => {};
      await render(
        <template>
          <Chip
            @route="tab-nav-demo.index"
            @href="/x"
            @onPress={{onPress}}
            data-test-id="route"
          >a</Chip>
          <Chip @href="/x" @onPress={{onPress}} data-test-id="href">b</Chip>
        </template>
      );

      assert
        .dom('[data-test-id="route"] [data-part="body"]')
        .hasAttribute('href', /tab-nav-demo/);
      assert
        .dom('[data-test-id="href"] a[data-part="body"]')
        .hasAttribute('href', '/x');
    });

    test('neither renders a non-interactive wrapper', async function (assert) {
      const onClose = () => {};
      await render(
        <template>
          <Chip @onClose={{onClose}}>x</Chip>
        </template>
      );

      assert.dom('span[data-part="body"]').exists();
      assert.dom('span[data-part="body"]').doesNotHaveAttribute('href');
      assert.dom('span[data-part="body"]').doesNotHaveAttribute('tabindex');
      assert.dom('span[data-part="body"]').doesNotHaveAttribute('role');
      assert.dom('span[data-part="body"]').doesNotHaveClass('chip-pressable');
    });

    test('an interactive body is marked pressable', async function (assert) {
      const onPress = () => {};
      await render(
        <template>
          <Chip @onPress={{onPress}} data-test-id="button">a</Chip>
          <Chip @href="/x" data-test-id="link">b</Chip>
        </template>
      );

      assert
        .dom('[data-test-id="button"] [data-part="body"]')
        .hasClass('chip-pressable');
      assert
        .dom('[data-test-id="link"] [data-part="body"]')
        .hasClass('chip-pressable');
    });

    test('the dot and content live inside the body', async function (assert) {
      const onPress = () => {};
      await render(
        <template>
          <Chip @onPress={{onPress}} @withDot={{true}}>x</Chip>
        </template>
      );

      assert.dom('[data-part="body"] [data-part="dot"]').exists();
      assert.dom('[data-part="body"] [data-part="content"]').hasText('x');
    });

    test('close button is a sibling, not nested', async function (assert) {
      let pressed = 0;
      let closed = 0;
      const onPress = () => {
        pressed++;
      };
      const onClose = () => {
        closed++;
      };
      await render(
        <template>
          <Chip @onPress={{onPress}} @onClose={{onClose}}>x</Chip>
        </template>
      );

      assert
        .dom('[data-part="body"] [data-part="close-button"]')
        .doesNotExist();
      const closeButton = document.querySelector('[data-part="close-button"]');
      assert.strictEqual(
        closeButton?.parentElement?.getAttribute('data-part'),
        'base',
        'the close button is a direct child of the wrapper'
      );

      await click('[data-part="close-button"]');
      assert.strictEqual(closed, 1, 'close fired');
      assert.strictEqual(pressed, 0, 'body press did not fire');
    });

    test('disabled button body', async function (assert) {
      let pressed = 0;
      const onPress = () => {
        pressed++;
      };
      await render(
        <template>
          <Chip @onPress={{onPress}} @isDisabled={{true}}>x</Chip>
        </template>
      );

      const body = document.querySelector(
        'button[data-part="body"]'
      ) as HTMLButtonElement;
      assert.dom(body).isDisabled();
      assert.dom(body).doesNotHaveClass('chip-pressable');

      // `click()` refuses a disabled control, so dispatch the events the
      // `press` modifier listens for directly.
      body.dispatchEvent(new PointerEvent('pointerdown', { bubbles: true }));
      body.dispatchEvent(new PointerEvent('pointerup', { bubbles: true }));
      body.dispatchEvent(
        new KeyboardEvent('keydown', { key: 'Enter', bubbles: true })
      );
      body.dispatchEvent(
        new KeyboardEvent('keyup', { key: 'Enter', bubbles: true })
      );
      assert.strictEqual(pressed, 0, 'handler did not fire');
    });

    test('disabled link body', async function (assert) {
      await render(
        <template>
          <Chip @href="/x" @isDisabled={{true}} data-test-id="href">a</Chip>
          <Chip
            @route="tab-nav-demo.index"
            @isDisabled={{true}}
            data-test-id="route"
          >b</Chip>
        </template>
      );

      for (const id of ['href', 'route']) {
        const selector = `[data-test-id="${id}"] a[data-part="body"]`;
        assert.dom(selector).doesNotHaveAttribute('href');
        assert.dom(selector).hasAttribute('aria-disabled', 'true');
      }
    });

    test('@isSelected sets aria-pressed on a button body', async function (assert) {
      const onPress = () => {};
      await render(
        <template>
          <Chip
            @onPress={{onPress}}
            @isSelected={{true}}
            data-test-id="on"
          >a</Chip>
          <Chip
            @onPress={{onPress}}
            @isSelected={{false}}
            data-test-id="off"
          >b</Chip>
          <Chip @onPress={{onPress}} data-test-id="unset">c</Chip>
        </template>
      );

      assert
        .dom('[data-test-id="on"] [data-part="body"]')
        .hasAttribute('aria-pressed', 'true');
      assert
        .dom('[data-test-id="off"] [data-part="body"]')
        .hasAttribute('aria-pressed', 'false');
      assert
        .dom('[data-test-id="unset"] [data-part="body"]')
        .doesNotHaveAttribute('aria-pressed');
    });
  });

  module('body states (real theme)', function () {
    test('an interactive body is a pointer with a focus ring; a static one is not', function (assert) {
      const pressable = realStyles.chip({ isPressable: true }).body();
      const staticBody = realStyles.chip({ isPressable: false }).body();

      assert.true(pressable.split(' ').includes('cursor-pointer'));
      assert.true(pressable.split(' ').includes('focus-visible:ring-2'));
      assert.false(staticBody.split(' ').includes('cursor-pointer'));
      assert.false(staticBody.split(' ').includes('focus-visible:ring-2'));
    });

    const hover = 'has-[>[data-part=body]:hover]:';
    const active = 'has-[>[data-part=body]:active]:';

    test('soft: hover -subtle to -muted, active one more step', function (assert) {
      const classes = realStyles
        .chip({ variant: 'soft', color: 'primary', isPressable: true })
        .base()
        .split(' ');

      assert.true(classes.includes('bg-primary-subtle'), 'rests on -subtle');
      assert.true(classes.includes(`${hover}bg-primary-muted`), 'hover');
      assert.true(classes.includes(`${active}bg-primary-soft`), 'active');
    });

    test('outline: hover transparent to -subtle, active one more step', function (assert) {
      const classes = realStyles
        .chip({ variant: 'outline', color: 'primary', isPressable: true })
        .base()
        .split(' ');

      assert.true(classes.includes(`${hover}bg-primary-subtle`), 'hover');
      assert.true(classes.includes(`${active}bg-primary-muted`), 'active');
    });

    test('solid: hover DEFAULT to -mild, active -firm', function (assert) {
      const classes = realStyles
        .chip({ variant: 'solid', color: 'primary', isPressable: true })
        .base()
        .split(' ');

      assert.true(classes.includes('bg-primary'), 'rests on DEFAULT');
      assert.true(classes.includes(`${hover}bg-primary-mild`), 'hover');
      assert.true(classes.includes(`${active}bg-primary-firm`), 'active');
    });

    test('a static or disabled chip has no hover or active fill', function (assert) {
      for (const isPressable of [false, undefined]) {
        const base = realStyles
          .chip({ variant: 'soft', color: 'primary', isPressable })
          .base();

        assert.false(base.includes(hover), `no hover (${String(isPressable)})`);
        assert.false(
          base.includes(active),
          `no active (${String(isPressable)})`
        );
      }
    });

    test('selected holds the pressed fill', function (assert) {
      const soft = realStyles
        .chip({
          variant: 'soft',
          color: 'primary',
          isPressable: true,
          isSelected: true
        })
        .base()
        .split(' ');

      assert.true(soft.includes('bg-primary-soft'), 'soft holds -soft');
      assert.false(soft.includes('bg-primary-subtle'), 'resting fill replaced');
      assert.false(
        soft.some((c) => c.startsWith(hover)),
        'hover does not lighten a selected chip'
      );

      const solid = realStyles
        .chip({ variant: 'solid', color: 'primary', isSelected: true })
        .base()
        .split(' ');
      assert.true(solid.includes('bg-primary-firm'), 'solid holds -firm');
      assert.false(solid.includes('bg-primary'), 'resting fill replaced');
    });
  });

  module('removal keys', function () {
    const keys = ['Backspace', 'Delete'] as const;

    for (const key of keys) {
      test(`${key} on a focused button body calls @onClose once`, async function (assert) {
        let closed = 0;
        let pressed = 0;
        const onClose = () => {
          closed++;
        };
        const onPress = () => {
          pressed++;
        };
        await render(
          <template>
            <Chip @onPress={{onPress}} @onClose={{onClose}}>x</Chip>
          </template>
        );

        await triggerKeyEvent('button[data-part="body"]', 'keydown', key);
        assert.strictEqual(closed, 1, 'closed once');
        assert.strictEqual(pressed, 0, 'did not press');
      });

      test(`${key} on a focused link body calls @onClose once`, async function (assert) {
        let closed = 0;
        const onClose = () => {
          closed++;
        };
        await render(
          <template>
            <Chip @href="/x" @onClose={{onClose}} data-test-id="href">a</Chip>
            <Chip
              @route="tab-nav-demo.index"
              @onClose={{onClose}}
              data-test-id="route"
            >b</Chip>
          </template>
        );

        await triggerKeyEvent(
          '[data-test-id="href"] a[data-part="body"]',
          'keydown',
          key
        );
        assert.strictEqual(closed, 1, 'href body closed once');
        await triggerKeyEvent(
          '[data-test-id="route"] a[data-part="body"]',
          'keydown',
          key
        );
        assert.strictEqual(closed, 2, 'route body closed once');
      });

      test(`${key} on a focused close button calls @onClose once`, async function (assert) {
        let closed = 0;
        const onClose = () => {
          closed++;
        };
        await render(
          <template>
            <Chip @onClose={{onClose}}>x</Chip>
          </template>
        );

        await triggerKeyEvent('[data-part="close-button"]', 'keydown', key);
        assert.strictEqual(closed, 1, 'closed once');
      });
    }

    test('the removal keys prevent the default only when they close', async function (assert) {
      const onClose = () => {};
      const onPress = () => {};
      await render(
        <template>
          <Chip
            @onPress={{onPress}}
            @onClose={{onClose}}
            data-test-id="removable"
          >a</Chip>
          <Chip @onPress={{onPress}} data-test-id="plain">b</Chip>
        </template>
      );

      const fire = (selector: string) => {
        const event = new KeyboardEvent('keydown', {
          key: 'Backspace',
          bubbles: true,
          cancelable: true
        });
        document.querySelector(selector)!.dispatchEvent(event);
        return event.defaultPrevented;
      };

      assert.true(fire('[data-test-id="removable"] [data-part="body"]'));
      assert.false(fire('[data-test-id="plain"] [data-part="body"]'));
    });

    test('the removal keys do nothing without @onClose', async function (assert) {
      let pressed = 0;
      const onPress = () => {
        pressed++;
      };
      await render(
        <template>
          <Chip @onPress={{onPress}} data-test-id="button">a</Chip>
          <Chip @href="/x" data-test-id="link">b</Chip>
        </template>
      );

      for (const key of keys) {
        await triggerKeyEvent(
          '[data-test-id="button"] [data-part="body"]',
          'keydown',
          key
        );
        await triggerKeyEvent(
          '[data-test-id="link"] [data-part="body"]',
          'keydown',
          key
        );
      }
      assert.strictEqual(pressed, 0, 'no press either');
      assert.dom('[data-part="body"]').exists({ count: 2 }, 'nothing removed');
    });

    test('the removal keys do nothing when disabled', async function (assert) {
      let closed = 0;
      const onClose = () => {
        closed++;
      };
      const onPress = () => {};
      await render(
        <template>
          <Chip
            @onPress={{onPress}}
            @onClose={{onClose}}
            @isDisabled={{true}}
            data-test-id="button"
          >a</Chip>
          <Chip
            @href="/x"
            @onClose={{onClose}}
            @isDisabled={{true}}
            data-test-id="link"
          >b</Chip>
        </template>
      );

      // `triggerKeyEvent` refuses a disabled control, so dispatch directly.
      for (const selector of [
        '[data-test-id="button"] [data-part="body"]',
        '[data-test-id="button"] [data-part="close-button"]',
        '[data-test-id="link"] [data-part="body"]',
        '[data-test-id="link"] [data-part="close-button"]'
      ]) {
        for (const key of keys) {
          document
            .querySelector(selector)!
            .dispatchEvent(
              new KeyboardEvent('keydown', { key, bubbles: true })
            );
        }
      }
      assert.strictEqual(closed, 0, 'never closed');
    });

    test('Enter and Space still press a removable button body once each', async function (assert) {
      let closed = 0;
      let pressed = 0;
      const onClose = () => {
        closed++;
      };
      const onPress = () => {
        pressed++;
      };
      await render(
        <template>
          <Chip @onPress={{onPress}} @onClose={{onClose}}>x</Chip>
        </template>
      );

      const selector = 'button[data-part="body"]';
      await triggerKeyEvent(selector, 'keydown', 'Enter');
      await triggerKeyEvent(selector, 'keyup', 'Enter');
      assert.strictEqual(pressed, 1, 'Enter pressed once');
      await triggerKeyEvent(selector, 'keydown', ' ');
      await triggerKeyEvent(selector, 'keyup', ' ');
      assert.strictEqual(pressed, 2, 'Space pressed once');
      assert.strictEqual(closed, 0, 'did not close');
    });
  });

  module('hit area (real theme)', function () {
    const padding = { xs: '0.5', sm: '1', md: '1', lg: '2' } as const;

    for (const size of ['xs', 'sm', 'md', 'lg'] as const) {
      test(`${size}: the body covers the pill except the close button`, function (assert) {
        const styles = realStyles.chip({ size, isPressable: true });
        const base = styles.base().split(' ');
        const body = styles.body().split(' ');
        const closeButton = styles.closeButton().split(' ');
        const px = padding[size];

        assert.true(body.includes('self-stretch'), 'body is full height');
        assert.true(
          body.includes(`pl-${px}`),
          'body carries the start padding'
        );
        assert.true(
          body.includes(`last:pr-${px}`),
          'body carries the end padding when it is the last child'
        );
        assert.true(
          closeButton.includes(`mr-${px}`),
          'close button carries the end padding'
        );
        assert.false(
          base.some((c) => /^p[xlr]?-/.test(c)),
          'base has no horizontal padding (no dead rim)'
        );
      });
    }
  });

  module('anatomy', function () {
    test('renders data-component="chip" on the root only, with data-part on every slot', async function (assert) {
      const onClose = () => {};
      await render(
        <template>
          <Chip @withDot={{true}} @onClose={{onClose}}>My Chip</Chip>
        </template>
      );

      assert.dom('[data-component="chip"]').hasAttribute('data-part', 'base');
      assert.dom('[data-component="chip"] [data-part="body"]').exists();
      assert.dom('[data-component="chip"] [data-part="content"]').exists();
      assert.dom('[data-component="chip"] [data-part="dot"]').exists();
      assert.dom('[data-component="chip"] [data-part="close-button"]').exists();
      assert.strictEqual(
        document.querySelectorAll('[data-component="chip"]').length,
        1,
        'data-component="chip" marks the root only, never a part'
      );
    });
  });
});
