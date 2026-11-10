import { module, test } from 'qunit';
import { isBelowBreakpoint, watchBreakpoint } from 'frontile/utils/breakpoint';
import {
  mockMatchMedia,
  removeMatchMedia,
  type MatchMediaMock
} from 'test-app/tests/helpers/match-media';

module('Unit | Utility | breakpoint', function (hooks) {
  let media: MatchMediaMock | undefined;

  hooks.afterEach(function () {
    media?.restore();
    media = undefined;
  });

  test('queries max-width at the rem value minus 0.02px', function (assert) {
    const original = window.matchMedia;
    const seen: string[] = [];
    window.matchMedia = ((query: string) => {
      seen.push(query);
      return original.call(window, query);
    }) as typeof window.matchMedia;
    try {
      isBelowBreakpoint('sm');
      isBelowBreakpoint('md');
      isBelowBreakpoint('lg');
    } finally {
      window.matchMedia = original;
    }
    assert.deepEqual(seen, [
      '(max-width: calc(40rem - 0.02px))',
      '(max-width: calc(48rem - 0.02px))',
      '(max-width: calc(64rem - 0.02px))'
    ]);
  });

  test('is true below and false at or above the breakpoint', function (assert) {
    media = mockMatchMedia(767);
    assert.true(isBelowBreakpoint('md'), '767px is below md');
    media.setWidth(768);
    assert.false(isBelowBreakpoint('md'), '768px is md');
    assert.true(isBelowBreakpoint('lg'), '768px is below lg');
    assert.false(isBelowBreakpoint('sm'), '768px is above sm');
  });

  test('watchBreakpoint reports changes until unsubscribed', function (assert) {
    media = mockMatchMedia(1024);
    const calls: boolean[] = [];
    const stop = watchBreakpoint('md', (below) => calls.push(below));
    media.setWidth(500);
    media.setWidth(600);
    media.setWidth(900);
    stop();
    media.setWidth(500);
    assert.deepEqual(calls, [true, false]);
  });

  test('without matchMedia: false, and watching does not throw', function (assert) {
    const restore = removeMatchMedia();
    try {
      assert.false(isBelowBreakpoint('md'));
      const stop = watchBreakpoint('md', () => {});
      stop();
      assert.ok(true, 'did not throw');
    } finally {
      restore();
    }
  });
});
