import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find, click, findAll } from '@ember/test-helpers';
import { cell } from 'ember-resources';
import { Stepper } from 'frontile';

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

module('Integration | Component | Stepper | frontile/navigation', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders a labelled ordered list', async function (assert) {
    await render(
      <template>
        <Stepper as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" />
            <S.Step @value="b" />
            <S.Step @value="c" />
          </S.List>
        </Stepper>
      </template>
    );

    assert.dom('ol').hasAria('label', 'Checkout');
    assert.dom('ol > li > button[data-part="step"]').exists({ count: 3 });
  });

  test('aria-current is on the active step only', async function (assert) {
    await render(
      <template>
        <Stepper @value="b" as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" data-test-step="a" />
            <S.Step @value="b" data-test-step="b" />
            <S.Step @value="c" data-test-step="c" />
          </S.List>
        </Stepper>
      </template>
    );

    assert.dom('[aria-current="step"]').exists({ count: 1 });
    assert.dom('[data-test-step="b"]').hasAria('current', 'step');
  });

  test('uncontrolled: @defaultValue seeds and clicks select', async function (assert) {
    const calls: string[] = [];
    const onChange = (value: string) => calls.push(value);

    await render(
      <template>
        <Stepper @defaultValue="a" @onChange={{onChange}} as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" data-test-step="a" />
            <S.Step @value="b" data-test-step="b" />
          </S.List>
        </Stepper>
      </template>
    );

    assert.dom('[data-test-step="a"]').hasAria('current', 'step');

    await click('[data-test-step="b"]');

    assert.dom('[data-test-step="b"]').hasAria('current', 'step');
    assert.dom('[data-test-step="a"]').doesNotHaveAttribute('aria-current');
    assert.deepEqual(calls, ['b']);
  });

  test('uncontrolled: starts on the first enabled step without @defaultValue', async function (assert) {
    await render(
      <template>
        <Stepper as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" @isDisabled={{true}} data-test-step="a" />
            <S.Step @value="b" data-test-step="b" />
            <S.Step @value="c" data-test-step="c" />
          </S.List>
        </Stepper>
      </template>
    );

    assert.dom('[data-test-step="b"]').hasAria('current', 'step');
  });

  test('controlled: @value={{undefined}} counts as controlled', async function (assert) {
    const calls: string[] = [];
    const onChange = (value: string) => calls.push(value);

    await render(
      <template>
        <Stepper @value={{undefined}} @onChange={{onChange}} as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" data-test-step="a" />
            <S.Step @value="b" data-test-step="b" />
          </S.List>
        </Stepper>
      </template>
    );

    assert.dom('[aria-current]').doesNotExist();

    await click('[data-test-step="b"]');

    assert.deepEqual(calls, ['b'], 'onChange still fires');
    assert.dom('[aria-current]').doesNotExist('selection did not move');
  });

  test('controlled: an onChange that does not update @value leaves selection unchanged', async function (assert) {
    const value = cell('a');
    const calls: string[] = [];
    const onChange = (next: string) => calls.push(next);

    await render(
      <template>
        <Stepper @value={{value.current}} @onChange={{onChange}} as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" data-test-step="a" />
            <S.Step @value="b" data-test-step="b" />
          </S.List>
        </Stepper>
      </template>
    );

    await click('[data-test-step="b"]');

    assert.deepEqual(calls, ['b']);
    assert.dom('[data-test-step="a"]').hasAria('current', 'step');
  });

  test('controlled: an onChange that updates @value moves selection', async function (assert) {
    const value = cell('a');
    const onChange = (next: string) => (value.current = next);

    await render(
      <template>
        <Stepper @value={{value.current}} @onChange={{onChange}} as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" data-test-step="a" />
            <S.Step @value="b" data-test-step="b" />
          </S.List>
        </Stepper>
      </template>
    );

    await click('[data-test-step="b"]');

    assert.dom('[data-test-step="b"]').hasAria('current', 'step');
  });

  test('a disabled step ignores clicks and carries aria-disabled', async function (assert) {
    const calls: string[] = [];
    const onChange = (value: string) => calls.push(value);

    await render(
      <template>
        <Stepper @defaultValue="a" @onChange={{onChange}} as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" data-test-step="a" />
            <S.Step @value="b" @isDisabled={{true}} data-test-step="b" />
          </S.List>
        </Stepper>
      </template>
    );

    assert.dom('[data-test-step="b"]').hasAria('disabled', 'true');

    await click('[data-test-step="b"]');

    assert.deepEqual(calls, []);
    assert.dom('[data-test-step="a"]').hasAria('current', 'step');
  });

  test('no step is active when @value matches nothing', async function (assert) {
    await render(
      <template>
        <Stepper @value="nope" as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" />
            <S.Step @value="b" />
          </S.List>
        </Stepper>
      </template>
    );

    assert.dom('[aria-current]').doesNotExist();
    assert.dom('[data-part="step"]').exists({ count: 2 });
  });

  test('duplicate values render distinct ids', async function (assert) {
    await render(
      <template>
        <Stepper @value="a" as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" />
            <S.Step @value="a" />
          </S.List>
        </Stepper>
      </template>
    );

    const ids = findAll('[data-part="step"]').map((el) => el.id);
    assert.strictEqual(ids.length, 2);
    assert.strictEqual(new Set(ids).size, 2, 'ids are unique');
    assert.notStrictEqual(ids[0], '');
  });
});
