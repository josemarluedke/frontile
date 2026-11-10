import { module, test } from 'qunit';
import { globalDocument } from 'frontile/utils/document-listener';

module('Unit | Utility | document-listener', function () {
  test('globalDocument returns the document in the browser', function (assert) {
    assert.strictEqual(globalDocument(), document);
  });
});
