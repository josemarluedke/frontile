// Build-time syntax highlighting for the homepage's code panels.
//
// The homepage used to tokenise its snippets in the browser: a trimmed lowlight
// registry (`app/utils/lowlight.ts`) plus a `highlight-code` helper, which put
// highlight.js and three grammars into the bundle every visitor downloads in
// order to colour six fixed strings. Nothing about those strings changes at
// runtime, so they are highlighted here instead — the same way
// `generate-signature-data.mjs` bakes the API tables' types — and the app
// imports the finished HTML.
//
// Run `pnpm generate-homepage-snippets` after editing anything in this file.
// Its output, `app/components/homepage/snippets.ts`, is generated and checked
// in, exactly like `app/components/signature-data.ts`.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { teal, blue, pink, green } from '@frontile/theme/colors';
import { highlightBlock } from './shiki-highlight.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

/* ------------------------------------------------------------------ *
 * The "Glint checks this" pair, on the proof section.
 * ------------------------------------------------------------------ */

const signatureSnippet = `import { Table, type ColumnConfig } from 'frontile';

interface Member { id: string; name: string; role: string }

const columns = [
  { key: 'name', name: 'Member' },
  { key: 'role', name: 'Role' }
] as const satisfies ColumnConfig<Member>[];`;

const templateSnippet = `<Table @columns={{columns}} @items={{members}} />

{{! Glint checks this against ColumnConfig<Member>: }}
<Table @columns={{columns}} @items={{projects}} />
{{! ^ Type 'Project[]' is not assignable to 'Member[]' }}`;

/* ------------------------------------------------------------------ *
 * The theme lab.
 *
 * These ramps used to live in `app/components/homepage/theme-lab.gts`, which
 * derived both the scoped custom properties and the configuration snippet from
 * them at runtime. The snippet has to be highlighted at build time now, and the
 * snippet and the ramp have to agree, so the derivation moved here and the
 * component consumes the finished data. The families are still imported from
 * `@frontile/theme` rather than transcribed, so the section's central claim —
 * that these are Frontile's own ramps — cannot expire silently.
 * ------------------------------------------------------------------ */

const FAMILIES = { teal, blue, pink, green };

/** Mirrors semantic.ts's light-theme primary derivation. */
function lightRamp(f) {
  return [
    { name: 'subtle', value: f['50'] },
    { name: 'muted', value: f['100'] },
    { name: 'soft', value: `${f['600']}1a` },
    { name: 'mild', value: f['400'] },
    { name: 'DEFAULT', value: f['600'] },
    { name: 'firm', value: f['700'] },
    { name: 'strong', value: f['900'] },
    { name: 'bolder', value: f['950'] },
  ];
}

/** Mirrors semantic.ts's dark-theme derivation — the ramp runs the other way. */
function darkRamp(f) {
  return [
    { name: 'subtle', value: f['900'] },
    { name: 'muted', value: f['700'] },
    { name: 'soft', value: `${f['300']}40` },
    { name: 'mild', value: f['500'] },
    { name: 'DEFAULT', value: f['300'] },
    { name: 'firm', value: f['200'] },
    { name: 'strong', value: f['100'] },
    { name: 'bolder', value: f['50'] },
  ];
}

function toConfigObject(ramp, indent) {
  return ramp
    .map(({ name, value }) => `${indent}${name}: '${value}'`)
    .join(',\n');
}

function configSnippet(light, dark) {
  return `// frontile.js
const { frontile } = require('@frontile/theme/plugin');

module.exports = frontile({
  themes: {
    light: {
      colors: {
        primary: {
${toConfigObject(light, '          ')}
        }
      }
    },
    dark: {
      colors: {
        primary: {
${toConfigObject(dark, '          ')}
        }
      }
    }
  }
});`;
}

const themePresets = Object.entries(FAMILIES).map(([key, family]) => {
  const light = lightRamp(family);
  const dark = darkRamp(family);

  return {
    key,
    label: key.charAt(0).toUpperCase() + key.slice(1),
    swatch: family['600'],
    light,
    dark,
    configHtml: highlightBlock(configSnippet(light, dark), 'javascript'),
  };
});

/* ------------------------------------------------------------------ */

const source = `// GENERATED FILE — do not edit by hand.
// Produced by site/lib/generate-homepage-snippets.mjs; run
// \`pnpm generate-homepage-snippets\` after changing a snippet or a ramp.
//
// Every string below is Shiki output from the same preset the docs pages use
// (\`@docfy/plugin-shiki\`), carrying \`--shiki-light\`/\`--shiki-dark\` custom
// properties rather than baked colours, so the homepage panels follow the
// theme without re-highlighting.

/** One step of a primary ramp, by the step names the theme plugin expects. */
export interface Level {
  name: string;
  value: string;
}

export interface ThemePreset {
  key: string;
  label: string;
  /** The family's 600 step, used for the picker's swatch. */
  swatch: string;
  light: Level[];
  dark: Level[];
  /** Pre-highlighted \`<code>\` for the configuration this ramp produces. */
  configHtml: string;
}

export const themePresets: ThemePreset[] = ${JSON.stringify(themePresets, null, 2)};

export const signatureSnippetHtml = ${JSON.stringify(highlightBlock(signatureSnippet, 'ts'))};

export const templateSnippetHtml = ${JSON.stringify(highlightBlock(templateSnippet, 'hbs'))};
`;

fs.writeFileSync(
  path.join(__dirname, '../app/components/homepage/snippets.ts'),
  source,
);
