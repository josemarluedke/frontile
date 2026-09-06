import { module, test } from 'qunit';
import {
  semanticColors,
  getContrastingColor,
  parse,
  wcagContrast
} from '@frontile/theme/colors';
import { useStyles } from '@frontile/theme';

/** Structurally compatible with `culori`'s `Color` (an opaque sRGB triple)
 * without importing the type from `culori` directly — `culori` isn't a
 * dependency of this app, only of `@frontile/theme`, which already re-exports
 * the values (`parse`, `wcagContrast`) this file needs. */
interface OpaqueRgb {
  mode: 'rgb';
  r: number;
  g: number;
  b: number;
}

/**
 * Pure-math contrast regression test for NotificationCard's text/background
 * pairings, computed directly from the theme's own colour objects
 * (`semanticColors`) and the theme's own contrast helpers (`getContrastingColor`,
 * `wcagContrast` re-exported from `packages/theme/src/colors/util.ts`) — the
 * same code path the `solid` variant's contrast text actually goes through —
 * rather than a private reimplementation of the WCAG maths. This is the test
 * that would have caught the `solid` variant's WCAG AA failure (its
 * description used to sit at 80% opacity, which dropped `danger`'s ratio to
 * ~3.37:1 in light mode) — see `packages/frontile/docs/notifications-usage.md`'s
 * contrast note and `packages/theme/src/components/notification-card.ts`'s
 * `solid` compound variants for the fix.
 *
 * No DOM/rendering is involved, so this runs as a plain unit test. Alpha
 * compositing (`culori` doesn't do this) is the only piece not already
 * covered by the theme's helpers, so it's the only piece still done locally.
 */

/** Composite a (possibly translucent) foreground color over an assumed-opaque
 * background, so `wcagContrast` (which does not composite) sees what the
 * browser actually paints. */
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

/** Contrast between a (possibly translucent) foreground hex and an opaque
 * background hex, compositing first if needed. Mirrors what the browser
 * actually paints. */
function contrastHex(fgHex: string, bgHex: string): number {
  const fg = parse(fgHex);
  const composited =
    fg && (fg.alpha ?? 1) < 1 ? compositeOver(fgHex, bgHex) : fgHex;
  return wcagContrast(composited, bgHex);
}

const AA_NORMAL_TEXT = 4.5;

const THEMES = ['light', 'dark'] as const;

const INTENTS = ['default', 'info', 'success', 'warning', 'danger'] as const;

/** Maps a notification `intent` to the semantic color category its
 * compound variants (in notification-card.ts) actually pull from. */
const CATEGORY_FOR_INTENT: Record<(typeof INTENTS)[number], string> = {
  default: 'neutral',
  info: 'primary',
  success: 'success',
  warning: 'warning',
  danger: 'danger'
};

/** The `default`/`tonal` title+icon color level per intent, mirroring the
 * compound variants in notification-card.ts. */
const DEFAULT_VARIANT_TEXT_LEVEL: Record<(typeof INTENTS)[number], string> = {
  default: 'firm',
  info: 'DEFAULT',
  success: 'bolder',
  warning: 'bolder',
  danger: 'firm'
};

/** Every value in `semanticColors` is ultimately a resolved hex/rgba string
 * or a nested object of them; test code only ever needs bracket access into
 * this loosely-typed shape, so a single `any`-backed helper keeps the
 * arithmetic above strictly typed while this stays terse. */
type ColorTree = { [key: string]: string | ColorTree };

function levelValue(category: ColorTree, level: string): string {
  const value = category[level];
  if (typeof value !== 'string') {
    throw new Error(`Missing color level "${level}"`);
  }
  return value;
}

module('Unit | Notifications | notification-card contrast', function () {
  for (const theme of THEMES) {
    const colors = semanticColors[theme] as unknown as ColorTree;
    const surfaceModal = levelValue(colors['surface'] as ColorTree, 'modal');

    test(`${theme}: default/tonal description clears AA (text-neutral-firm on surface-modal)`, function (assert) {
      const ratio = contrastHex(
        levelValue(colors['neutral'] as ColorTree, 'firm'),
        surfaceModal
      );
      assert.true(
        ratio >= AA_NORMAL_TEXT,
        `expected >= ${AA_NORMAL_TEXT}:1, got ${ratio.toFixed(2)}:1`
      );
    });

    for (const intent of INTENTS) {
      const category = CATEGORY_FOR_INTENT[intent];

      test(`${theme}: default variant ${intent} title/icon clears AA`, function (assert) {
        const level = DEFAULT_VARIANT_TEXT_LEVEL[intent];
        const fg = levelValue(colors[category] as ColorTree, level);
        const ratio = contrastHex(fg, surfaceModal);
        assert.true(
          ratio >= AA_NORMAL_TEXT,
          `${category}-${level} on surface-modal: expected >= ${AA_NORMAL_TEXT}:1, got ${ratio.toFixed(2)}:1`
        );
      });

      test(`${theme}: tonal variant ${intent} icon/title clears AA (on-${category}-soft on composited ${category}-soft)`, function (assert) {
        const soft = levelValue(colors[category] as ColorTree, 'soft');
        const onSoft = levelValue(
          colors[`on-${category}`] as ColorTree,
          'soft'
        );
        const compositedBg = compositeOver(soft, surfaceModal);
        const ratio = wcagContrast(onSoft, compositedBg);
        assert.true(
          ratio >= AA_NORMAL_TEXT,
          `on-${category}-soft on composited ${category}-soft: expected >= ${AA_NORMAL_TEXT}:1, got ${ratio.toFixed(2)}:1`
        );
      });

      test(`${theme}: solid variant ${intent} title/icon clears AA (this is the pairing BUG 1 broke)`, function (assert) {
        const bg = levelValue(colors[category] as ColorTree, 'DEFAULT');
        const fg = getContrastingColor(bg);
        const ratio = wcagContrast(fg, bg);

        assert.true(
          ratio >= AA_NORMAL_TEXT,
          `on-${category} on ${category}: expected >= ${AA_NORMAL_TEXT}:1, got ${ratio.toFixed(2)}:1`
        );
      });

      test(`${theme}: solid variant ${intent} description uses the shipped theme class and clears AA`, function (assert) {
        // Reads the *actual* shipped `description` class from
        // notification-card.ts (not a hand-copied literal), so this catches
        // a regression to a translucent cut like the old `/80` — not just
        // the color math above, which can't see the class string at all.
        // `useStyles()` may have been swapped for mock markers by another
        // test file's module-level `registerCustomStyles` call by the time
        // this runs (there is no way to unregister one) — that's fine here:
        // it would just make this assertion fail loudly rather than
        // silently check the wrong thing, since a mock slot never contains
        // an opacity-modifier suffix either.
        const { description } = useStyles().notificationCard({
          intent,
          variant: 'solid'
        });
        const descriptionClass = description();

        assert.false(
          /\/\d+(?:\s|$)/.test(descriptionClass),
          `expected no opacity-modifier suffix (e.g. "/80") on the description ` +
            `class; got "${descriptionClass}"`
        );

        const bg = levelValue(colors[category] as ColorTree, 'DEFAULT');
        const fg = getContrastingColor(bg);
        const ratio = wcagContrast(fg, bg);
        assert.true(
          ratio >= AA_NORMAL_TEXT,
          `description ink on ${category}: expected >= ${AA_NORMAL_TEXT}:1, got ${ratio.toFixed(2)}:1`
        );
      });
    }
  }
});
