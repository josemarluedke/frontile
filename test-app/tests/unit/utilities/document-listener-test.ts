import { module, test } from 'qunit';
import { listen, globalDocument } from 'frontile/utils/document-listener';

module('Unit | Utility | document-listener', function () {
  test('globalDocument returns the document in the browser', function (assert) {
    assert.strictEqual(globalDocument(), document);
  });

  test('listen registers until the returned function is called', function (assert) {
    const seen: string[] = [];
    const stop = listen(document, 'keydown', (event) => seen.push(event.key));
    document.dispatchEvent(new KeyboardEvent('keydown', { key: 'a' }));
    stop();
    document.dispatchEvent(new KeyboardEvent('keydown', { key: 'b' }));
    assert.deepEqual(seen, ['a']);
  });

  test('without a document (FastBoot/SSR) listen is a no-op and does not throw', function (assert) {
    const stop = listen(undefined, 'keydown', () => {
      assert.ok(false, 'never called');
    });
    stop();
    assert.ok(true, 'did not throw');
  });
});
