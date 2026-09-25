import type { DefaultConfig } from './types';

export function getConfigOption<T extends keyof DefaultConfig>(
  config: DefaultConfig,
  key: T,
  defaultValue: NonNullable<DefaultConfig[T]>
): NonNullable<DefaultConfig[T]> {
  const value = config[key];

  if (value === undefined) {
    return defaultValue;
  }

  return value;
}
