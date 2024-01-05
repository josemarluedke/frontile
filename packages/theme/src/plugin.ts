import plugin from 'tailwindcss/plugin';
import { notificationTransitions } from './components';
import kebabCase from 'lodash.kebabcase';
import type { CSSRuleObject, PluginAPI } from 'tailwindcss/types/config';
import { overlayTransitions } from './components/overlays';

function frontile(): ReturnType<typeof plugin> {
  return plugin(({ addComponents, theme }) => {
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
  });
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
        [`@media (max-height: calc(${size} + ${margin}))`]: {
          maxHeight: `calc(100vh - ${margin})`
        }
      };
    }

    addComponents({ [`.drawer--vertical-${key}`]: rules });
    rules = {
      maxWidth: size
    };

    if (key !== 'full') {
      rules = {
        ...rules,
        [`@media (max-width: calc(${size} + ${margin}))`]: {
          maxWidth: `calc(100vw - ${margin})`
        }
      };
    }

    addComponents({ [`.drawer--horizontal-${key}`]: rules });
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
        [`@media (max-width: ${size})`]: {
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
//     background: `linear-gradient(180deg, rgba(255, 255, 255, 0) 0%, rgba(255, 255, 255, 0.8) 50%, ${defaultTheme.colors.white} 100%)`
//   };

//   const rules: CSSRuleObject = {
//     position: 'absolute',
//     top: `calc(-${options.size} - ${defaultTheme.borderWidth.DEFAULT})`,
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
      [`${name}-enter`]: enter,
      [`${name}-enter-to`]: enterTo || leave,
      [`${name}-leave`]: leave,
      [`${name}-leave-to`]: leaveTo || enter
    });

    if (enterActive) {
      addComponents({
        [`${name}-enter-active`]: enterActive
      });
    }
    if (leaveActive) {
      addComponents({
        [`${name}-leave-active`]: leaveActive
      });
    }
  });
}

export { frontile };
