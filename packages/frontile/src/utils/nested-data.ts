/**
 * Utility functions for working with nested data structures in forms.
 * These functions convert between nested objects and flat dotted-path notation.
 */

/**
 * Type guard to check if a value is a plain object (not an array, Date, File, etc.)
 */
function isPlainObject(value: unknown): value is Record<string, unknown> {
  return (
    value !== null &&
    typeof value === 'object' &&
    !Array.isArray(value) &&
    !(value instanceof Date) &&
    !(value instanceof File) &&
    !(value instanceof FileList)
  );
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
