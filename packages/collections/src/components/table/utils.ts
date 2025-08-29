import type { ContentValue } from '@glint/template';
import type { ColumnDefinition } from './types';

/**
 * Safely extracts a value from an object using either a custom accessorFn or direct property access
 */
export function getSafeValue<T>(
  obj: T,
  column: ColumnDefinition<T>
): ContentValue {
  // Use custom accessor function if provided
  if (column.accessorFn) {
    return column.accessorFn(obj);
  }

  // Fallback to direct property access
  return getSafeValueByKey(obj, column.key);
}

/**
 * Safely extracts a value from an object by key and ensures it's safe for template rendering
 */
export function getSafeValueByKey(obj: unknown, key: string): ContentValue {
  if (!obj || typeof obj !== 'object') {
    return undefined;
  }

  const value = (obj as Record<string, unknown>)[key];

  // Return the value if it's already a safe template type
  if (
    typeof value === 'string' ||
    typeof value === 'number' ||
    typeof value === 'boolean' ||
    value === null ||
    value === undefined
  ) {
    return value;
  }

  // For other types, convert to string representation
  if (typeof value === 'object' && value !== null) {
    // Handle arrays
    if (Array.isArray(value)) {
      return value.join(', ');
    }
    // Handle objects with toString method
    return value.toString();
  }

  // Fallback - convert to string
  return String(value);
}
