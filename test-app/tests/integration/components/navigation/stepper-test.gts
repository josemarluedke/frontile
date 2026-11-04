import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  find,
  click,
  findAll,
  settled,
  focus,
  triggerKeyEvent,
  fillIn
} from '@ember/test-helpers';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import { cell } from 'ember-resources';
import { Stepper } from 'frontile';
import type { TOC } from '@ember/component/template-only';

module(
  'Integration | Component | Stepper | container tokens',
  function (hooks) {
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
          <div class="@container/stepper w-[30rem] [--x:10rem]">
            <div
              data-test-probe
              class="hidden @min-[var(--x)]/stepper:block"
            ></div>
          </div>
        </template>
      );

      assert.strictEqual(display('[data-test-probe]'), 'none');
    });
  }
);

module(
  'Integration | Component | Stepper | frontile/navigation',
  function (hooks) {
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
  }
);

module('Integration | Component | Stepper | step content', function (hooks) {
  setupRenderingTest(hooks);

  const states = () =>
    findAll('[data-part="item"]').map(
      (el) => (el as HTMLElement).dataset['state']
    );

  test('it renders title and description', async function (assert) {
    await render(
      <template>
        <Stepper @value="a" as |S|>
          <S.List @label="Checkout">
            <S.Step
              @value="a"
              @title="Account"
              @description="Your details"
              data-test-step="a"
            />
          </S.List>
        </Stepper>
      </template>
    );

    assert.dom('[data-test-step="a"] [data-part="title"]').hasText('Account');
    assert
      .dom('[data-test-step="a"] [data-part="description"]')
      .hasText('Your details');
  });

  test('completion is derived from order', async function (assert) {
    await render(
      <template>
        <Stepper @value="c" as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" />
            <S.Step @value="b" />
            <S.Step @value="c" />
            <S.Step @value="d" />
          </S.List>
        </Stepper>
      </template>
    );

    assert.deepEqual(states(), ['complete', 'complete', 'active', 'upcoming']);
  });

  test('@isComplete overrides the derived state', async function (assert) {
    await render(
      <template>
        <Stepper @value="b" as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" @isComplete={{false}} />
            <S.Step @value="b" />
            <S.Step @value="c" @isComplete={{true}} />
          </S.List>
        </Stepper>
      </template>
    );

    assert.deepEqual(states(), ['upcoming', 'active', 'complete']);
  });

  test('@isLoading renders a spinner and sets aria-busy', async function (assert) {
    await render(
      <template>
        <Stepper @value="a" as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" @isLoading={{true}} data-test-step="a" />
            <S.Step @value="b" data-test-step="b" />
          </S.List>
        </Stepper>
      </template>
    );

    assert.dom('[data-test-step="a"]').hasAttribute('aria-busy', 'true');
    assert.dom('[data-test-step="a"] [data-component="spinner"]').exists();
    assert.dom('[data-test-step="b"]').doesNotHaveAttribute('aria-busy');
    assert
      .dom('[data-test-step="b"] [data-component="spinner"]')
      .doesNotExist();
  });

  test('@isInvalid sets data-invalid and adds screen-reader text', async function (assert) {
    await render(
      <template>
        <Stepper @value="a" as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" @isInvalid={{true}} data-test-step="a" />
            <S.Step @value="b" data-test-step="b" />
          </S.List>
        </Stepper>
      </template>
    );

    const [first, second] = findAll('[data-part="item"]') as HTMLElement[];
    assert.strictEqual(first?.dataset['invalid'], 'true');
    assert.strictEqual(second?.dataset['invalid'], 'false');
    assert.dom('[data-test-step="a"] .sr-only').hasText(/invalid/i);
    assert.dom('[data-test-step="b"] .sr-only').doesNotExist();
  });

  test('@icon renders in the indicator of an upcoming step', async function (assert) {
    const Icon: TOC<{ Element: SVGElement }> = <template>
      <svg data-test-icon ...attributes></svg>
    </template>;

    await render(
      <template>
        <Stepper @value="a" as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" />
            <S.Step @value="b" @icon={{Icon}} data-test-step="b" />
          </S.List>
        </Stepper>
      </template>
    );

    assert.dom('[data-test-step="b"] [data-test-icon]').exists();
  });

  test('a custom indicator block replaces the default indicator content', async function (assert) {
    await render(
      <template>
        <Stepper @value="a" as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" data-test-step="a">
              <:indicator>X</:indicator>
            </S.Step>
          </S.List>
        </Stepper>
      </template>
    );

    assert.dom('[data-test-step="a"] [data-part="indicator"]').hasText('X');
  });

  test('an invalid step is danger-colored even when it is also complete', async function (assert) {
    await render(
      <template>
        <Stepper @value="c" as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" @isInvalid={{true}} data-test-step="a" />
            <S.Step @value="b" data-test-step="b" />
            <S.Step @value="c" data-test-step="c" />
            <S.Step @value="d" @isInvalid={{true}} data-test-step="d" />
          </S.List>
        </Stepper>
      </template>
    );

    const background = (value: string): string =>
      getComputedStyle(
        find(`[data-test-step="${value}"] [data-part="indicator"]`) as Element
      ).backgroundColor;

    assert.strictEqual(
      background('a'),
      background('d'),
      'complete and invalid looks like upcoming and invalid'
    );
    assert.notStrictEqual(
      background('a'),
      background('b'),
      'and not like a valid complete step'
    );
  });
});

module('Integration | Component | Stepper | helpers', function (hooks) {
  setupRenderingTest(hooks);

  test('next moves to the next enabled step and fires onChange', async function (assert) {
    const calls: string[] = [];
    const onChange = (value: string) => calls.push(value);

    await render(
      <template>
        <Stepper @defaultValue="a" @onChange={{onChange}} as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" data-test-step="a" />
            <S.Step @value="b" data-test-step="b" />
          </S.List>
          <button
            type="button"
            data-test-next
            {{on "click" S.next}}
          >Next</button>
        </Stepper>
      </template>
    );

    await click('[data-test-next]');

    assert.dom('[data-test-step="b"]').hasAria('current', 'step');
    assert.deepEqual(calls, ['b']);
  });

  test('prev moves back, and next and prev skip disabled steps', async function (assert) {
    await render(
      <template>
        <Stepper @defaultValue="a" as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" data-test-step="a" />
            <S.Step @value="b" @isDisabled={{true}} data-test-step="b" />
            <S.Step @value="c" data-test-step="c" />
          </S.List>
          <button
            type="button"
            data-test-next
            {{on "click" S.next}}
          >Next</button>
          <button
            type="button"
            data-test-prev
            {{on "click" S.prev}}
          >Prev</button>
        </Stepper>
      </template>
    );

    await click('[data-test-next]');
    assert.dom('[data-test-step="c"]').hasAria('current', 'step');

    await click('[data-test-prev]');
    assert.dom('[data-test-step="a"]').hasAria('current', 'step');
  });

  test('goTo can reach a disabled step', async function (assert) {
    await render(
      <template>
        <Stepper @defaultValue="a" as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" data-test-step="a" />
            <S.Step @value="b" @isDisabled={{true}} data-test-step="b" />
          </S.List>
          <button
            type="button"
            data-test-go
            {{on "click" (fn S.goTo "b")}}
          >Go</button>
        </Stepper>
      </template>
    );

    await click('[data-test-go]');

    assert.dom('[data-test-step="b"]').hasAria('current', 'step');
  });

  test('hasNext and hasPrev reflect position', async function (assert) {
    await render(
      <template>
        <Stepper @defaultValue="a" as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" />
            <S.Step @value="b" />
          </S.List>
          <span data-test-has-next>{{S.hasNext}}</span>
          <span data-test-has-prev>{{S.hasPrev}}</span>
          <button
            type="button"
            data-test-next
            {{on "click" S.next}}
          >Next</button>
        </Stepper>
      </template>
    );

    assert.dom('[data-test-has-next]').hasText('true');
    assert.dom('[data-test-has-prev]').hasText('false');

    await click('[data-test-next]');

    assert.dom('[data-test-has-next]').hasText('false');
    assert.dom('[data-test-has-prev]').hasText('true');
  });

  test('controlled: helpers only call onChange', async function (assert) {
    const calls: string[] = [];
    const onChange = (value: string) => calls.push(value);

    await render(
      <template>
        <Stepper @value="a" @onChange={{onChange}} as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" data-test-step="a" />
            <S.Step @value="b" data-test-step="b" />
          </S.List>
          <button
            type="button"
            data-test-next
            {{on "click" S.next}}
          >Next</button>
        </Stepper>
      </template>
    );

    await click('[data-test-next]');

    assert.deepEqual(calls, ['b']);
    assert.dom('[data-test-step="a"]').hasAria('current', 'step');
  });

  test('next on the last step and prev on the first do not fire onChange', async function (assert) {
    const calls: string[] = [];
    const onChange = (value: string) => calls.push(value);

    await render(
      <template>
        <Stepper @defaultValue="a" @onChange={{onChange}} as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" />
            <S.Step @value="b" />
          </S.List>
          <button
            type="button"
            data-test-next
            {{on "click" S.next}}
          >Next</button>
          <button
            type="button"
            data-test-prev
            {{on "click" S.prev}}
          >Prev</button>
        </Stepper>
      </template>
    );

    await click('[data-test-prev]');
    assert.deepEqual(calls, [], 'prev on the first step does nothing');

    await click('[data-test-next]');
    await click('[data-test-next]');
    assert.deepEqual(calls, ['b'], 'next on the last step does nothing');
  });

  test('all steps disabled: no selection and next is a no-op', async function (assert) {
    const calls: string[] = [];
    const onChange = (value: string) => calls.push(value);

    await render(
      <template>
        <Stepper @onChange={{onChange}} as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" @isDisabled={{true}} />
            <S.Step @value="b" @isDisabled={{true}} />
          </S.List>
          <span data-test-has-next>{{S.hasNext}}</span>
          <button
            type="button"
            data-test-next
            {{on "click" S.next}}
          >Next</button>
        </Stepper>
      </template>
    );

    assert.dom('[aria-current]').doesNotExist();
    assert.dom('[data-test-has-next]').hasText('false');

    await click('[data-test-next]');

    assert.deepEqual(calls, []);
  });

  test('adding and removing steps updates hasNext', async function (assert) {
    const showB = cell(true);

    await render(
      <template>
        <Stepper @defaultValue="a" as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" />
            {{#if showB.current}}
              <S.Step @value="b" />
            {{/if}}
          </S.List>
          <span data-test-has-next>{{S.hasNext}}</span>
        </Stepper>
      </template>
    );

    assert.dom('[data-test-has-next]').hasText('true');

    showB.current = false;
    await settled();

    assert.dom('[data-test-has-next]').hasText('false');
    assert.dom('[data-part="step"]').exists({ count: 1 });
  });

  test('removing the selected step does not throw', async function (assert) {
    const showB = cell(true);

    await render(
      <template>
        <Stepper @value="b" as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" />
            {{#if showB.current}}
              <S.Step @value="b" />
            {{/if}}
          </S.List>
        </Stepper>
      </template>
    );

    assert.dom('[aria-current="step"]').exists();

    showB.current = false;
    await settled();

    assert.dom('[aria-current]').doesNotExist();
    assert.dom('[data-part="step"]').exists({ count: 1 });
  });
});

module('Integration | Component | Stepper | keyboard', function (hooks) {
  setupRenderingTest(hooks);

  test('arrow keys move focus without selecting', async function (assert) {
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

    await focus('[data-test-step="a"]');
    await triggerKeyEvent('[data-test-step="a"]', 'keydown', 'ArrowRight');

    assert.strictEqual(document.activeElement, find('[data-test-step="b"]'));
    assert.dom('[data-test-step="a"]').hasAria('current', 'step');
    assert.deepEqual(calls, []);
  });

  test('Enter and Space select the focused step', async function (assert) {
    const calls: string[] = [];
    const onChange = (value: string) => calls.push(value);

    await render(
      <template>
        <Stepper @defaultValue="a" @onChange={{onChange}} as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" data-test-step="a" />
            <S.Step @value="b" data-test-step="b" />
            <S.Step @value="c" data-test-step="c" />
          </S.List>
        </Stepper>
      </template>
    );

    await focus('[data-test-step="a"]');
    await triggerKeyEvent('[data-test-step="a"]', 'keydown', 'ArrowRight');
    await triggerKeyEvent('[data-test-step="b"]', 'keydown', 'Enter');
    assert.dom('[data-test-step="b"]').hasAria('current', 'step');

    await triggerKeyEvent('[data-test-step="b"]', 'keydown', 'ArrowRight');
    await triggerKeyEvent('[data-test-step="c"]', 'keydown', ' ');
    assert.dom('[data-test-step="c"]').hasAria('current', 'step');
    assert.deepEqual(calls, ['b', 'c']);
  });

  test('vertical orientation uses up and down arrows', async function (assert) {
    await render(
      <template>
        <Stepper @defaultValue="a" @orientation="vertical" as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" data-test-step="a" />
            <S.Step @value="b" data-test-step="b" />
          </S.List>
        </Stepper>
      </template>
    );

    await focus('[data-test-step="a"]');
    await triggerKeyEvent('[data-test-step="a"]', 'keydown', 'ArrowRight');
    assert.strictEqual(
      document.activeElement,
      find('[data-test-step="a"]'),
      'right arrow does nothing when vertical'
    );

    await triggerKeyEvent('[data-test-step="a"]', 'keydown', 'ArrowDown');
    assert.strictEqual(document.activeElement, find('[data-test-step="b"]'));
  });

  test('disabled steps are skipped by arrow keys', async function (assert) {
    await render(
      <template>
        <Stepper @defaultValue="a" as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" data-test-step="a" />
            <S.Step @value="b" @isDisabled={{true}} data-test-step="b" />
            <S.Step @value="c" data-test-step="c" />
          </S.List>
        </Stepper>
      </template>
    );

    await focus('[data-test-step="a"]');
    await triggerKeyEvent('[data-test-step="a"]', 'keydown', 'ArrowRight');

    assert.strictEqual(document.activeElement, find('[data-test-step="c"]'));
  });

  test('exactly one step is tabbable', async function (assert) {
    await render(
      <template>
        <Stepper @defaultValue="b" as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" data-test-step="a" />
            <S.Step @value="b" data-test-step="b" />
            <S.Step @value="c" data-test-step="c" />
          </S.List>
        </Stepper>
      </template>
    );

    assert.dom('[data-part="step"][tabindex="0"]').exists({ count: 1 });
    assert.dom('[data-test-step="b"]').hasAttribute('tabindex', '0');
    assert.dom('[data-test-step="a"]').hasAttribute('tabindex', '-1');
  });
});

module('Integration | Component | Stepper | panel', function (hooks) {
  setupRenderingTest(hooks);

  test('only the active panel renders', async function (assert) {
    await render(
      <template>
        <Stepper @defaultValue="a" as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" data-test-step="a" />
            <S.Step @value="b" data-test-step="b" />
          </S.List>
          <S.Panel @value="a">First</S.Panel>
          <S.Panel @value="b">Second</S.Panel>
        </Stepper>
      </template>
    );

    assert.dom('[data-part="panel"]').exists({ count: 1 });
    assert.dom('[data-part="panel"]').hasText('First');

    await click('[data-test-step="b"]');

    assert.dom('[data-part="panel"]').exists({ count: 1 });
    assert.dom('[data-part="panel"]').hasText('Second');
  });

  test('keepMounted keeps an inactive panel in the DOM with hidden, preserving its state', async function (assert) {
    await render(
      <template>
        <Stepper @defaultValue="a" as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" data-test-step="a" />
            <S.Step @value="b" data-test-step="b" />
          </S.List>
          <S.Panel @value="a" @keepMounted={{true}} data-test-panel="a">
            <input data-test-input />
          </S.Panel>
          <S.Panel @value="b" data-test-panel="b">Second</S.Panel>
        </Stepper>
      </template>
    );

    await fillIn('[data-test-input]', 'typed');
    await click('[data-test-step="b"]');

    assert.dom('[data-test-panel="a"]').exists();
    assert.dom('[data-test-panel="a"]').hasAttribute('hidden');
    assert.dom('[data-test-panel="b"]').doesNotHaveAttribute('hidden');

    await click('[data-test-step="a"]');

    assert.dom('[data-test-panel="a"]').doesNotHaveAttribute('hidden');
    assert.dom('[data-test-input]').hasValue('typed');
    assert.dom('[data-test-panel="b"]').doesNotExist('unmounted by default');
  });

  test('the panel is labelled by its step', async function (assert) {
    await render(
      <template>
        <Stepper @defaultValue="a" as |S|>
          <S.List @label="Checkout">
            <S.Step @value="a" data-test-step="a" />
          </S.List>
          <S.Panel @value="a">First</S.Panel>
        </Stepper>
      </template>
    );

    const step = find('[data-test-step="a"]') as HTMLElement;
    assert.dom('[data-part="panel"]').hasAttribute('role', 'region');
    assert.dom('[data-part="panel"]').hasAttribute('aria-labelledby', step.id);
  });
});

module('Integration | Component | Stepper | responsive', function (hooks) {
  setupRenderingTest(hooks);

  const Fixture: TOC<{
    Args: {
      style?: string;
      labelPosition?: 'end' | 'bottom';
      orientation?: 'horizontal' | 'vertical';
      collapseLabels?: boolean;
      size?: 'sm' | 'md' | 'lg';
    };
  }> = <template>
    <div style={{@style}}>
      <Stepper
        @value="b"
        @labelPosition={{@labelPosition}}
        @orientation={{@orientation}}
        @collapseLabels={{@collapseLabels}}
        @size={{@size}}
        as |S|
      >
        <S.List @label="Checkout">
          <S.Step @value="a" @title="Account" data-test-step="a" />
          <S.Step @value="b" @title="Billing" data-test-step="b" />
          <S.Step @value="c" @title="Review" data-test-step="c" />
          <S.Step @value="d" @title="Confirm" data-test-step="d" />
        </S.List>
      </Stepper>
    </div>
  </template>;

  // Layout sizes, not `getBoundingClientRect`: Ember's test container is
  // rendered at `transform: scale(0.5)`, which halves every rect but leaves
  // layout -- and so container queries -- untouched.
  //
  // The *label* is measured, not the title inside it: `sr-only` clips the
  // label to 1px, but a title that is not stretched (`items-center`) still has
  // its natural width inside the clipped box.
  const labelWidth = (root: ParentNode, step = 'a'): number =>
    (
      root.querySelector(
        `[data-test-step="${step}"] [data-part="label"]`
      ) as HTMLElement
    ).offsetWidth;

  const titleVisible = (): boolean => labelWidth(document) > 10;

  const summaryDisplay = (): string | undefined => {
    const summary = find('[data-part="summary"]');
    return summary ? getComputedStyle(summary).display : undefined;
  };

  test('narrow: titles are visually hidden and the summary is visible', async function (assert) {
    await render(<template><Fixture @style="width: 20rem" /></template>);

    assert.false(titleVisible(), 'title is visually hidden');
    assert.notStrictEqual(summaryDisplay(), 'none');
    assert.dom('[data-part="summary"]').includesText('Step 2 of 4');
    assert.dom('[data-part="summary"]').includesText('Billing');
    assert.dom('[data-part="summary"]').hasAttribute('aria-hidden', 'true');
  });

  test('collapsed titles stay in the accessibility tree', async function (assert) {
    await render(<template><Fixture @style="width: 20rem" /></template>);

    const title = find(
      '[data-test-step="a"] [data-part="title"]'
    ) as HTMLElement;
    assert.notStrictEqual(getComputedStyle(title).display, 'none');
    assert.notStrictEqual(getComputedStyle(title).visibility, 'hidden');
    assert.dom(title).hasText('Account');
  });

  test('labelPosition bottom shows titles from the bottom threshold', async function (assert) {
    await render(
      <template>
        <Fixture @style="width: 24rem" @labelPosition="bottom" />
        <Fixture @style="width: 30rem" @labelPosition="bottom" />
      </template>
    );

    const [narrow, wide] = findAll('[data-part="base"]') as HTMLElement[];

    assert.true(
      labelWidth(narrow as HTMLElement) <= 1,
      'collapsed below 28rem'
    );
    assert.true(labelWidth(wide as HTMLElement) > 10, 'visible from 28rem');
    assert.strictEqual(
      getComputedStyle(wide?.querySelector('[data-part="summary"]') as Element)
        .display,
      'none',
      'summary hides once titles show'
    );
  });

  test('labelPosition end shows titles from the end threshold, and stays collapsed between', async function (assert) {
    await render(
      <template>
        <Fixture @style="width: 30rem" />
        <Fixture @style="width: 44rem" />
      </template>
    );

    const [between, wide] = findAll('[data-part="base"]') as HTMLElement[];

    assert.true(
      labelWidth(between as HTMLElement) <= 1,
      'collapsed between the thresholds'
    );
    assert.true(labelWidth(wide as HTMLElement) > 10, 'visible from 42rem');
  });

  test('@collapseLabels={{false}} always shows titles and omits the summary', async function (assert) {
    await render(
      <template>
        <Fixture @style="width: 20rem" @collapseLabels={{false}} />
      </template>
    );

    assert.true(titleVisible());
    assert.dom('[data-part="summary"]').doesNotExist();
  });

  test('vertical always shows titles and has no summary', async function (assert) {
    await render(
      <template>
        <Fixture @style="width: 20rem" @orientation="vertical" />
      </template>
    );

    assert.true(titleVisible());
    assert.dom('[data-part="summary"]').doesNotExist();
  });

  test('the step hit area is at least 44px at every size', async function (assert) {
    await render(
      <template>
        <Fixture @style="width: 20rem" @size="sm" />
        <Fixture @style="width: 20rem" @size="md" />
        <Fixture @style="width: 20rem" @size="lg" />
      </template>
    );

    const steps = findAll('[data-test-step="a"]') as HTMLElement[];
    assert.strictEqual(steps.length, 3);
    for (const step of steps) {
      assert.true(step.offsetWidth >= 44, `width ${step.offsetWidth}`);
      assert.true(step.offsetHeight >= 44, `height ${step.offsetHeight}`);
    }
  });
});
