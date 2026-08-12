import type { CSSRuleObject, PluginAPI } from 'tailwindcss/types/config';

function drawerSizes(
  addComponents: PluginAPI['addComponents'],
  margin: string
): void {
  const sizes = ['xs', 'sm', 'md', 'lg', 'xl', 'full'];

  sizes.forEach((key) => {
    const sizeVar = `var(--drawer-${key})`;

    // `min()` keeps the size within the viewport. A media query cannot be used
    // here: `var()` is not allowed in a media query condition.
    addComponents({
      [`.drawer--vertical-${key}`]: {
        maxHeight:
          key === 'full' ? sizeVar : `min(${sizeVar}, calc(100vh - ${margin}))`
      }
    });

    addComponents({
      [`.drawer--horizontal-${key}`]: {
        maxWidth:
          key === 'full' ? sizeVar : `min(${sizeVar}, calc(100vw - ${margin}))`
      }
    });
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
      // `min()` keeps the size within the viewport. A media query cannot be
      // used here: `var()` is not allowed in a media query condition.
      rules = {
        maxWidth: `min(${sizeVar}, calc(100vw - ${margin}))`
      };
    }

    addComponents({ [`.modal--${key}`]: rules });
  });
}

export { modalSizes, drawerSizes };
