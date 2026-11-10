import pageTitle from 'ember-page-title/helpers/page-title';
import {
  gray,
  blue,
  green,
  orange,
  pink,
  red,
  teal,
  violet,
  yellow
} from '@frontile/theme/colors';
import PaletteCard, {
  type PaletteStep
} from 'test-app/components/foundations/palette-card';

function steps(ramp: Record<string, string>): PaletteStep[] {
  return Object.entries(ramp).map(([step, value]) => ({ step, value }));
}

const RAMPS = Object.entries({
  gray,
  blue,
  green,
  orange,
  pink,
  red,
  teal,
  violet,
  yellow
}).map(([name, ramp]) => ({ name, steps: steps(ramp) }));

// `black` and `white` are not exported from `@frontile/theme/colors`. They are
// defined in packages/theme/src/colors/palette-absolute.ts and repeated here.
const ABSOLUTE: PaletteStep[] = [
  { step: 'black', value: '#000000' },
  { step: 'white', value: '#ffffff' }
];

<template>
  {{pageTitle "Palette"}}
  <h1 class="text-neutral-bolder mb-6 text-2xl font-semibold">Palette</h1>

  <div class="flex flex-col gap-8">
    {{#each RAMPS as |ramp|}}
      <PaletteCard @name={{ramp.name}} @steps={{ramp.steps}} />
    {{/each}}
    <PaletteCard
      @name="absolute"
      @steps={{ABSOLUTE}}
      @description="Constant across light and dark. Not emitted as CSS variables; read from palette-absolute.ts in the theme source."
    />
  </div>
</template>
