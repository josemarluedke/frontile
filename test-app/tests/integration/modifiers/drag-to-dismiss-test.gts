import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find, settled, waitUntil } from '@ember/test-helpers';
import { dragToDismiss } from 'frontile/modifiers/drag-to-dismiss';

// jsdom-free helper: dispatch a real PointerEvent on the element. Chrome
// supports the constructor; `pointerId` is what setPointerCapture keys on, and
// a synthetic id will make capture throw — the modifier guards that.
function pointer(
  el: Element,
  type: 'pointerdown' | 'pointermove' | 'pointerup',
  x: number,
  y: number
): void {
  el.dispatchEvent(
    new PointerEvent(type, {
      bubbles: true,
      cancelable: true,
      pointerId: 1,
      isPrimary: true,
      button: 0,
      buttons: type === 'pointerup' ? 0 : 1,
      clientX: x,
      clientY: y
    })
  );
}

module('Integration | Modifier | dragToDismiss', function (hooks) {
  setupRenderingTest(hooks);

  test('it dismisses when dragged past the distance threshold', async function (assert) {
    let dismissed = 0;
    const onDismiss = () => {
      dismissed += 1;
    };

    await render(
      <template>
        <div
          data-test-id="panel"
          style="height: 200px; width: 200px;"
          {{dragToDismiss
            axis="y"
            direction=1
            isEnabled=true
            onDismiss=onDismiss
            handleSelector="[data-test-id='handle']"
          }}
        >
          <div data-test-id="handle" style="height: 20px;"></div>
        </div>
      </template>
    );

    const handle = find("[data-test-id='handle']")!;
    pointer(handle, 'pointerdown', 0, 0);
    pointer(handle, 'pointermove', 0, 80); // 80 > 25% of 200
    pointer(handle, 'pointerup', 0, 80);

    // onDismiss is deferred until the exit animation finishes (transitionend
    // or its setTimeout fallback), not fired synchronously on pointerup —
    // await settled() does not wait for a raw setTimeout, so poll instead.
    await waitUntil(() => dismissed === 1);
    await settled();

    assert.strictEqual(dismissed, 1, 'onDismiss fired once');
  });

  test('it springs back when dragged under the threshold', async function (assert) {
    let dismissed = 0;
    const onDismiss = () => {
      dismissed += 1;
    };

    await render(
      <template>
        <div
          data-test-id="panel"
          style="height: 200px; width: 200px;"
          {{dragToDismiss
            axis="y"
            direction=1
            isEnabled=true
            onDismiss=onDismiss
            handleSelector="[data-test-id='handle']"
          }}
        >
          <div data-test-id="handle" style="height: 20px;"></div>
        </div>
      </template>
    );

    const handle = find("[data-test-id='handle']")!;
    const panel = find("[data-test-id='panel']") as HTMLElement;
    pointer(handle, 'pointerdown', 0, 0);
    pointer(handle, 'pointermove', 0, 10); // 10 < 25% of 200
    assert.ok(
      panel.style.transform.includes('10'),
      'tracks the pointer during the drag'
    );

    pointer(handle, 'pointerup', 0, 10);
    await settled();

    assert.strictEqual(dismissed, 0, 'onDismiss did not fire');
  });

  test('it ignores drags when disabled', async function (assert) {
    let dismissed = 0;
    const onDismiss = () => {
      dismissed += 1;
    };

    await render(
      <template>
        <div
          data-test-id="panel"
          style="height: 200px; width: 200px;"
          {{dragToDismiss
            axis="y"
            direction=1
            isEnabled=false
            onDismiss=onDismiss
            handleSelector="[data-test-id='handle']"
          }}
        >
          <div data-test-id="handle" style="height: 20px;"></div>
        </div>
      </template>
    );

    const handle = find("[data-test-id='handle']")!;
    pointer(handle, 'pointerdown', 0, 0);
    pointer(handle, 'pointermove', 0, 150);
    pointer(handle, 'pointerup', 0, 150);
    await settled();

    assert.strictEqual(dismissed, 0, 'onDismiss did not fire');
  });

  test('a drag away from the dismiss direction is damped', async function (assert) {
    const onDismiss = () => {};

    await render(
      <template>
        <div
          data-test-id="panel"
          style="height: 200px; width: 200px;"
          {{dragToDismiss
            axis="y"
            direction=1
            isEnabled=true
            onDismiss=onDismiss
            handleSelector="[data-test-id='handle']"
          }}
        >
          <div data-test-id="handle" style="height: 20px;"></div>
        </div>
      </template>
    );

    const handle = find("[data-test-id='handle']")!;
    const panel = find("[data-test-id='panel']") as HTMLElement;
    pointer(handle, 'pointerdown', 0, 0);
    pointer(handle, 'pointermove', 0, -100);

    const match = /translateY\((-?[\d.]+)px\)/.exec(panel.style.transform);
    assert.ok(match, 'a transform was applied');
    assert.ok(
      Math.abs(Number(match![1])) < 30,
      `damped to ${match![1]}px, well under the raw 100px`
    );

    pointer(handle, 'pointerup', 0, -100);
    await settled();
  });

  test('it free-drags on the whole element when no selectors are configured', async function (assert) {
    let dismissed = 0;
    const onDismiss = () => {
      dismissed += 1;
    };

    await render(
      <template>
        <div
          data-test-id="panel"
          style="height: 200px; width: 200px;"
          {{dragToDismiss
            axis="y"
            direction=1
            isEnabled=true
            onDismiss=onDismiss
          }}
        >
        </div>
      </template>
    );

    const panel = find("[data-test-id='panel']")!;
    pointer(panel, 'pointerdown', 0, 0);
    pointer(panel, 'pointermove', 0, 80); // 80 > 25% of 200
    pointer(panel, 'pointerup', 0, 80);

    await waitUntil(() => dismissed === 1);
    await settled();

    assert.strictEqual(dismissed, 1, 'onDismiss fired once');
  });

  test('on commit, the exit animation continues from the released offset (never back toward 0) and onDismiss fires only once it finishes', async function (assert) {
    let dismissed = 0;
    let transformWhenDismissed: string | undefined;
    const onDismiss = () => {
      dismissed += 1;
      const el = find("[data-test-id='panel']") as HTMLElement;
      transformWhenDismissed = el.style.transform;
    };

    await render(
      <template>
        <div
          data-test-id="panel"
          style="height: 200px; width: 200px;"
          {{dragToDismiss
            axis="y"
            direction=1
            isEnabled=true
            onDismiss=onDismiss
            handleSelector="[data-test-id='handle']"
          }}
        >
          <div data-test-id="handle" style="height: 20px;"></div>
        </div>
      </template>
    );

    const handle = find("[data-test-id='handle']")!;
    const panel = find("[data-test-id='panel']") as HTMLElement;

    pointer(handle, 'pointerdown', 0, 0);
    pointer(handle, 'pointermove', 0, 80); // 80 > 25% of 200, commits
    pointer(handle, 'pointerup', 0, 80);

    // Immediately after pointerup, onDismiss must not have fired yet — it is
    // deferred until the exit animation completes — and the transform must
    // not have snapped back toward 0: it should be at or beyond the released
    // 80px offset, continuing the gesture rather than reversing it.
    const matchAfterRelease = /translateY\((-?[\d.]+)px\)/.exec(
      panel.style.transform
    );
    assert.ok(matchAfterRelease, 'a transform is present right after release');
    assert.ok(
      Number(matchAfterRelease![1]) >= 80,
      `transform does not fall back below the released offset, got "${panel.style.transform}"`
    );
    assert.strictEqual(dismissed, 0, 'onDismiss has not fired yet');

    await waitUntil(() => dismissed === 1);
    await settled();

    assert.strictEqual(
      dismissed,
      1,
      'onDismiss fires once the exit animation completes'
    );

    const matchAtDismiss = transformWhenDismissed
      ? /translateY\((-?[\d.]+)px\)/.exec(transformWhenDismissed)
      : null;
    assert.ok(
      matchAtDismiss && Number(matchAtDismiss[1]) >= 80,
      `onDismiss saw the transform still at/beyond the released offset, got "${transformWhenDismissed}"`
    );
  });
});
