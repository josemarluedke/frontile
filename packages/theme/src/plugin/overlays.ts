import type { CSSRuleObject, PluginAPI } from 'tailwindcss/types/config';

function drawerSizes(
  addComponents: PluginAPI['addComponents'],
  margin: string
): void {
  const sizes = ['xs', 'sm', 'md', 'lg', 'xl', 'full'];

  sizes.forEach((key) => {
    const sizeVar = `var(--drawer-${key})`;
    let rules: CSSRuleObject = {
      maxHeight: sizeVar
    };

    if (key !== 'full') {
      rules = {
        ...rules,
        [`@media(max-height: calc(${sizeVar} + ${margin}))`]: {
          maxHeight: `calc(100vh - ${margin})`
        }
      };
    }

    addComponents({ [`.drawer--vertical-${key}`]: rules });
    rules = {
      maxWidth: sizeVar
    };

    if (key !== 'full') {
      rules = {
        ...rules,
        [`@media(max-width: calc(${sizeVar} + ${margin}))`]: {
          maxWidth: `calc(100vw - ${margin})`
        }
      };
    }

    addComponents({ [`.drawer--horizontal-${key}`]: rules });
  });
}

function modalSizes(
  addComponents: PluginAPI['addComponents'],
  margin: string
): void {
  const sizes = ['xs', 'sm', 'md', 'lg', 'xl', 'full'];

  sizes.forEach((key) => {
    const sizeVar = `var(--modal-${key})`;
    let rules: CSSRuleObject = {};

    if (key === 'full') {
      rules = {
        width: sizeVar,
        height: sizeVar,
        marginTop: 'auto',
        marginBottom: 'auto',
        borderRadius: '0'
      };
    } else {
      rules = {
        maxWidth: sizeVar,
        [`@media(max-width: ${sizeVar})`]: {
          maxWidth: `calc(100vw - ${margin})`
        }
      };
    }

    addComponents({ [`.modal--${key}`]: rules });
  });
}

export { modalSizes, drawerSizes };
