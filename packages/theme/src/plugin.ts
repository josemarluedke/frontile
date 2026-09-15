import plugin from 'tailwindcss/plugin';
import { overlayTransitions } from './components/overlays';
import svgToDataUri from 'mini-svg-data-uri';

import { resolveThemes, resolveConfig } from './plugin/resolve';
import { modalSizes, drawerSizes } from './plugin/overlays';
import { registerPowerSelectComponents } from './plugin/power-select';
import { addTransitions } from './plugin/transitions';
import type { PluginConfig } from './types';
export { swapColorValues } from './colors/util';
export { safelist } from './plugin/safelist';

function frontile(config: PluginConfig = {}): ReturnType<typeof plugin> {
  const c = resolveConfig(config);
  const resolved = resolveThemes(c.themes, c.defaultTheme);

  return plugin(
    ({ addComponents, theme, addVariant, addBase, addUtilities }) => {
      addBase({
        ...resolved?.base,
        ':root': {
          '--divider-sketch': `url("${svgToDataUri(dividerSketchIcon)}")`
        }
      });

      addUtilities({
        ...resolved?.utilities
      });

      resolved?.variants.forEach((variant) => {
        addVariant(variant.name, variant.definition);
      });

      addTransitions(addComponents, '.overlay-transition', overlayTransitions);

      // drawer and modal sizes (using CSS variables)
      drawerSizes(addComponents, theme('spacing.8'));
      modalSizes(addComponents, theme('spacing.8'));

      addComponents({
        '.checked-bg-checkbox:checked': {
          backgroundImage: `url("${svgToDataUri(checkboxIcon)}")`
        },
        '.indeterminate-bg-checkbox:indeterminate': {
          backgroundImage: `url("${svgToDataUri(checkboxIndeterminateIcon)}")`
        },
        '.checked-bg-radio:checked': {
          backgroundImage: `url("${svgToDataUri(radioIconLight)}")`
        },
        '.dark .checked-bg-radio:checked': {
          backgroundImage: `url("${svgToDataUri(radioIconDark)}")`
        },
        '.divider-sketch': {
          maskImage: 'var(--divider-sketch)',
          maskSize: '100% 100%',
          maskRepeat: 'no-repeat'
        }
      });

      registerPowerSelectComponents(addComponents);
    },
    {
      theme: {
        extend: {
          colors: {
            ...(resolved?.colors as Record<string, never>)
          }
        }
      }
    }
  );
}

const checkboxIcon = `<svg viewBox="0 0 16 16" fill="white" xmlns="http://www.w3.org/2000/svg"><path d="M5.125 7.666a1.304 1.304 0 00-.882-.328 1.3 1.3 0 00-.876.343c-.232.216-.364.51-.367.816-.003.307.124.602.352.822l2.508 2.339c.235.219.554.342.886.342.333 0 .651-.123.887-.342l5.015-4.677c.228-.22.355-.516.352-.822a1.132 1.132 0 00-.367-.817A1.301 1.301 0 0011.757 5a1.304 1.304 0 00-.882.328l-4.129 3.85-1.621-1.512z"/></svg>`;
const checkboxIndeterminateIcon = `<svg viewBox="0 0 16 16" fill="white" xmlns="http://www.w3.org/2000/svg"><path d="M3 7.5C3 7.22386 3.22386 7 3.5 7H12.5C12.7761 7 13 7.22386 13 7.5V8.5C13 8.77614 12.7761 9 12.5 9H3.5C3.22386 9 3 8.77614 3 8.5V7.5Z" fill="white"/></svg>`;
const radioIconLight = `<svg viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg"><circle cx="8" cy="8" r="4" fill="white"/></svg>`;
const radioIconDark = `<svg viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg"><circle cx="8" cy="8" r="4" fill="#0c0c15"/></svg>`;

// Hand-drawn divider rule. Exported from Figma at 432x4 and reduced to one
// decimal place — the original carried six, which is 0.000025px of precision on
// a 4px-tall line. `preserveAspectRatio="none"` is load-bearing: without it the
// default `xMidYMid meet` letterboxes the artwork inside the mask box instead of
// stretching it. There is deliberately no `fill` — this is used as a mask, so
// only its alpha matters and the colour comes from the element's background.
const dividerSketchIcon = `<svg viewBox="0 0 432 4" preserveAspectRatio="none" xmlns="http://www.w3.org/2000/svg"><path d="M391.4 0C384.6 0.2 377.4 -0.2 370.4 0.3C368.6 0 366.6 0.5 365 0.3C361.5 -0.1 358.4 0.5 355 0.5C352 0.4 349.1 -0.2 346.2 0.1C343.5 0.4 341 -0 338.5 0.2C335.4 0.6 332.7 -0.1 329.7 0C327.1 0.2 324.4 0 321.8 0C313.5 -0 305.3 -0.1 297.1 0.2C295.9 0.3 294.9 0.2 293.8 0.2C287.8 0 281.8 -0.1 275.9 0.3C273.4 0.5 270.8 0.1 268.3 0.4C262.3 -0.1 256.5 -0 250.5 0.4C248 0.6 245.3 0.6 242.7 0.3C241.3 0.2 239.8 0.1 238.3 0.1C235.3 -0.1 232.4 0.4 229.5 0.2C226.8 0 224.3 0.1 221.7 0.3C219.2 0.5 216.6 -0.1 214.1 0.4C209.7 0.2 205.3 0.2 200.9 0.6C193.4 0.6 185.9 0.6 178.4 0.6C166.8 0.6 155.1 0.6 143.5 0.6C134.5 0.6 125.5 0.7 116.5 0.8C114.2 0.8 112 0.9 109.8 0.9C106.8 1 103.8 1.2 100.8 1.2C94.4 1.1 88.1 1.3 81.7 1.4C80.2 1.4 78.7 1.4 77.2 1.5C70.2 2 63.1 2 56.1 1.5C50.5 1.5 44.9 1.1 39.4 1.7C37.6 1.8 35.7 1.8 33.8 1.9C30.9 2 27.9 2 25 2.4C23 2.6 20.6 2.7 18.4 2.6C12.3 2.5 6.6 3.1 0.8 3.5C0.5 3.5 0.3 3.6 0 3.7C0.6 3.8 1.2 4 1.9 4C6 4 10.1 4 14.2 3.9C15.4 3.9 16.6 3.9 17.6 3.8C21.5 3.3 25.7 3.4 29.8 3.3C35.3 3.1 50.8 3.1 55.3 3.2C63.2 3.3 71.1 3.4 78.9 3.2C80.8 3.2 82.7 3.2 84.6 3.1C87.6 3.1 90.7 3.2 93.5 2.9C96.5 2.7 99.3 3.2 102.4 2.8C104.7 2.6 107.6 2.7 110.2 2.7C132.3 2.7 154.5 2.7 176.6 2.7C184.9 2.7 193.1 2.6 201.4 2.6C208.9 2.6 216.4 2.5 223.9 2.5C259.2 2.5 294.5 2.5 329.8 2.5C345.6 2.5 361.3 2.5 377.1 2.5C382.7 2.5 388.4 2.6 393.8 2C397.6 2 401.3 2 405.1 1.9C413.7 1.8 422.3 1.8 430.9 1.7C431.9 1.7 432.1 1.5 431.9 1.2C431.8 1 431.5 0.8 430.6 0.8C429.9 0.7 429.2 0.6 428.5 0.6C427.7 0.6 427 0.6 426.2 0.5C421.7 0.5 417.3 0.4 412.9 0.1C408.5 -0.1 403.9 0 399.4 0.1C396.8 0.1 394.3 0.3 391.5 0L391.4 0Z"/></svg>`;

export { frontile };
