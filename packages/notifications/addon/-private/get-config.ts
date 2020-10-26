import config from 'ember-get-config';
import { DefaultConfig } from './types';
import { get } from '@ember/object';

export function getConfigOption<T extends keyof DefaultConfig>(
  key: T,
  defaultValue: NonNullable<DefaultConfig[T]>
): NonNullable<DefaultConfig[T]> {
  const value = get(
    config['@frontile/notifications'] || ({} as never),
    key as never
  );

  if (value === undefined) {
    return defaultValue;
  }

  return value;
}
