import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  triggerEvent,
  triggerKeyEvent,
  click
} from '@ember/test-helpers';
import { registerCustomStyles, tv } from '@frontile/theme';
import { Button } from 'frontile';
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { trackDeprecations } from '../../../helpers/deprecations';

registerCustomStyles({
  button: tv({
    base: [],
    variants: {
      isInGroup: { true: ['in-group'] },
      variant: {
        solid: 'button-solid',
        soft: 'button-soft',
        subtle: 'button-subtle',
        outline: 'button-outline',
        ghost: 'button-ghost',
        plain: 'button-plain',
        custom: 'button-custom'
      },
      intent: {
        default: 'intent-default',
        primary: 'intent-primary',
        success: 'intent-success',
        warning: 'intent-warning',
        danger: 'intent-danger'
      },
      size: {
        xs: 'btn-xs',
        sm: 'btn-sm',
        md: 'btn-md',
        lg: 'btn-lg',
        xl: 'btn-xl'
      }
    },
    defaultVariants: {
      size: 'md',
      intent: 'primary',
      variant: 'solid'
    }
  }) as never
});

module(
  'Integration | Component | Button | @frontile/buttons',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders', async function (assert) {
      await render(
        <template>
          <Button data-test-id="button">My Button</Button>
        </template>
      );

      assert.dom('[data-test-id="button"]').hasText('My Button');
      assert.dom('[data-test-id="button"]').hasAttribute('type', 'button');
    });

    test('it accepts @type argument', async function (assert) {
      await render(
        <template>
          <Button @type="submit" data-test-id="button">My Button</Button>
        </template>
      );

      assert.dom('[data-test-id="button"]').hasAttribute('type', 'submit');
    });

    test('renders data-component="button" on the root only, with data-part="base"', async function (assert) {
      await render(
        <template>
          <Button>My Button</Button>
        </template>
      );

      assert.dom('[data-component="button"]').hasAttribute('data-part', 'base');
      assert.strictEqual(
        document.querySelectorAll('[data-component="button"]').length,
        1,
        'data-component="button" marks the root only'
      );
    });

    module('Style classes', () => {
      module('@appearance', () => {
        test('it adds class for default appearance', async function (assert) {
          await render(
            <template>
              <Button data-test-id="button">My Button</Button>
            </template>
          );

          assert
            .dom('[data-test-id="button"]')
            .doesNotHaveClass('button-outline');
          assert
            .dom('[data-test-id="button"]')
            .doesNotHaveClass('button-plain');
          assert
            .dom('[data-test-id="button"]')
            .doesNotHaveClass('button-custom');
          assert.dom('[data-test-id="button"]').hasClass('button-solid');
        });

        test('it adds class for outlined appearance', async function (assert) {
          await render(
            <template>
              <Button @appearance="outlined" data-test-id="button">My Button</Button>
            </template>
          );

          assert
            .dom('[data-test-id="button"]')
            .doesNotHaveClass('button-solid');
          assert
            .dom('[data-test-id="button"]')
            .doesNotHaveClass('button-plain');
          assert
            .dom('[data-test-id="button"]')
            .doesNotHaveClass('button-custom');
          assert.dom('[data-test-id="button"]').hasClass('button-outline');
        });

        test('it adds class for minimal appearance', async function (assert) {
          await render(
            <template>
              <Button @appearance="minimal" data-test-id="button">My Button</Button>
            </template>
          );

          assert
            .dom('[data-test-id="button"]')
            .doesNotHaveClass('button-solid');
          assert
            .dom('[data-test-id="button"]')
            .doesNotHaveClass('button-outline');
          assert
            .dom('[data-test-id="button"]')
            .doesNotHaveClass('button-custom');
          assert.dom('[data-test-id="button"]').hasClass('button-plain');
        });

        test('it adds class for custom appearance', async function (assert) {
          await render(
            <template>
              <Button @appearance="custom" data-test-id="button">My Button</Button>
            </template>
          );

          assert
            .dom('[data-test-id="button"]')
            .doesNotHaveClass('button-solid');
          assert
            .dom('[data-test-id="button"]')
            .doesNotHaveClass('button-outline');
          assert
            .dom('[data-test-id="button"]')
            .doesNotHaveClass('button-plain');
          assert.dom('[data-test-id="button"]').hasClass('button-custom');
        });
      });

      module('@variant', () => {
        test('@variant renders the new class', async function (assert) {
          await render(
            <template>
              <Button @variant="outline" data-test-id="button">x</Button>
            </template>
          );

          assert.dom('[data-test-id="button"]').hasClass('button-outline');
        });

        test('@appearance still renders, and deprecates exactly once', async function (assert) {
          const { ids } = trackDeprecations();

          await render(
            <template>
              <Button @appearance="outlined" data-test-id="button">x</Button>
            </template>
          );

          assert.dom('[data-test-id="button"]').hasClass('button-outline');
          assert.deepEqual(ids, ['frontile.button.appearance']);
        });

        test('@appearance="minimal" maps to plain', async function (assert) {
          await render(
            <template>
              <Button @appearance="minimal" data-test-id="button">x</Button>
            </template>
          );

          assert.dom('[data-test-id="button"]').hasClass('button-plain');
        });

        test('@variant wins when both are passed', async function (assert) {
          await render(
            <template>
              <Button
                @variant="solid"
                @appearance="outlined"
                data-test-id="button"
              >x</Button>
            </template>
          );

          assert.dom('[data-test-id="button"]').hasClass('button-solid');
          assert
            .dom('[data-test-id="button"]')
            .doesNotHaveClass('button-outline');
        });

        test('@appearance="custom" passes through unmapped', async function (assert) {
          const { ids } = trackDeprecations();

          await render(
            <template>
              <Button @appearance="custom" data-test-id="button">x</Button>
            </template>
          );

          // `custom` keeps its name, so it is absent from the value map and
          // must pass through untouched rather than falling back to the
          // default.
          assert.dom('[data-test-id="button"]').hasClass('button-custom');
          assert.deepEqual(ids, ['frontile.button.appearance']);
        });

        test('ghost carries a hover fill and plain does not', async function (assert) {
          await render(
            <template>
              <Button @variant="ghost" data-test-id="ghost">x</Button>
              <Button @variant="plain" data-test-id="plain">x</Button>
            </template>
          );

          assert.dom('[data-test-id="ghost"]').hasClass('button-ghost');
          assert.dom('[data-test-id="plain"]').hasClass('button-plain');
        });
      });

      module('@intent', () => {
        test('it adds class for the an intent', async function (assert) {
          await render(
            <template>
              <Button @intent="primary" data-test-id="button">My Button</Button>
            </template>
          );

          assert.dom('[data-test-id="button"]').hasClass('intent-primary');
        });
      });

      module('sizes', () => {
        test('it adds class size xs"', async function (assert) {
          await render(
            <template>
              <Button @size="xs" data-test-id="button">My Button</Button>
            </template>
          );

          assert.dom('[data-test-id="button"]').hasClass('btn-xs');
        });

        test('it adds class size xl', async function (assert) {
          await render(
            <template>
              <Button @size="xl" data-test-id="button">My Button</Button>
            </template>
          );

          assert.dom('[data-test-id="button"]').hasClass('btn-xl');
        });
      });
    });

    test('it yields classNames when renderless', async function (assert) {
      await render(
        <template>
          <Button @isRenderless={{true}} as |btn|>
            <div data-test-id="my-div">{{btn.classNames}}</div>
          </Button>
        </template>
      );
      assert
        .dom('[data-test-id="my-div"]')
        .hasText('button-solid intent-default btn-md');
    });

    module('Press functionality', () => {
      test('it handles onPress callback', async function (assert) {
        let pressEventCount = 0;

        class TestComponent extends Component {
          handlePress = () => {
            pressEventCount++;
          };

          <template>
            <Button @onPress={{this.handlePress}} data-test-id="button">
              Press me
            </Button>
          </template>
        }

        await render(<template><TestComponent /></template>);

        await triggerEvent('[data-test-id="button"]', 'pointerdown');
        await triggerEvent('[data-test-id="button"]', 'pointerup');

        assert.strictEqual(
          pressEventCount,
          1,
          'onPress callback was called once'
        );
      });

      test('it sets data-pressed attribute when pressed', async function (assert) {
        await render(
          <template>
            <Button data-test-id="button">Press me</Button>
          </template>
        );

        assert
          .dom('[data-test-id="button"]')
          .doesNotHaveAttribute('data-pressed');

        await triggerEvent('[data-test-id="button"]', 'pointerdown');
        assert
          .dom('[data-test-id="button"]')
          .hasAttribute('data-pressed', 'true');

        await triggerEvent('[data-test-id="button"]', 'pointerup');
        assert
          .dom('[data-test-id="button"]')
          .doesNotHaveAttribute('data-pressed');
      });

      // The `press` modifier calls preventDefault on Enter/Space keydown, which
      // cancels the click the browser would otherwise synthesize. These two
      // tests pin down which callbacks survive that, because the docs tell
      // readers to reach for @onPress over {{on "click"}} on its account.
      test('@onPress fires for keyboard Enter and Space', async function (assert) {
        let pressCount = 0;

        class TestComponent extends Component {
          handlePress = () => {
            pressCount++;
          };

          <template>
            <Button data-test-id="button" @onPress={{this.handlePress}}>
              Press me
            </Button>
          </template>
        }

        await render(<template><TestComponent /></template>);

        await triggerKeyEvent('[data-test-id="button"]', 'keydown', 'Enter');
        await triggerKeyEvent('[data-test-id="button"]', 'keyup', 'Enter');
        assert.strictEqual(pressCount, 1, 'Enter triggered @onPress');

        await triggerKeyEvent('[data-test-id="button"]', 'keydown', ' ');
        await triggerKeyEvent('[data-test-id="button"]', 'keyup', ' ');
        assert.strictEqual(pressCount, 2, 'Space triggered @onPress');
      });

      test('a click listener does not fire for keyboard activation', async function (assert) {
        let clickCount = 0;

        class TestComponent extends Component {
          handleClick = () => {
            clickCount++;
          };

          <template>
            <Button data-test-id="button" {{on "click" this.handleClick}}>
              Press me
            </Button>
          </template>
        }

        await render(<template><TestComponent /></template>);

        await triggerKeyEvent('[data-test-id="button"]', 'keydown', 'Enter');
        await triggerKeyEvent('[data-test-id="button"]', 'keyup', 'Enter');
        assert.strictEqual(
          clickCount,
          0,
          'Enter did not reach the click listener'
        );

        await click('[data-test-id="button"]');
        assert.strictEqual(clickCount, 1, 'a pointer click still reaches it');
      });

      test('it works with renderless mode', async function (assert) {
        let pressEventCount = 0;

        class TestComponent extends Component {
          handlePress = () => {
            pressEventCount++;
          };

          <template>
            <Button
              @isRenderless={{true}}
              @onPress={{this.handlePress}}
              as |btn|
            >
              <div data-test-id="custom-button" class={{btn.classNames}}>
                Custom Button
              </div>
            </Button>
          </template>
        }

        await render(<template><TestComponent /></template>);

        // Renderless mode should not handle press events on its own
        await triggerEvent('[data-test-id="custom-button"]', 'pointerdown');
        await triggerEvent('[data-test-id="custom-button"]', 'pointerup');

        assert.strictEqual(
          pressEventCount,
          0,
          'onPress should not be called in renderless mode'
        );
      });
    });

    module('@isLoading', function () {
      test('it is not loading by default', async function (assert) {
        await render(
          <template>
            <Button data-test-id="button">Save</Button>
          </template>
        );

        assert.dom('[data-test-id="button"]').doesNotHaveAttribute('disabled');
        assert.dom('[data-test-id="button"]').doesNotHaveAttribute('aria-busy');
        assert
          .dom('[data-test-id="button"]')
          .doesNotHaveAttribute('data-loading');
      });

      test('it disables and marks the button busy while loading', async function (assert) {
        await render(
          <template>
            <Button @isLoading={{true}} data-test-id="button">Save</Button>
          </template>
        );

        assert.dom('[data-test-id="button"]').isDisabled();
        assert.dom('[data-test-id="button"]').hasAttribute('aria-busy', 'true');
        assert
          .dom('[data-test-id="button"]')
          .hasAttribute('data-loading', 'true');
      });

      test('it clears the loading state when @isLoading becomes false', async function (assert) {
        class State {
          @tracked isLoading = true;
        }
        const state = new State();
        const stopLoading = () => (state.isLoading = false);

        await render(
          <template>
            <Button
              @isLoading={{state.isLoading}}
              data-test-id="button"
            >Save</Button>
            <button
              type="button"
              data-test-id="stop"
              {{on "click" stopLoading}}
            >stop</button>
          </template>
        );

        assert.dom('[data-test-id="button"]').isDisabled();

        await click('[data-test-id="stop"]');

        assert.dom('[data-test-id="button"]').isNotDisabled();
        assert.dom('[data-test-id="button"]').doesNotHaveAttribute('aria-busy');
      });

      test('a consumer disabled={{false}} does not defeat @isLoading', async function (assert) {
        await render(
          <template>
            <Button
              @isLoading={{true}}
              disabled={{false}}
              data-test-id="button"
            >
              Save
            </Button>
          </template>
        );

        assert.dom('[data-test-id="button"]').isDisabled();
      });

      test('a consumer disabled={{true}} survives @isLoading toggling off', async function (assert) {
        class State {
          @tracked isLoading = true;
        }
        const state = new State();
        const stopLoading = () => (state.isLoading = false);

        await render(
          <template>
            <Button
              @isLoading={{state.isLoading}}
              disabled={{true}}
              data-test-id="button"
            >Save</Button>
            <button
              type="button"
              data-test-id="stop"
              {{on "click" stopLoading}}
            >stop</button>
          </template>
        );

        await click('[data-test-id="stop"]');

        assert
          .dom('[data-test-id="button"]')
          .isDisabled('the consumer disable is restored, not cleared');
      });

      test('known limitation: a consumer disable applied mid-load is lost when loading ends', async function (assert) {
        // Pins the fail-open direction documented on `disableWhile` in
        // button.gts: the modifier snapshots `previous = el.disabled` only
        // when it installs (when `loading` becomes true). A `disabled`
        // binding that flips false -> true *after* that, while loading is
        // still in flight, does not cause the modifier to re-run (it only
        // reacts to `loading` changing), so `previous` stays stale at
        // `false`. When loading ends, teardown restores that stale
        // `previous`, silently discarding the consumer's disable.
        //
        // A literal `disabled={{true}}` would NOT reproduce this: Glimmer
        // writes attributes before modifiers run, so `previous` would
        // already be `true` at install time (see the passing
        // 'a consumer disabled={{true}} survives @isLoading toggling off'
        // test above). This test uses a tracked binding that changes only
        // after the modifier has installed, which is the case that goes
        // stale.
        class State {
          @tracked isLoading = true;
          @tracked disabled = false;
        }
        const state = new State();
        const disableButton = () => (state.disabled = true);
        const stopLoading = () => (state.isLoading = false);

        await render(
          <template>
            <Button
              @isLoading={{state.isLoading}}
              disabled={{state.disabled}}
              data-test-id="button"
            >Save</Button>
            <button
              type="button"
              data-test-id="disable"
              {{on "click" disableButton}}
            >disable</button>
            <button
              type="button"
              data-test-id="stop"
              {{on "click" stopLoading}}
            >stop</button>
          </template>
        );

        // Modifier installed with `previous = false`. Flip the consumer's
        // own `disabled` binding to `true` while loading is still active —
        // `loading` itself does not change, so the modifier does not re-run.
        await click('[data-test-id="disable"]');

        await click('[data-test-id="stop"]');

        assert
          .dom('[data-test-id="button"]')
          .isNotDisabled(
            "known limitation: the consumer's disabled={{true}} is lost because the modifier's stale `previous` snapshot wins on teardown"
          );
      });

      test('@onPress does not fire while loading', async function (assert) {
        let pressCount = 0;
        const handlePress = () => (pressCount += 1);

        await render(
          <template>
            <Button
              @isLoading={{true}}
              @onPress={{handlePress}}
              data-test-id="button"
            >Save</Button>
          </template>
        );

        // The `press` modifier listens on pointer/mouse/key events and
        // registers no `click` listener, so a native `element.click()` can
        // never reach `onPress` and a test built on one passes even when
        // `@isLoading` is unwired. Synthetic `dispatchEvent` is no better: it
        // reaches listeners regardless of `disabled`, so driving
        // pointerdown/pointerup would fail against a correct implementation.
        // Asserting that the click helper refuses the element is the
        // faithful check — it refuses for exactly the reason the browser
        // does.
        await assert.rejects(
          click('[data-test-id="button"]'),
          /disabled/,
          'the click helper refuses a disabled button'
        );

        assert.strictEqual(pressCount, 0, '@onPress never fired');
      });

      test('it renders a spinner only while loading', async function (assert) {
        class State {
          @tracked isLoading = false;
        }
        const state = new State();
        const startLoading = () => (state.isLoading = true);

        await render(
          <template>
            <Button
              @isLoading={{state.isLoading}}
              data-test-id="button"
            >Save</Button>
            <button
              type="button"
              data-test-id="start"
              {{on "click" startLoading}}
            >go</button>
          </template>
        );

        assert.dom('[data-component="spinner"]').doesNotExist();

        await click('[data-test-id="start"]');

        assert.dom('[data-component="spinner"]').exists();
      });

      test('the label stays visible while loading', async function (assert) {
        await render(
          <template>
            <Button @isLoading={{true}} data-test-id="button">Save</Button>
          </template>
        );

        assert.dom('[data-test-id="button"]').hasText('Save');
      });

      test('the spinner renders before the label', async function (assert) {
        await render(
          <template>
            <Button @isLoading={{true}} data-test-id="button">Save</Button>
          </template>
        );

        const button = document.querySelector('[data-test-id="button"]');
        const spinner = button?.querySelector('[data-component="spinner"]');

        assert.ok(spinner, 'the spinner is inside the button');
        assert.strictEqual(
          button?.firstElementChild,
          spinner,
          'the spinner is the first element in the button'
        );
      });

      test('the <:icon> block renders before the label by default', async function (assert) {
        await render(
          <template>
            <Button data-test-id="button">
              <:icon><span data-test-id="icon">i</span></:icon>
              <:default>Save</:default>
            </Button>
          </template>
        );

        const button = document.querySelector('[data-test-id="button"]');

        assert.dom('[data-test-id="icon"]').exists();
        assert.strictEqual(
          button?.firstElementChild,
          button?.querySelector('[data-test-id="icon"]'),
          'the icon is the first element in the button'
        );
        assert.dom('[data-test-id="button"]').hasText('i Save');
      });

      test('the spinner replaces the <:icon> block while loading', async function (assert) {
        await render(
          <template>
            <Button @isLoading={{true}} data-test-id="button">
              <:icon><span data-test-id="icon">i</span></:icon>
              <:default>Save</:default>
            </Button>
          </template>
        );

        assert.dom('[data-component="spinner"]').exists();
        assert
          .dom('[data-test-id="icon"]')
          .doesNotExist('the icon is replaced, not joined, by the spinner');
      });

      test('@iconPlacement="end" puts the icon after the label', async function (assert) {
        await render(
          <template>
            <Button @iconPlacement="end" data-test-id="button">
              <:icon><span data-test-id="icon">i</span></:icon>
              <:default><span data-test-id="label">Save</span></:default>
            </Button>
          </template>
        );

        const button = document.querySelector('[data-test-id="button"]');

        assert.strictEqual(
          button?.lastElementChild,
          button?.querySelector('[data-test-id="icon"]'),
          'the icon is the last element in the button'
        );
        assert.strictEqual(
          button?.firstElementChild,
          button?.querySelector('[data-test-id="label"]'),
          'the label comes before the icon'
        );
      });

      test('@iconPlacement="end" puts the spinner after the label', async function (assert) {
        await render(
          <template>
            <Button
              @isLoading={{true}}
              @iconPlacement="end"
              data-test-id="button"
            >
              <:icon><span data-test-id="icon">i</span></:icon>
              <:default><span data-test-id="label">Save</span></:default>
            </Button>
          </template>
        );

        const button = document.querySelector('[data-test-id="button"]');

        assert.strictEqual(
          button?.lastElementChild,
          button?.querySelector('[data-component="spinner"]'),
          'the spinner is the last element in the button'
        );
        assert.strictEqual(
          button?.firstElementChild,
          button?.querySelector('[data-test-id="label"]'),
          'the label comes before the spinner'
        );
      });

      test('a button with no <:icon> block still shows the spinner', async function (assert) {
        await render(
          <template>
            <Button @isLoading={{true}} data-test-id="button">Save</Button>
          </template>
        );

        assert.dom('[data-component="spinner"]').exists();
      });

      test('the <:loading> block replaces the label while loading', async function (assert) {
        class State {
          @tracked isLoading = false;
        }
        const state = new State();
        const startLoading = () => (state.isLoading = true);

        await render(
          <template>
            <Button @isLoading={{state.isLoading}} data-test-id="button">
              <:default>Save</:default>
              <:loading>Saving…</:loading>
            </Button>
            <button
              type="button"
              data-test-id="start"
              {{on "click" startLoading}}
            >go</button>
          </template>
        );

        assert.dom('[data-test-id="button"]').hasText('Save');

        await click('[data-test-id="start"]');

        assert.dom('[data-test-id="button"]').hasText('Saving…');
      });

      test('the default block returns when loading ends', async function (assert) {
        class State {
          @tracked isLoading = true;
        }
        const state = new State();
        const stopLoading = () => (state.isLoading = false);

        await render(
          <template>
            <Button @isLoading={{state.isLoading}} data-test-id="button">
              <:default>Save</:default>
              <:loading>Saving…</:loading>
            </Button>
            <button
              type="button"
              data-test-id="stop"
              {{on "click" stopLoading}}
            >stop</button>
          </template>
        );

        assert.dom('[data-test-id="button"]').hasText('Saving…');

        await click('[data-test-id="stop"]');

        assert.dom('[data-test-id="button"]').hasText('Save');
      });

      test('the yielded hash carries isLoading', async function (assert) {
        await render(
          <template>
            <Button @isLoading={{true}} data-test-id="button" as |b|>
              {{if b.isLoading "busy" "idle"}}
            </Button>
          </template>
        );

        assert.dom('[data-test-id="button"]').hasText('busy');
      });

      test('@isRenderless yields isLoading and ignores <:icon> and <:loading>', async function (assert) {
        await render(
          <template>
            <Button @isRenderless={{true}} @isLoading={{true}}>
              <:icon><span data-test-id="icon">i</span></:icon>
              <:default as |b|>
                <a href="/next" class={{b.classNames}} data-test-id="link">
                  {{if b.isLoading "Loading…" "Go"}}
                </a>
              </:default>
              <:loading>Saving…</:loading>
            </Button>
          </template>
        );

        assert.dom('[data-test-id="link"]').hasText('Loading…');
        assert.dom('[data-test-id="icon"]').doesNotExist();
        assert.dom('[data-component="spinner"]').doesNotExist();
      });

      test('plain content with no named blocks still renders', async function (assert) {
        await render(
          <template>
            <Button data-test-id="button">Save</Button>
          </template>
        );

        assert.dom('[data-test-id="button"]').hasText('Save');
      });
    });
  }
);
