import { module, test } from 'qunit';
import {
  paginationRange,
  type PaginationItem
} from 'frontile/components/navigation/pagination/range';

/**
 * Renders a range as the string a user would read, so the expectations below
 * are legible at a glance: `'1 2 … 12'` rather than a nest of object literals.
 */
function shape(items: PaginationItem[]): string {
  return items
    .map((item) => (item.type === 'ellipsis' ? '…' : String(item.value)))
    .join(' ');
}

function range(page: number, totalPages: number, siblingCount = 1): string {
  return shape(paginationRange({ page, totalPages, siblingCount }));
}

module('Unit | navigation/pagination/range', function () {
  test('a single page renders just itself', function (assert) {
    assert.strictEqual(range(1, 1), '1');
  });

  test('a short range renders every page with no ellipsis', function (assert) {
    assert.strictEqual(range(1, 7), '1 2 3 4 5 6 7');
    assert.strictEqual(range(4, 7), '1 2 3 4 5 6 7');
  });

  test('a trailing ellipsis appears when the tail is cut off', function (assert) {
    assert.strictEqual(range(1, 12), '1 2 3 4 5 … 12');
  });

  test('a leading ellipsis appears when the head is cut off', function (assert) {
    assert.strictEqual(range(12, 12), '1 … 8 9 10 11 12');
  });

  test('both ellipses appear in the middle of a long range', function (assert) {
    assert.strictEqual(range(6, 12), '1 … 5 6 7 … 12');
  });

  test('the window keeps a stable slot count as the page moves', function (assert) {
    const widths = new Set<number>();

    for (let page = 1; page <= 20; page++) {
      widths.add(
        paginationRange({ page, totalPages: 20, siblingCount: 1 }).length
      );
    }

    assert.deepEqual(
      [...widths],
      [7],
      'every page renders the same number of slots, so the control never reflows'
    );
  });

  test('siblingCount 0 shows only the current page between the boundaries', function (assert) {
    assert.strictEqual(range(6, 12, 0), '1 … 6 … 12');
  });

  test('siblingCount 2 widens the window', function (assert) {
    assert.strictEqual(range(7, 20, 2), '1 … 5 6 7 8 9 … 20');
  });

  test('a one-page gap renders the page instead of an ellipsis', function (assert) {
    assert.strictEqual(
      range(1, 8),
      '1 2 3 4 5 … 8',
      'page 2 fills the leading gap on its own; only the trailing gap (6-7) is two pages wide and so collapses'
    );
  });

  test('a non-positive totalPages yields nothing', function (assert) {
    assert.deepEqual(
      paginationRange({ page: 1, totalPages: 0, siblingCount: 1 }),
      []
    );
  });
});
