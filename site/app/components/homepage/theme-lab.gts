import Component from '@glimmer/component';
import type { TOC } from '@ember/component/template-only';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { htmlSafe } from '@ember/template';
import { Button, Chip, Field, ProgressBar, ToggleButton } from 'frontile';
import CodePanel from './code-panel';

type SafeString = ReturnType<typeof htmlSafe>;

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

const FAMILIES: Record<string, Family> = {
  teal: {
    '50': '#f1fdfc',
    '100': '#c6f5f4',
    '200': '#7ce0e1',
    '300': '#47c1c7',
    '400': '#26a0aa',
    '500': '#12828e',
    '600': '#076873',
    '700': '#01525c',
    '900': '#003138',
    '950': '#00262c'
  },
  blue: {
    '50': '#f9fcff',
    '100': '#f1f7ff',
    '200': '#d2e6ff',
    '300': '#95c4ff',
    '400': '#4a8ee7',
    '500': '#2259a6',
    '600': '#053273',
    '700': '#001b4e',
    '900': '#00072d',
    '950': '#020825'
  },
  pink: {
    '50': '#fefafc',
    '100': '#ffebf4',
    '200': '#ffcee4',
    '300': '#fca8cc',
    '400': '#f17bad',
    '500': '#e1458a',
    '600': '#c10566',
    '700': '#920147',
    '900': '#4a011c',
    '950': '#390011'
  },
  green: {
    '50': '#f7ffeb',
    '100': '#e6ffbc',
    '200': '#d1ff8c',
    '300': '#bbff60',
    '400': '#a3fa3a',
    '500': '#66e221',
    '600': '#2fc511',
    '700': '#07a20a',
    '900': '#005321',
    '950': '#002e1b'
  }
};

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
 * Black or white, whichever contrasts better — the same choice the plugin's
 * `resolve.ts` makes when it generates `on-*` colors. Emitting these alongside
 * the ramp is not optional: `text-on-primary` would otherwise keep the ink
 * generated for the *original* ramp, and a light accent like Green would render
 * white-on-green at roughly 2.3:1.
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

const LabPanel: TOC<{
  Args: {
    /** Which theme this copy shows, relative to the visitor's own. */
    scheme: string;
  };
}> = <template>
  <div class="theme-lab__panel theme-lab-scope bg-surface-app text-neutral-firm">
    <p
      class="font-label text-label-2xs text-neutral-firm uppercase mb-4"
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

      <Field @name="lab-project" as |field|>
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
            class="font-label text-label-2xs text-neutral-firm uppercase mb-3"
          >Swap the primary ramp</legend>
          <div class="flex flex-wrap gap-2">
            {{#each this.presets as |item|}}
              <ToggleButton
                @isSelected={{this.isActive item.key}}
                @size="sm"
                @onChange={{fn this.selectPreset item}}
              >
                <span
                  class="theme-lab__swatch"
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
        <LabPanel @scheme="Your theme" />
        <div class="theme-inverse" aria-hidden="true" inert>
          <LabPanel @scheme="Inverted" />
        </div>
      </div>

      {{! The configuration that produces it }}
      <div>
        <p class="font-body text-body-sm text-neutral-firm mb-3">
          One ramp per scheme, in a plain CommonJS file that Frontile compiles to
          custom properties — generating the matching
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
