import powerSelectPlugin from 'tailwindcss-ember-power-select';
import type { PluginAPI } from 'tailwindcss/types/config';

function registerPowerSelectComponents(
  addComponents: PluginAPI['addComponents']
): void {
  addComponents({
    '.ember-power-select-trigger, .ember-power-select-dropdown, .ember-power-select-search-input':
      {
        '--tw-bg-opacity': '1',
        '--tw-border-opacity': '1',
        '--tw-text-opacity': '1',
        '--tw-placeholder-opacity': '1'
      },
    // Dark-mode surfaces for the deprecated forms-legacy components. These
    // used to reference the numbered `--default-*` variables, which went away
    // with the color scale in v0.18 — leaving the dropdown transparent and its
    // options unreadable. Mapped onto the semantic tokens instead.
    '.dark .ember-power-select-search-input, .dark .ember-power-select-trigger, .dark .ember-power-select-dropdown':
      {
        backgroundColor: `var(--color-surface-input)`,
        color: `var(--color-neutral-bolder)`
      }
  });
  powerSelectPlugin.registerComponents(
    {
      addComponents
    },
    {},
    {
      textColor: `hsl(var(--default-900) / var(--default-900-opacity, var(--tw-bg-opacity)))`,
      disabledTextColor: `hsl(var(--default-500) / var(--default-500-opacity, var(--tw-text-opacity)))`,
      disabledBorderColor: `hsl(var(--default-200) / var(--default-200-opacity, var(--tw-border-opacity)))`,
      placeholderTextColor: `hsl(var(--default-400) / var(--default-400-opacity, var(--tw-placeholder-opacity)))`,
      backgroundColor: 'white',
      dropdownBackgroundColor: 'white',
      borderColor: `hsl(var(--default-400) / var(--default-400-opacity, var(--tw-border-opacity)))`,
      focusBorderColor: `hsl(var(--primary-400) / var(--primary-400-opacity, var(--tw-border-opacity)))`,
      invalidBorderColor: `hsl(var(--danger-400) / var(--danger-400-opacity, var(--tw-border-opacity)))`
      //   triggerFocusBoxShadow: config.focusBoxShadow,
      //   triggerFocusBoxShadowInvalid: config.focusBoxShadowInvalid,
      //   searchInputFocusBoxShadow: config.focusBoxShadow
    }
  );
}

export { registerPowerSelectComponents };
