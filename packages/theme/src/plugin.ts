import plugin from 'tailwindcss/plugin';
import { notificationTransitions } from './components';
import kebabCase from 'lodash.kebabcase';
import type { CSSRuleObject, PluginAPI } from 'tailwindcss/types/config';

function frontile(): ReturnType<typeof plugin> {
  return plugin(({ addComponents }) => {
    addTransitions(
      addComponents,
      '.notification-transition',
      notificationTransitions
    );
  });
}

type Transition = {
  enter: CSSRuleObject;
  leave: CSSRuleObject;
  leaveTo: CSSRuleObject;
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
