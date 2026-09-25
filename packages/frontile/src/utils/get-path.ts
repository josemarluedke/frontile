import { isUnsafeKey } from '../-private/unsafe-keys';

/**
 * Reads a dotted path (`'profile.email'`) from plain data, returning
 * `undefined` as soon as a segment is missing or lands on a non-object.
 *
 * Replaces `get` from `@ember/object` for form data. Only own properties are
 * read, and unsafe segments (`__proto__`, `constructor`, `prototype`) are
 * refused, because field names can come from untrusted schemas.
 */
export function getPath(data: unknown, path: string): unknown {
  let current: unknown = data;

  for (const key of path.split('.')) {
    if (
      current === null ||
      typeof current !== 'object' ||
      isUnsafeKey(key) ||
      !Object.prototype.hasOwnProperty.call(current, key)
    ) {
      return undefined;
    }

    current = (current as Record<string, unknown>)[key];
  }

  return current;
}
