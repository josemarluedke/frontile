/**
 * Path segments that are refused as object keys.
 *
 * Field names come from the `name` attribute of the form's controls, which an
 * app may render from a server-supplied schema, a CMS, or URL state — so they
 * are untrusted input.
 *
 * `__proto__` is the real vector: `isPlainObject(Object.prototype)` is `true`,
 * so when `unflattenData`'s walk reached a `__proto__` segment it accepted
 * `Object.prototype` as an already-existing nested object instead of creating a
 * fresh one, and the final assignment wrote onto every object in the
 * application.
 *
 * `constructor` and `prototype` do not reach `Object.prototype` through that
 * walk as it is written — `current['constructor']` is a function, which
 * `isPlainObject` rejects, so the walk shadows it with a fresh own key. They
 * are refused anyway, as defense in depth: it keeps form data from shadowing
 * those names, and it means a later change to the walk (or an intermediate that
 * is a plain object with a `constructor` of its own) cannot quietly turn them
 * into live vectors.
 */
const UNSAFE_KEYS = ['__proto__', 'constructor', 'prototype'];

/**
 * Checks a single path segment. Callers refuse the whole entry rather than
 * substituting a safe key, so no partially-built path is left behind.
 */
export function isUnsafeKey(key: string): boolean {
  return UNSAFE_KEYS.includes(key);
}
