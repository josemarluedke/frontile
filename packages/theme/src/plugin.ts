import plugin from 'tailwindcss/plugin';
import { notificationTransitions } from './components';
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
  const resolved = resolveThemes(c.themes, c.defaultTheme, c.prefix);

  return plugin(
    ({ addComponents, theme, addVariant, addBase }) => {
      addBase({
        ...resolved?.utilities
      });

      resolved?.variants.forEach((variant) => {
        addVariant(variant.name, variant.definition);
      });

      addVariant('data-is-active', '&[data-active=true]');
      addVariant(
        'group-data-is-active',
        ':merge(.group)[data-active="true"] &'
      );

      addTransitions(
        addComponents,
        '.notification-transition',
        notificationTransitions
      );

      addTransitions(addComponents, '.overlay-transition', overlayTransitions);

      // drawer sizes
      drawerSizes(
        addComponents,
        {
          xs: '20rem',
          sm: '24rem',
          md: '28rem',
          lg: '32rem',
          xl: '36rem',
          full: '100%'
        },
        theme('spacing.8')
      );
      modalSizes(
        addComponents,
        {
          xs: '20rem',
          sm: '24rem',
          md: '28rem',
          lg: '32rem',
          xl: '36rem',
          full: '100%'
        },
        theme('spacing.8')
      );

      addComponents({
        '.checked-bg-checkbox:checked': {
          backgroundImage: `url("${svgToDataUri(checkboxIcon)}")`
        },
        '.checked-bg-radio:checked': {
          backgroundImage: `url("${svgToDataUri(radioIcon)}")`
        }
      });

      registerPowerSelectComponents(addComponents, c.prefix);
    },
    {
      theme: {
        extend: {
          colors: {
            ...(resolved?.colors as Record<string, never>)
          },
          opacity: {
            hover: `var(--${c.prefix}-hover-opacity)`,
            disabled: `var(--${c.prefix}-disabled-opacity)`
          },
          aria: {
            invalid: 'invalid="true"'
          },
          animation: {
            loading: 'loading 1.5s linear infinite'
          },
          keyframes: {
            loading: {
              from: {
                transform: 'translateX(-100%) scaleX(0)'
              },
              to: {
                transform: 'translateX(200%) scaleX(3)'
              }
            }
          }
        }
      }
    }
  );
}

const checkboxIcon = `<svg viewBox="0 0 16 16" fill="white" xmlns="http://www.w3.org/2000/svg"><path d="M5.125 7.666a1.304 1.304 0 00-.882-.328 1.3 1.3 0 00-.876.343c-.232.216-.364.51-.367.816-.003.307.124.602.352.822l2.508 2.339c.235.219.554.342.886.342.333 0 .651-.123.887-.342l5.015-4.677c.228-.22.355-.516.352-.822a1.132 1.132 0 00-.367-.817A1.301 1.301 0 0011.757 5a1.304 1.304 0 00-.882.328l-4.129 3.85-1.621-1.512z"/></svg>`;
const radioIcon = `<svg viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg"><circle cx="8" cy="8" r="6" stroke="white" stroke-width="3" fill="none" /></svg>`;

export { frontile };
