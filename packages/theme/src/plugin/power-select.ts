import powerSelectPlugin from 'tailwindcss-ember-power-select';
import type { PluginAPI } from 'tailwindcss/types/config';

function registerPowerSelectComponents(
  addComponents: PluginAPI['addComponents'],
  prefix: string
): void {
  addComponents({
    '.ember-power-select-trigger, .ember-power-select-dropdown, .ember-power-select-search-input':
      {
        '--tw-bg-opacity': '1',
        '--tw-border-opacity': '1',
        '--tw-text-opacity': '1',
        '--tw-placeholder-opacity': '1'
      },
    '.dark .ember-power-select-search-input, .dark .ember-power-select-trigger':
      {
        backgroundColor: `hsl(var(--${prefix}-default-100) / var(--${prefix}-default-100-opacity, var(--tw-bg-opacity)))`
      },
    '.dark .ember-power-select-dropdown': {
      backgroundColor: `hsl(var(--${prefix}-default-200) / var(--${prefix}-default-200-opacity, var(--tw-bg-opacity)))`
    }
  });
  powerSelectPlugin.registerComponents(
    {
      addComponents
    },
    {},
    {
      textColor: `hsl(var(--${prefix}-default-900) / var(--${prefix}-default-900-opacity, var(--tw-bg-opacity)))`,
      disabledTextColor: `hsl(var(--${prefix}-default-500) / var(--${prefix}-default-500-opacity, var(--tw-text-opacity)))`,
      disabledBorderColor: `hsl(var(--${prefix}-default-200) / var(--${prefix}-default-200-opacity, var(--tw-border-opacity)))`,
      placeholderTextColor: `hsl(var(--${prefix}-default-400) / var(--${prefix}-default-400-opacity, var(--tw-placeholder-opacity)))`,
      backgroundColor: 'white',
      dropdownBackgroundColor: 'white',
      borderColor: `hsl(var(--${prefix}-default-400) / var(--${prefix}-default-400-opacity, var(--tw-border-opacity)))`,
      focusBorderColor: `hsl(var(--${prefix}-primary-400) / var(--${prefix}-primary-400-opacity, var(--tw-border-opacity)))`,
      invalidBorderColor: `hsl(var(--${prefix}-danger-400) / var(--${prefix}-danger-400-opacity, var(--tw-border-opacity)))`
      //   triggerFocusBoxShadow: config.focusBoxShadow,
      //   triggerFocusBoxShadowInvalid: config.focusBoxShadowInvalid,
      //   searchInputFocusBoxShadow: config.focusBoxShadow
    }
  );
}

export { registerPowerSelectComponents };
