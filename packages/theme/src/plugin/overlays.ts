import type { CSSRuleObject, PluginAPI } from 'tailwindcss/types/config';

function drawerSizes(
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
        [`@media(max-height: calc(${size} + ${margin}))`]: {
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
        [`@media(max-width: calc(${size} + ${margin}))`]: {
          maxWidth: `calc(100vw - ${margin})`
        }
      };
    }

    addComponents({ [`.drawer--horizontal-${key}`]: rules });
  });
}

function modalSizes(
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
        [`@media(max-width: ${size})`]: {
          maxWidth: `calc(100vw - ${margin})`
        }
      };
    }

    addComponents({ [`.modal--${key}`]: rules });
  });
}

export { modalSizes, drawerSizes };
