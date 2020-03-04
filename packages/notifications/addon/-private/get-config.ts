import config from 'ember-get-config';
import { DefaultConfig } from './types';
import { getWithDefault } from '@ember/object';

export function getConfigOption<T extends keyof DefaultConfig>(
  key: T,
  defaultValue: NonNullable<DefaultConfig[T]> | undefined
): NonNullable<DefaultConfig[T]> {
  return getWithDefault(
    config['@frontile/notifications'] || ({} as never),
    key as never,
    defaultValue as never
  );
}
