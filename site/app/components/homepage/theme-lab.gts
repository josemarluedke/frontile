import Component from '@glimmer/component';
import type { TOC } from '@ember/component/template-only';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { htmlSafe } from '@ember/template';
import type { SafeString } from '@ember/template';
import { Button, Chip, Field, ProgressBar, ToggleButton } from 'frontile';
import { teal, blue, pink, green } from '@frontile/theme/colors';
import CodePanel from './code-panel';

/**
 * Live demonstration of the token system: picking a ramp rewrites the same
 * `--color-primary-*` custom properties the theme plugin generates, and every
 * Frontile component inside re-resolves against them.
 *
 * Two details make this an honest demonstration rather than a trick:
 *
 * 1. **Each scheme gets its own ramp.** Frontile's accent ramps invert in dark
 *    mode — `DEFAULT` is the 600 step in light and the 300 step in dark — so
 *    feeding the light ramp to a dark panel produces unreadable
 *    dark-blue-on-black, which the real system never ships. The ramps below are
 *    derived from the palette exactly as
 *    `packages/theme/src/colors/semantic.ts` derives them.
 * 2. **The scoping matches the plugin.** Instead of an inline style that
 *    overrides both schemes at once, this writes a scoped stylesheet using the
 *    plugin's own selector pairs, so each panel picks up the ramp for the
 *    scheme it is actually rendering in.
 *
 * The families are real palette families from `@frontile/theme`. The hex
 * literals here are the subject matter, not styling.
 */

/** A palette family, by the step names `palette.ts` uses. */
type Step =
  | '50'
  | '100'
  | '200'
  | '300'
  | '400'
  | '500'
  | '600'
  | '700'
  | '900'
  | '950';
type Family = Record<Step, string>;

interface Level {
  name: string;
  value: string;
}

interface Preset {
  key: string;
  label: string;
  swatchStyle: SafeString;
  family: Family;
}

/**
 * The real palette families, imported rather than transcribed. An earlier
 * version inlined all forty hex values, which made the section's central claim
 * — that these are Frontile's own ramps — expire silently the first time the
 * palette was retuned.
 */
const FAMILIES: Record<string, Family> = { teal, blue, pink, green };

/** Mirrors semantic.ts's light-theme primary derivation. */
function lightRamp(f: Family): Level[] {
  return [
    { name: 'subtle', value: f['50'] },
    { name: 'muted', value: f['100'] },
    { name: 'soft', value: `${f['600']}1a` },
    { name: 'mild', value: f['400'] },
    { name: 'DEFAULT', value: f['600'] },
    { name: 'firm', value: f['700'] },
    { name: 'strong', value: f['900'] },
    { name: 'bolder', value: f['950'] }
  ];
}

/** Mirrors semantic.ts's dark-theme derivation — the ramp runs the other way. */
function darkRamp(f: Family): Level[] {
  return [
    { name: 'subtle', value: f['900'] },
    { name: 'muted', value: f['700'] },
    { name: 'soft', value: `${f['300']}40` },
    { name: 'mild', value: f['500'] },
    { name: 'DEFAULT', value: f['300'] },
    { name: 'firm', value: f['200'] },
    { name: 'strong', value: f['100'] },
    { name: 'bolder', value: f['50'] }
  ];
}

/**
 * Relative luminance of a hex color, per WCAG. Alpha suffixes (the `soft`
 * level carries one) are ignored — they sit over a surface we do not know here,
 * and `soft` is never used as a text background.
 */
function luminance(hex: string): number {
  const h = hex.replace('#', '').slice(0, 6);
  const channels = [0, 2, 4].map((i) => {
    const v = parseInt(h.slice(i, i + 2), 16) / 255;

    return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4);
  });

  return (
    0.2126 * channels[0]! + 0.7152 * channels[1]! + 0.0722 * channels[2]!
  );
}

/**
 * Black or white, whichever contrasts better. Emitting these alongside the ramp
 * is not optional: `text-on-primary` would otherwise keep the ink generated for
 * the *original* ramp, and a light accent like Green would render
 * white-on-green at roughly 2.3:1.
 *
 * This is a luminance threshold, while the plugin's `getContrastingColor`
 * compares real WCAG ratios through culori — so the two can disagree on a
 * borderline swatch. The theme does not export that helper today; when it does,
 * this should call it instead of approximating it.
 */
function onColor(hex: string): string {
  return luminance(hex) > 0.179 ? '#000000' : '#ffffff';
}

function toCustomProperties(ramp: Level[]): string {
  return ramp
    .flatMap(({ name, value }) => {
      const suffix = name === 'DEFAULT' ? '' : `-${name}`;

      return [
        `  --color-primary${suffix}: ${value};`,
        `  --color-on-primary${suffix}: ${onColor(value)};`
      ];
    })
    .join('\n');
}

function toConfigObject(ramp: Level[], indent: string): string {
  return ramp
    .map(({ name, value }) => `${indent}${name}: '${value}'`)
    .join(',\n');
}

const PRESETS: Preset[] = Object.entries(FAMILIES).map(([key, family]) => ({
  key,
  label: key.charAt(0).toUpperCase() + key.slice(1),
  family,
  swatchStyle: htmlSafe(`background: ${family['600']}`)
}));

/**
 * One copy of the demo UI, in whichever theme its wrapper resolves to.
 *
 * Both copies are fully interactive. This is deliberately unlike the hero's
 * theme seam, where the two copies are one picture of a UI and are therefore
 * `inert`: here they are two peer panels, and half the point is that the
 * inverted theme has finished focus, hover, and pressed states of its own. An
 * earlier version marked the inverted copy `inert` and `aria-hidden`, which
 * silently made that unprovable.
 */
const LabPanel: TOC<{
  Args: {
    /** Which theme this copy shows, relative to the visitor's own. */
    scheme: string;
    /** Distinguishes this copy's form controls from the other's. */
    fieldName: string;
  };
}> = <template>
  <div
    class="theme-lab-scope rounded-xl border border-neutral-soft bg-surface-app
      p-5 text-neutral-firm"
  >
    <p
      class="field-label mb-4"
    >{{@scheme}}</p>

    <div class="space-y-4">
      <div class="flex flex-wrap items-center gap-2">
        <Button @intent="primary" @size="sm">Save changes</Button>
        <Button @intent="primary" @appearance="outlined" @size="sm">
          Preview
        </Button>
        <Button @intent="primary" @appearance="minimal" @size="sm">
          Cancel
        </Button>
      </div>

      <Field @name={{@fieldName}} as |field|>
        <field.Input
          @label="Project name"
          @size="sm"
          @value="Quarterly report"
        />
      </Field>

      <ProgressBar
        @intent="primary"
        @label="Upload"
        @progress={{68}}
        @size="sm"
      />

      <div class="flex flex-wrap gap-2">
        <Chip @intent="primary" @size="sm">Primary</Chip>
        <Chip @intent="primary" @appearance="outlined" @size="sm">Outlined</Chip>
        <Chip @intent="primary" @appearance="faded" @size="sm">Faded</Chip>
      </div>
    </div>
  </div>
</template>;

export default class ThemeLab extends Component {
  presets = PRESETS;

  @tracked activePreset: Preset = PRESETS[0]!;

  @action
  selectPreset(next: Preset): void {
    this.activePreset = next;
  }

  isActive = (key: string): boolean => key === this.activePreset.key;

  /**
   * A scoped stylesheet using the plugin's own selector pairs, so each panel
   * resolves the ramp belonging to the scheme it renders in.
   */
  get scopedCss(): string {
    const f = this.activePreset.family;

    return [
      '.light .theme-lab-scope, .dark .theme-inverse .theme-lab-scope {',
      toCustomProperties(lightRamp(f)),
      '}',
      '.dark .theme-lab-scope, .light .theme-inverse .theme-lab-scope {',
      toCustomProperties(darkRamp(f)),
      '}'
    ].join('\n');
  }

  get configSnippet(): string {
    const f = this.activePreset.family;

    return `// frontile.js
const { frontile } = require('@frontile/theme/plugin');

module.exports = frontile({
  themes: {
    light: {
      colors: {
        primary: {
${toConfigObject(lightRamp(f), '          ')}
        }
      }
    },
    dark: {
      colors: {
        primary: {
${toConfigObject(darkRamp(f), '          ')}
        }
      }
    }
  }
});`;
  }

  <template>
    {{! This demonstration's own scoped ramp. }}
    {{! template-lint-disable no-forbidden-elements }}
    <style>{{this.scopedCss}}</style>
    {{! template-lint-enable no-forbidden-elements }}

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-x-10 gap-y-8 items-start">
      <div class="lg:col-span-2">
        <fieldset>
          <legend
            class="field-label mb-3"
          >Swap the primary ramp</legend>
          <div class="flex flex-wrap gap-2">
            {{#each this.presets as |item|}}
              <ToggleButton
                @isSelected={{this.isActive item.key}}
                @size="sm"
                @onChange={{fn this.selectPreset item}}
              >
                <span
                  class="inline-block size-3 rounded-full mr-2 align-[-1px]"
                  style={{item.swatchStyle}}
                  aria-hidden="true"
                ></span>
                {{item.label}}
              </ToggleButton>
            {{/each}}
          </div>
        </fieldset>

      </div>

      {{! Both schemes, one configuration, live }}
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <LabPanel @scheme="Your theme" @fieldName="lab-project-ambient" />
        <div class="theme-inverse">
          <LabPanel @scheme="Inverted" @fieldName="lab-project-inverted" />
        </div>
      </div>

      {{! The configuration that produces it }}
      <div>
        <p class="font-body text-body-sm text-neutral-firm mb-3">
          One ramp per scheme, in a plain CommonJS file that Frontile compiles to
          custom properties, generating the matching
          <code
            class="font-code text-code-sm text-primary-firm"
          >on-primary-*</code>
          contrast colors for you. Wire it up with
          <code
            class="font-code text-code-sm text-primary-firm"
          >@plugin "./frontile.js"</code>
          in your stylesheet.
        </p>
        <CodePanel
          @code={{this.configSnippet}}
          @language="javascript"
          @label="frontile.js"
          @isCollapsible={{true}}
        />
      </div>
    </div>
  </template>
}
