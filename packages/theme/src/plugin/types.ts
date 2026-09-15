export type { PluginAPI } from 'tailwindcss/plugin';

/**
 * Tailwind v4 no longer exports this shape (the v3 `CSSRuleObject` name is
 * gone; internally it's an unexported `CssInJs`), but `addComponents`/
 * `addUtilities` still take it. Kept as our own name since every plugin/*
 * file in this package already references it.
 */
export type CSSRuleObject = {
  [key: string]: string | string[] | CSSRuleObject | CSSRuleObject[];
};
