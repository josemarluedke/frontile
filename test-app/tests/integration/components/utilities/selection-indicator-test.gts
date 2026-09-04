import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, settled, find } from '@ember/test-helpers';
import { SelectionIndicator } from 'frontile';
import { cell } from 'ember-resources';

function nextFrame(): Promise<void> {
  return new Promise((resolve) => requestAnimationFrame(() => resolve()));
}

module(
  'Integration | Utility | selection-indicator | @frontile/utilities',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it writes the selected target geometry as custom properties', async function (assert) {
      const indicator = new SelectionIndicator();
      const aSelected = cell(false);
      const bSelected = cell(true);

      await render(
        <template>
          <div
            data-test-container
            style="position: relative; width: 300px;"
            {{indicator.setupContainer}}
          >
            <div
              data-test-item="a"
              style="display: inline-block; width: 100px; height: 40px;"
              {{indicator.setupTarget aSelected.current}}
            >A</div>
            <div
              data-test-item="b"
              style="display: inline-block; width: 120px; height: 40px;"
              {{indicator.setupTarget bSelected.current}}
            >B</div>
          </div>
        </template>
      );

      const container = find('[data-test-container]') as HTMLElement;
      const b = find('[data-test-item="b"]') as HTMLElement;

      assert.strictEqual(
        container.style.getPropertyValue('--fr-si-width'),
        `${b.offsetWidth}px`,
        'width tracks the selected target'
      );
      assert.strictEqual(
        container.style.getPropertyValue('--fr-si-x'),
        `${b.offsetLeft}px`,
        'x tracks the selected target'
      );

      aSelected.current = true;
      bSelected.current = false;
      await settled();

      const a = find('[data-test-item="a"]') as HTMLElement;
      assert.strictEqual(
        container.style.getPropertyValue('--fr-si-width'),
        `${a.offsetWidth}px`,
        'width follows selection to the new target'
      );
      assert.strictEqual(
        container.style.getPropertyValue('--fr-si-x'),
        `${a.offsetLeft}px`,
        'x follows selection to the new target'
      );
    });

    test('it stays un-ready until the first real measurement', async function (assert) {
      const indicator = new SelectionIndicator();

      await render(
        <template>
          <div
            data-test-container
            style="position: relative;"
            {{indicator.setupContainer}}
          >
            <div
              data-test-item
              style="width: 80px; height: 30px;"
              {{indicator.setupTarget true}}
            >A</div>
          </div>
        </template>
      );

      const container = find('[data-test-container]') as HTMLElement;
      assert.ok(
        container.hasAttribute('data-fr-si-ready'),
        'ready once a real measurement has landed and a frame has passed'
      );
    });

    test('a hidden container publishes no geometry and stays un-ready', async function (assert) {
      const indicator = new SelectionIndicator();

      await render(
        <template>
          <div data-test-outer style="display: none;">
            <div
              data-test-container
              style="position: relative;"
              {{indicator.setupContainer}}
            >
              <div
                style="width: 80px; height: 30px;"
                {{indicator.setupTarget true}}
              >A</div>
            </div>
          </div>
        </template>
      );

      const container = find('[data-test-container]') as HTMLElement;
      assert.notOk(
        container.hasAttribute('data-fr-si-ready'),
        'a zero-size measurement never marks the indicator ready'
      );
      assert.strictEqual(
        container.style.getPropertyValue('--fr-si-width'),
        '',
        'no width is published for a hidden container'
      );
    });

    test('with no selected target it publishes nothing and is not ready', async function (assert) {
      const indicator = new SelectionIndicator();

      await render(
        <template>
          <div
            data-test-container
            style="position: relative;"
            {{indicator.setupContainer}}
          >
            <div
              style="width: 80px; height: 30px;"
              {{indicator.setupTarget false}}
            >A</div>
          </div>
        </template>
      );

      const container = find('[data-test-container]') as HTMLElement;
      assert.notOk(container.hasAttribute('data-fr-si-ready'), 'not ready');
      assert.strictEqual(
        container.style.getPropertyValue('--fr-si-x'),
        '',
        'no geometry published'
      );
    });

    test('it recomputes when the container resizes', async function (assert) {
      const indicator = new SelectionIndicator();
      const width = cell('300px');

      await render(
        <template>
          <div
            data-test-container
            style="position: relative; width: {{width.current}};"
            {{indicator.setupContainer}}
          >
            <div
              data-test-item
              style="width: 50%; height: 30px;"
              {{indicator.setupTarget true}}
            >A</div>
          </div>
        </template>
      );

      const container = find('[data-test-container]') as HTMLElement;
      const before = container.style.getPropertyValue('--fr-si-width');

      width.current = '500px';
      await settled();
      // ResizeObserver delivers off the microtask queue, which `settled()`
      // does not await; give it a frame.
      await nextFrame();
      await nextFrame();

      assert.notStrictEqual(
        container.style.getPropertyValue('--fr-si-width'),
        before,
        'geometry is recomputed after the container resizes'
      );
    });
  }
);
