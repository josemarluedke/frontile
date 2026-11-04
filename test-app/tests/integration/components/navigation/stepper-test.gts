import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find } from '@ember/test-helpers';

module('Integration | Component | Stepper | container tokens', function (hooks) {
  setupRenderingTest(hooks);

  function display(selector: string): string {
    return getComputedStyle(find(selector) as Element).display;
  }

  test('the stepper tokens reach a consumer build: narrow container stays hidden', async function (assert) {
    await render(
      <template>
        <div class="@container/stepper w-[20rem]">
          <div
            data-test-probe
            class="hidden @fr-stepper-bottom/stepper:block"
          ></div>
        </div>
      </template>
    );

    assert.strictEqual(display('[data-test-probe]'), 'none');
  });

  test('the stepper tokens reach a consumer build: bottom threshold reveals at 30rem', async function (assert) {
    await render(
      <template>
        <div class="@container/stepper w-[30rem]">
          <div
            data-test-probe
            class="hidden @fr-stepper-bottom/stepper:block"
          ></div>
        </div>
      </template>
    );

    assert.strictEqual(display('[data-test-probe]'), 'block');
  });

  test('the stepper tokens reach a consumer build: end threshold waits for 42rem', async function (assert) {
    await render(
      <template>
        <div class="@container/stepper w-[30rem]">
          <div
            data-test-probe
            class="hidden @fr-stepper-end/stepper:block"
          ></div>
        </div>
        <div class="@container/stepper w-[44rem]">
          <div
            data-test-probe-wide
            class="hidden @fr-stepper-end/stepper:block"
          ></div>
        </div>
      </template>
    );

    assert.strictEqual(display('[data-test-probe]'), 'none');
    assert.strictEqual(display('[data-test-probe-wide]'), 'block');
  });

  test('a var() container condition does not match', async function (assert) {
    await render(
      <template>
        <div
          class="@container/stepper w-[30rem]"
          style="--x: 10rem"
        >
          <div
            data-test-probe
            class="hidden @min-[var(--x)]/stepper:block"
          ></div>
        </div>
      </template>
    );

    assert.strictEqual(display('[data-test-probe]'), 'none');
  });
});
