import { module, test } from 'qunit';
import { semanticColors, parse, wcagContrast } from '@frontile/theme/colors';
import { realStyles } from 'test-app/tests/helpers/real-theme-styles';

/**
 * Pure-math contrast regression test for the form controls' own colour
 * pairings, in the same spirit as
 * `tests/unit/notifications/notification-card-contrast-test.ts`: every
 * assertion reads the *shipped* class string out of `realStyles` (not
 * `useStyles()`, which other test files overwrite with mock markers) and then
 * resolves it through `semanticColors`, so it fails both when a class is
 * changed to a weaker level and when the level's own value drifts.
 *
 * This is the test that would have caught the invalid-field bug: the invalid
 * border and its focus ring used the translucent `soft` level (`danger` at
 * 15%), which composites to ~1.1:1 against the field — an error state that is
 * literally invisible in dark mode.
 *
 * Two known failures are deliberately NOT asserted here, because fixing them
 * restyles every field in the library and is a design decision rather than a
 * bug (see the contrast notes in `packages/theme/src/components/forms/forms.ts`):
 *   - the resting border `border-neutral-soft` is 1.37:1 in light mode,
 *     against the 3:1 that WCAG 1.4.11 asks of a control's visual boundary;
 *   - `placeholder-neutral` is 3.13:1 in light mode, against AA's 4.5:1.
 */

interface OpaqueRgb {
  mode: 'rgb';
  r: number;
  g: number;
  b: number;
}

/** Composite a (possibly translucent) foreground over an opaque background,
 * so `wcagContrast` (which does not composite) sees what the browser paints. */
function compositeOver(fgHex: string, bgHex: string): OpaqueRgb {
  const fg = parse(fgHex);
  const bg = parse(bgHex);
  if (!fg || !bg) {
    throw new Error(`Failed to parse color: ${fgHex} / ${bgHex}`);
  }
  const a = fg.alpha ?? 1;
  const fgR = 'r' in fg ? fg.r : 0;
  const fgG = 'g' in fg ? fg.g : 0;
  const fgB = 'b' in fg ? fg.b : 0;
  const bgR = 'r' in bg ? bg.r : 0;
  const bgG = 'g' in bg ? bg.g : 0;
  const bgB = 'b' in bg ? bg.b : 0;
  return {
    mode: 'rgb',
    r: fgR * a + bgR * (1 - a),
    g: fgG * a + bgG * (1 - a),
    b: fgB * a + bgB * (1 - a)
  };
}

function contrastHex(fgHex: string, bgHex: string): number {
  const fg = parse(fgHex);
  const composited =
    fg && (fg.alpha ?? 1) < 1 ? compositeOver(fgHex, bgHex) : fgHex;
  return wcagContrast(composited, bgHex);
}

type ColorTree = { [key: string]: string | ColorTree };

function levelValue(category: ColorTree, level: string): string {
  const value = category[level];
  if (typeof value !== 'string') {
    throw new Error(`Missing color level "${level}"`);
  }
  return value;
}

const CATEGORIES = [
  'neutral',
  'primary',
  'secondary',
  'tertiary',
  'success',
  'warning',
  'danger'
] as const;

const LEVELS = [
  'subtle',
  'muted',
  'soft',
  'mild',
  'firm',
  'strong',
  'bolder'
] as const;

/**
 * Pull the semantic colour out of the one class in `classes` that matches
 * `utility` (e.g. `border` under the `aria-invalid:` variant), and resolve it
 * against `theme`. Returns the hex plus the class it came from, so failure
 * messages name the class that has to change.
 */
function tokenFor(
  classes: string,
  utility: string,
  variant = '',
  theme: 'light' | 'dark' = 'light'
): { hex: string; className: string } {
  const colors = semanticColors[theme] as unknown as ColorTree;
  const levelGroup = LEVELS.join('|');
  const catGroup = CATEGORIES.join('|');
  const pattern = new RegExp(
    `^${variant}${utility}-(${catGroup})(?:-(${levelGroup}))?$`
  );

  // Last match wins: `tv()` emits the base slot's classes before the variant
  // classes that override them, so an unprefixed lookup for `border` on an
  // invalid field must resolve to the invalid border, not the resting one.
  for (const className of classes.split(/\s+/).reverse()) {
    const match = pattern.exec(className);
    if (match) {
      const [, category, level] = match;
      return {
        hex: levelValue(
          colors[category as string] as ColorTree,
          level ?? 'DEFAULT'
        ),
        className
      };
    }
  }

  throw new Error(
    `No class matching ${pattern} in "${classes}" — the theme no longer ` +
      `styles this, or the utility was renamed`
  );
}

const AA_NORMAL_TEXT = 4.5;
const AA_NON_TEXT = 3;

const THEMES = ['light', 'dark'] as const;

const FEEDBACK_STATUSES = [
  'primary',
  'secondary',
  'tertiary',
  'success',
  'warning',
  'danger'
] as const;

module('Unit | Forms | form control contrast', function () {
  for (const theme of THEMES) {
    const colors = semanticColors[theme] as unknown as ColorTree;
    const surface = colors['surface'] as ColorTree;
    const surfaceApp = levelValue(surface, 'app');
    const surfaceInput = levelValue(surface, 'input');
    // A card sits over the app surface and, in dark mode, is translucent
    // white — so text on a card is the *harder* case there, not the easier one.
    const surfaceCard = compositeOver(levelValue(surface, 'card'), surfaceApp);

    // --- the reported bug --------------------------------------------------

    test(`${theme}: invalid field border is visible against the field`, function (assert) {
      const { input } = realStyles.input();
      const { hex, className } = tokenFor(
        input(),
        'border',
        'aria-invalid:',
        theme
      );
      const ratio = contrastHex(hex, surfaceInput);
      assert.true(
        ratio >= AA_NON_TEXT,
        `${className} on surface-input: expected >= ${AA_NON_TEXT}:1, got ${ratio.toFixed(2)}:1`
      );
    });

    test(`${theme}: a focused invalid field rings danger, not the neutral focus colour`, function (assert) {
      // `ring-focus` resolves to `--color-primary-muted`, so an invalid field
      // that never overrides it keeps a teal halo around a red border. The
      // override has to both exist and be an opaque halo of the same weight as
      // `ring-focus` -- which is what `muted` is, and what `soft` is not.
      const { input } = realStyles.input();
      const { hex, className } = tokenFor(
        input(),
        'ring',
        'aria-invalid:focus:',
        theme
      );
      assert.true(
        className.startsWith('aria-invalid:focus:ring-danger'),
        `expected a danger ring, got "${className}"`
      );

      const focusRing = levelValue(colors['primary'] as ColorTree, 'muted');
      assert.strictEqual(
        contrastHex(hex, surfaceInput).toFixed(0),
        contrastHex(focusRing, surfaceInput).toFixed(0),
        `${className} should carry the same visual weight as ring-focus ` +
          `(primary-muted); got ${contrastHex(hex, surfaceInput).toFixed(2)}:1 ` +
          `vs ${contrastHex(focusRing, surfaceInput).toFixed(2)}:1`
      );
    });

    test(`${theme}: focused field border is visible against the field`, function (assert) {
      const { input } = realStyles.input();
      const { hex, className } = tokenFor(input(), 'border', 'focus:', theme);
      const ratio = contrastHex(hex, surfaceInput);
      assert.true(
        ratio >= AA_NON_TEXT,
        `${className} on surface-input: expected >= ${AA_NON_TEXT}:1, got ${ratio.toFixed(2)}:1`
      );
    });

    test(`${theme}: invalid one-time-code cell border is visible against the cell`, function (assert) {
      const { cell } = realStyles.inputOtp({ isInvalid: true });
      const { hex, className } = tokenFor(cell(), 'border', '', theme);
      const ratio = contrastHex(hex, surfaceInput);
      assert.true(
        ratio >= AA_NON_TEXT,
        `${className} on surface-input: expected >= ${AA_NON_TEXT}:1, got ${ratio.toFixed(2)}:1`
      );
    });

    test(`${theme}: invalid chips field border is visible against the field`, function (assert) {
      const { chipsField } = realStyles.select({ hasChips: true });
      const { hex, className } = tokenFor(
        chipsField(),
        'border',
        'data-\\[invalid=true\\]:',
        theme
      );
      const ratio = contrastHex(hex, surfaceInput);
      assert.true(
        ratio >= AA_NON_TEXT,
        `${className} on surface-input: expected >= ${AA_NON_TEXT}:1, got ${ratio.toFixed(2)}:1`
      );
    });

    // --- text on the form --------------------------------------------------

    for (const status of FEEDBACK_STATUSES) {
      test(`${theme}: ${status} feedback text clears AA on app and card surfaces`, function (assert) {
        const classes = realStyles.formFeedback({ status });
        const { hex, className } = tokenFor(classes, 'text', '', theme);

        const onApp = contrastHex(hex, surfaceApp);
        assert.true(
          onApp >= AA_NORMAL_TEXT,
          `${className} on surface-app: expected >= ${AA_NORMAL_TEXT}:1, got ${onApp.toFixed(2)}:1`
        );

        const onCard = wcagContrast(hex, surfaceCard);
        assert.true(
          onCard >= AA_NORMAL_TEXT,
          `${className} on surface-card: expected >= ${AA_NORMAL_TEXT}:1, got ${onCard.toFixed(2)}:1`
        );
      });
    }

    test(`${theme}: description text clears AA`, function (assert) {
      const { hex, className } = tokenFor(
        realStyles.formDescription(),
        'text',
        '',
        theme
      );
      const ratio = contrastHex(hex, surfaceApp);
      assert.true(
        ratio >= AA_NORMAL_TEXT,
        `${className} on surface-app: expected >= ${AA_NORMAL_TEXT}:1, got ${ratio.toFixed(2)}:1`
      );
    });

    test(`${theme}: label and its required asterisk clear AA`, function (assert) {
      const { base, asterisk } = realStyles.label();

      const labelToken = tokenFor(base(), 'text', '', theme);
      const labelRatio = contrastHex(labelToken.hex, surfaceApp);
      assert.true(
        labelRatio >= AA_NORMAL_TEXT,
        `${labelToken.className} on surface-app: expected >= ${AA_NORMAL_TEXT}:1, got ${labelRatio.toFixed(2)}:1`
      );

      const asteriskToken = tokenFor(asterisk(), 'text', '', theme);
      const asteriskRatio = contrastHex(asteriskToken.hex, surfaceApp);
      assert.true(
        asteriskRatio >= AA_NORMAL_TEXT,
        `${asteriskToken.className} on surface-app: expected >= ${AA_NORMAL_TEXT}:1, got ${asteriskRatio.toFixed(2)}:1`
      );
    });

    test(`${theme}: entered value text clears AA against the field`, function (assert) {
      const { input } = realStyles.input();
      const { hex, className } = tokenFor(input(), 'text', '', theme);
      const ratio = contrastHex(hex, surfaceInput);
      assert.true(
        ratio >= AA_NORMAL_TEXT,
        `${className} on surface-input: expected >= ${AA_NORMAL_TEXT}:1, got ${ratio.toFixed(2)}:1`
      );
    });

    test(`${theme}: checkbox and radio borders are visible against the field`, function (assert) {
      for (const [name, styles] of [
        ['checkbox', realStyles.checkbox()],
        ['radio', realStyles.radio()]
      ] as const) {
        const { hex, className } = tokenFor(
          styles.input(),
          'border',
          '',
          theme
        );
        const ratio = contrastHex(hex, surfaceInput);
        assert.true(
          ratio >= AA_NON_TEXT,
          `${name}: ${className} on surface-input: expected >= ${AA_NON_TEXT}:1, got ${ratio.toFixed(2)}:1`
        );
      }
    });
  }
});
