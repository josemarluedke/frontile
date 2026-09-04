/**
 * Utility functions for working with nested data structures in forms.
 * These functions convert between nested objects and flat dotted-path notation.
 */

/**
 * `File` and `FileList` are browser globals. `FileList` in particular has no
 * counterpart in Node, so a bare `value instanceof FileList` is a hard
 * `ReferenceError` rather than `false` when a Form is server-rendered.
 */
function isFileLike(value: object): boolean {
  return (
    (typeof File !== 'undefined' && value instanceof File) ||
    (typeof FileList !== 'undefined' && value instanceof FileList)
  );
}

/**
 * Type guard to check if a value is a plain object (not an array, Date, File, etc.)
 */
function isPlainObject(value: unknown): value is Record<string, unknown> {
  return (
    value !== null &&
    typeof value === 'object' &&
    !Array.isArray(value) &&
    !(value instanceof Date) &&
    !isFileLike(value)
  );
}

/**
 * Path segments that are refused as object keys.
 *
 * Field names come from the `name` attribute of the form's controls, which an
 * app may render from a server-supplied schema, a CMS, or URL state — so they
 * are untrusted input.
 *
 * `__proto__` is the real vector: `isPlainObject(Object.prototype)` is `true`,
 * so when the walk below reached a `__proto__` segment it accepted
 * `Object.prototype` as an already-existing nested object instead of creating a
 * fresh one, and the final assignment wrote onto every object in the
 * application.
 *
 * `constructor` and `prototype` do not reach `Object.prototype` through the
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
function isUnsafeKey(key: string): boolean {
  return UNSAFE_KEYS.includes(key);
}

/**
 * Checks whether a dotted path is safe to materialize. A single unsafe segment
 * anywhere in the path poisons the whole path, so the entry is refused wholesale
 * rather than partially built.
 */
function isSafePath(keys: string[]): boolean {
  return !keys.some(isUnsafeKey);
}

/**
 * Flattens a nested object into a flat object with dotted-path keys.
 *
 * @example
 * flattenData({name: {first: 'John', last: 'Doe'}, email: 'john@example.com'})
 * // Returns: {'name.first': 'John', 'name.last': 'Doe', 'email': 'john@example.com'}
 *
 * @param data - The nested data object to flatten
 * @param prefix - Internal parameter for recursion (parent path)
 * @returns A flat object with dotted-path keys
 */
export function flattenData<T = unknown>(
  data: Record<string, unknown>,
  prefix = ''
): Record<string, T> {
  const result: Record<string, T> = {};

  for (const key in data) {
    if (!Object.prototype.hasOwnProperty.call(data, key)) {
      continue;
    }

    // Refuse unsafe keys here too, so a hostile or already-polluted input
    // cannot produce a dotted path that `unflattenData` would have to reject
    // on the way back in.
    if (isUnsafeKey(key)) {
      continue;
    }

    const value = data[key];
    const fullPath = prefix ? `${prefix}.${key}` : key;

    if (isPlainObject(value)) {
      // Recursively flatten nested objects
      Object.assign(result, flattenData(value, fullPath));
    } else {
      // Store primitive values, arrays, and special objects as-is
      result[fullPath] = value as T;
    }
  }

  return result;
}

/**
 * Unflattens a flat object with dotted-path keys into a nested object structure.
 *
 * @example
 * unflattenData({'name.first': 'John', 'name.last': 'Doe', 'email': 'john@example.com'})
 * // Returns: {name: {first: 'John', last: 'Doe'}, email: 'john@example.com'}
 *
 * @param data - The flat data object with dotted-path keys
 * @returns A nested object structure
 */
export function unflattenData<T = unknown>(
  data: Record<string, unknown>
): Record<string, T> {
  const result: Record<string, unknown> = {};

  for (const path in data) {
    if (!Object.prototype.hasOwnProperty.call(data, path)) {
      continue;
    }

    const value = data[path];
    const keys = path.split('.');

    if (!isSafePath(keys)) {
      continue;
    }

    let current = result;

    // Navigate/create nested structure
    for (let i = 0; i < keys.length - 1; i++) {
      const key = keys[i];
      if (!key) continue;

      if (!isPlainObject(current[key])) {
        current[key] = {};
      }
      current = current[key] as Record<string, unknown>;
    }

    // Set the final value
    const lastKey = keys[keys.length - 1];
    if (lastKey) {
      current[lastKey] = value;
    }
  }

  return result as Record<string, T>;
}

/**
 * Checks if the data structure contains any nested objects.
 * If true, we need to handle it as nested data.
 *
 * @param data - The data object to check
 * @returns True if the data contains nested plain objects
 */
export function hasNestedData(data: Record<string, unknown>): boolean {
  for (const key in data) {
    if (Object.prototype.hasOwnProperty.call(data, key)) {
      if (isPlainObject(data[key])) {
        return true;
      }
    }
  }
  return false;
}

/**
 * Deep equality comparison for nested objects.
 * Handles primitives, arrays, and nested objects.
 *
 * @param a - First value to compare
 * @param b - Second value to compare
 * @returns True if values are deeply equal
 */
export function deepEqual(a: unknown, b: unknown): boolean {
  // Handle primitives and same reference
  if (a === b) return true;

  // Handle null/undefined
  if (a == null || b == null) return a === b;

  // Handle different types
  if (typeof a !== typeof b) return false;

  // Handle arrays
  if (Array.isArray(a) && Array.isArray(b)) {
    if (a.length !== b.length) return false;
    return a.every((item, index) => deepEqual(item, b[index]));
  }

  // Handle plain objects
  if (isPlainObject(a) && isPlainObject(b)) {
    const keysA = Object.keys(a);
    const keysB = Object.keys(b);

    if (keysA.length !== keysB.length) return false;

    return keysA.every((key) => deepEqual(a[key], b[key]));
  }

  // Handle special objects (Date, File, etc.) - compare by reference
  return a === b;
}
