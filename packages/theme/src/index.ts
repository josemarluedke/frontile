import * as components from './components';

let localStyles = components;

function registerCustomStyles(styles: Partial<typeof components>): void {
  localStyles = { ...components, ...styles };
}

function useStyles(): typeof components {
  return localStyles;
}

export { useStyles, registerCustomStyles };
