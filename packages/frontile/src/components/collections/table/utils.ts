import type { Column } from '@universal-ember/table';
import type { FrontileStickyOptions, FrontilePluginOption } from './types';

/**
 * Helper to extract Frontile sticky options from a universal-ember column's pluginOptions
 */
export function extractFrontileOptions<T = unknown>(
  column?: Column<T>
): FrontileStickyOptions | undefined {
  if (!column?.config?.pluginOptions) {
    return undefined;
  }

  // Find the frontile plugin option
  const pluginOptions = column.config.pluginOptions as (
    | FrontilePluginOption
    | unknown
  )[];

  const frontileOption = pluginOptions.find(
    (option): option is FrontilePluginOption =>
      Array.isArray(option) && option[0] === 'frontile'
  );

  if (frontileOption && typeof frontileOption[1] === 'function') {
    return frontileOption[1]();
  }

  return undefined;
}
