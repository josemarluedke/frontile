declare module 'tailwindcss-ember-power-select' {
  import type { PluginAPI } from 'tailwindcss/types/config';

  export function registerComponents(
    api: Partial<PluginAPI>,
    userOptions: Record<string, string>,
    customConfig: Record<string, string>
  );
}
