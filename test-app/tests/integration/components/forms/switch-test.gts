import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click, find, settled } from '@ember/test-helpers';

import { Switch } from 'frontile';
import { cell } from 'ember-resources';

module('Integration | Component | @frontile/forms/Switch', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders', async function (assert) {
    await render(<template><Switch @label="Name" /></template>);

    assert.dom('[data-component="label"]').hasText('Name');
    assert.dom('[data-component="switch"]').exists();
  });

  test('it renders html attributes', async function (assert) {
    await render(
      <template>
        <Switch @label="Name" @name="some-name" data-test-input />
      </template>
    );

    assert.dom('[data-test-input]').exists();
    assert.dom('[name="some-name"]').exists();
  });

  test('it should have id attr with matching label attr `for`', async function (assert) {
    await render(<template><Switch @label="Name" data-test-input /></template>);

    const el = find('[data-test-input]') as HTMLInputElement;
    const id = el.getAttribute('id') || '';

    assert.ok(/ember[1-9.]/.test(id), 'should have generated an id');

    assert.dom('[data-component="label"]').hasAttribute('for', id);
  });

  test('should mutate the value using onChange action (controlled)', async function (assert) {
    const mySwitchValue = cell(false);
    const updateValue = (value: boolean) => (mySwitchValue.current = value);

    await render(
      <template>
        <Switch
          data-test-input
          @label="Name"
          @isSelected={{mySwitchValue.current}}
          @onChange={{updateValue}}
        />
      </template>
    );

    assert.dom('[data-test-input]').isNotChecked();
    await click('[data-test-input]');

    assert.dom('[data-test-input]').isChecked();
    assert.equal(mySwitchValue.current, true, 'should have mutated the value');

    await click('[data-test-input]');
    assert.dom('[data-test-input]').isNotChecked();
    assert.equal(
      mySwitchValue.current,
      false,
      'should have mutated the value again'
    );
  });

  test('should mutate the value using onChange action (uncontrolled)', async function (assert) {
    let mySwitchValue = true;
    const updateValue = (value: boolean) => (mySwitchValue = value);

    await render(
      <template>
        <Switch
          data-test-input
          @label="Name"
          @defaultSelected={{true}}
          @onChange={{updateValue}}
        />
      </template>
    );

    assert.dom('[data-test-input]').isChecked();
    await click('[data-test-input]');

    assert.dom('[data-test-input]').isNotChecked();
    assert.equal(mySwitchValue, false, 'should have mutated the value');

    await click('[data-test-input]');
    assert.dom('[data-test-input]').isChecked();
    assert.equal(mySwitchValue, true, 'should have mutated the value again');
  });

  test('renders data attributes (uncontrolled)', async function (assert) {
    const disabled = cell(false);
    await render(
      <template>
        <Switch
          data-test-input
          @isDisabled={{disabled.current}}
          @label="Name"
          @defaultSelected={{true}}
        />
      </template>
    );

    assert.dom('[data-test-input]').isChecked();
    assert
      .dom('[data-component="switch"]')
      .hasAttribute('data-selected', 'true');
    assert
      .dom('[data-component="switch"]')
      .hasAttribute('data-disabled', 'false');

    await click('[data-test-input]');

    assert.dom('[data-test-input]').isNotChecked();
    assert
      .dom('[data-component="switch"]')
      .hasAttribute('data-selected', 'false');

    disabled.current = true;
    await settled();

    assert
      .dom('[data-component="switch"]')
      .hasAttribute('data-disabled', 'true');
  });

  test('it renders content blocks', async function (assert) {
    await render(
      <template>
        <Switch data-test-input @label="Name">
          <:startContent>Start</:startContent>
          <:thumbContent as |o|>T: {{o.isSelected}}</:thumbContent>
          <:endContent>End</:endContent>
        </Switch>
      </template>
    );

    assert.dom('[data-test-id="switch-start-content"]').hasText('Start');
    assert.dom('[data-test-id="switch-end-content"]').hasText('End');
    assert.dom('[data-test-id="switch-thumb-content"]').hasText('T: false');

    await click('[data-test-input]');
    assert.dom('[data-test-id="switch-thumb-content"]').hasText('T: true');
  });

  test('show error messages when errors has items', async function (assert) {
    const errors = cell<string[]>([]);
    await render(
      <template>
        <div class="my-container">
          <Switch data-test-input @errors={{errors.current}} @label="Name" />
        </div>
      </template>
    );

    assert.dom('[data-test-input]').doesNotHaveAttribute('aria-invalid');

    errors.current = ['This field is required'];
    await settled();

    assert.dom('[data-test-input]').hasAttribute('aria-invalid');
    assert
      .dom('[data-component="form-feedback"]')
      .hasText('This field is required');
  });

  test('do not show error messages if errors has no elements', async function (assert) {
    await render(
      <template>
        <div class="my-container">
          <Switch data-test-input @label="Name" />
        </div>
      </template>
    );

    assert.dom('[data-test-input]').doesNotHaveAttribute('aria-invalid');
    assert.dom('[data-component="form-feedback"]').doesNotExist();
  });

  test('it add classes to all slots', async function (assert) {
    const classes = {
      base: 'my-base-class',
      wrapper: 'my-wrapper-class',
      labelContainer: 'my-label-container-class',
      hiddenInput: 'my-hidden-input-class',
      startContent: 'my-start-content-class',
      endContent: 'my-end-content-class',
      label: 'my-label-class'
    };
    await render(
      <template>
        <Switch @label="Cool" @classes={{classes}}>
          <:startContent>S</:startContent>
          <:endContent>E</:endContent>
        </Switch>
      </template>
    );

    assert.dom('.my-base-class').exists();
    assert.dom('.my-wrapper-class').exists();
    assert.dom('.my-label-container-class').exists();
    assert.dom('.my-label-class').exists();
    assert.dom('.my-hidden-input-class').exists();
    assert.dom('.my-start-content-class').exists();
    assert.dom('.my-end-content-class').exists();
  });
  // Regression: Tailwind v4 compiles `translate-x-*` to the standalone CSS
  // `translate` property and `scale-*` to `scale` -- not to `transform`. The
  // Switch theme used `transition-transform-opacity` and
  // `transition-background`, neither of which is a real Tailwind v4 utility,
  // so they compiled to nothing at all and every one of these elements changed
  // state in a single frame.
  //
  // These assertions read the *computed* transition and the transitions the
  // browser actually starts. A class-presence assertion passes happily while
  // the component is broken -- the class string was there the whole time.
  //
  // Note: `transition-property` computes to `all` even with no transition
  // utility at all (that is its CSS initial value), so merely finding the
  // property in the list proves nothing. What separates a real transition from
  // none is a non-zero *duration* for that property.
  test('each animated slot transitions the property it actually changes', async function (assert) {
    const isSelected = cell(false);

    await render(
      <template>
        <Switch @label="Airplane mode" @isSelected={{isSelected.current}}>
          <:startContent>S</:startContent>
          <:endContent>E</:endContent>
        </Switch>
      </template>
    );

    const wrapper = find('[data-component="switch"] > span') as HTMLElement;
    const thumb = find('[data-test-id="switch-thumb-content"]') as HTMLElement;
    const startContent = find(
      '[data-test-id="switch-start-content"]'
    ) as HTMLElement;
    const endContent = find(
      '[data-test-id="switch-end-content"]'
    ) as HTMLElement;

    // The duration the browser will actually use for `property` on `el`, in
    // seconds. Zero means the element does not transition it, whatever the
    // class string says.
    const durationFor = (el: HTMLElement, property: string): number => {
      const computed = window.getComputedStyle(el);
      const properties = computed.transitionProperty
        .split(',')
        .map((entry) => entry.trim());
      const durations = computed.transitionDuration
        .split(',')
        .map((entry) => entry.trim());

      let seconds = 0;
      properties.forEach((entry, index) => {
        if (entry !== property && entry !== 'all') {
          return;
        }
        // transition-duration repeats to cover a longer property list.
        const duration = durations[index % durations.length] ?? '0s';
        seconds = Math.max(seconds, parseFloat(duration) || 0);
      });
      return seconds;
    };

    const describe = (el: HTMLElement): string => {
      const computed = window.getComputedStyle(el);
      return `${computed.transitionProperty} / ${computed.transitionDuration}`;
    };

    // The property an element's geometry is actually written to. Tailwind v4
    // puts `translate-x-*` on `translate` and `scale-*` on `scale`, so a
    // transition naming only `transform` never fires.
    const geometryProperty = (el: HTMLElement, fallback: string): string => {
      const computed = window.getComputedStyle(el) as unknown as Record<
        string,
        string
      >;
      for (const property of ['translate', 'scale']) {
        const value = computed[property];
        if (value && value !== 'none') {
          return property;
        }
      }
      return fallback;
    };

    // The wrapper's fill changes via `group-data-[selected=true]:bg-*`.
    assert.ok(
      durationFor(wrapper, 'background-color') > 0,
      `wrapper transitions background-color (${describe(wrapper)})`
    );

    // The thumb slides with `ms-*` (margin-inline-start).
    assert.ok(
      durationFor(thumb, 'margin-inline-start') > 0,
      `thumb transitions margin-inline-start (${describe(thumb)})`
    );

    // startContent scales in (`scale-50` -> `scale-100`) and fades.
    const startProperty = geometryProperty(startContent, 'scale');
    assert.ok(
      durationFor(startContent, startProperty) > 0,
      `startContent transitions the property it is scaled with (${startProperty}; ${describe(startContent)})`
    );
    assert.ok(
      durationFor(startContent, 'opacity') > 0,
      `startContent transitions opacity (${describe(startContent)})`
    );

    // endContent slides out with `translate-x-3` and fades.
    assert.ok(
      durationFor(endContent, 'opacity') > 0,
      `endContent transitions opacity (${describe(endContent)})`
    );

    // Reading the computed styles above also establishes the before-change
    // style, so the browser has something to transition *from*.
    isSelected.current = true;
    await settled();

    const endProperty = geometryProperty(endContent, 'translate');
    assert.ok(
      durationFor(endContent, endProperty) > 0,
      `endContent transitions the property it is moved with (${endProperty}; ${describe(endContent)})`
    );

    // getAnimations() flushes pending style changes, so the transitions started
    // by the selection change are observable here. Only a CSSTransition carries
    // `transitionProperty`, which is enough to pick them out.
    const runningOn = (el: HTMLElement): string[] =>
      el
        .getAnimations()
        .map(
          (animation) =>
            (animation as Animation & { transitionProperty?: string })
              .transitionProperty
        )
        .filter((property): property is string => typeof property === 'string');

    const endRunning = runningOn(endContent);
    assert.ok(
      endRunning.includes(endProperty),
      `toggling starts a transition on ${endProperty} for endContent (running: ${endRunning.join(', ') || 'none'})`
    );

    const wrapperRunning = runningOn(wrapper);
    assert.ok(
      wrapperRunning.includes('background-color'),
      `toggling starts a background-color transition on the wrapper (running: ${wrapperRunning.join(', ') || 'none'})`
    );
  });
});
