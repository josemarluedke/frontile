import { deprecate } from '@ember/debug';

export interface RenamedArgOptions {
  /** Component name as it appears to a consumer, e.g. `'Button'`. */
  component: string;
  /** The old argument name, without the `@`. */
  from: string;
  /** The new argument name, without the `@`. */
  to: string;
  /** Deprecation id, e.g. `'frontile.button.appearance'`. */
  id: string;
}

function warn(options: RenamedArgOptions, detail = ''): void {
  deprecate(
    `${options.component}: \`@${options.from}\` is deprecated. Use \`@${options.to}\` instead.${detail}`,
    false,
    {
      id: options.id,
      until: '0.19.0',
      for: 'frontile',
      since: { available: '0.18.0', enabled: '0.18.0' }
    }
  );
}

/**
 * Resolve an argument that was renamed without its values changing.
 *
 * The new argument wins when both are passed — a consumer mid-migration has
 * written the new one deliberately — but the deprecation still fires, because
 * the old one is still in their template and still needs removing.
 */
export function renamedArg<T>(
  next: T | undefined,
  legacy: T | undefined,
  options: RenamedArgOptions
): T | undefined {
  if (typeof legacy === 'undefined') {
    return next;
  }

  warn(options);

  return typeof next === 'undefined' ? legacy : next;
}

/**
 * Resolve an argument whose name *and* values moved.
 *
 * `values` maps old spellings to new ones. A legacy value absent from the map
 * kept its name (e.g. Button's `custom`) and passes through untouched — so the
 * map only lists what actually changed.
 */
export function renamedArgValue<Old extends string, New extends string>(
  next: New | undefined,
  legacy: Old | undefined,
  values: Partial<Record<Old, New>>,
  options: RenamedArgOptions
): New | undefined {
  if (typeof legacy === 'undefined') {
    return next;
  }

  const mapped = values[legacy] ?? (legacy as unknown as New);

  warn(
    options,
    values[legacy] ? ` \`${legacy}\` is now \`${values[legacy]}\`.` : ''
  );

  return typeof next === 'undefined' ? mapped : next;
}
