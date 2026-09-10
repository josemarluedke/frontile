import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find, settled, waitUntil } from '@ember/test-helpers';
import { dragToDismiss } from 'frontile/modifiers/drag-to-dismiss';

// jsdom-free helper: dispatch a real PointerEvent on the element. Chrome
// supports the constructor; `pointerId` is what setPointerCapture keys on, and
// a synthetic id will make capture throw — the modifier guards that.
//
// Returns `dispatchEvent`'s own boolean: `false` means some listener called
// `preventDefault()` on this (cancelable) event -- the reliable way to check,
// since checking `event.defaultPrevented` from a listener on the same target
// can run *before* an ancestor's listener (e.g. the modifier's, on a parent
// element) gets a chance to call it during the bubble phase.
function pointer(
  el: Element,
  type: 'pointerdown' | 'pointermove' | 'pointerup' | 'pointercancel',
  x: number,
  y: number
): boolean {
  return el.dispatchEvent(
    new PointerEvent(type, {
      bubbles: true,
      cancelable: true,
      pointerId: 1,
      isPrimary: true,
      button: 0,
      buttons: type === 'pointerup' || type === 'pointercancel' ? 0 : 1,
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

  test('a press on the scroll container that moves away from the dismiss direction never claims the gesture and never preventDefaults', async function (assert) {
    const onDismiss = () => {
      assert.notOk(true, 'onDismiss must not fire');
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
            scrollSelector="[data-test-id='scroller']"
          }}
        >
          <div data-test-id="scroller" style="height: 100%; overflow-y: auto;">
            content
          </div>
        </div>
      </template>
    );

    const scroller = find("[data-test-id='scroller']")!;
    const panel = find("[data-test-id='panel']") as HTMLElement;

    // Content is shorter than the scroller, so it's always "at the edge" --
    // this is exactly the case that used to hijack every touch. Direction 1
    // dismisses downward; move upward instead (away from the dismiss
    // direction), past the claim threshold.
    pointer(scroller, 'pointerdown', 0, 0);
    const notCancelled = pointer(scroller, 'pointermove', 0, -40);
    pointer(scroller, 'pointerup', 0, -40);
    await settled();

    assert.strictEqual(
      panel.style.transform,
      '',
      'the panel was never dragged'
    );
    assert.true(
      notCancelled,
      'preventDefault was never called, so native scrolling stayed live'
    );
  });

  test('a press on the scroll container that moves toward the dismiss direction past the claim threshold still dismisses', async function (assert) {
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
            scrollSelector="[data-test-id='scroller']"
          }}
        >
          <div data-test-id="scroller" style="height: 100%; overflow-y: auto;">
            content
          </div>
        </div>
      </template>
    );

    const scroller = find("[data-test-id='scroller']")!;

    // Still at the scroll edge (content shorter than container), but now
    // moving down (toward the dismiss direction) well past both the claim
    // threshold and the 25% distance threshold.
    pointer(scroller, 'pointerdown', 0, 0);
    pointer(scroller, 'pointermove', 0, 80);
    pointer(scroller, 'pointerup', 0, 80);

    await waitUntil(() => dismissed === 1);
    await settled();

    assert.strictEqual(dismissed, 1, 'onDismiss fired once');
  });

  test('a press on the scroll container below the claim threshold does not preventDefault', async function (assert) {
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
            scrollSelector="[data-test-id='scroller']"
          }}
        >
          <div data-test-id="scroller" style="height: 100%; overflow-y: auto;">
            content
          </div>
        </div>
      </template>
    );

    const scroller = find("[data-test-id='scroller']")!;

    pointer(scroller, 'pointerdown', 0, 0);
    const notCancelled = pointer(scroller, 'pointermove', 0, 4); // well under CLAIM_THRESHOLD_PX
    pointer(scroller, 'pointerup', 0, 4);
    await settled();

    assert.true(
      notCancelled,
      'a tiny move below the claim threshold is left alone'
    );
  });

  test('a drag is refused while the scroll container is still settling', async function (assert) {
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
            scrollSelector="[data-test-id='scroller']"
          }}
        >
          <div data-test-id="scroller" style="height: 100%; overflow-y: auto;">
            content
          </div>
        </div>
      </template>
    );

    const scroller = find("[data-test-id='scroller']")!;

    // A fling that decelerates to rest against the edge leaves the scroller
    // reporting "at the edge", so without a lock the very next press reads as
    // a dismiss drag. This drag would otherwise dismiss outright: it is along
    // the axis, toward the dismiss direction, and past the 25% threshold.
    scroller.dispatchEvent(new Event('scroll', { bubbles: false }));
    pointer(scroller, 'pointerdown', 0, 0);
    pointer(scroller, 'pointermove', 0, 80);
    pointer(scroller, 'pointerup', 0, 80);

    await new Promise((resolve) => setTimeout(resolve, 400));
    await settled();

    assert.strictEqual(dismissed, 0, 'the drag was refused while settling');

    // Once the lock has expired the identical gesture is honoured again, so
    // the lock delays the gesture rather than disabling it.
    await new Promise((resolve) => setTimeout(resolve, 200));

    pointer(scroller, 'pointerdown', 0, 0);
    pointer(scroller, 'pointermove', 0, 80);
    pointer(scroller, 'pointerup', 0, 80);

    await waitUntil(() => dismissed === 1);
    await settled();

    assert.strictEqual(dismissed, 1, 'the same drag dismissed once settled');
  });

  test('a short but fast flick dismisses on velocity alone', async function (assert) {
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

    // 40px is well under the distance threshold (25% of 200px = 50px), so a
    // dismiss here can only come from the velocity path. Real time has to
    // pass between the events: PointerEvent.timeStamp is set by the browser,
    // and without a gap the elapsed time falls under MIN_VELOCITY_ELAPSED_MS
    // and velocity() deliberately reports zero.
    pointer(handle, 'pointerdown', 0, 0);
    await new Promise((resolve) => setTimeout(resolve, 20));
    pointer(handle, 'pointermove', 0, 40);
    pointer(handle, 'pointerup', 0, 40);

    await waitUntil(() => dismissed === 1);
    await settled();

    assert.strictEqual(dismissed, 1, 'the flick dismissed on velocity');
  });

  test('a pause before release does not count toward velocity', async function (assert) {
    let dismissed = 0;
    const onDismiss = () => {
      dismissed += 1;
    };

    await render(
      <template>
        <div
          data-test-id="panel"
          style="height: 600px; width: 200px;"
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

    // 100px stays under the distance threshold (25% of 600px = 150px), so
    // only velocity could dismiss here. The pointer then rests well past the
    // trailing window before lifting, and holding still is not a flick.
    //
    // The numbers are chosen so this discriminates. Averaging the whole
    // gesture -- 100px over the ~170ms since pointerdown -- yields 0.59px/ms,
    // over the 0.4 threshold, so a velocity() that reuses the first sample
    // dismisses here. Re-windowing against the release finds no sample in the
    // trailing 100ms and correctly reports no recent motion at all.
    pointer(handle, 'pointerdown', 0, 0);
    await new Promise((resolve) => setTimeout(resolve, 20));
    pointer(handle, 'pointermove', 0, 100);
    await new Promise((resolve) => setTimeout(resolve, 150));
    pointer(handle, 'pointerup', 0, 100);

    // Wait past the exit animation's own timeout (SETTLE_MS + 50) before
    // asserting. A commit defers onDismiss until that fires, and `settled()`
    // does not wait on a raw setTimeout -- so asserting immediately would
    // report zero dismissals even when one had been scheduled.
    await new Promise((resolve) => setTimeout(resolve, 400));
    await settled();

    assert.strictEqual(dismissed, 0, 'a held pointer did not dismiss');
  });

  test('prefers-reduced-motion dismisses without an exit animation', async function (assert) {
    let dismissed = 0;
    const onDismiss = () => {
      dismissed += 1;
    };

    const originalMatchMedia = window.matchMedia;
    window.matchMedia = ((query: string) =>
      ({
        matches: query.includes('prefers-reduced-motion'),
        media: query
      }) as MediaQueryList) as typeof window.matchMedia;

    try {
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
      pointer(handle, 'pointermove', 0, 80);
      pointer(handle, 'pointerup', 0, 80);

      // No waitUntil: under reduced motion the dismiss is immediate rather
      // than deferred until an exit animation finishes.
      assert.strictEqual(dismissed, 1, 'onDismiss fired synchronously');
      assert.notOk(
        panel.style.transition.includes('transform'),
        `no exit transition was set (transition: "${panel.style.transition}")`
      );
    } finally {
      window.matchMedia = originalMatchMedia;
    }

    await settled();
  });

  test('pointercancel on a pending (unclaimed) gesture resets cleanly without dismissing', async function (assert) {
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
            scrollSelector="[data-test-id='scroller']"
          }}
        >
          <div data-test-id="scroller" style="height: 100%; overflow-y: auto;">
            content
          </div>
        </div>
      </template>
    );

    const scroller = find("[data-test-id='scroller']")!;
    const panel = find("[data-test-id='panel']") as HTMLElement;

    // A small move that hasn't crossed the claim threshold yet, then the
    // browser takes over (as it would once it recognizes a native scroll)
    // and fires pointercancel instead of pointerup.
    pointer(scroller, 'pointerdown', 0, 0);
    pointer(scroller, 'pointermove', 0, 4);
    pointer(scroller, 'pointercancel', 0, 4);
    await settled();

    assert.strictEqual(dismissed, 0, 'onDismiss did not fire');
    assert.strictEqual(
      panel.style.transform,
      '',
      'the panel was never dragged'
    );

    // A fresh gesture afterwards must still work normally.
    pointer(scroller, 'pointerdown', 0, 0);
    pointer(scroller, 'pointermove', 0, 80);
    pointer(scroller, 'pointerup', 0, 80);

    await waitUntil(() => dismissed === 1);
    await settled();

    assert.strictEqual(dismissed, 1, 'a later gesture still dismisses');
  });
});
