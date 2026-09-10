import { module, test } from 'qunit';
import {
  afterFirstPaint,
  shouldDeferMount,
  shouldSkipEnterTransition,
  withoutEnterTransition,
  INERT_ENTER_TRANSITION,
  type MountAnimationState
} from 'frontile/components/overlays/mount-animation';

// The situation this feature exists for: an overlay that is already open the
// first time it renders, in a real browser, with animations on.
const openAtMount: MountAnimationState = {
  isFirstOpen: true,
  animationsEnabled: true,
  animateOnMount: undefined,
  canWaitForFrame: true,
  hasPainted: false
};

module('Unit | Overlays | mount-animation', function () {
  module('shouldDeferMount', function () {
    test('defers an overlay that renders already open', function (assert) {
      assert.true(shouldDeferMount(openAtMount));
    });

    test('does not defer an overlay that opens later', function (assert) {
      assert.false(
        shouldDeferMount({ ...openAtMount, isFirstOpen: false }),
        'an overlay opened by interaction already animates against a painted page'
      );
    });

    test('does not defer when animations are off', function (assert) {
      assert.false(
        shouldDeferMount({ ...openAtMount, animationsEnabled: false }),
        'nothing to wait for, and tests would see a frame of empty DOM'
      );
    });

    test('does not defer when the mount animation is opted out of', function (assert) {
      assert.false(
        shouldDeferMount({ ...openAtMount, animateOnMount: false }),
        'skipping the animation means rendering immediately, not later'
      );
    });

    test('does not defer without a frame to wait for', function (assert) {
      assert.false(
        shouldDeferMount({ ...openAtMount, canWaitForFrame: false }),
        'no requestAnimationFrame (prerender) means no paint to wait for'
      );
    });

    test('animateOnMount={{true}} is the default, not an override', function (assert) {
      assert.true(shouldDeferMount({ ...openAtMount, animateOnMount: true }));
    });

    test('does not defer once the page has painted', function (assert) {
      assert.false(
        shouldDeferMount({ ...openAtMount, hasPainted: true }),
        'a boot slow enough to render after the page appeared is already visible'
      );
    });
  });

  module('shouldSkipEnterTransition', function () {
    test('skips only when opted out while mounting open', function (assert) {
      assert.true(
        shouldSkipEnterTransition({ ...openAtMount, animateOnMount: false })
      );
      assert.false(
        shouldSkipEnterTransition(openAtMount),
        'the default animates'
      );
      assert.false(
        shouldSkipEnterTransition({
          ...openAtMount,
          isFirstOpen: false,
          animateOnMount: false
        }),
        'an overlay opened by interaction is not a mount, so it still animates'
      );
    });

    test('is irrelevant when animations are already off', function (assert) {
      assert.false(
        shouldSkipEnterTransition({
          ...openAtMount,
          animationsEnabled: false,
          animateOnMount: false
        })
      );
    });

    test('opting out still skips after the page has painted', function (assert) {
      assert.true(
        shouldSkipEnterTransition({
          ...openAtMount,
          hasPainted: true,
          animateOnMount: false
        }),
        'the opt-out is about the mount, not about when the mount happens'
      );
    });
  });

  module('afterFirstPaint', function (hooks) {
    // The page under test has already painted, so a `buffered: true` paint
    // observer resolves immediately -- which is exactly the ordering that used
    // to strand the wait: it cancelled its own timeout and then waited on a
    // frame.
    let restoreFrame: (() => void) | undefined;

    hooks.afterEach(function () {
      restoreFrame?.();
      restoreFrame = undefined;
    });

    function withoutFrames(): void {
      const original = window.requestAnimationFrame;
      window.requestAnimationFrame = (() => 0) as typeof original;
      restoreFrame = (): void => {
        window.requestAnimationFrame = original;
      };
    }

    test('still runs when frames never arrive, as in a hidden tab', async function (assert) {
      withoutFrames();

      let ran = false;
      afterFirstPaint(() => {
        ran = true;
      });

      await new Promise((resolve) => setTimeout(resolve, 400));

      assert.true(
        ran,
        'the timeout is the backstop for a page that never paints a frame'
      );
    });

    test('runs its callback once', async function (assert) {
      let calls = 0;
      afterFirstPaint(() => {
        calls += 1;
      });

      await new Promise((resolve) => setTimeout(resolve, 400));

      assert.strictEqual(calls, 1);
    });

    test('cancelling prevents the callback', async function (assert) {
      withoutFrames();

      let ran = false;
      const cancel = afterFirstPaint(() => {
        ran = true;
      });
      cancel();

      await new Promise((resolve) => setTimeout(resolve, 400));

      assert.false(ran, 'a destroyed overlay must not be woken up later');
    });
  });

  module('withoutEnterTransition', function () {
    test('replaces the enter half and keeps everything else', function (assert) {
      const result = withoutEnterTransition({
        name: 'overlay-transition--zoom',
        isEnabled: true,
        leaveClass: 'my-leave'
      });

      assert.strictEqual(result.name, 'overlay-transition--zoom');
      assert.true(result.isEnabled, 'the modifier stays enabled');
      assert.strictEqual(
        result.leaveClass,
        'my-leave',
        'the close animation is untouched'
      );
      assert.strictEqual(result.enterClass, INERT_ENTER_TRANSITION.enterClass);
      assert.strictEqual(
        result.enterActiveClass,
        INERT_ENTER_TRANSITION.enterActiveClass
      );
      assert.strictEqual(
        result.enterToClass,
        INERT_ENTER_TRANSITION.enterToClass
      );
    });

    test('overrides consumer-provided enter classes', function (assert) {
      const result = withoutEnterTransition({
        enterClass: 'my-enter',
        enterActiveClass: 'my-enter-active',
        enterToClass: 'my-enter-to'
      });

      assert.strictEqual(result.enterClass, INERT_ENTER_TRANSITION.enterClass);
      assert.strictEqual(
        result.enterActiveClass,
        INERT_ENTER_TRANSITION.enterActiveClass
      );
      assert.strictEqual(
        result.enterToClass,
        INERT_ENTER_TRANSITION.enterToClass
      );
    });
  });
});
