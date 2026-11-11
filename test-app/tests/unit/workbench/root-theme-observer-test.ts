import { module, test } from 'qunit';
import { settled } from '@ember/test-helpers';
import { subscribe } from 'test-app/utils/workbench/root-theme-observer';

module('Unit | workbench | root-theme-observer', function () {
  test('subscribers share one observer and unsubscribe works', async function (assert) {
    const Original = window.MutationObserver;
    let created = 0;
    let disconnected = 0;
    class Counting extends Original {
      constructor(cb: MutationCallback) {
        super(cb);
        created++;
      }
      disconnect(): void {
        disconnected++;
        super.disconnect();
      }
    }
    window.MutationObserver = Counting;
    const root = document.documentElement;
    const wait = (): Promise<void> => new Promise((r) => setTimeout(r, 20));

    try {
      let a = 0;
      let b = 0;
      const offA = subscribe(() => a++);
      const offB = subscribe(() => b++);
      assert.strictEqual(created, 1, 'two subscribers create one observer');

      root.classList.toggle('wb-observer-probe');
      await wait();
      assert.strictEqual(a, 1, 'A notified');
      assert.strictEqual(b, 1, 'B notified');

      offA();
      root.classList.toggle('wb-observer-probe');
      await wait();
      assert.strictEqual(a, 1, 'A no longer notified');
      assert.strictEqual(b, 2, 'B still notified');
      assert.strictEqual(disconnected, 0, 'observer stays while B subscribed');

      offB();
      assert.strictEqual(disconnected, 1, 'last unsubscribe disconnects');
      root.classList.toggle('wb-observer-probe');
      await wait();
      assert.strictEqual(b, 2, 'B no longer notified');
    } finally {
      window.MutationObserver = Original;
      root.classList.remove('wb-observer-probe');
      await settled();
    }
  });
});
