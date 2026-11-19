import { module, test } from 'qunit';
import * as theme from '@frontile/theme';
import { useStyles } from '@frontile/theme';

// v0.19 removed `@frontile/forms-legacy` and `ember-power-select` support from
// the theme. The safelist half lives in scripts/__tests__/theme-legacy-removed-test.mjs:
// importing the Tailwind plugin entry hangs the browser test page.
module('Unit | @frontile/theme | removed legacy styles', function () {
  test('no forms-legacy recipes are exported', function (assert) {
    // The recipes are not named exports of the package root: they are reached
    // through `useStyles()`, so check both.
    const exported = [...Object.keys(theme), ...Object.keys(useStyles())];
    for (const name of [
      'formInput',
      'formTextarea',
      'formCheckbox',
      'formRadio',
      'formCheckboxGroup',
      'formRadioGroup',
      'formSelect'
    ]) {
      assert.false(exported.includes(name), `${name} is not exported`);
    }
  });
});
