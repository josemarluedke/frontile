import { module, test } from 'qunit';
import { semanticColors } from '@frontile/theme/colors';
import { useStyles } from '@frontile/theme';

/**
 * Pure-math contrast regression test for NotificationCard's text/background
 * pairings, computed directly from the theme's own colour objects
 * (`semanticColors`, the same data `packages/theme/src/colors/semantic.ts`
 * feeds into the Tailwind plugin) rather than from a hand-maintained docs
 * table. This is the test that would have caught the `solid` variant's
 * WCAG AA failure (its description used to sit at 80% opacity, which
 * dropped `danger`'s ratio to ~3.37:1 in light mode) — see
 * `packages/frontile/docs/notifications-usage.md`'s contrast note and
 * `packages/theme/src/components/notification-card.ts`'s `solid` compound
 * variants for the fix.
 *
 * No DOM/rendering is involved: relative luminance and alpha compositing
 * are pure arithmetic, so this runs as a plain unit test.
 */

type RGBA = { r: number; g: number; b: number; a: number };

function hexToRgba(hex: string): RGBA {
  const h = hex.replace('#', '');
  const r = parseInt(h.substring(0, 2), 16);
  const g = parseInt(h.substring(2, 4), 16);
  const b = parseInt(h.substring(4, 6), 16);
  const a = h.length > 6 ? parseInt(h.substring(6, 8), 16) / 255 : 1;
  return { r, g, b, a };
}

/** Composite `fg` (which may carry alpha) over an assumed-opaque `bg`. */
function compositeOver(fg: RGBA, bg: RGBA): RGBA {
  const a = fg.a;
  return {
    r: fg.r * a + bg.r * (1 - a),
    g: fg.g * a + bg.g * (1 - a),
    b: fg.b * a + bg.b * (1 - a),
    a: 1
  };
}

function srgbChannelToLinear(c: number): number {
  const scaled = c / 255;
  return scaled <= 0.03928
    ? scaled / 12.92
    : Math.pow((scaled + 0.055) / 1.055, 2.4);
}

function relativeLuminance({ r, g, b }: RGBA): number {
  return (
    0.2126 * srgbChannelToLinear(r) +
    0.7152 * srgbChannelToLinear(g) +
    0.0722 * srgbChannelToLinear(b)
  );
}

/** WCAG contrast ratio between two (assumed opaque) colors. */
function contrastRatio(a: RGBA, b: RGBA): number {
  const l1 = relativeLuminance(a);
  const l2 = relativeLuminance(b);
  const lighter = Math.max(l1, l2);
  const darker = Math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

/**
 * Contrast between a (possibly translucent) foreground hex and an opaque
 * background hex, compositing first if needed. Mirrors what the browser
 * actually paints.
 */
function contrastHex(fgHex: string, bgHex: string): number {
  const fg = hexToRgba(fgHex);
  const bg = hexToRgba(bgHex);
  const composited = fg.a < 1 ? compositeOver(fg, bg) : fg;
  return contrastRatio(composited, bg);
}

/**
 * Same algorithm `packages/theme/src/colors/util.ts`'s `getContrastingColor`
 * uses to auto-generate `on-{color}` for every semantic color's `DEFAULT`
 * level: pick whichever of pure black/white contrasts more with the
 * background.
 */
function getContrastingColor(bgHex: string): string {
  const bg = hexToRgba(bgHex);
  const black: RGBA = { r: 0, g: 0, b: 0, a: 1 };
  const white: RGBA = { r: 255, g: 255, b: 255, a: 1 };
  const withBlack = contrastRatio(bg, black);
  const withWhite = contrastRatio(bg, white);
  return withBlack > withWhite ? '#000000' : '#ffffff';
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
        const compositedBg = compositeOver(
          hexToRgba(soft),
          hexToRgba(surfaceModal)
        );
        const ratio = contrastRatio(hexToRgba(onSoft), compositedBg);
        assert.true(
          ratio >= AA_NORMAL_TEXT,
          `on-${category}-soft on composited ${category}-soft: expected >= ${AA_NORMAL_TEXT}:1, got ${ratio.toFixed(2)}:1`
        );
      });

      test(`${theme}: solid variant ${intent} title/icon clears AA (this is the pairing BUG 1 broke)`, function (assert) {
        const bg = levelValue(colors[category] as ColorTree, 'DEFAULT');
        const fg = getContrastingColor(bg);
        const ratio = contrastHex(fg, bg);

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
        const ratio = contrastHex(fg, bg);
        assert.true(
          ratio >= AA_NORMAL_TEXT,
          `description ink on ${category}: expected >= ${AA_NORMAL_TEXT}:1, got ${ratio.toFixed(2)}:1`
        );
      });
    }
  }
});
