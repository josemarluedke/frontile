import { module, test } from 'qunit';
import safeStyles from '@frontile/utilities/utils/safe-styles';

module('Unit | @frontile/utilities/utils/safeStyles', function () {
  test('it works', function (assert) {
    const result = safeStyles({ height: '10px', overflow: 'hidden' });
    assert.equal(result.toString(), 'height:10px;overflow:hidden');
  });
});
