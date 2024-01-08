import plugin from 'tailwindcss/plugin';
import { notificationTransitions } from './components';
import kebabCase from 'lodash.kebabcase';
import type { CSSRuleObject, PluginAPI } from 'tailwindcss/types/config';
import { overlayTransitions } from './components/overlays';
import svgToDataUri from 'mini-svg-data-uri';
// @ts-ignore
import powerSelectPlugin from 'tailwindcss-ember-power-select';

function frontile(): ReturnType<typeof plugin> {
  return plugin(
    ({ addComponents, theme }) => {
      addTransitions(
        addComponents,
        '.notification-transition',
        notificationTransitions
      );

      addTransitions(addComponents, '.overlay-transition', overlayTransitions);

      // drawer sizes
      drawer(
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
      modal(
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

      const checkboxIcon = `<svg viewBox="0 0 16 16" fill="white" xmlns="http://www.w3.org/2000/svg"><path d="M5.125 7.666a1.304 1.304 0 00-.882-.328 1.3 1.3 0 00-.876.343c-.232.216-.364.51-.367.816-.003.307.124.602.352.822l2.508 2.339c.235.219.554.342.886.342.333 0 .651-.123.887-.342l5.015-4.677c.228-.22.355-.516.352-.822a1.132 1.132 0 00-.367-.817A1.301 1.301 0 0011.757 5a1.304 1.304 0 00-.882.328l-4.129 3.85-1.621-1.512z"/></svg>`;
      const radioIcon = `<svg viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg"><circle cx="8" cy="8" r="6" stroke="white" stroke-width="3" fill="none" /></svg>`;

      addComponents({
        '.checked-bg-checkbox:checked': {
          backgroundImage: `url("${svgToDataUri(checkboxIcon)}")`
        },
        '.checked-bg-radio:checked': {
          backgroundImage: `url("${svgToDataUri(radioIcon)}")`
        }
      });

      powerSelectPlugin.registerComponents({
        addComponents
      });
    },
    {
      theme: {
        extend: {
          aria: {
            invalid: 'invalid="true"'
          }
        }
      }
    }
  );
}

function drawer(
  addComponents: PluginAPI['addComponents'],
  sizes: { [key: string]: string },
  margin: string
): void {
  Object.keys(sizes).forEach((key) => {
    const size = sizes[key] as string;
    let rules: CSSRuleObject = {
      maxHeight: size
    };

    if (key !== 'full') {
      rules = {
        ...rules,
        [`@media(max - height: calc(${size} + ${margin}))`]: {
          maxHeight: `calc(100vh - ${margin})`
        }
      };
    }

    addComponents({ [`.drawer--vertical - ${key}`]: rules });
    rules = {
      maxWidth: size
    };

    if (key !== 'full') {
      rules = {
        ...rules,
        [`@media(max - width: calc(${size} + ${margin}))`]: {
          maxWidth: `calc(100vw - ${margin})`
        }
      };
    }

    addComponents({ [`.drawer--horizontal - ${key}`]: rules });
  });
}

function modal(
  addComponents: PluginAPI['addComponents'],
  sizes: { [key: string]: string },
  margin: string
): void {
  Object.keys(sizes).forEach((key) => {
    const size = sizes[key] as string;
    let rules: CSSRuleObject = {};

    if (key === 'full') {
      rules = {
        width: size,
        height: size,
        marginTop: 'auto',
        marginBottom: 'auto',
        borderRadius: '0'
      };
    } else {
      rules = {
        maxWidth: size,
        [`@media(max - width: ${size})`]: {
          maxWidth: `calc(100vw - ${margin})`
        }
      };
    }

    addComponents({ [`.modal--${key}`]: rules });
  });
}

// function obscurer() {
//   const options = {
//     disabled: false,
//     size: defaultTheme.padding[4],
//     background: `linear - gradient(180deg, rgba(255, 255, 255, 0) 0 %, rgba(255, 255, 255, 0.8) 50 %, ${ defaultTheme.colors.white } 100 %)`
//   };

//   const rules: CSSRuleObject = {
//     position: 'absolute',
//     top: `calc(-${ options.size } - ${ defaultTheme.borderWidth.DEFAULT })`,
//     left: '0',
//     content: '" "',
//     height: options.size,
//     width: '100%',
//     background: options.background
//   };
// }

type Transition = {
  enter: CSSRuleObject;
  leave: CSSRuleObject;
  leaveTo?: CSSRuleObject;
  enterTo?: CSSRuleObject;
  leaveActive?: CSSRuleObject;
  enterActive?: CSSRuleObject;
};

function addTransitions(
  addComponents: PluginAPI['addComponents'],
  baseSelector: string,
  transitions?: { [key: string]: Transition }
): void {
  if (!transitions) {
    return;
  }

  Object.keys(transitions).forEach((key) => {
    const transition = transitions[key];

    if (!transition) {
      return;
    }
    const name = `${baseSelector}--${kebabCase(key)}`;

    const { enter, enterTo, leave, leaveActive, enterActive, leaveTo } =
      transition;

    addComponents({
      [`${name} - enter`]: enter,
      [`${name} - enter - to`]: enterTo || leave,
      [`${name} - leave`]: leave,
      [`${name} - leave - to`]: leaveTo || enter
    });

    if (enterActive) {
      addComponents({
        [`${name} - enter - active`]: enterActive
      });
    }
    if (leaveActive) {
      addComponents({
        [`${name} - leave - active`]: leaveActive
      });
    }
  });
}

export { frontile };
