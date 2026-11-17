import { module, test } from 'qunit';
import { realStyles } from 'test-app/tests/helpers/real-theme-styles';

/**
 * Start and end content in a form field (a currency prefix, a search glyph,
 * a trailing unit) takes the spec's `neutral-soft` text color. Reads the
 * shipped class strings out of `realStyles`.
 *
 * Deliberately no WCAG assertion: `neutral-soft` on the field surface is a
 * low-contrast pairing by design (see forms-contrast-test.ts).
 */

const tokens = (classes: string) => classes.split(/\s+/).filter(Boolean);

module('Unit | forms | field start and end content', function () {
  test('the shared input recipe colours startContent and endContent neutral-soft', function (assert) {
    const { startContent, endContent } = realStyles.input({});

    assert.true(tokens(startContent()).includes('text-neutral-soft'));
    assert.true(tokens(endContent()).includes('text-neutral-soft'));
  });

  test('size and pointer-events variants keep the color', function (assert) {
    for (const size of ['sm', 'md', 'lg'] as const) {
      const { startContent, endContent } = realStyles.input({
        size,
        startContentPointerEvents: 'none',
        endContentPointerEvents: 'auto'
      });

      assert.true(
        tokens(startContent()).includes('text-neutral-soft'),
        `startContent ${size}`
      );
      assert.true(
        tokens(endContent()).includes('text-neutral-soft'),
        `endContent ${size}`
      );
    }
  });

  test('recipes extending input pick up the color on both slots', function (assert) {
    const recipes = {
      textarea: realStyles.textarea({}),
      select: realStyles.select({}),
      autocomplete: realStyles.autocomplete({}),
      nativeSelect: realStyles.nativeSelect({})
    };

    for (const [name, slots] of Object.entries(recipes)) {
      assert.true(
        tokens(slots.startContent()).includes('text-neutral-soft'),
        `${name} startContent`
      );
      assert.true(
        tokens(slots.endContent()).includes('text-neutral-soft'),
        `${name} endContent`
      );
    }
  });

  test('recipes that restate endContent as a field adornment keep the color', function (assert) {
    for (const [name, slots] of Object.entries({
      datePicker: realStyles.datePicker({}),
      dateInput: realStyles.dateInput({})
    })) {
      assert.true(
        tokens(slots.endContent()).includes('text-neutral-soft'),
        `${name} endContent`
      );
    }
  });

  test('the segmented date picker end cluster keeps the color', function (assert) {
    const { endContent } = realStyles.datePicker({ isSegmented: true });

    assert.true(tokens(endContent()).includes('text-neutral-soft'));
  });

  test('switchInput thumb icons are not form-field adornments and are untouched', function (assert) {
    const { startContent, endContent } = realStyles.switchInput({});

    assert.false(tokens(startContent()).includes('text-neutral-soft'));
    assert.false(tokens(endContent()).includes('text-neutral-soft'));
  });
});
